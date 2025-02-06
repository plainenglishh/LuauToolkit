local bytecode = require("../../bytecode/lib");
local common = require("../../common/lib");

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
    --[=[
        A table of globals, defaults to a table with the entire luau standard library.
    ]=]
    globals: Environment?,
    
    --[=[
        A callback to be called when a BREAK instruction is encountered.
    ]=]
    break_callback: () -> ()?,

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
    if bit32.extract(n, 1) == 1 then
        return n - 2^16;
    else
        return n;
    end
end

local function INSN_E(insn: number): number
    local n = bit32.extract(insn, 8, 24);
    if bit32.extract(n, 1) == 1 then
        return n - 2^24;
    else
        return n;
    end
end

local function create_upvalue(val: any, type: "ref"|"val"): Upvalue
    local inner = val;

    return {
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
    local chunk = if type(chunk) ~= "table" then bytecode.decode(chunk) else chunk;
    local options: LoadOptions = options or {
        globals = common.stdlib,
    };

    local genv: Environment = options.globals :: {[any]: any};
    local closures: {CachedClosure} = {};
    
    local interrupt = options.interrupt_callback;
    local function try_interrupt()
        if interrupt then
            interrupt();
        end
    end

    local debugger_break = options.interrupt_callback;
    local function try_debugger_break()
        if debugger_break then
            debugger_break();
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
        for i, v in closures do
            if v.id == pid and v.env == fenv and v.upvalues == upvalues then
                return v.closure;
            end
        end

        local proto = get_proto(pid) or error("unknown proto");

        --[=[
            This tha "loaded" function that runs.
        ]=]
        local function closure(...)
            local pc = -1;
            local instructions = proto._raw_instructions or error("expected raw instructions");

            local stack: {any} = table.create(256);
            local top = 0;

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
                    return get_proto(constant.value);
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
                return stack[reg + 1];
            end

            local function get_reg_range(start: number, count: number): {number}
                return {table.unpack(stack, start + 1, start + count)};
            end

            --[=[
                Sets a register to a given value.
                This gets inlined in -O2
            ]=]
            local function set_reg(reg: number, value: any)
                stack[reg + 1] = value;
            end

            local function set_reg_range(values: {number}, start: number, limit: number?)
                local limit = limit or #values;
                table.move(values, 1, limit, start + 1, stack);
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
                print(value)
                upvalues[uv + 1].set(value);
            end

            local function get_global(k: string): any
                return fenv[k];
            end

            local function set_global(k: string, v: any)
                fenv[k] = v;
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
                pc += offset;
            end

            while true do
                pc += 1;

                if (pc * 4) >= instructions_length then
                    break;
                end

                local insn = buffer.readu32(instructions, pc * 4);
                local op = INSN_OP(insn);

                if op == 0 then
                elseif op == 1 then
                    try_debugger_break();
                elseif op == 2 then -- LOADNIL
                    set_reg(INSN_A(insn), nil);
                elseif op == 3 then -- LOADB
                    set_reg(INSN_A(insn), INSN_B(insn) ~= 0);
                    jump(INSN_C(insn));
                elseif op == 4 then -- LOADK
                    set_reg(INSN_A(insn), INSN_B(insn));
                elseif op == 5 then -- LOADK
                    set_reg(INSN_A(insn), get_const(INSN_B(insn)));
                elseif op == 6 then -- MOVE
                    set_reg(INSN_A(insn), get_reg(INSN_B(insn)));
                elseif op == 7 then -- GETGLOBAL
                    set_reg(INSN_A(insn), get_global(get_const(get_aux())));
                elseif op == 8 then -- SETGLOBAL
                    set_global(get_const(get_aux()), get_reg(INSN_A(insn)));
                elseif op == 9 then -- GETUPVAL
                    set_reg(INSN_A(insn), get_uv(INSN_B(insn)));
                elseif op == 10 then -- SETUPVAL
                    -- TODO! REF upvalues
                    set_uv(INSN_B(insn), get_reg(INSN_A(insn)));
                elseif op == 11 then -- CLOSEUPVALS
                    -- Do nothing for now.
                elseif op == 12 then -- GETIMPORT
                    set_reg(INSN_A(insn), get_const(INSN_D(insn)));
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
                            table.insert(uv, create_upvalue(cap_val, "ref"));
                        elseif cap_type == 2 then -- UPVAL
                            table.insert(uv, upvalues[cap_val]);
                        end
                    end
                    
                    set_reg(INSN_A(insn), new_closure(INSN_D(insn), fenv, uv));
                elseif op == 20 then -- NAMECALL
                elseif op == 21 then -- CALL
                    try_interrupt();

                    --todo set unused args to nil.

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

                    set_reg_range(results, a + 1, nresults);
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
                elseif op == 25 then
                elseif op == 26 then
                elseif op == 27 then
                elseif op == 28 then
                elseif op == 29 then
                elseif op == 30 then
                elseif op == 31 then
                elseif op == 32 then
                elseif op == 33 then
                elseif op == 34 then
                elseif op == 35 then
                elseif op == 36 then
                elseif op == 37 then
                elseif op == 38 then
                elseif op == 39 then
                elseif op == 40 then
                elseif op == 41 then
                elseif op == 42 then
                elseif op == 43 then
                elseif op == 44 then
                elseif op == 45 then
                elseif op == 46 then
                elseif op == 47 then
                elseif op == 48 then
                elseif op == 49 then
                elseif op == 50 then
                elseif op == 51 then
                elseif op == 52 then
                elseif op == 53 then
                elseif op == 54 then
                elseif op == 55 then
                elseif op == 56 then
                elseif op == 57 then
                elseif op == 58 then
                elseif op == 59 then
                elseif op == 60 then
                elseif op == 61 then
                elseif op == 62 then
                elseif op == 63 then
                elseif op == 64 then
                    --TODO!
                elseif op == 65 then
                elseif op == 66 then
                elseif op == 67 then
                elseif op == 68 then
                elseif op == 69 then
                elseif op == 70 then
                elseif op == 71 then
                elseif op == 72 then
                elseif op == 73 then
                elseif op == 74 then
                elseif op == 75 then
                elseif op == 76 then
                elseif op == 77 then
                elseif op == 78 then
                elseif op == 79 then
                elseif op == 80 then
                elseif op == 81 then
                elseif op == 82 then
                end
            end
        end

        table.insert(closures, {
            id = pid,
            closure = closure,
            upvalues = upvalues,
            env = fenv,
        });

        return closure;
    end

    return new_closure(chunk.main_proto, genv, {});
end

return partial;