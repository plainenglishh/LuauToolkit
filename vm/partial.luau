local bytecode = require("../bytecode");
local common = require("../common");

type Closure = (...any) -> (...any);
type Environment = {[any]: any};
type CachedClosure = {
    id: number,
    closure: Closure,
    env: Environment, 
    upvalues: {any},
};

type Upvalue = {
    get: () -> any,
    set: (val: any) -> (),
};

export type LoadOptions = {
    debug_prints: boolean?,

    --[=[
        A table of globals, defaults to a table with the entire luau standard library.
    ]=]
    globals: Environment?,
    
    --[=[
        A callback to be called when a BREAK instruction is encountered.
    ]=]
    break_callback: (pc: number, stack: {any}) -> ()?,

    --[=[
        A callback to be called at safe points (i.e loop iterations or function calls).
    ]=]
    interrupt_callback: () -> ()?,

    --[=[
        The maximum number of seconds the loaded proto should be allowed to run for, defaults to no limit.s
    ]=]
    script_timeout: number?,
};

local function INSN_OP(insn: number): number
    return bit32.extract(insn, 0, 8);
end

local function INSN_A(insn: number): number
    return bit32.extract(insn, 8, 8);
end

local function INSN_B(insn: number): number
    return bit32.extract(insn, 16, 8);
end

local function INSN_C(insn: number): number
    return bit32.extract(insn, 24, 8);
end

local function INSN_D(insn: number): number
    local n = bit32.extract(insn, 16, 16);

    if n < 0x8000 then
        return n;
    else
        return n - 0x10000;
    end
end

local function INSN_E(insn: number): number
    local n = bit32.extract(insn, 8, 24);
    
    if n < 0x800000 then
        return n;
    else
        return n - 0x1000000;
    end
end

local function PATCH_INSN_E(insn: number, e: number?): number
    local raw = 0;
    raw = bit32.replace(raw, INSN_OP(insn), 0, 8);
    raw = bit32.replace(raw, e or 0, 8, 24);
    return raw;
end

local function fastcall(id: number, ...: any): ...any
    return bytecode.constants.builtins[id](...);
end

local function create_upvalue(val: any, type: "ref"|"val"): Upvalue
    local inner = val;

    return {
        __type = "upvalue",
        type = type,
        get = function()
            return inner;
        end,
        set = function(val: any)
            inner = val;
        end
    };
end

local partial = {};

function partial.load(chunk: buffer|string|bytecode.BytecodeChunk, options: LoadOptions?)
    local chunk = if type(chunk) ~= "table" then bytecode.decode(chunk, true) else chunk;
    local options: LoadOptions = options or {
        globals = common.stdlib,
    };
    local debug_prints = options.debug_prints or false;

    local genv: Environment = options.globals :: {[any]: any};
    local closures: {CachedClosure} = {};
    
    local interrupt = options.interrupt_callback;
    local function try_interrupt()
        if interrupt then
            interrupt();
        end
    end

    local debugger_break = options.break_callback;
    local function try_debugger_break(pc: number, stack: {any})
        if debugger_break then
            debugger_break(pc, stack);
        end
    end

    local function debug_print(msg: string, ident: boolean?)
        if debug_prints then
            local space = "";
            local pfx = "";
            if ident ~= false then
                space = "|       ";
            else
                pfx = "[vm]:\n";
            end
            print(`{pfx}[vm]: {space}{msg}`);
        end
    end

    --[=[
        Returns a proto object from an ID.
    ]=]
    local function get_proto(id: number): bytecode.BytecodeProto?
        return chunk.protos[id + 1];
    end

    local function get_string(id): string
        return chunk.strings[id];
    end

    --[=[
        Creates a closure from a proto id.
    ]=]
    local function new_closure(pid: number, fenv: Environment?, upvalues: {Upvalue}): Closure
        local fenv = fenv or genv;
        local proto = get_proto(pid) or error("unknown proto");

        --[=[
            This tha "loaded" function that runs.
        ]=]
        local function closure(...)
            debug_print(`executing closure {pid}`);
            local pc = -1;
            local instructions = proto._raw_instructions or error("expected raw instructions");
            local vararg = {...};

            local registers: {any} = table.create(256);
            local top = 0;

            for i, const in proto.constants do
                if const.type == "closure" then
                    const.value = new_closure(const.value, fenv, upvalues);
                end
            end

            local instructions_length = buffer.len(instructions);

            local get_import;

            --[=[
                Returns a value from the constant table.
            ]=]
            local function get_const(k: number): any
                local constant = proto.constants[k + 1] or error(`attempt to get unknown constant {k}`);

                if constant.type == "nil" or constant.type == "boolean" or constant.type == "number" then
                    return constant.value;
                elseif constant.type == "string" then
                    return get_string(constant.value);
                elseif constant.type == "import" then
                    return get_import(constant.value);
                elseif constant.type == "closure" then
                    return constant.value;
                elseif constant.type == "vector" then
                    return vector.create(unpack(constant.value));
                elseif constant.type == "table" then
                    return error("");
                else
                    return error("");
                end
            end
            
            function get_import(i: number): any
                local path = bytecode.decode_import_id(i);
                local current = fenv;
                for _, component_id in path do
                    local component = get_const(component_id);
                    if current[component] then
                        current = current[component];
                    else
                        return;
                    end
                end
                return current;
            end

            --[=[
                Returns the value stored in a register.
                This gets inlined in -O2
            ]=]
            local function get_reg(reg: number): any
                return registers[reg + 1];
            end

            local function get_reg_range(start: number, count: number): {any}
                return {table.unpack(registers, start + 1, start + count)};
            end

            --[=[
                Sets a register to a given value.
                This gets inlined in -O2
            ]=]
            local function set_reg(reg: number, value: any)
                debug_print(`set register {reg} to {value}`);
                registers[reg + 1] = value;
                --print(`R{reg} set to {value}`);
            end

            local function set_reg_range(values: {any}, start: number, count: number?)
                local count = count or #values;
                if count == 0 then
                    return;
                end

                table.move(values, 1, count, start + 1, registers);
                if debug_prints then
                    for i = start, start + count do
                        debug_print(`set register {i} to {registers[i + 1]}`);
                    end
                end
            end

            --[=[
                Returns the value at a given upvalue index.
            ]=]
            local function get_uv(uv: number): any
                return upvalues[uv + 1].get();
            end

            --[=[
                Sets an upvalue to a given value.
            ]=]
            local function set_uv(uv: number, value: number)
                upvalues[uv + 1].set(value);
            end

            --[=[
                Returns the next "instruction", incrementing the pc.
            ]=]
            local function get_aux()
                pc += 1;
                return buffer.readu32(instructions, pc * 4);
            end

            --[=[
                Jumps to a given offset.
            ]=]
            local function jump(offset: number)
                debug_print(`jumping: {offset}`);
                pc += offset;
            end

            while true do
                pc += 1;

                if (pc * 4) >= instructions_length then
                    break;
                end

                local insn = buffer.readu32(instructions, pc * 4);
                local op = INSN_OP(insn);

                if debug_prints then
                    local info = bytecode.get_opcode_info(op) or error("");
                    local args = "";
                    local aux = "";

                    for i, operand in info.operands do
                        if i == 1 then
                            args ..= " ";
                        else
                            args ..= ", ";
                        end

                        if operand.name == "a" then
                            args ..= INSN_A(insn);
                        elseif operand.name == "b" then
                            args ..= INSN_B(insn);
                        elseif operand.name == "c" then
                            args ..= INSN_C(insn);
                        elseif operand.name == "d" then
                            args ..= INSN_D(insn);
                        elseif operand.name == "e" then
                            args ..= INSN_E(insn);
                        elseif operand.name == "aux" then
                            args ..= buffer.readu32(instructions, (pc + 1) * 4);
                            aux = ` 0x{string.format("%08X",  buffer.readu32(instructions, (pc + 1) * 4))}`;
                        end
                    end

                    debug_print(`{pid}:{pc} {info.name}{args} (0x{string.format("%08X", insn)}{aux})`, false);
                end

                if op == 0 then
                elseif op == 1 then
                    try_debugger_break(pc, registers);
                elseif op == 2 then -- LOADNIL
                    set_reg(INSN_A(insn), nil);
                elseif op == 3 then -- LOADB
                    set_reg(INSN_A(insn), INSN_B(insn) ~= 0);
                    jump(INSN_C(insn));
                elseif op == 4 then -- LOADN
                    set_reg(INSN_A(insn), INSN_D(insn));
                elseif op == 5 then -- LOADK
                    set_reg(INSN_A(insn), get_const(INSN_B(insn)));
                elseif op == 6 then -- MOVE
                    set_reg(INSN_A(insn), get_reg(INSN_B(insn)));
                elseif op == 7 then -- GETGLOBAL
                    set_reg(INSN_A(insn), fenv[get_const(get_aux())]);
                elseif op == 8 then -- SETGLOBAL
                    fenv[get_const(get_aux())] = get_reg(INSN_A(insn));
                elseif op == 9 then -- GETUPVAL
                    set_reg(INSN_A(insn), get_uv(INSN_B(insn)));
                elseif op == 10 then -- SETUPVAL
                    -- TODO! REF upvalues
                    set_uv(INSN_B(insn), get_reg(INSN_A(insn)));
                elseif op == 11 then -- CLOSEUPVALS
                    -- Do nothing for now.
                elseif op == 12 then -- GETIMPORT
                    set_reg(INSN_A(insn), get_import(get_aux()));
                elseif op == 13 then -- GETTABLE
                    set_reg(INSN_A(insn), get_reg(INSN_B(insn))[get_reg(INSN_C(insn))]);
                elseif op == 14 then -- SETTABLE
                    get_reg(INSN_B(insn))[get_reg(INSN_C(insn))] = get_reg(INSN_A(insn));
                elseif op == 15 then -- GETTABLEKS
                    set_reg(INSN_A(insn), get_reg(INSN_B(insn))[get_const(get_aux())]);
                elseif op == 16 then -- SETTABLEKS
                    get_reg(INSN_B(insn))[get_const(get_aux())] = get_reg(INSN_A(insn));
                elseif op == 17 then -- GETTABLEN
                    set_reg(INSN_A(insn), get_reg(INSN_B(insn))[INSN_C(insn) + 1]);
                elseif op == 18 then -- SETTABLEN
                    get_reg(INSN_B(insn))[INSN_C(insn) + 1] = get_reg(INSN_A(insn));
                elseif op == 19 then -- NEWCLOSURE
                    local uv: {Upvalue} = {};

                    while pc < instructions_length do
                        pc += 1;
                        local capture = buffer.readu32(instructions, pc * 4);
                        if INSN_OP(capture) ~= 70 then
                            pc -= 1;
                            break;
                        end

                        local cap_type = INSN_A(capture);
                        local cap_val = INSN_B(capture);

                        if cap_type == 0 then -- VAL
                            table.insert(uv, create_upvalue(cap_val, "val"));
                        elseif cap_type == 1 then -- REF
                            error("REF upvalues not yet supported");
                            table.insert(uv, create_upvalue(cap_val, "ref"));
                        elseif cap_type == 2 then -- UPVAL
                            table.insert(uv, upvalues[cap_val]);
                        end
                    end

                    set_reg(INSN_A(insn), new_closure(INSN_D(insn), fenv, uv));
                elseif op == 20 then -- NAMECALL
                    local a = INSN_A(insn);
                    local obj =  get_reg(a);
                    set_reg(a, obj[get_const(get_aux())]);
                    set_reg(a + 1, obj);
                elseif op == 21 then -- CALL
                    try_interrupt();

                    local a, b, c = INSN_A(insn), INSN_B(insn), INSN_C(insn);
                    local func = get_reg(a);

                    local nparams = b - 1;
                    if nparams == -1 then
                        nparams = top - a; 
                    end

                    local args = get_reg_range(a + 1, nparams);
                    local results = {func(table.unpack(args))};

                    local nresults = c - 1;
                    if nresults == -1 then
                        nresults = #results;
                        top = a + (nresults - 1);
                    end

                    set_reg_range(results, a, nresults);
                elseif op == 22 then -- RETURN
                    try_interrupt();

                    local a = INSN_A(insn);
                    
                    local nresults = INSN_B(insn) - 1;
                    if nresults == -1 then
                        nresults = top - a;
                    end

                    local results = get_reg_range(a, nresults);
                    return table.unpack(results);
                elseif op == 23 then -- JUMP
                    jump(INSN_D(insn));
                elseif op == 24 then -- JUMPBACK
                    try_interrupt();
                    jump(INSN_D(insn));
                elseif op == 25 then -- JUMPIF
                    try_interrupt();
                    if get_reg(INSN_A(insn)) then
                        jump(INSN_D(insn));
                    end
                elseif op == 26 then -- JUMPIFNOT
                    try_interrupt();
                    if not get_reg(INSN_A(insn)) then
                        jump(INSN_D(insn));
                    end
                elseif op == 27 then -- JUMPIFEQ
                    try_interrupt();
                    if get_reg(INSN_A(insn)) == get_reg(get_aux()) then
                        jump(INSN_D(insn));
                    end
                elseif op == 28 then -- JUMPIFLE
                    try_interrupt();
                    if get_reg(INSN_A(insn)) <= get_reg(get_aux()) then
                        jump(INSN_D(insn));
                    end
                elseif op == 29 then -- JUMPIFLT
                    try_interrupt();
                    if get_reg(INSN_A(insn)) < get_reg(get_aux()) then
                        jump(INSN_D(insn));
                    end
                elseif op == 30 then -- JUMPIFNOTEQ
                    try_interrupt();
                    if not (get_reg(INSN_A(insn)) == get_reg(get_aux())) then
                        jump(INSN_D(insn));
                    end
                elseif op == 31 then -- JUMPIFNOTLE
                    try_interrupt();
                    if not (get_reg(INSN_A(insn)) <= get_reg(get_aux())) then
                        jump(INSN_D(insn));
                    end
                elseif op == 32 then -- JUMPIFNOTLT
                    try_interrupt();
                    if not (get_reg(INSN_A(insn)) < get_reg(get_aux())) then
                        jump(INSN_D(insn));
                    end
                elseif op == 33 then -- ADD
                    set_reg(INSN_A(insn), get_reg(INSN_B(insn)) + get_reg(INSN_C(insn)));
                elseif op == 34 then -- SUB
                    set_reg(INSN_A(insn), get_reg(INSN_B(insn)) - get_reg(INSN_C(insn)));
                elseif op == 35 then -- MUL                    
                    set_reg(INSN_A(insn), get_reg(INSN_B(insn)) * get_reg(INSN_C(insn)));
                elseif op == 36 then -- DIV
                    set_reg(INSN_A(insn), get_reg(INSN_B(insn)) / get_reg(INSN_C(insn)));
                elseif op == 37 then -- MOD
                    set_reg(INSN_A(insn), get_reg(INSN_B(insn)) % get_reg(INSN_C(insn)));    
                elseif op == 38 then -- POW
                    set_reg(INSN_A(insn), get_reg(INSN_B(insn)) ^ get_reg(INSN_C(insn)));
                elseif op == 39 then -- ADDK
                    set_reg(INSN_A(insn), get_reg(INSN_B(insn)) + get_const(INSN_C(insn)));
                elseif op == 40 then -- SUBK
                    set_reg(INSN_A(insn), get_reg(INSN_B(insn)) - get_const(INSN_C(insn)));
                elseif op == 41 then -- MULK                
                    set_reg(INSN_A(insn), get_reg(INSN_B(insn)) * get_const(INSN_C(insn)));
                elseif op == 42 then -- DIVK
                    set_reg(INSN_A(insn), get_reg(INSN_B(insn)) / get_const(INSN_C(insn)));
                elseif op == 43 then -- MODK
                    set_reg(INSN_A(insn), get_reg(INSN_B(insn)) % get_const(INSN_C(insn)));    
                elseif op == 44 then -- POWK
                    set_reg(INSN_A(insn), get_reg(INSN_B(insn)) ^ get_const(INSN_C(insn)));
                elseif op == 45 then -- AND
                    set_reg(INSN_A(insn), get_reg(INSN_B(insn)) and get_reg(INSN_C(insn)));
                elseif op == 46 then -- OR
                    set_reg(INSN_A(insn), get_reg(INSN_B(insn)) or get_reg(INSN_C(insn)));
                elseif op == 47 then -- ANDK
                    set_reg(INSN_A(insn), get_reg(INSN_B(insn)) and get_const(INSN_C(insn)));
                elseif op == 48 then -- ORK
                    set_reg(INSN_A(insn), get_reg(INSN_B(insn)) or get_const(INSN_C(insn)));
                elseif op == 49 then -- CONCAT
                    local b = INSN_B(insn);
                    local str = get_reg_range(b, INSN_C(insn) - b);
                    set_reg(INSN_A(insn), table.concat(str, ""));
                elseif op == 50 then -- NOT
                    set_reg(INSN_A(insn), not get_reg(INSN_B(insn)));
                elseif op == 51 then -- MINUS
                    set_reg(INSN_A(insn), -get_reg(INSN_B(insn)));
                elseif op == 52 then -- LENGTH
                    set_reg(INSN_A(insn), #get_reg(INSN_B(insn)));
                elseif op == 53 then -- NEWTABLE
                    set_reg(INSN_A(insn), table.create(get_aux()));
                elseif op == 54 then -- DUPTABLE
                    error("table constants not yet supported");
                elseif op == 55 then -- SETLIST
                    local count = INSN_C(insn) - 1;
                    local idx_start = get_aux();
                    if count == -1 then
                        count = top;
                    end

                    local target = get_reg(INSN_A(insn));
                    local start = INSN_B(insn);
                    for i = 0, count - 1 do
                        target[idx_start + i] = get_reg(start + i);
                    end
                elseif op == 56 then -- FORNPREP
                    local base = INSN_A(insn);
                    local limit = get_reg(base);
                    local index = get_reg(base + 2);
                
                    
                    if index > limit then
                        jump(INSN_D(insn));
                    end

                    set_reg(base + 3, index);
                elseif op == 57 then -- FORNLOOP
                    local base = INSN_A(insn);
                    local index = get_reg(base + 2) + get_reg(base + 1);
                    set_reg(base + 2, index);

                    local limit = get_reg(base);
                    if not (index > limit) then
                        jump(INSN_D(insn));
                    end
                elseif op == 58 then -- FORGLOOP
                    try_interrupt();
                    local ra = INSN_A(insn);

                    local aux = get_aux();
                    local var_count = bit32.extract(aux, 0, 8);
                    local _ipairs_fast_iter = bit32.extract(aux, 31, 1) == 1;

                    local generator = get_reg(ra);
                    local state = get_reg(ra + 1);
                    local index = get_reg(ra + 2);

                    if typeof(generator) == "nil" then
                        debug_print("iter mode: generalised");
                        local parts = common.get_table_parts(state);
                        local array_size = parts.array_size;
                        local array_part = parts.array;
                        local hash_size = parts.hash_size;
                        local hash_part = parts.hash;

                        -- Clear extra variables
                        if var_count > 2 then
                            for i = 2, var_count do
                                set_reg(ra + 3 + i, nil);
                            end
                        end

                        -- Terminate ipairs traversal
                        if var_count < 0 and (index >= array_size or parts.array[index + 1] == nil) then
                            continue;
                        end

                        -- Array Portion
                        local goto_dispatch = false;

                        while index < array_size do
                            local e = array_part[index + 1];
                            
                            if e ~= nil then
                                set_reg(ra + 2, index + 1);
                                set_reg(ra + 3, index + 1);
                                set_reg(ra + 4, e);

                                jump(INSN_D(insn) - 1);
                                goto_dispatch = true;
                                break;
                            end
                            
                            index += 1;
                        end

                        if goto_dispatch then
                            continue;
                        end
                        
                        -- Hash Part
                        while index - array_size < hash_size do
                            local e = hash_part[index - array_size + 1];
                            
                            if e[1] ~= nil then
                                set_reg(ra + 2, index + 1);
                                set_reg(ra + 3, e[1]);
                                set_reg(ra + 4, e[2]);

                                jump(INSN_D(insn) - 1);
                                goto_dispatch = true;
                                break;
                            end

                            index += 1;
                        end

                        if goto_dispatch then
                            continue;
                        end
                    else
                        debug_print("iter mode: iterator func");

                        local args = {generator(state, index)};
                        if args[1] == nil then
                            continue;
                        end

                        set_reg(ra + 2, args[1]);
                        set_reg_range(args, ra + 3, var_count);
                        jump(INSN_D(insn) - 1);
                    end
                elseif op == 59 then -- FORGPREP_INEXT
                    jump(INSN_D(insn));
                elseif op == 60 then -- FASTCALL3
                    -- fallthrough for now
                elseif op == 61 then -- FORGPREP_NEXT
                    jump(INSN_D(insn));
                elseif op == 62 then -- NATIVECALL
                    -- Do nothing
                elseif op == 63 then -- GETVARARGS
                    local a = INSN_A(insn);
                    local count = INSN_B(insn) - 1;
                    if count == -1 then
                        count = #vararg;
                        top = a + (count - 1);
                    end

                    set_reg_range(vararg, a, count);
                elseif op == 64 then -- DUPCLOSURE
                    set_reg(INSN_A(insn), get_const(INSN_D(insn)));
                elseif op == 65 then -- PREPVARARGS
                    top += #vararg;
                elseif op == 66 then -- LOADKX
                    set_reg(INSN_A(insn), get_const(get_aux()));
                elseif op == 67 then -- JUMPX
                    try_interrupt();
                    jump(INSN_E(insn));
                elseif op == 68 then -- FASTCALL
                    -- fallthrough for now
                elseif op == 69 then -- COVERAGE
                    local hits = INSN_E(insn);

                    if hits < 2^(23-1) then
                        buffer.writeu32(instructions, pc * 4, PATCH_INSN_E(insn, hits + 1));
                    end
                elseif op == 70 then -- CAPTURE
                    error("unhandled CAPTURE instruction"); -- Handled by 'NEWCLOSURE'.
                elseif op == 71 then -- SUBRK
                    set_reg(INSN_A(insn), get_const(INSN_C(insn)) - get_reg(INSN_B(insn)));
                elseif op == 72 then -- DIVRK
                    set_reg(INSN_A(insn), get_const(INSN_C(insn)) / get_reg(INSN_B(insn)));
                elseif op == 73 then -- FASTCALL1
                    -- fallthrough for now
                elseif op == 74 then -- FASTCALL2
                    -- fallthrough for now
                elseif op == 75 then -- FASTCALL2K
                    -- fallthrough for now
                elseif op == 76 then -- FORGPREP  
                    local ra_generator = INSN_A(insn);
                    local ra_state = ra_generator + 1;
                    local ra_index = ra_generator + 2;

                    local state = get_reg(ra_generator);

                    if typeof(state) == "function" then
                        debug_print("function iteration");
                        -- handled by FORGLOOP
                    else
                        local mt = getmetatable(state);
                        if typeof(mt) ~= "table" and mt ~= nil then
                            error("attempt to iterate over value with locked metatable, unable to get __iter");
                        end

                        if mt and mt.__iter then
                            debug_print("__iter iteration");
                            error("__iter not yet functioning")
                        elseif mt and mt.__call then
                            print("__call iteration");
                            -- handled by FORGLOOP, may be deprecated by luau
                        elseif typeof(state) == "table" then
                            debug_print("normal iteration");
                            set_reg(ra_state, state);
                            set_reg(ra_index, 0);
                            set_reg(ra_generator, nil);
                        else
                            error(`attempt to iterate over {typeof(state)}`);
                        end
                    end

                    jump(INSN_D(insn));
                elseif op == 77 then -- JUMPXEQKNIL
                    local aux = get_aux();
                    local not_flag = bit32.extract(aux, 31) == 1;
                    
                    if not_flag then
                        if get_reg(INSN_A(insn)) ~= nil then
                            jump(INSN_D(insn));
                        end
                    else
                        if get_reg(INSN_A(insn)) == nil then
                            jump(INSN_D(insn));
                        end
                    end
                elseif op == 78 then -- JUMPXEQKB
                    local aux = get_aux();
                    local not_flag = bit32.extract(aux, 31) == 1;
                    local bool = bit32.extract(aux, 0) == 1;
                    
                    if not_flag then
                        if get_reg(INSN_A(insn)) ~= bool then
                            jump(INSN_D(insn));
                        end
                    else
                        if get_reg(INSN_A(insn)) == bool then
                            jump(INSN_D(insn));
                        end
                    end
                elseif op == 79 or op == 80 then -- JUMPXEQKN
                    local aux = get_aux();
                    local not_flag = bit32.extract(aux, 31) == 1;
                    local const = bit32.extract(aux, 0, 24);
                    
                    if not_flag then
                        if get_reg(INSN_A(insn)) ~= get_const(const) then
                            jump(INSN_D(insn));
                        end
                    else
                        if get_reg(INSN_A(insn)) == get_const(const) then
                            jump(INSN_D(insn));
                        end
                    end
                elseif op == 81 then -- IDIV
                    set_reg(INSN_A(insn), get_reg(INSN_B(insn)) // get_reg(INSN_C(insn)));
                elseif op == 82 then -- ADDK
                    set_reg(INSN_A(insn), get_reg(INSN_B(insn)) // get_const(INSN_C(insn)));
                elseif op == 255 then -- ext: JUMPR (ABC)
                    jump(get_reg(INSN_A(insn)));
                end
            end
        end

        table.insert(closures, {
            id = pid,
            closure = closure,
            upvalues = upvalues,
            env = fenv,
        });

        debug_print(`loaded closure {pid}`);

        return closure;
    end

    return new_closure(chunk.main_proto, genv, {});
end

return partial;