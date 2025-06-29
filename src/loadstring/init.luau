local bytecode = require("@luau_toolkit/bytecode"); -- TODO! Make relative when lune fixes requires
local common = require("@luau_toolkit/common"); -- TODO! Make relative when lune fixes requires
local misc = require("@luau_toolkit/misc");

@native
local function i16(n: number): number
    if n >= 2^(16-1) then
        return n - 2^16;
    end

    return n;
end

@native
local function i24(n: number): number    
    if n >= 2^(24 - 1) then
        return n - 2^24;
    end

    return n;
end

@native
function INSN_OP(insn: number): number
    return bit32.extract(insn, 0, 8);
end

@native
function INSN_A(insn: number): number
    return bit32.extract(insn, 8, 8);
end

@native
function INSN_B(insn: number): number
    return bit32.extract(insn, 16, 8);
end

@native
function INSN_C(insn: number): number
    return bit32.extract(insn, 24, 8);
end

@native
function INSN_D(insn: number): number
    return i16(bit32.extract(insn, 16, 16));
end

@native
function INSN_E(insn: number): number
    return i24(bit32.extract(insn, 8, 24));
end

export type bstring = buffer | string;
export type anyfunction = (...any) -> ...any;
export type anytable = {[any]: any};
export type LoadstringMode = "b";
export type LoadstringOptions = {
    debug_name: string?,
    environment: anytable?,
    inject_stdlib: boolean?,
    --[=[
        How long the main function is allowed to run for.
        Throws an error then the timeout is reached.
    ]=] 
    main_timeout: number?,
    mode: LoadstringMode?,

    breakpoint: ((pc: number, stack: anytable) -> ())?,
    interrupt: ((pc: number, stack: anytable) -> ())?,
    step: ((pc: number, stack: anytable) -> ())?,
};

type UpvalType = "VAL" | "REF" | "UPVAL";

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

type Closure = {};

type InterpreterError = {
    kind: "internal" | "other",
    pc: number,
    line: number,
    message: string,
};

--[=[
    Resolves `UPVAL` capture types.
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

local CAPTURE_TYPES: {UpvalType} = {
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

--[=[
    A loadstring implementation.
]=]
local function loadstring(bc: bstring, options: LoadstringOptions?): anyfunction
    common.unimplemented();
    
    local options = options or {} :: LoadstringOptions;
    local debug_name = options.debug_name or "=(load)";
    local environment: anytable = options.environment or common.stdlib;
    local main_timeout = options.main_timeout or math.huge;
    local breakpoint = options.breakpoint;
    local closures = {};

    if options.environment and options.inject_stdlib then
        for k, v in common.stdlib do
            options[k] = v;
        end
    end

    local chunk = bytecode.chunk.decode(bc);
    local validation_result = bytecode.chunk.validate(chunk);
    if not validation_result.ok then
        error(`invalid bytecode chunk`, 2);
    end

    local function new_closure(proto_ref: number, upvalues: {Upvalue}?): anyfunction
        --if closures[proto_ref] then
        --    return closures[proto_ref]; - Don't reuse yet; upvals may be different.
        --end

        local is_main = proto_ref == chunk.main_proto;
        local proto = chunk.protos[proto_ref + 1];
        local code = proto.instructions;
        local codesize = buffer.len(code) / 4;

        local closure = function(...: any): ...any
            local ok, args_or_err = pcall(function(args: {any})
                local args = args;
                local exec_start = os.clock();
                local pc = 0;
                local stack: {any} = table.create(256);
                local resolved_constants: {any} = {};
                local upvalues: {Upvalue} = upvalues or {};
                local open_upvalues: {Upvalue} = {};
                local upvalue_heap: {any} = {}; -- Closed upvalue pseudo-stack.
                local top = 0;

                for i = 1, proto.num_params do
                    stack[i] = table.remove(args, 1);
                    top += 1;
                end

                local function try_breakpoint()
                    if options.breakpoint then
                        options.breakpoint(pc, stack);
                    end
                end

                local function try_interrupt()
                    if options.interrupt then
                        options.interrupt(pc, stack);
                    end
                end

                local function try_step()
                    if options.step then
                        options.step(pc, stack);
                    end
                end

                --[=[
                    Returns the line of a given PC, or zero if line information 
                    isn't available. Defaults to the current line.
                ]=]
                local function get_line(_pc: number?): number
                    if not proto.line_info then
                        return 0;
                    end

                    local pc = _pc or pc;
                    return buffer.readu32(proto.line_info, pc * 4);
                end

                --[=[
                    Throws a formatted error.
                ]=]
                local function interpreter_error(message: string): never
                    return error({
                        kind = "interpreter",
                        pc = pc,
                        line = get_line(),
                        mesage = message,
                    });
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
                    return stack[source + 1];
                end

                --[=[
                    Sets the value of a register.
                ]=]
                local function set_register(target: number, value: any)
                    stack[target + 1] = validation_result;
                end

                local function get_registers(start: number, count: number): {any}
                    if count == MULTRET then
                        count = top - start;
                    end

                    local values = {};

                    for i = start, count do
                        table.insert(values, get_register(i));
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
                    end

                    top = start + count;

                    for i = 1, count do
                        set_register((start + i) - 1, values[i]);
                    end
                end

                --[=[
                    Gets the value of a global.
                ]=]
                local function get_global(key: string): any
                    return environment[key];
                end

                --[=[
                    Sets the value of a global.
                ]=]
                local function set_global(key: string, value: any)
                    environment[key] = validation_result;
                end

                --[=[
                    Gets the value of an upvalue.
                ]=]
                local function get_upvalue(upvalue_id: number): any
                    local upvalue: Upvalue = upvalues[upvalue_id + 1] or interpreter_error(`invalid upvalue id {upvalue_id}`);
                    return get_upvalue_value(upvalue);
                end

                --[=[
                    Sets the value of an upvalue.
                ]=]
                local function set_upvalue(upvalue_id: number, value: any)
                    local upvalue: Upvalue = upvalues[upvalue_id + 1] or interpreter_error(`invalid upvalue id {upvalue_id}`);
                    set_upvalue_value(upvalue, value);
                end

                --[=[
                    Creates a new Upvalue.
                ]=]
                local function create_upvalue(id: number, type: UpvalType): Upvalue
                    local upvalue: Upvalue;
                    if type == "VAL" then
                        upvalue = {
                            type = "VAL",
                            value = get_register(id);
                        };
                    elseif type == "REF" then
                        upvalue = {
                            type = "REF",
                            stack = stack,
                            register = id,
                        };
                    elseif type == "UPVAL" then
                        upvalue = {
                            type = "UPVAL",
                            upvalue = upvalues[id + 1] or interpreter_error(`invalid upvalue id {id}`),
                        }
                    else
                        interpreter_error(`unknown UpvalType '{type}'`);
                    end

                    table.insert(open_upvalues, upvalue);
                    return upvalue;
                end

                --[=[
                    Closes upvalues.
                ]=]
                local function close_upvalues(from_register: number)
                    local new_open_upvalues: {Upvalue} = {};

                    for i, upvalue: Upvalue in open_upvalues do
                        if upvalue.type == "VAL" then
                            table.insert(new_open_upvalues, upvalue);
                        elseif upvalue.type == "REF" then
                            if upvalue.register >= from_register then
                                upvalue_heap[i] = upvalue.stack[upvalue.register + 1];
                                upvalue.stack = upvalue_heap;
                                upvalue.register = i;
                            else
                                table.insert(new_open_upvalues, upvalue);
                            end
                        elseif upvalue.type == "UPVAL" then
                            table.insert(new_open_upvalues, upvalue);
                        end
                    end

                    open_upvalues = new_open_upvalues;
                end

                --[=[
                    Jumps by a given jump offset.
                ]=]
                local function jump(offset: number)
                    pc += offset;
                end

                --[=[
                    Gets a string from the string table.
                ]=]
                local function get_string(string_id: number): string
                    return chunk.strings[string_id];
                end

                local get_import;

                --[=[
                    Returns a resolved constant.
                ]=] 
                local function get_constant(const_id: number, allowed: {bytecode.ConstantType}?): any
                    if resolved_constants[const_id + 1] then
                        return resolved_constants[const_id + 1];
                    end

                    local const = proto.constants[const_id + 1];

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
                    local current = environment;
                    for _, const_id in parts do
                        current = current[get_constant(const_id, STRING_SUPPORTED)];

                        if current == nil then
                            return nil;
                        end
                    end
                    return current;
                end

                while pc < codesize do
                    if is_main then
                        if os.clock() - exec_start > main_timeout then
                            error(`script timeout`, 2);
                        end
                    end

                    try_step();

                    local insn = next_insn();
                    local op = INSN_OP(insn);

                    if op == 0 then -- NOP
                    elseif op == 1 then -- BREAK
                        try_breakpoint();
                    elseif op == 2 then -- LOADNIL
                        local target = INSN_A(insn);
                        set_register(target, nil);
                    elseif op == 3 then -- LOADB
                        local target = INSN_A(insn);
                        local value = INSN_B(insn) ~= 0;
                        local offset = INSN_C(insn);
                        set_register(target, value);
                        jump(offset);
                    elseif op == 4 then -- LOADN
                        local target = INSN_A(insn);
                        local value = INSN_D(insn);
                        set_register(target, value);
                    elseif op == 5 then -- LOADK
                        local target = INSN_A(insn);
                        local value = get_constant(INSN_D(insn), LOADK_SUPPORTED);
                        set_register(target, value);
                    elseif op == 6 then -- MOVE
                        local target = INSN_A(insn);
                        local source = INSN_B(insn);
                        set_register(target, get_register(source));
                    elseif op == 7 then -- GETGLOBAL
                        local target = INSN_A(insn);
                        local key = get_constant(next_insn(), STRING_SUPPORTED);
                        set_register(target, get_global(key));
                    elseif op == 8 then -- SETGLOBAL
                        local target = INSN_A(insn);
                        local key = get_constant(next_insn(), STRING_SUPPORTED);
                        set_global(key, get_register(target));
                    elseif op == 9 then -- GETUPVAL
                        local target = INSN_A(insn);
                        set_register(target, get_upvalue(INSN_B(insn)));
                    elseif op == 10 then -- SETUPVAL
                        local source = INSN_A(insn);
                        set_upvalue(INSN_B(insn), get_register(source));
                    elseif op == 11 then -- CLOSEUPVALS
                        close_upvalues(INSN_A(insn));
                    elseif op == 12 then -- GETIMPORT
                        local target = INSN_A(insn);
                        local import = get_constant(INSN_D(insn), IMPORT_SUPPORTED);
                        set_register(target, import);
                    elseif op == 13 then -- GETTABLE
                        local target = INSN_A(insn);
                        local tbl = get_register(INSN_B(insn));
                        local ket = get_register(INSN_C(insn));
                        set_register(target, tbl[ket]);
                    elseif op == 14 then -- SETTABLE
                        local source = INSN_A(insn);
                        local tbl = get_register(INSN_B(insn));
                        local key = get_register(INSN_C(insn));
                        tbl[key] = get_register(source);
                    elseif op == 15 then -- GETTABLEKS
                        local target = INSN_A(insn);
                        local tbl = get_register(INSN_B(insn));
                        local key = get_constant(next_insn(), STRING_SUPPORTED);
                        set_register(target, tbl[key]);
                    elseif op == 16 then -- SETTABLEKS
                        local source = INSN_A(insn);
                        local tbl = get_register(INSN_B(insn));
                        local key = get_constant(next_insn(), STRING_SUPPORTED);
                        tbl[key] = get_register(source);
                    elseif op == 17 then -- GETTABLEN
                        local target = INSN_A(insn);
                        local tbl = get_register(INSN_B(insn));
                        local key = INSN_C(insn) + 1;
                        set_register(target, tbl[key]);
                    elseif op == 18 then -- SETTABLEN
                        local source = INSN_A(insn);
                        local tbl = get_register(INSN_B(insn));
                        local key = INSN_C(insn) + 1;
                        tbl[key] = get_register(source);
                    elseif op == 19 then -- NEWCLOSURE
                        local target = INSN_A(insn);
                        local proto_ref = proto.child_protos[INSN_D(insn) + 1] or interpreter_error("no child proto");
                        local upvalues = {};

                        while true do
                            if pc == codesize then
                                break;
                            end

                            local insn = next_insn();
                            local op = INSN_OP(insn);
                            if op ~= 70 then
                                break;
                            end

                            local capture_type: UpvalType = CAPTURE_TYPES[INSN_A(insn)];
                            local id = INSN_B(insn);
                            local upvalue = create_upvalue(id, capture_type)
                            table.insert(upvalues, upvalue);
                        end

                        set_register(target, new_closure(proto_ref, upvalues));
                    elseif op == 20 then -- NAMECALL
                        local target = INSN_A(insn);
                        local source = get_register(INSN_B(insn));
                        local name = get_constant(next_insn(), STRING_SUPPORTED);

                        local method = source[name];
                        set_register(target, method);
                        set_register(target + 1, source);
                    elseif op == 21 then -- CALL
                        try_interrupt();

                        local ra = INSN_A(insn);
                        local target = get_register(ra);
                        local argument_count = INSN_B(insn) - 1;
                        local result_count = INSN_C(insn) - 1;
                        local args = get_registers(ra + 1, argument_count);
                        local results = { target(unpack(args)) };
                        set_registers(target + 1, result_count, results);
                    elseif op == 22 then -- RETURN
                        local start = INSN_A(insn);
                        local result_count = INSN_B(insn);
                        local results = get_registers(start, result_count);
                        return results;
                    elseif op == 23 then -- JUMP
                        local offset = INSN_D(insn);
                        jump(offset);
                    elseif op == 24 then -- JUMPBACK
                        try_interrupt();
                        local offset = INSN_D(insn);
                        jump(offset);
                    elseif op == 25 then -- JUMPIF
                        local value = get_register(INSN_A(insn));
                        local offset = INSN_D(insn);
                        if value then
                            jump(offset);
                        end
                    elseif op == 26 then -- JUMPIFNOT
                        local value = get_register(INSN_A(insn));
                        local offset = INSN_D(insn);
                        if not value then
                            jump(offset);
                        end
                    elseif op == 27 then -- JUMPIFEQ
                        local lhs = get_register(INSN_A(insn));
                        local rhs = get_register(next_insn());
                        local offset = INSN_D(insn);
                        if lhs == rhs then
                            jump(offset);
                        end
                    elseif op == 28 then -- JUMPIFLE
                        local lhs = get_register(INSN_A(insn));
                        local rhs = get_register(next_insn());
                        local offset = INSN_D(insn);
                        if lhs <= rhs then
                            jump(offset);
                        end
                    elseif op == 29 then -- JUMPIFLT
                        local lhs = get_register(INSN_A(insn));
                        local rhs = get_register(next_insn());
                        local offset = INSN_D(insn);
                        if lhs < rhs then
                            jump(offset);
                        end
                    elseif op == 30 then -- JUMPIFNOTEQ
                        local lhs = get_register(INSN_A(insn));
                        local rhs = get_register(next_insn());
                        local offset = INSN_D(insn);
                        if lhs ~= rhs then
                            jump(offset);
                        end
                    elseif op == 31 then -- JUMPIFNOTLE
                        local lhs = get_register(INSN_A(insn));
                        local rhs = get_register(next_insn());
                        local offset = INSN_D(insn);
                        if not (lhs <= rhs) then
                            jump(offset);
                        end
                    elseif op == 32 then -- JUMPIFNOTLT
                        local lhs = get_register(INSN_A(insn));
                        local rhs = get_register(next_insn());
                        local offset = INSN_D(insn);
                        if not (lhs < rhs) then
                            jump(offset);
                        end
                    elseif op == 33 then -- ADD
                        local target = INSN_A(insn);
                        local lhs = get_register(INSN_B(insn));
                        local rhs = get_register(INSN_C(insn));
                        set_register(target, lhs + rhs);
                    elseif op == 34 then -- SUB
                        local target = INSN_A(insn);
                        local lhs = get_register(INSN_B(insn));
                        local rhs = get_register(INSN_C(insn));
                        set_register(target, lhs - rhs);
                    elseif op == 35 then -- MUL
                        local target = INSN_A(insn);
                        local lhs = get_register(INSN_B(insn));
                        local rhs = get_register(INSN_C(insn));
                        set_register(target, lhs * rhs);
                    elseif op == 36 then -- DIV
                        local target = INSN_A(insn);
                        local lhs = get_register(INSN_B(insn));
                        local rhs = get_register(INSN_C(insn));
                        set_register(target, lhs / rhs);
                    elseif op == 37 then -- MOD
                        local target = INSN_A(insn);
                        local lhs = get_register(INSN_B(insn));
                        local rhs = get_register(INSN_C(insn));
                        set_register(target, lhs % rhs);
                    elseif op == 38 then -- POW
                        local target = INSN_A(insn);
                        local lhs = get_register(INSN_B(insn));
                        local rhs = get_register(INSN_C(insn));
                        set_register(target, lhs ^ rhs);
                    elseif op == 39 then -- ADDK
                        local target = INSN_A(insn);
                        local lhs = get_register(INSN_B(insn));
                        local rhs = get_constant(INSN_C(insn), NUMBER_SUPPORTED);
                        set_register(target, lhs + rhs);
                    elseif op == 40 then -- SUBK
                        local target = INSN_A(insn);
                        local lhs = get_register(INSN_B(insn));
                        local rhs = get_constant(INSN_C(insn), NUMBER_SUPPORTED);
                        set_register(target, lhs - rhs);
                    elseif op == 41 then -- MULK
                        local target = INSN_A(insn);
                        local lhs = get_register(INSN_B(insn));
                        local rhs = get_constant(INSN_C(insn), NUMBER_SUPPORTED);
                        set_register(target, lhs * rhs);
                    elseif op == 42 then -- DIVK
                        local target = INSN_A(insn);
                        local lhs = get_register(INSN_B(insn));
                        local rhs = get_constant(INSN_C(insn), NUMBER_SUPPORTED);
                        set_register(target, lhs / rhs);
                    elseif op == 43 then -- MODK
                        local target = INSN_A(insn);
                        local lhs = get_register(INSN_B(insn));
                        local rhs = get_constant(INSN_C(insn), NUMBER_SUPPORTED);
                        set_register(target, lhs % rhs);
                    elseif op == 44 then -- POWK
                        local target = INSN_A(insn);
                        local lhs = get_register(INSN_B(insn));
                        local rhs = get_constant(INSN_C(insn), NUMBER_SUPPORTED);
                        set_register(target, lhs ^ rhs);
                    elseif op == 45 then -- AND
                        local target = INSN_A(insn);
                        local lhs = get_register(INSN_B(insn));
                        local rhs = get_register(INSN_C(insn));
                        set_register(target, lhs and rhs);
                    elseif op == 46 then -- OR
                        local target = INSN_A(insn);
                        local lhs = get_register(INSN_B(insn));
                        local rhs = get_register(INSN_C(insn));
                        set_register(target, lhs or rhs);
                    elseif op == 47 then -- ANDK
                        local target = INSN_A(insn);
                        local lhs = get_register(INSN_B(insn));
                        local rhs = get_constant(INSN_C(insn), NUMBER_SUPPORTED);
                        set_register(target, lhs and rhs);
                    elseif op == 48 then -- ORK
                        local target = INSN_A(insn);
                        local lhs = get_register(INSN_B(insn));
                        local rhs = get_constant(INSN_C(insn), NUMBER_SUPPORTED);
                        set_register(target, lhs or rhs);
                    elseif op == 49 then -- CONCAT
                        local target = INSN_A(insn);
                        local source_start = INSN_B(insn);
                        local source_end = INSN_C(insn);
                        local count = source_end - source_start;
                        local values = get_registers(source_start, count);
                        set_register(target, table.concat(values, ""));
                    elseif op == 50 then -- NOT
                        local target = INSN_A(insn);
                        local value = get_register(INSN_B(insn));
                        set_register(target, not value);
                    elseif op == 51 then -- MINUS
                        local target = INSN_A(insn);
                        local value = get_register(INSN_B(insn));
                        set_register(target, -value);
                    elseif op == 52 then -- LENGTH
                        local target = INSN_A(insn);
                        local value = get_register(INSN_B(insn));
                        set_register(target, #value);
                    elseif op == 53 then -- NEWTABLE
                        local target = INSN_A(insn);
                        set_register(target, table.create(next_insn()));
                    elseif op == 54 then -- DUPTABLE
                        local target = INSN_A(insn);
                        local value = table.clone(get_constant(INSN_D(insn)));
                        set_register(target, value);
                    elseif op == 55 then -- SETLIST
                        local target = get_register(INSN_A(insn));
                        local source_start = INSN_B(insn);
                        local count = INSN_C(insn) - 1;
                        local index_start = next_insn();
                        local values = get_registers(source_start, count);

                        for i = 0, #values - 1 do
                            target[index_start + i] = values[i + 1];
                        end
                    elseif op == 56 then -- FORNPREP
                        local base = INSN_A(insn);
                        local offset = INSN_D(insn);
                        local limit = get_register(base);
                        local index = get_register(base + 2);

                        if index > limit then
                            jump(offset);
                        end

                        set_register(base + 3, index);
                    elseif op == 57 then -- FORNLOOP
                        try_interrupt();
                        local base = INSN_A(insn);
                        local offset = INSN_D(insn);
                        local index = get_register(base + 2) + get_register(base + 1);
                        set_register(base + 2, index);

                        local limit = get_register(base);
                        if not (index > limit) then
                            jump(offset);
                        end
                    elseif op == 58 then -- FORGLOOP
                        -- TODO
                    elseif op == 59 then -- FORGPREP_INEXT
                    elseif op == 60 then -- FASTCALL3
                    elseif op == 61 then -- FORGPREP_NEXT
                    elseif op == 62 then -- NATIVECALL
                    elseif op == 63 then -- GETVARARGS
                    elseif op == 64 then -- DUPCLOSURE
                    elseif op == 65 then -- PREPVARARGS
                        -- Skip
                    elseif op == 66 then -- LOADKX
                    elseif op == 67 then -- JUMPX
                    elseif op == 68 then -- FASTCALL
                    elseif op == 69 then -- COVERAGE
                    elseif op == 70 then -- CAPTURE
                        interpreter_error("unhandled CAPTURE instruction");
                    elseif op == 71 then -- SUBRK
                    elseif op == 72 then -- DIVRK
                    elseif op == 73 then -- FASTCALL1
                    elseif op == 74 then -- FASTCALL2
                    elseif op == 75 then -- FASTCALL2K
                    elseif op == 76 then -- FORGPREP
                    elseif op == 77 then -- JUMPXEQKNIL
                    elseif op == 78 then -- JUMPXEQKB
                    elseif op == 79 then -- JUMPXEQKN
                    elseif op == 80 then -- JUMPXEQKS
                    elseif op == 81 then -- IDIV
                    elseif op == 82 then -- IDIVK
                    else
                        interpreter_error(`unknown instruction {op}`);
                    end
                end

                return {};
            end, { ... });

            if ok then
                return unpack(args_or_err);
            else
                local err = args_or_err :: InterpreterError;
                
                if err.kind == "other" then
                    error(`{misc.display_chunk_name(debug_name)}:{err.line}: {err.message}`, 2);
                else
                    error(`interpreter error {misc.display_chunk_name(debug_name)}({err.line}/{err.pc}): {err.message}`);
                end
            end
        end

        closures[proto_ref] = closure;
        return closure;
    end

    return new_closure(chunk.main_proto);
end

return loadstring;
