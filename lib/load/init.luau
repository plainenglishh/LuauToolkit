local bytecode = require("./bytecode");
local common = require("./common");

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
    local d = bit32.extract(insn, 16, 16);

    if d >= 2^(16-1) then
        return d - 2^16;
    end

    return d;
end

function INSN_E(insn: number): number
    local e = bit32.extract(insn, 8, 24);

    if e >= 2^(24-1) then
        return e - 2^24;
    end

    return e;
end

local function PATCH_INSN_E(insn: number, e: number): number
    if e < 0 then
        e = e + 2^24;
    end

    local raw = insn;
    raw = bit32.replace(raw, e, 8, 24);
    return raw;
end

local VM_ERROR = {
    INVALID_MAIN = "invalid main proto",
    NONEXISTENT_CONSTANT = "nonexistent constant",
};

export type LoadedClosure = (...any) -> (...any)
type Env = {[any]: any};

type CreateVector4 = (number, number, number, number) -> vector;
local create_vector_4 = vector.create :: CreateVector4;

local default_env: Env = table.freeze(table.clone(common.stdlib :: {[any]: any})); -- This can be reused across scripts.

local function get_import(env: Env, constants: {any}, id: number): any
    local current: any = env;
    
    for i, v in bytecode.import_id.decode(id) do
        local idx: string = constants[v + 1] or error(VM_ERROR.NONEXISTENT_CONSTANT);
        current = current[idx];
        if current == nil then
            return nil;    
        end
    end

    return current;
end

type Upvalue = {
    type: "VAL",
    value: any,
} | {
    type: "REF",
    registers: {any},
    register: number,
} | {
    type: "UPVAL",
    upvalue: Upvalue,
};

local function resolve_upvalue(upvalue: Upvalue): Upvalue
    if upvalue.type ~= "UPVAL" then
        return upvalue;
    else
        return resolve_upvalue(upvalue);
    end
end

local function close_upvalue(upvalue: Upvalue)
    if upvalue.type ~= "REF" then
        return; -- Non REF don't need closing.
    end

    local value = upvalue.registers[upvalue.register + 1];
    upvalue.register = 0;
    upvalue.registers = { value };
end

local function load_error(fmt: string, ...: any): never
    error("load_error: "..(string.format :: any)(fmt, ...), 2);
end

local function load(bc: buffer | string, debug_name: string?, env: Env?): LoadedClosure
    local debug_name = debug_name or "=load";
    local env = env or default_env;

    local safe_env = table.isfrozen(env);
    
    local chunk = bytecode.chunk.decode(bc);
    local protos = chunk.protos;
    local strings = chunk.strings;

    local function new_closure(proto: bytecode.Proto, upvalues: {Upvalue}?): LoadedClosure
        local upvalues: {Upvalue} = upvalues or {};

        local constants = table.create(#proto.constants, nil :: any);

        for i, const in proto.constants do
            if const.type == "nil" then
            elseif const.type == "boolean" or const.type == "number" then
                constants[i] = const.value;
            elseif const.type == "string" then
                constants[i] = strings[const.value] or load_error(`attempt to get nonexistent string {const.value} for constant {i - 1}`);
            elseif const.type == "vector" then
                if common.VECTOR_SIZE == 3 then
                    constants[i] = vector.create(const.value[1], const.value[2], const.value[3]);
                elseif common.VECTOR_SIZE == 4 then
                    constants[i] = create_vector_4(const.value[1], const.value[2], const.value[3], const.value[4]);
                end
            elseif const.type == "table" then
                -- no point
            elseif const.type == "import" then
                constants[i] = get_import(env, constants, const.value);
            elseif const.type == "closure" then
                -- do nothing, treat dupclosure as newclosure for now
            end
        end
        
        table.freeze(constants);

        local dbg_pc = 0;

        local function loaded_closure(...: any): ...any
            local registers = table.create(255, nil :: any);
            local pc = 0;
            local top = 0;

            local code = proto.instructions;
            local code_size = buffer.len(code);

            local function vm_error(fmt: string, ...: any): never
                local insn = buffer.readu32(code, dbg_pc);
                local next_insn = if dbg_pc == code_size then nil else buffer.readu32(code, dbg_pc + 1);
                local prefix = string.format("vm_error(pc=%i, insn=0x%.8X, op=%i, dbg=%q): ", dbg_pc, insn, INSN_OP(insn), bytecode.instructions.display(insn, next_insn));
                local body = (string.format :: any)(fmt, ...);
                error(prefix..body, 2);
            end

            local function read_insn(): number
                local insn = buffer.readu32(code, pc);
                pc += 1;
                return insn;
            end

            local function get_register(reg: number): any
                return registers[reg + 1];
            end

            local function set_register(reg: number, value: any)
                registers[reg + 1] = value;
            end

            local function get_registers(base_reg: number): {any}
                local values = {};
                table.move(registers, base_reg + 1, top, 1, values);
                return values;
            end

            local function set_registers(base_reg: number, values: {any}, count: number?)
                local count = count or #values;
                table.move(values, 1, count, base_reg + 1, registers);
                top = base_reg + 1 + count;
            end

            local function get_constant(id: number): any
                return constants[id + 1] or vm_error(`attept to get nonexistent constant {id}`);
            end

            local function get_upvalue(id: number): any
                local upvalue: Upvalue = upvalues[id + 1] or vm_error(`attempt to get nonexistent upvalue {id}`);
                upvalue = resolve_upvalue(upvalue);
                
                if upvalue.type == "REF" then
                    return upvalue.registers[upvalue.register + 1];
                elseif upvalue.type == "VAL" then
                    return upvalue.value;
                else
                    error("unreachable");
                end
            end

            local function set_upvalue(id: number, value: any)
                local upvalue: Upvalue = upvalues[id + 1] or vm_error(`attempt to set nonexistent upvalue {id}`);
                upvalue = resolve_upvalue(upvalue);
                
                if upvalue.type == "REF" then
                    upvalue.registers[upvalue.register + 1] = value;
                elseif upvalue.type == "VAL" then
                    upvalue.value = value;
                else
                    error("unreachable");
                end
            end

            while pc < code_size do 
                dbg_pc = pc;

                local insn = read_insn();
                local op = INSN_OP(insn);

                if op == 0 then
                else
                    vm_error("illegal instruction");
                end
            end
        end

        return function(...: any): ...any
            local results: {any} = {pcall(loaded_closure, ...)};
            local ok = table.remove(results, 1);
            if ok then
                return unpack(results);
            end

            local message = tostring(table.remove(results, 1));
            local stripped_message = common.strip_where(message);
            if string.sub(stripped_message, 1, 8) == "vm_error" or string.sub(stripped_message, 1, 10) == "load_error" then
                error(message, 0);
            end

            local line = "";
            if proto.line_info then
                line = `:{buffer.readu32(proto.line_info, dbg_pc)}`;
            end

            error(`{common.display_chunk_name(debug_name)}{line}: {stripped_message}`, 0);
        end;
    end

    local main_proto = chunk.protos[chunk.main_proto + 1] or error(VM_ERROR.INVALID_MAIN);

    return new_closure(main_proto, {});
end

return load;
