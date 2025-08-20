--!native

local bytecode = require("@luau_toolkit/bytecode"); -- TODO! Make relative when lune fixes requires
local common = require("@luau_toolkit/common"); -- TODO! Make relative when lune fixes requires

local function from_i16(n: number): number
    if n >= 2^(16-1) then
        return n - 2^16;
    end

    return n;
end

local function from_i24(n: number): number    
    if n >= 2^(24 - 1) then
        return n - 2^24;
    end

    return n;
end

local function to_i24(n: number): number    
    if n < 0 then
        return n + 2^24;
    end

    return n;
end

function INSN_OP(insn: number): number
    return bit32.extract(insn, 0, 8);
end

function INSN_A(insn: number): number
    return bit32.extract(insn, 8, 8);
end

function INSN_B(insn: number): number
    return bit32.extract(insn, 16, 8);
end

function INSN_C(insn: number): number
    return bit32.extract(insn, 24, 8);
end

function INSN_D(insn: number): number
    return from_i16(bit32.extract(insn, 16, 16));
end

function INSN_E(insn: number): number
    return from_i24(bit32.extract(insn, 8, 24));
end

local function PATCH_INSN_E(insn: number, e: number?): number
    local raw = insn;
    raw = bit32.replace(raw, to_i24(e or 0), 8, 24);
    return raw;
end

export type bstring = buffer | string;

export type LoadedFunction = (...any) -> ...any;
export type Stack = {any};

export type Environment = {[string]: any};
export type LoadstringMode = "b";
export type LoadstringOptions = {
    --[=[
        The debug name assigned to the chunk.
    ]=]
    chunk_name: string?,

    --[=[
        How 'debuggable' the chunks execution should be, at the cost of 
        performance.

        0 = no unnecessary debugging
        1 = 
    ]=]
    debug_level: number?,

    --[=[
        The global table.

        This is the table `GETIMPORT` accesses and the second place `GETGLOBAL` 
        checks if the key wasn't found in `environment`.

        This table cannot be mutated by the loaded bytecode, but any tables 
        accessible through it can be, so make sure to call `table.freeze` on
        sensitive tables, or provide deep copies..

        Defaults to the safe luau standard library as defined in 
        `@luau_toolkit/common`.
    ]=]
    globals: Environment?,

    --[=[
        The environment table.

        This is the table `SETGLOBAL` mutates and `GETGLOBAL` first accesses.

        Defaults to an empty table.
    ]=]
    environment: Environment?,

    --[=[
        An array of upvalues available to main function.

        The first key (1) corrosponds to upvalue index 0.
    ]=]
    upvalues: {any}?,

    --[=[
        How long the main function is allowed to run for in seconds
            .
        Throws an error then the timeout is reached.
    ]=] 
    timeout: number?,
    
    --[=[
        
    ]=]
    mode: ("b")?,

    --[=[
        Allow bytecode chunks that don't pass the `@luau_toolkit/bytecode` 
        `bytecode.validate` checks.
    ]=]
    allow_invalid: boolean?,

    --[=[
        A callback function invoked on `BREAK` instructions.
    ]=]
    break_callback: ((pc: number, stack: Stack) -> ())?,

    --[=[
        A callback function invoked at interrupt points.
    ]=]
    interrupt_callback: ((pc: number, stack: Stack) -> ())?,

    --[=[
        A callback function invoked at every step.
    ]=]
    step_callback: ((pc: number, stack: Stack) -> ())?,

    --[=[
        Callback called before the main function returns.

        Used to extract `pc`/`stack` info for tests.
    ]=]
    main_exit_callback: ((pc: number, stack: Stack) -> ())?,
};

type UpvalueType = "VAL" | "REF" | "UPVAL";

type Upvalue = {
    type: "VAL",
    value: any,
} | {
    type: "REF",
    stack: {any},
    register: number,
} | {
    type: "UPVAL",
    upvalue: Upvalue,
};

--[=[
    Resolves `UPVAL` upvalues to a concrete `VAL`/`REF` upvalue.
]=]
local function walk_upvalues(upvalue: Upvalue): Upvalue
    if upvalue.type == "VAL" or upvalue.type == "REF" then
        return upvalue;
    end

    return walk_upvalues(upvalue.upvalue);
end

local function get_upvalue_value(upvalue: Upvalue): any
    local upvalue = walk_upvalues(upvalue);

    if upvalue.type == "VAL" then
        return upvalue.value;
    elseif upvalue.type == "REF" then
        return upvalue.stack[upvalue.register + 1];
    else
        error("unknown upvalue type");
    end
end

local function set_upvalue_value(upvalue: Upvalue, value: any)
    local upvalue = walk_upvalues(upvalue);

    if upvalue.type == "VAL" then
        upvalue.value = value;
    elseif upvalue.type == "REF" then
        upvalue.stack[upvalue.register + 1] = value;
    else
        error("unknown upvalue type");
    end
end

local CAPTURE_TYPES: {UpvalueType} = {
    [0] = "VAL",
    [1] = "REF",
    [2] = "UPVAL",
};

local MULTRET = -1;

local LOADK_SUPPORTED: {bytecode.ConstantType} = {"number", "vector", "string"};
local STRING_SUPPORTED: {bytecode.ConstantType} = {"string"};
local IMPORT_SUPPORTED: {bytecode.ConstantType} = {"import"};
local NUMBER_SUPPORTED: {bytecode.ConstantType} = {"number"};
local TABLE_SUPPORTED: {bytecode.ConstantType} = {"table"};

local ERR_NONEXISTENT = "attempt to get non-existent %* '%*'";
local ERR_UNKNOWN = "unknown %* '%*'";
local ERR_UNSUPPORTED = "unsupported %* '%*'";
local ERR_UNHANDLED_INSTRUCTION = "unhandled %* instruction";

local all_closures = {};

local function is_loadstring_closure(closure: LoadedFunction): boolean
    return table.find(all_closures, closure) ~= nil;
end

--[=[
    A loadstring implementation.
]=]
local function loadstring(bc: bstring, options: LoadstringOptions?): LoadedFunction    
    local options = options or {} :: LoadstringOptions;
    local chunk_name = options.chunk_name or "=loadstring";
    local environment: Environment = options.environment or {};
    local globals: Environment = options.globals or common.stdlib :: Environment;
    local timeout = options.timeout;
    local debug_level = options.debug_level or 0;

    local chunk = bytecode.chunk.decode(bc);

    local validation_result = bytecode.chunk.validate(chunk);
    if not validation_result.ok and options.allow_invalid ~= true then
        error(`invalid bytecode chunk`, 2);
    end

    local main_upvalues: {Upvalue} = {};
    if options.upvalues then
        for i, v in options.upvalues do
            table.insert(main_upvalues, {
                type = "REF",
                stack = options.upvalues,
                register = i - 1,
            });
        end
    end
    
    local closures = {};

    local function create_closure(proto_id: number, upvalues: {Upvalue}): LoadedFunction
        if #upvalues == 0 and closures[proto_id] then
            return closures[proto_id];
        end

        local proto = chunk.protos[proto_id + 1];

        local debug_pc = 0;

        --[=[
            Returns the line of a given PC, or zero if line information 
            isn't available. Defaults to the current line.
        ]=]
        local function get_line(pc: number): number
            if not proto.line_info then
                return 0;
            end

            return buffer.readu32(proto.line_info, pc * 4);
        end
        
        local inner_closure;
        inner_closure = function(...): ...any
            local exec_start = os.clock();

            local args = { ... };
            local is_main = proto_id == chunk.main_proto;
            local code = proto.instructions;
            local codesize = buffer.len(code) / 4;
            local pc = 0;
            local registers: {any} = table.create(proto.max_stack_size);
            local upvalues: {Upvalue} = upvalues;
            local open_upvalues: {Upvalue} = {};
            local upvalue_heap: {any} = {}; -- pseudo-stack for closed upvalues
            local top = 0;
            local debug_pc_enabled = debug_level >= 1;

            for i = 1, proto.num_params do
                registers[i] = table.remove(args, 1);
                top += 1;
            end

            local function get_closure_level(): number
                local level = 0;
                while true do
                    level += 1;
                    local fn = debug.info(level, "f");

                    if fn == inner_closure then
                        return level;
                    elseif fn == nil then
                        return 1;
                    end
                end
            end

            local function external_panic(message: string, ...): never
                return error(string.format(message :: any, ...), get_closure_level());
            end

            local function internal_panic(message: string, ...)
                local pc = pc - 1;
                local insn = buffer.readu32(code, (pc - 1) * 4);
                local next_insn;

                if pc < codesize then
                    next_insn = buffer.readu32(code, (pc + 1) * 4);
                end

                local display = bytecode.instructions.display(insn, next_insn);
                return error(`interpreter error @ pc={pc} [{display}]: {string.format(message :: any, ...)}`, 2);
            end

            --[=[
                Returns the next instruction, incrementing the pc after.
            ]=]
            local function next_insn(): number
                local insn = buffer.readu32(code, pc * 4);
                pc += 1;
                return insn; 
            end

            --[=[
                Gets the value of a register.
            ]=]
            local function get_register(source: number): any
                return registers[source + 1];
            end

            local function _dump_registers()
                print("register dump:"); 
                for i = 1, 256 do
                    print(`  {i-1}. {registers[i]}`); 
                end
            end

            --[=[
                Sets the value of a register.
            ]=]
            local function set_register(target: number, value: any)
                registers[target + 1] = value;
            end

            local function get_registers(start: number, count: number): {any}
                if count == MULTRET then
                    count = top - start;
                end

                local values = {};

                for i = 1, count do
                    values[i] = registers[start + i];
                end

                return values;
            end

            --[=[
                Sets registers start .. `start` + `count` to the values in `values`.
                Adjusts the stack top.
            ]=]
            local function set_registers(start: number, count: number, values: {any})
                if count == MULTRET then
                    count = #values;
                    top = start + count;
                end

                for i = 1, count do
                    registers[start + i] = values[i];
                end

                --_dump_registers()
            end

            --[=[
                Gets the value of a global.
            ]=]
            local function get_global(key: string): any
                return environment[key] or globals[key];
            end

            --[=[
                Sets the value of a global.
            ]=]
            local function set_global(key: string, value: any)
                environment[key] = value;
            end

            --[=[
                Gets the value of an upvalue.
            ]=]
            local function get_upvalue(upvalue_id: number): any
                local upvalue: Upvalue = upvalues[upvalue_id + 1] or internal_panic(ERR_NONEXISTENT, "upvalue", upvalue_id);
                return get_upvalue_value(upvalue);
            end

            --[=[
                Sets the value of an upvalue.
            ]=]
            local function set_upvalue(upvalue_id: number, value: any)
                local upvalue: Upvalue = upvalues[upvalue_id + 1] or internal_panic(ERR_NONEXISTENT, "upvalue", upvalue_id);
                set_upvalue_value(upvalue, value);
            end

            --[=[
                Creates a new Upvalue.
            ]=]
            local function create_upvalue(id: number, type: UpvalueType): Upvalue
                if type == "VAL" then
                    return {
                        type = "VAL",
                        value = get_register(id);
                    };
                elseif type == "REF" then
                    local upvalue: Upvalue = {
                        type = "REF",
                        stack = registers,
                        register = id,
                    };

                    table.insert(open_upvalues, upvalue);

                    return upvalue;
                elseif type == "UPVAL" then
                    return {
                        type = "UPVAL",
                        upvalue = upvalues[id + 1] or internal_panic(ERR_NONEXISTENT, "upvalue", id),
                    };
                else
                    return internal_panic(ERR_UNKNOWN, "upvalue", type);
                end
            end

            --[=[
                Closes upvalues. This isn't strictly necessary but it allows the
                stack table to be GCed.
            ]=]
            local function close_upvalues(from_register: number)
                local new_open_upvalues: {Upvalue} = {};

                for i, upvalue: Upvalue in open_upvalues do
                    if upvalue.type ~= "REF" then -- REF upvalues shouldn't appear in `open_upvalues`.
                        internal_panic(ERR_UNSUPPORTED, "upvalue", upvalue.type);
                        continue;
                    end

                    if upvalue.register >= from_register then
                        upvalue_heap[upvalue.register + 1] = upvalue.stack[upvalue.register + 1];
                        upvalue.stack = upvalue_heap;
                    else
                        table.insert(new_open_upvalues, upvalue);
                    end
                end

                open_upvalues = new_open_upvalues;
            end

            --[=[
                Jumps by a given jump offset.

                If `adjust_for_aux` is true, we assume the aux instruction
                has been consumed.
            ]=]
            local function jump(offset: number, adjust_for_aux: boolean?)
                if adjust_for_aux then
                    if offset < 0 then
                        offset = offset;
                    else
                        offset = offset - 1;
                    end
                end

                pc += offset;
            end

            local strings = chunk.strings;

            --[=[
                Gets a string from the string table.
            ]=]
            local function get_string(string_id: number): string
                return strings[string_id];
            end

            local get_import;
            local resolved_constants: {any} = {};
            local constants = proto.constants;

            --[=[
                Returns a resolved constant.
            ]=] 
            local function get_constant(const_id: number, allowed: {bytecode.ConstantType}?): any
                if resolved_constants[const_id + 1] then
                    return resolved_constants[const_id + 1];
                end

                local const = constants[const_id + 1] or internal_panic(ERR_NONEXISTENT, "constant", const_id);

                if allowed then
                    if not table.find(allowed, const.type) then
                        error(`unsupported const {const.type}`);
                    end
                end

                local value: any;

                if const.type == "string" then
                    value = get_string(const.value);
                elseif const.type == "import" then
                    value = get_import(const.value);
                elseif const.type == "table" then
                    --[[local t = {};

                    for i, v in const.value do
                        t[get_constant(v)]
                    end

                    value = t;]]
                    value = {};
                elseif const.type == "closure" then
                    error("");
                elseif const.type == "vector" then
                    value = vector.create(const.value[1], const.value[2], const.value[3]);
                else
                    value = const.value;
                end

                resolved_constants[const_id + 1] = value;
                return value;
            end

            --[=[
                Returns an import from an import id.
            ]=]
            function get_import(id: number): any
                local parts = bytecode.import_id.decode(id);
                local current = globals;
                for _, const_id in parts do
                    current = current[get_constant(const_id, STRING_SUPPORTED)];

                    if current == nil then
                        return nil;
                    end
                end
                return current;
            end

            -- localise before hot loop
            local interrupt_callback = options.interrupt_callback;
            local step_callback = options.step_callback;
            local break_callback = options.break_callback;
            local main_exit_callback = options.main_exit_callback;

            local function try_interrupt()
                if interrupt_callback then
                    interrupt_callback(pc, registers);
                end
            end

            while pc < codesize do
                if is_main and timeout then
                    if os.clock() - exec_start >= timeout :: number then
                        external_panic("script timeout");
                    end
                end

                if step_callback then
                    step_callback(pc, registers);
                end

                local insn = next_insn();
                local opcode = INSN_OP(insn);

                if debug_pc_enabled then
                    debug_pc = pc;
                end
                --local info = bytecode.instructions.get_metadata(op) or { name = "NONE" };
                --print(info.name);

                if opcode == 0 then -- NOP
                elseif opcode == 1 then -- BREAK
                    if break_callback then
                        break_callback(pc, registers);
                    end
                elseif opcode == 2 then -- LOADNIL
                    local target = INSN_A(insn);
                    set_register(target, nil);
                elseif opcode == 3 then -- LOADB
                    local target = INSN_A(insn);
                    local value = INSN_B(insn) ~= 0;
                    local offset = INSN_C(insn);
                    set_register(target, value);
                    jump(offset);
                elseif opcode == 4 then -- LOADN
                    local target = INSN_A(insn);
                    local value = INSN_D(insn);
                    set_register(target, value);
                elseif opcode == 5 then -- LOADK
                    local target = INSN_A(insn);
                    local value = get_constant(INSN_D(insn), LOADK_SUPPORTED);
                    set_register(target, value);
                elseif opcode == 6 then -- MOVE
                    local target = INSN_A(insn);
                    local source = INSN_B(insn);
                    set_register(target, get_register(source));
                elseif opcode == 7 then -- GETGLOBAL
                    local target = INSN_A(insn);
                    local key = get_constant(next_insn(), STRING_SUPPORTED);
                    set_register(target, get_global(key));
                elseif opcode == 8 then -- SETGLOBAL
                    local target = INSN_A(insn);
                    local key = get_constant(next_insn(), STRING_SUPPORTED);
                    set_global(key, get_register(target));
                elseif opcode == 9 then -- GETUPVAL
                    local target = INSN_A(insn);
                    set_register(target, get_upvalue(INSN_B(insn)));
                elseif opcode == 10 then -- SETUPVAL
                    local source = INSN_A(insn);
                    set_upvalue(INSN_B(insn), get_register(source));
                elseif opcode == 11 then -- CLOSEUPVALS
                    close_upvalues(INSN_A(insn));
                elseif opcode == 12 then -- GETIMPORT
                    pc += 1;
                    local target = INSN_A(insn);
                    local import = get_constant(INSN_D(insn), IMPORT_SUPPORTED);
                    set_register(target, import);
                elseif opcode == 13 then -- GETTABLE
                    local target = INSN_A(insn);
                    local tbl = get_register(INSN_B(insn));
                    local ket = get_register(INSN_C(insn));
                    set_register(target, tbl[ket]);
                elseif opcode == 14 then -- SETTABLE
                    local source = INSN_A(insn);
                    local tbl = get_register(INSN_B(insn));
                    local key = get_register(INSN_C(insn));
                    tbl[key] = get_register(source);
                elseif opcode == 15 then -- GETTABLEKS
                    local target = INSN_A(insn);
                    local tbl = get_register(INSN_B(insn));
                    local key = get_constant(next_insn(), STRING_SUPPORTED);
                    set_register(target, tbl[key]);
                elseif opcode == 16 then -- SETTABLEKS
                    local source = INSN_A(insn);
                    local tbl = get_register(INSN_B(insn));
                    local key = get_constant(next_insn(), STRING_SUPPORTED);
                    tbl[key] = get_register(source);
                elseif opcode == 17 then -- GETTABLEN
                    local target = INSN_A(insn);
                    local tbl = get_register(INSN_B(insn));
                    local key = INSN_C(insn) + 1;
                    set_register(target, tbl[key]);
                elseif opcode == 18 then -- SETTABLEN
                    local source = INSN_A(insn);
                    local tbl = get_register(INSN_B(insn));
                    local key = INSN_C(insn) + 1;
                    tbl[key] = get_register(source);
                elseif opcode == 19 then -- NEWCLOSURE
                    local target = INSN_A(insn);
                    local child_proto_id = INSN_D(insn);
                    local proto_ref = proto.child_protos[child_proto_id + 1] or internal_panic(ERR_NONEXISTENT, "child proto", child_proto_id);
                    local upvalues = {};

                    while true do
                        if pc == codesize then
                            break;
                        end

                        local insn = next_insn();
                        local op = INSN_OP(insn);
                        if op ~= 70 then
                            pc -= 1;
                            break;
                        end

                        local capture_type: UpvalueType = CAPTURE_TYPES[INSN_A(insn)];
                        local id = INSN_B(insn);
                        local upvalue = create_upvalue(id, capture_type)
                        table.insert(upvalues, upvalue);
                    end

                    set_register(target, create_closure(proto_ref, upvalues));
                elseif opcode == 20 then -- NAMECALL
                    local target = INSN_A(insn);
                    local source = get_register(INSN_B(insn));
                    local name = get_constant(next_insn(), STRING_SUPPORTED);

                    local method = source[name];
                    set_register(target, method);
                    set_register(target + 1, source);
                elseif opcode == 21 then -- CALL
                    try_interrupt();
                    local ra = INSN_A(insn);
                    local target = get_register(ra);
                    local argument_count = INSN_B(insn) - 1;
                    local result_count = INSN_C(insn) - 1;
                    local args = get_registers(ra + 1, argument_count);
                    local results = { target(unpack(args)) };
                    set_registers(ra, result_count, results);
                elseif opcode == 22 then -- RETURN
                    if is_main and main_exit_callback then
                        main_exit_callback(pc, registers);
                    end

                    local start = INSN_A(insn);
                    local result_count = INSN_B(insn) - 1;
                    local results = get_registers(start, result_count);
                    return results;
                elseif opcode == 23 then -- JUMP
                    local offset = INSN_D(insn);
                    jump(offset);
                elseif opcode == 24 then -- JUMPBACK
                    try_interrupt();
                    local offset = INSN_D(insn);
                    jump(offset);
                elseif opcode == 25 then -- JUMPIF
                    local value = get_register(INSN_A(insn));
                    local offset = INSN_D(insn);
                    if value then
                        jump(offset);
                    end
                elseif opcode == 26 then -- JUMPIFNOT
                    local value = get_register(INSN_A(insn));
                    local offset = INSN_D(insn);
                    if not value then
                        jump(offset);
                    end
                elseif opcode == 27 then -- JUMPIFEQ
                    local lhs = get_register(INSN_A(insn));
                    local rhs = get_register(next_insn());
                    local offset = INSN_D(insn);
                    if lhs == rhs then
                        jump(offset, true);
                    end
                elseif opcode == 28 then -- JUMPIFLE
                    local lhs = get_register(INSN_A(insn));
                    local rhs = get_register(next_insn());
                    local offset = INSN_D(insn);
                    if lhs <= rhs then
                        jump(offset, true);
                    end
                elseif opcode == 29 then -- JUMPIFLT
                    local lhs = get_register(INSN_A(insn));
                    local rhs = get_register(next_insn());
                    local offset = INSN_D(insn);
                    if lhs < rhs then
                        jump(offset, true);
                    end
                elseif opcode == 30 then -- JUMPIFNOTEQ
                    local lhs = get_register(INSN_A(insn));
                    local rhs = get_register(next_insn());
                    local offset = INSN_D(insn);
                    if lhs ~= rhs then
                        jump(offset, true);
                    end
                elseif opcode == 31 then -- JUMPIFNOTLE
                    local lhs = get_register(INSN_A(insn));
                    local rhs = get_register(next_insn());
                    local offset = INSN_D(insn);
                    if not (lhs <= rhs) then
                        jump(offset, true);
                    end
                elseif opcode == 32 then -- JUMPIFNOTLT
                    local lhs = get_register(INSN_A(insn));
                    local rhs = get_register(next_insn());
                    local offset = INSN_D(insn);
                    if not (lhs < rhs) then
                        jump(offset, true);
                    end
                elseif opcode == 33 then -- ADD
                    local target = INSN_A(insn);
                    local lhs = get_register(INSN_B(insn));
                    local rhs = get_register(INSN_C(insn));
                    set_register(target, lhs + rhs);
                elseif opcode == 34 then -- SUB
                    local target = INSN_A(insn);
                    local lhs = get_register(INSN_B(insn));
                    local rhs = get_register(INSN_C(insn));
                    set_register(target, lhs - rhs);
                elseif opcode == 35 then -- MUL
                    local target = INSN_A(insn);
                    local lhs = get_register(INSN_B(insn));
                    local rhs = get_register(INSN_C(insn));
                    set_register(target, lhs * rhs);
                elseif opcode == 36 then -- DIV
                    local target = INSN_A(insn);
                    local lhs = get_register(INSN_B(insn));
                    local rhs = get_register(INSN_C(insn));
                    set_register(target, lhs / rhs);
                elseif opcode == 37 then -- MOD
                    local target = INSN_A(insn);
                    local lhs = get_register(INSN_B(insn));
                    local rhs = get_register(INSN_C(insn));
                    set_register(target, lhs % rhs);
                elseif opcode == 38 then -- POW
                    local target = INSN_A(insn);
                    local lhs = get_register(INSN_B(insn));
                    local rhs = get_register(INSN_C(insn));
                    set_register(target, lhs ^ rhs);
                elseif opcode == 39 then -- ADDK
                    local target = INSN_A(insn);
                    local lhs = get_register(INSN_B(insn));
                    local rhs = get_constant(INSN_C(insn), NUMBER_SUPPORTED);
                    set_register(target, lhs + rhs);
                elseif opcode == 40 then -- SUBK
                    local target = INSN_A(insn);
                    local lhs = get_register(INSN_B(insn));
                    local rhs = get_constant(INSN_C(insn), NUMBER_SUPPORTED);
                    set_register(target, lhs - rhs);
                elseif opcode == 41 then -- MULK
                    local target = INSN_A(insn);
                    local lhs = get_register(INSN_B(insn));
                    local rhs = get_constant(INSN_C(insn), NUMBER_SUPPORTED);
                    set_register(target, lhs * rhs);
                elseif opcode == 42 then -- DIVK
                    local target = INSN_A(insn);
                    local lhs = get_register(INSN_B(insn));
                    local rhs = get_constant(INSN_C(insn), NUMBER_SUPPORTED);
                    set_register(target, lhs / rhs);
                elseif opcode == 43 then -- MODK
                    local target = INSN_A(insn);
                    local lhs = get_register(INSN_B(insn));
                    local rhs = get_constant(INSN_C(insn), NUMBER_SUPPORTED);
                    set_register(target, lhs % rhs);
                elseif opcode == 44 then -- POWK
                    local target = INSN_A(insn);
                    local lhs = get_register(INSN_B(insn));
                    local rhs = get_constant(INSN_C(insn), NUMBER_SUPPORTED);
                    set_register(target, lhs ^ rhs);
                elseif opcode == 45 then -- AND
                    local target = INSN_A(insn);
                    local lhs = get_register(INSN_B(insn));
                    local rhs = get_register(INSN_C(insn));
                    set_register(target, lhs and rhs);
                elseif opcode == 46 then -- OR
                    local target = INSN_A(insn);
                    local lhs = get_register(INSN_B(insn));
                    local rhs = get_register(INSN_C(insn));
                    set_register(target, lhs or rhs);
                elseif opcode == 47 then -- ANDK
                    local target = INSN_A(insn);
                    local lhs = get_register(INSN_B(insn));
                    local rhs = get_constant(INSN_C(insn));
                    set_register(target, lhs and rhs);
                elseif opcode == 48 then -- ORK
                    local target = INSN_A(insn);
                    local lhs = get_register(INSN_B(insn));
                    local rhs = get_constant(INSN_C(insn));
                    set_register(target, lhs or rhs);
                elseif opcode == 49 then -- CONCAT
                    local target = INSN_A(insn);
                    local source_start = INSN_B(insn);
                    local source_end = INSN_C(insn);
                    local count = source_end - source_start;
                    local values = get_registers(source_start, count);
                    set_register(target, table.concat(values, ""));
                elseif opcode == 50 then -- NOT
                    local target = INSN_A(insn);
                    local value = get_register(INSN_B(insn));
                    set_register(target, not value);
                elseif opcode == 51 then -- MINUS
                    local target = INSN_A(insn);
                    local value = get_register(INSN_B(insn));
                    set_register(target, -value);
                elseif opcode == 52 then -- LENGTH
                    local target = INSN_A(insn);
                    local value = get_register(INSN_B(insn));
                    set_register(target, #value);
                elseif opcode == 53 then -- NEWTABLE
                    local target = INSN_A(insn);
                    set_register(target, table.create(next_insn()));
                elseif opcode == 54 then -- DUPTABLE
                    local target = INSN_A(insn);
                    local value = table.clone(get_constant(INSN_D(insn)));
                    set_register(target, value);
                elseif opcode == 55 then -- SETLIST
                    local target = get_register(INSN_A(insn));
                    local source_start = INSN_B(insn);
                    local count = INSN_C(insn) - 1;
                    local index_start = next_insn();
                    local values = get_registers(source_start, count);

                    for i = 0, #values - 1 do
                        target[index_start + i] = values[i + 1];
                    end
                elseif opcode == 56 then -- FORNPREP
                    local base = INSN_A(insn);
                    local offset = INSN_D(insn);
                    local limit = get_register(base);
                    local index = get_register(base + 2);

                    if index > limit then
                        jump(offset);
                    end

                    set_register(base + 3, index);
                elseif opcode == 57 then -- FORNLOOP
                    try_interrupt();
                    local base = INSN_A(insn);
                    local offset = INSN_D(insn);
                    local index = get_register(base + 2) + get_register(base + 1);
                    set_register(base + 2, index);

                    local limit = get_register(base);
                    if not (index > limit) then
                        jump(offset);
                    end
                elseif opcode == 58 then -- FORGLOOP
                    error("unimplemented");
                elseif opcode == 59 then -- FORGPREP_INEXT
                    error("unimplemented");
                elseif opcode == 60 then -- FASTCALL3
                    error("unimplemented");
                elseif opcode == 61 then -- FORGPREP_NEXT
                    error("unimplemented");
                elseif opcode == 62 then -- NATIVECALL
                    error("how did this get here?");
                elseif opcode == 63 then -- GETVARARGS
                    error("unimplemented");
                elseif opcode == 64 then -- DUPCLOSURE
                    error("unimplemented");
                elseif opcode == 65 then -- PREPVARARGS
                    -- Skip
                elseif opcode == 66 then -- LOADKX
                    set_register(INSN_A(insn), get_constant(next_insn(), LOADK_SUPPORTED));
                elseif opcode == 67 then -- JUMPX
                    jump(INSN_E(insn));
                elseif opcode == 68 then -- FASTCALL
                    error("unimplemented");
                elseif opcode == 69 then -- COVERAGE
                    local hit = INSN_E(insn);
                    local new_insn = PATCH_INSN_E(insn, hit + 1);
                    buffer.writeu32(code, pc - 1, new_insn);
                elseif opcode == 70 then -- CAPTURE
                    internal_panic(ERR_UNHANDLED_INSTRUCTION, "CAPTURE");
                elseif opcode == 71 then -- SUBRK
                    error("unimplemented");
                elseif opcode == 72 then -- DIVRK
                    error("unimplemented");
                elseif opcode == 73 then -- FASTCALL1
                    error("unimplemented");
                elseif opcode == 74 then -- FASTCALL2
                    error("unimplemented");
                elseif opcode == 75 then -- FASTCALL2K
                    error("unimplemented");
                elseif opcode == 76 then -- FORGPREP
                    error("unimplemented");
                elseif opcode == 77 then -- JUMPXEQKNIL
                    error("unimplemented");
                elseif opcode == 78 then -- JUMPXEQKB
                    error("unimplemented");
                elseif opcode == 79 then -- JUMPXEQKN
                    error("unimplemented");
                elseif opcode == 80 then -- JUMPXEQKS
                    error("unimplemented");
                elseif opcode == 81 then -- IDIV
                    error("unimplemented");
                elseif opcode == 82 then -- IDIVK
                    error("unimplemented");
                else
                    internal_panic(ERR_UNKNOWN, "opcode", opcode);
                end
            end

            if is_main and main_exit_callback then
                main_exit_callback(pc, registers);
            end

            return; --interpreter_error("no return");
        end

        local closure: LoadedFunction;
        if debug_level >= 1 then
            closure = function(...: any): ...any
                local results: {any} = { pcall(inner_closure :: any, ...) };
                local ok = table.remove(results, 1);

                if not ok then
                    local err = tostring(results[1] or "unknown error");
                    err = common.strip_error_prefix(err);
                    error(`{common.display_chunk_name(chunk_name)}:{get_line(debug_pc - 1)}: {err}`, 2);
                end

                return unpack(results);
            end
            
            table.insert(all_closures, closure);
        else
            closure = inner_closure;
        end


        if #upvalues == 0 then
            closures[proto_id] = closure;
        end

        return closure;
    end

    return create_closure(chunk.main_proto, main_upvalues);
end

return loadstring;
