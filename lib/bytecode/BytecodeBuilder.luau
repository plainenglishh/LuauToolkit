local common = require("../common");
local chunk = require("./chunk");
local constants = require("./constants");
local import_id = require("./import_id");
local instructions = require("./instructions");
local t = require("./types");

local byteparse = common.byteparse;

local ERR_UNSTARTED_FUNCTION = "this method can only be called when constructing a function";

local function reinterpret_unsigned(n: number, bitwidth: number): number
    if n < 0 then
        return n + 2^bitwidth;
    end

    return n;
end

export type BytecodeBuilder = setmetatable<BytecodeBuilderState, BytecodeBuilderMt>;

type WorkingProto = {
    ref: number,
    max_stack_size: number,
    num_params: number,
    num_upvalues: number,
    is_vararg: boolean,
    line_defined: number,
    debug_name: string?,
    flags: {t.ProtoFlag},
    constants: {t.Constant},
    child_protos: {number},
    instructions: typeof(byteparse.writer(nil :: any)),
    current_line: number,
    line_info: typeof(byteparse.writer(nil :: any)),
    type_info: t.ProtoTypeInfo?,
    debug_info: t.ProtoDebugInfo?,
    labels: {[string]: number},
};

type BytecodeBuilderMt = {
    __index: BytecodeBuilderImpl,
};

type BytecodeBuilderState = {
    _luau_version: number,
    _types_version: number,
    _strings: {string},
    _userdata_types: {number},
    _working_proto: WorkingProto?,
    _main: number,
    _protos: {t.Proto},
};

type BytecodeBuilderImpl = {
    --[=[
        Creates a new `BytecodeBuilder` instance.
    ]=]
    new: () -> BytecodeBuilder,

    --[=[
        Sets the bytecode version number.
    ]=]
    set_luau_version: (self: BytecodeBuilder, version: number) -> (),
    set_types_version: (self: BytecodeBuilder, version: number) -> (),

    get_string: (self: BytecodeBuilder, ref: number) -> string?,

    --[=[
        Adds a string to the chunk string table.
    ]=]
    add_string: (self: BytecodeBuilder, value: string | buffer, force: boolean?) -> number,
    
    --[=[
        Adds a new userdata type.

        Returns the `type` number.
    ]=]
    add_userdata_type: (self: BytecodeBuilder, type_name: string) -> number,
    
    --[=[
        Sets the main function to the given index, or the current function if no
        ref is provided.
    ]=]
    set_main: (self: BytecodeBuilder, proto_ref: number?) -> (),

    --[=[
        Begins a function.
    ]=]
    begin_function: (self: BytecodeBuilder) -> number,

    set_stack_size: (self: BytecodeBuilder, size: number) -> (),
    increment_stack_size: (self: BytecodeBuilder, by: number?) -> (),
    set_num_params: (self: BytecodeBuilder, count: number) -> (),
    set_num_upvalues: (self: BytecodeBuilder, count: number) -> (),
    set_vararg: (self: BytecodeBuilder, vararg: boolean) -> (),

    emit_abc: (self: BytecodeBuilder, op: number | t.InstructionName, a: number?, b: number?, c: number?, aux: number?) -> (),
    emit_ad: (self: BytecodeBuilder, op: number | t.InstructionName, a: number?, d: number?, aux: number?) -> (),
    emit_e: (self: BytecodeBuilder, op: number | t.InstructionName, e: number?, aux: number?) -> (),
    emit_instruction: (self: BytecodeBuilder, insn: t.Instruction) -> (),

    get_constant: (self: BytecodeBuilder, ref: number) -> t.Constant?,
    add_constant: (self: BytecodeBuilder, constant: t.Constant, force: boolean?) -> number,
    add_constant_nil: (self: BytecodeBuilder, force: boolean?) -> number,
    add_constant_boolean: (self: BytecodeBuilder, value: boolean, force: boolean?) -> number,
    add_constant_number: (self: BytecodeBuilder, value: number, force: boolean?) -> number,
    add_constant_string: (self: BytecodeBuilder, value: string | number, force: boolean?) -> number,
    add_constant_import: (self: BytecodeBuilder, value: {string}, force: boolean?) -> (number, number),
    add_constant_table: (self: BytecodeBuilder, value: {number}, force: boolean?) -> number,
    add_constant_closure: (self: BytecodeBuilder, value: number, force: boolean?) -> number,
    add_constant_vector: (self: BytecodeBuilder, value: {number}, force: boolean?) -> number,

    set_line: (self: BytecodeBuilder, line: number) -> (),
    increment_line: (self: BytecodeBuilder, by: number?) -> (),

    set_function_name: (self: BytecodeBuilder, name: string) -> (),
    set_local_name: (self: BytecodeBuilder, name: string, register: number, start_pc: number, end_pc: number) -> (),
    set_upvalue_name: (self: BytecodeBuilder, name: string, id: number) -> (),

    set_function_type: (self: BytecodeBuilder, type: string) -> (),
    set_local_type: (self: BytecodeBuilder, type: number, register: number, start_pc: number, end_pc: number) -> (),
    set_upvalue_type: (self: BytecodeBuilder, type: number, id: number) -> (),
    
    --[=[
        Closes a function.
    ]=]
    end_function: (self: BytecodeBuilder) -> number,

    to_chunk: (self: BytecodeBuilder) -> t.Chunk,
    to_bytecode: (self: BytecodeBuilder) -> buffer,
};


local BytecodeBuilderMt = {};
local BytecodeBuilder = {};

BytecodeBuilderMt.__index = BytecodeBuilder;

function BytecodeBuilder.new(): BytecodeBuilder
    return setmetatable({
        _luau_version = constants.SUPPORTED_VERSIONS.target,
        _types_version = 1,
        _strings = {},
        _userdata_types = {},
        _working_proto = nil :: WorkingProto?,
        _main = -1,
        _protos = {},
    }, BytecodeBuilderMt);
end

function BytecodeBuilder.set_luau_version(self: BytecodeBuilder, version: number)
    self._luau_version = version;
end

function BytecodeBuilder.set_types_version(self: BytecodeBuilder, version: number)
    self._types_version = version;
end

function BytecodeBuilder.get_string(self: BytecodeBuilder, ref: number): string?
    return self._strings[ref];
end

function BytecodeBuilder.add_string(self: BytecodeBuilder, value: string | buffer, force: boolean?): number
    if force then
        local idx = table.find(self._strings, value);
        if idx then
            return idx;
        end
    end

    local idx = #self._strings + 1;
    self._strings[idx] = if type(value) == "string" then value else buffer.tostring(value);
    return idx;
end

function BytecodeBuilder.add_userdata_type(self: BytecodeBuilder, name: string): number
    local idx = #self._userdata_types;
    if idx > 32 then
        error("too many userdata types", 2);    
    end

    self._userdata_types[idx] = self:add_string(name);
    return 64 + idx;
end

function BytecodeBuilder.set_main(self: BytecodeBuilder, ref: number?)
    if ref then
        self._main = ref;
    end

    if not self._working_proto then
        error(ERR_UNSTARTED_FUNCTION, 2); 
    end

    self._main = self._working_proto.ref;
end

function BytecodeBuilder.begin_function(self: BytecodeBuilder): number
    local ref = #self._protos;
    
    self._working_proto = {
        ref = ref,
        max_stack_size = 0,
        num_params = 0,
        num_upvalues = 0,
        is_vararg = false,
        line_defined = 0,
        debug_name = nil,
        flags = {},
        constants = {},
        child_protos = {},
        instructions = byteparse.writer(1024),
        current_line = 0,
        line_info = byteparse.writer(1024),
        labels = {},
    };

    return ref;
end

function BytecodeBuilder.set_stack_size(self: BytecodeBuilder, size: number)
    if not self._working_proto then
        error(ERR_UNSTARTED_FUNCTION, 2);
    end

    self._working_proto.max_stack_size = size;
end

function BytecodeBuilder.increment_stack_size(self: BytecodeBuilder, by: number?)
    if not self._working_proto then
        error(ERR_UNSTARTED_FUNCTION, 2);
    end

    self._working_proto.max_stack_size += by or 1;
end

function BytecodeBuilder.set_num_params(self: BytecodeBuilder, count: number)
    if not self._working_proto then
        error(ERR_UNSTARTED_FUNCTION, 2);
    end

    self._working_proto.num_params = count;
end

function BytecodeBuilder.set_num_upvalues(self: BytecodeBuilder, count: number)
    if not self._working_proto then
        error(ERR_UNSTARTED_FUNCTION, 2);
    end

    self._working_proto.num_upvalues = count;
end

function BytecodeBuilder.set_vararg(self: BytecodeBuilder, vararg: boolean)
    if not self._working_proto then
        error(ERR_UNSTARTED_FUNCTION, 2);
    end

    self._working_proto.is_vararg = vararg;
end

function BytecodeBuilder.emit_abc(self: BytecodeBuilder, op: number | t.InstructionName, a: number?, b: number?, c: number?, aux: number?)
    if not self._working_proto then
        error(ERR_UNSTARTED_FUNCTION, 2);
    end

    local op = if type(op) == "number" then op else (instructions.get_metadata(op) or error(`unknown instruction {op}`)).opcode;
    
    local meta = instructions.metadata[op];
    if meta then
        if aux == nil and meta.aux then
            aux = 0;
        elseif aux ~= nil and not meta.aux then
            error(`{meta.name} doesn't accept an aux instruction`, 2);
        end

        if meta.mode ~= "abc" then
            error(`{meta.name} uses argument mode {meta.mode}`, 2);
        end
    end

    local raw = op;
    raw = bit32.replace(raw, a or 0, 8, 8);
    raw = bit32.replace(raw, b or 0, 16, 8);
    raw = bit32.replace(raw, c or 0, 24, 8);

    self._working_proto.instructions.write_u32(raw);
    self._working_proto.line_info.write_u32(self._working_proto.current_line);

    if aux then
        self._working_proto.instructions.write_u32(aux);
        self._working_proto.line_info.write_u32(self._working_proto.current_line);
    end
end

function BytecodeBuilder.emit_ad(self: BytecodeBuilder, op: number | t.InstructionName, a: number?, d: number?, aux: number?)
    if not self._working_proto then
        error(ERR_UNSTARTED_FUNCTION, 2);
    end

    local op = if type(op) == "number" then op else (instructions.get_metadata(op) or error(`unknown instruction {op}`)).opcode;

    local meta = instructions.metadata[op];
    if meta then
        if aux == nil and meta.aux then
            aux = 0;
        elseif aux ~= nil and not meta.aux then
            error(`{meta.name} doesn't accept an aux instruction`, 2);
        end

        if meta.mode ~= "ad" then
            error(`{meta.name} uses argument mode {meta.mode}`, 2);
        end
    end

    local raw = op;
    raw = bit32.replace(raw, a or 0, 8, 8);
    raw = bit32.replace(raw, reinterpret_unsigned(d or 0, 16), 16, 16);

    self._working_proto.instructions.write_u32(raw);
    self._working_proto.line_info.write_u32(self._working_proto.current_line);
    
    if aux then
        self._working_proto.instructions.write_u32(aux);
        self._working_proto.line_info.write_u32(self._working_proto.current_line);
    end
end

function BytecodeBuilder.emit_e(self: BytecodeBuilder, op: number | t.InstructionName, e: number?, aux: number?)
    if not self._working_proto then
        error(ERR_UNSTARTED_FUNCTION, 2);
    end
    
    local op = if type(op) == "number" then op else (instructions.get_metadata(op) or error(`unknown instruction {op}`)).opcode;

    local meta = instructions.metadata[op];
    if meta then
        if aux == nil and meta.aux then
            aux = 0;
        elseif aux ~= nil and not meta.aux then
            error(`{meta.name} doesn't accept an aux instruction`, 2);
        end

        if meta.mode ~= "e" then
            error(`{meta.name} uses argument mode {meta.mode}`, 2);
        end
    end

    local raw = op;
    raw = bit32.replace(raw, reinterpret_unsigned(e or 0, 24), 8, 24);

    self._working_proto.instructions.write_u32(raw);
    self._working_proto.line_info.write_u32(self._working_proto.current_line);

    if aux then
        self._working_proto.instructions.write_u32(aux);
        self._working_proto.line_info.write_u32(self._working_proto.current_line);
    end
end

function BytecodeBuilder.emit_instruction(self: BytecodeBuilder, insn: t.Instruction)
    if not self._working_proto then
        error(ERR_UNSTARTED_FUNCTION, 2);
    end

    local insn, aux = instructions.encode_instruction(insn);
    
    self._working_proto.instructions.write_u32(insn);
    if aux then
        self._working_proto.instructions.write_u32(aux);
    end
end

function BytecodeBuilder.get_constant(self: BytecodeBuilder, ref: number): t.Constant?
    if not self._working_proto then
        error(ERR_UNSTARTED_FUNCTION, 2);
    end

    return self._working_proto.constants[ref + 1];
end

function BytecodeBuilder.add_constant(self: BytecodeBuilder, constant: t.Constant, force: boolean?): number
    if not self._working_proto then
        error(ERR_UNSTARTED_FUNCTION, 2);
    end

    if not force then
        for i, v in self._working_proto.constants do
            if v.type == constant.type and v.value == constant.value then
                return i - 1;
            end
        end
    end

    local idx = #self._working_proto.constants + 1;
    self._working_proto.constants[idx] = constant;
    return idx - 1;
end

function BytecodeBuilder.add_constant_nil(self: BytecodeBuilder, force: boolean?): number
    return self:add_constant({
        type = "nil",
        value = nil,
    }, force);
end

function BytecodeBuilder.add_constant_boolean(self: BytecodeBuilder, value: boolean, force: boolean?): number
    return self:add_constant({
        type = "boolean",
        value = value,
    }, force);
end

function BytecodeBuilder.add_constant_number(self: BytecodeBuilder, value: number, force: boolean?): number
    return self:add_constant({
        type = "number",
        value = value,
    }, force);
end

function BytecodeBuilder.add_constant_string(self: BytecodeBuilder, value: string | number, force: boolean?): number
    return self:add_constant({
        type = "string",
        value = if type(value) == "number" then value else self:add_string(value, force),
    }, force);
end

function BytecodeBuilder.add_constant_import(self: BytecodeBuilder, value: {string}, force: boolean?): (number, number)
    if #value < 1 or #value > 3 then
        error("path must be within 1..3 components", 2);        
    end

    local parts = {};
    for i, v in value do 
        parts[i] = self:add_constant_string(v, force);
    end
    local import_id = import_id.encode(parts);

    return self:add_constant({
        type = "import",
        value = import_id,
    }, force), import_id;
end

function BytecodeBuilder.add_constant_table(self: BytecodeBuilder, value: {number}, force: boolean?): number
    return self:add_constant({
        type = "table",
        value = value,
    }, force);
end

function BytecodeBuilder.add_constant_closure(self: BytecodeBuilder, value: number, force: boolean?): number
    return self:add_constant({
        type = "closure",
        value = value,
    }, force);
end

function BytecodeBuilder.add_constant_vector(self: BytecodeBuilder, value: {number}, force: boolean?): number
    return self:add_constant({
        type = "vector",
        value = value,
    }, force);
end

function BytecodeBuilder.set_line(self: BytecodeBuilder, line: number)
    if not self._working_proto then
        error(ERR_UNSTARTED_FUNCTION, 2);
    end
    
    if line < self._working_proto.current_line then
        error("line must increment", 2);
    end

    self._working_proto.current_line = line;
end

function BytecodeBuilder.increment_line(self: BytecodeBuilder, by: number?)
    if not self._working_proto then
        error(ERR_UNSTARTED_FUNCTION, 2);
    end
    
    self._working_proto.current_line += by or 1;
end

function BytecodeBuilder.set_function_name(self: BytecodeBuilder, name: string)
    if not self._working_proto then
        error(ERR_UNSTARTED_FUNCTION, 2);
    end

    self._working_proto.debug_name = name;
end

function BytecodeBuilder.set_local_name(self: BytecodeBuilder, name: string, register: number, start_pc: number, end_pc: number)
    if not self._working_proto then
        error(ERR_UNSTARTED_FUNCTION, 2);
    end

    local debug_info: t.ProtoDebugInfo = self._working_proto.debug_info or {
        locals = {},
        upvalues = {},
    };
    self._working_proto.debug_info = debug_info;

    table.insert(debug_info.locals, {
        name = self:add_string(name),
        start_pc = start_pc,
        end_pc = end_pc,
        register = register
    });
end

function BytecodeBuilder.set_upvalue_name(self: BytecodeBuilder, name: string, id: number)
    if not self._working_proto then
        error(ERR_UNSTARTED_FUNCTION, 2);
    end

    local debug_info: t.ProtoDebugInfo = self._working_proto.debug_info or {
        locals = {},
        upvalues = {},
    };
    self._working_proto.debug_info = debug_info;

    debug_info.upvalues[id] = {
        name = self:add_string(name),
    };
end

function BytecodeBuilder.set_function_type(self: BytecodeBuilder, type: string)
    if not self._working_proto then
        error(ERR_UNSTARTED_FUNCTION, 2);
    end

    local type_info: t.ProtoTypeInfo = self._working_proto.type_info or {
        func = "any",
        locals = {},
        upvalues = {},
    };
    self._working_proto.type_info = type_info;

    type_info.func = type;
end

function BytecodeBuilder.set_local_type(self: BytecodeBuilder, type: number, register: number, start_pc: number, end_pc: number)
    if not self._working_proto then
        error(ERR_UNSTARTED_FUNCTION, 2);
    end

    local type_info: t.ProtoTypeInfo = self._working_proto.type_info or {
        func = "any",
        locals = {},
        upvalues = {},
    };
    self._working_proto.type_info = type_info;

    table.insert(type_info.locals, {
        type = type,
        start_pc = start_pc,
        length = end_pc - start_pc,
        register = register
    });
end

function BytecodeBuilder.set_upvalue_type(self: BytecodeBuilder, type: number, id: number)
    if not self._working_proto then
        error(ERR_UNSTARTED_FUNCTION, 2);
    end

    local type_info: t.ProtoTypeInfo = self._working_proto.type_info or {
        func = "any",
        locals = {},
        upvalues = {},
    };
    self._working_proto.type_info = type_info;

    type_info.upvalues[id] = type;
end

function BytecodeBuilder.end_function(self: BytecodeBuilder): number
    if not self._working_proto then
        error(ERR_UNSTARTED_FUNCTION, 2);
    end

    local working_proto = self._working_proto;
    self._working_proto = nil;

    -- TODO! assert upvalue debug info is contiguous!

    local proto: t.Proto = {
        max_stack_size = working_proto.max_stack_size,
        num_params = working_proto.num_params,
        num_upvalues = working_proto.num_upvalues,
        is_vararg = working_proto.is_vararg,
        flags = working_proto.flags,
        types = working_proto.type_info,
        instructions = working_proto.instructions.to_buffer(),
        constants = working_proto.constants,
        child_protos = working_proto.child_protos,
        line_defined = working_proto.line_defined,
        debug_name = if working_proto.debug_name then self:add_string(working_proto.debug_name) else 0,
        line_info = if working_proto.current_line ~= 0 then working_proto.line_info.to_buffer() else nil,
        debug_info = working_proto.debug_info,
    };

    table.insert(self._protos, proto);
    return working_proto.ref;
end

function BytecodeBuilder.to_chunk(self: BytecodeBuilder): t.Chunk
    if self._working_proto then
        error("unfinished function", 2);
    end

    if self._main == -1 then
        error("no main function set", 2); 
    end

    return {
        luau_version = self._luau_version,
        types_version = self._types_version,
        strings = self._strings,
        userdata_types = self._userdata_types,
        protos = self._protos,
        main_proto = self._main,
    };
end

function BytecodeBuilder.to_bytecode(self: BytecodeBuilder): buffer
    return chunk.encode(self:to_chunk());
end

return BytecodeBuilder;
