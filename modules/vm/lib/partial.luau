local bytecode = require("../../bytecode/lib");
local t = require("./typedefs");

type PartialVMOptions = {
    interrupt_callback: () -> ()?,
    break_callback: () -> ()?,
    step_callback: (pc: number, inst: bytecode.BytecodeInstruction, info: bytecode.OpcodeInfo) -> ()?,
};

local ERRORS = {
    Unsupported = "%s not supported",
    Unimplemeneted = "%s not yet supported",

    InvalidInstruction = "encountered invalid instruction '%s'",
    UnknownObject = "attempt to get unknown %s '%s'",
    WrongConstant = "attempt to get constant %s in an instruction that doesn't support it",

    InvalidJump = "attempt to jump to %i, which is an invalid location"
};

local partial_vm = {};

--[=[
    'Loads' a bytecode chunk, returning a function to execute it.
]=]
function partial_vm.load(chunk: string|buffer|bytecode.BytecodeChunk, env: {[any]: any}?, options: PartialVMOptions?)
    print("[warn]: VM isnt fully implemented! most programs will not work");
    
    local options = options or {};
    local chunk = if type(chunk) ~= "table" then bytecode.decode(chunk) else chunk;

    local function load_proto(proto: bytecode.BytecodeProto, env: {[any]: any}?)
        local env = env or {};
        local proto_id = (table.find(chunk.protos, proto) or 0) - 1;
        local instructions = {};
        
        local stack_top = 0;

        local function adjust_stack_top(by: number)
            stack_top += by;
        end

        for _, v in proto.instructions do
            table.insert(instructions, v);
            if v.operands.aux then
                table.insert(instructions, false :: any);
            end
        end

        local function execute_proto(...)
            local registers = table.create(256);
            local pc = -1;

            local function panic(err_type: string, ...): never
                local current_inst = instructions[pc + 1];
                local message = string.format(ERRORS[err_type], ...);
                
                error({
                    type = err_type,
                    message = message,
                    pc = pc,
                    inst = current_inst,
                    proto = proto_id,
                    chunk = chunk,
                } :: t.VMError);
            end

            local function get_string(s: number): string
                return chunk.strings[s] or panic("UnknownObject", "string", s);
            end        

            local function get_global(name: string)
                return env[name];
            end

            local function set_global(name: string, value: any)
                env[name] = value;
            end

            local function get_proto(p: number)
                return chunk.protos[p + 1] or panic("UnknownObject", "proto", p);
            end

            local get_import;

            --[=[
                Returns a value from the constant table.
            ]=]
            local function get_constant(k: number, limit: {string}?): any
                local constant = proto.constants[k + 1] or panic(`attempt to get unknown constant {k}`);

                if limit then
                    if not table.find(limit, constant.type) then
                        panic("WrongConstant", constant.type);
                    end
                end

                if constant.type == "nil" or constant.type == "boolean" or constant.type == "number" then
                    return constant.value;
                elseif constant.type == "string" then
                    return get_string(constant.value);
                elseif constant.type == "import" then
                    return get_import(constant.value);
                elseif constant.type == "closure" then
                    return get_proto(constant.value);
                elseif constant.type == "vector" then
                    return vector.create(unpack(constant.value));
                elseif constant.type == "table" then
                    return panic("Unimplemeneted", "table constants");
                else
                    return panic("Unsupported", `constant type '{constant.type}'`);
                end
            end
            
            function get_import(i: number): any
                local path = bytecode.decode_import_id(i);
                local current = env;
                for _, component_id in path do
                    local component = get_constant(component_id);
                    if current[component] then
                        current = current[component];
                    else
                        return;
                    end
                end
                return current;
            end

            --[=[
                Calls a callback
            ]=]
            local function call_callback(name: "break"|"interrupt"|"step", ...)
                local callback = options[name.."_callback"];
                if callback then
                    callback(...);
                end
            end
            

            --[=[
                Sets a register to a given value.
            ]=]
            local function set(r: number, value: any)
                registers[r + 1] = value;
            end

            --[=[
                Returns a value from a register.
            ]=]
            local function get(r: number): any
                return registers[r + 1];
            end

            --[=[
                Jumps to a given offset.
            ]=]
            local function jump(offset: number)
                local new_pc = pc + offset;
                if new_pc < 0 or new_pc > #instructions then
                    panic("InvalidJump", new_pc);
                end 
                pc = new_pc;
            end

            --[=[
                Returns the next instruction.
            ]=]
            local function fetch(): bytecode.BytecodeInstruction?
                local inst;
                while true do
                    pc += 1;
                    inst = instructions[pc + 1];
                    if inst :: any ~= false then
                        break;
                    end
                end
                return inst;
            end

            local function dump_registers()
                local r = "";

                for k, v in registers do
                    r ..= `R{k - 1} = <{type(v)}> {v}, `;
                end

                print(r);
            end

            local function fastcall(id: number, ...): (boolean, any)
                local fn = bytecode.constants.builtins[id];
                if not fn then
                    return false;
                end
                
                local results = {fn(...)};
                return true, results;
            end

            while true do
                local inst = fetch();
                if not inst then
                    break;
                end

                local info = bytecode.get_opcode_info(inst.opcode) or panic(`unknown opcode {inst.opcode}`);

                call_callback("step", pc, inst, info);

                local name = info.name;
                local a, b, c, d, e, aux = inst.operands.a, inst.operands.b, inst.operands.c, inst.operands.d, inst.operands.e, inst.operands.aux;

                if name == "NOP" then
                    
                elseif name == "BREAK" then
                    call_callback("break");
                elseif name == "LOADNIL" then
                    set(a, nil);
                elseif name == "LOADB" then
                    set(a, b == 1);
                    jump(c);
                elseif name == "LOADN" then
                    set(a, d);
                elseif name == "LOADK" then
                    set(a, get_constant(d, {"number", "vector", "string"}));
                elseif name == "MOVE" then
                    set(a, get(b));
                elseif name == "GETGLOBAL" then
                    set(a, get_global(get_constant(aux, {"string"})));
                elseif name == "SETGLOBAL" then
                    set_global(get_constant(aux), get(a));
                elseif name == "GETUPVAL" then
                    panic("Unimplemeneted", "upvalues");
                elseif name == "SETUPVAL" then
                    panic("Unimplemeneted", "upvalues");
                elseif name == "CLOSEUPVALS" then
                    panic("Unimplemeneted", "upvalues");
                elseif name == "GETIMPORT" then
                    set(a, get_constant(d, {"import"}));
                elseif name == "GETTABLE" then
                    set(a, get(b)[get(c)]);
                elseif name == "SETTABLE" then
                    get(b)[get(c)] = get(a);
                elseif name == "GETTABLEKS" then
                    set(a, get(b)[get_constant(aux, {"string"})]);
                elseif name == "SETTABLEKS" then
                    get(b)[get_constant(aux, {"string"})] = get(a);
                elseif name == "GETTABLEN" then
                    set(a, get(b)[get(c) + 1]);
                elseif name == "SETTABLEN" then
                    get(b)[get(c) + 1] = get(a);
                elseif name == "NEWCLOSURE" then
                    set(a, load_proto(get_proto(d)));
                elseif name == "NAMECALL" then
                    local obj = get(a);
                    set(a + 1, obj);
                    set(a, obj[get_constant(aux, {"string"})]);
                elseif name == "CALL" then
                    local fn = get(a);
                    local argc = if b == 0 then stack_top else b-1;

                    local args = {};
                    for i = 1, argc do
                        table.insert(args, get(a + i));
                    end

                    local returns = {fn(unpack(args))};

                    local retc = c;
                    if retc == 0 then
                        adjust_stack_top(#returns);
                        retc = stack_top;
                    else
                        retc -= 1;
                    end

                    for i = 1, retc do
                        set(a + i - 1, returns[i]);
                    end
                elseif name == "RETURN" then
                    local retc = if b == 0 then stack_top else b-1;

                    local returns = {};
                    for i = 1, retc do
                        table.insert(returns, get(a + i - 1));
                    end
                    return unpack(returns);
                elseif name == "JUMP" then
                    jump(d);
                elseif name == "JUMPBACK" then
                    call_callback("interrupt");
                    jump(d);
                elseif name == "JUMPIF" then
                    call_callback("interrupt");
                    if get(a) then
                        jump(d);
                    end
                elseif name == "JUMPIFNOT" then
                    call_callback("interrupt");
                    if not get(a) then
                        jump(d);
                    end
                elseif name == "JUMPIFEQ" then
                    call_callback("interrupt");
                    if get(a) == get(aux) then
                        jump(d);
                    end
                elseif name == "JUMPIFLE" then
                    call_callback("interrupt");
                    if get(a) <= get(aux) then
                        jump(d);
                    end
                elseif name == "JUMPIFLT" then
                    call_callback("interrupt");
                    if get(a) < get(aux) then
                        jump(d);
                    end
                elseif name == "JUMPIFNOTEQ" then
                    call_callback("interrupt");
                    if not (get(a) == get(aux)) then
                        jump(d);
                    end
                elseif name == "JUMPIFNOTLE" then
                    call_callback("interrupt");
                    if not(get(a) <= get(aux)) then
                        jump(d);
                    end
                elseif name == "JUMPIFNOTLT" then
                    call_callback("interrupt");
                    if not (get(a) < get(aux)) then
                        jump(d);
                    end
                elseif name == "ADD" then
                    set(a, get(b) + get(c));
                elseif name == "SUB" then
                    set(a, get(b) - get(c));
                elseif name == "MUL" then
                    set(a, get(b) * get(c));
                elseif name == "DIV" then
                    set(a, get(b) / get(c));
                elseif name == "MOD" then
                    set(a, get(b) % get(c));
                elseif name == "POW" then
                    set(a, get(b) ^ get(c)); 
                elseif name == "ADDK" then
                    set(a, get(b) + get_constant(c));
                elseif name == "SUBK" then
                    set(a, get(b) - get_constant(c));
                elseif name == "MULK" then
                    set(a, get(b) * get_constant(c));
                elseif name == "DIVK" then
                    set(a, get(b) / get_constant(c));
                elseif name == "MODK" then
                    set(a, get(b) % get_constant(c));
                elseif name == "POWK" then
                    set(a, get(b) ^ get_constant(c)); 
                elseif name == "AND" then
                    set(a, get(b) and get(c)); 
                elseif name == "OR" then
                    set(a, get(b) or get(c)); 
                elseif name == "ANDK" then
                    set(a, get(b) and get_constant(c)); 
                elseif name == "ORK" then
                    set(a, get(b) or get_constant(c)); 
                elseif name == "CONCAT" then
                    local str = {};
                    for i = b, c do
                        table.insert(str, get(i));
                    end
                    set(a, table.concat(str, ""));
                elseif name == "NOT" then
                    set(a, not get(b)); 
                elseif name == "MINUS" then
                    set(a, -get(b)); 
                elseif name == "LENGTH" then
                    set(a, #get(b)); 

                elseif name == "NEWTABLE" then
                    set(a, table.create(aux));
                elseif name == "DUBTABLE" then
                    panic("Unimplemeneted", "table constants");
                elseif name == "SETLIST" then
                    local target = get(a);
                
                    local count = c;
                    if count == 0 then
                        count = stack_top;
                    else
                        count -= 1;
                    end

                    for i = 0, count - 1 do
                        target[i] = get(b + i);
                    end
                elseif name == "FORNPREP" then
                    local base = a;
                    local limit = get(base);
                    local index = get(base + 2);

                    if index > limit then
                        jump(d);
                    end

                    set(base + 3, get(base + 2));
                elseif name == "FORNLOOP" then
                    local base = a;

                    set(base + 2, get(base + 2) + get(base + 1));

                    local limit = get(base);
                    local index = get(base + 2);
                    if not (index > limit) then
                        jump(d);
                    end
                elseif name == "FORGLOOP" then
                elseif name == "FORGPREP_INEXT" then
                elseif name == "FASTCALL3" then

                elseif name == "FORGPREP_NEXT" then
                elseif name == "NATIVECALL" then
                    -- Do nothing
                elseif name == "GETVARARGS" then
                elseif name == "DUPCLOSURE" then
                    set(a, load_proto(get_proto(d)));
                elseif name == "PREPVARARGS" then
                    
                elseif name == "LOADKX" then
                    set(a, get_constant(aux, {"number", "string"}));
                elseif name == "JUMPX" then
                    jump(e);
                elseif name == "FASTCALL" then
                elseif name == "COVERAGE" then
                elseif name == "CAPTURE" then
                    panic("Unimplemeneted", "upvalues");
                elseif name == "SUBRK" then
                    set(a, get_constant(b) - get(c));
                elseif name == "DIVRK" then
                    set(a, get_constant(b) / get(c));
                elseif name == "FASTCALL1" then
                    
                elseif name == "FASTCALL2" then
                elseif name == "FASTCALL2K" then
                elseif name == "FORGPREP" then
                elseif name == "JUMPXEQKNIL" then
                elseif name == "JUMPXEQKB" then
                elseif name == "JUMPXEQKN" then
                elseif name == "JUMPXEQKS" then
                elseif name == "IDIV" then
                    set(a, get(b) / get(c)); 
                elseif name == "IDIVK" then
                    set(a, get(b) // get_constant(c)); 
                else
                    panic("InvalidInstruction", name);
                end
            end
        end

        return execute_proto;
    end

    return load_proto(chunk.protos[chunk.main_proto + 1], env);
end

return partial_vm;