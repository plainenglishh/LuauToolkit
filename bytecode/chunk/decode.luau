--[[
    This file contains the function used to decode a bytecode chunk.
]]

local byteparse = require("../byteparse");
local constants = require("../constants");
local t = require("../types");

--[=[
    Decodes a bytecode chunk into a `BytecodeChunk` object.

    NOTE: This function intentionally does **not** check for validity. 
          Run `bytecode.chunk.validate` beforehand if this is desired.
]=]
local function decode(bc: t.bstring): t.BytecodeChunk
    local bc = if type(bc) == "string" then buffer.fromstring(bc) else bc;
    local reader = byteparse.reader(bc);

    local function read_constant(): t.BytecodeConstant
        local ktype_id = reader.read_u8();
        local ktype = constants.constant_types[ktype_id];

        local constant: t.BytecodeConstant = {
            type = ktype :: any,
            value = nil,
        };

        if ktype == "nil" then
            constant.value = nil;
        elseif ktype == "boolean" then
            constant.value = reader.read_bool();    
        elseif ktype == "number" then
            constant.value = reader.read_f64();
        elseif ktype == "string" then
            constant.value = reader.read_varint();
        elseif ktype == "import" then
            constant.value = reader.read_u32();
        elseif ktype == "table" then
            local length = reader.read_varint();
            local tbl = table.create(length);

            for i = 1, length do
                tbl[i] = reader.read_varint();
            end

            constant.value = tbl;
        elseif ktype == "closure" then
            constant.value = reader.read_varint();
        elseif ktype == "vector" then
            constant.value = { reader.read_f32(), reader.read_f32(), reader.read_f32(), reader.read_f32() };
        end

        return constant;
    end

    local function read_debug_info(): t.BytecodeProtoDebugInfo
        local debug_info = {};

        debug_info.locals = {};
        local locals_count = reader.read_varint();
        for i = 1, locals_count do
            debug_info.locals[i] = {
                name = reader.read_varint(),
                start_pc = reader.read_varint(),
                end_pc = reader.read_varint(),
                reg = reader.read_u8(),
            };
        end

        debug_info.upvalues = {};
        local upvalue_count = reader.read_varint();
        for i = 1, upvalue_count do
            debug_info.upvalues[i] = {
                name = reader.read_varint(),
            };
        end

        return debug_info;
    end

    local function read_line_info(instructions_count: number): buffer
        --- Borrowed from fiu's implementation
        local cursor_start = reader.get_cursor();

        local linegaplog2 = reader.read_u8();

        local intervals = bit32.rshift((instructions_count - 1), linegaplog2) + 1

        local lineinfo = table.create(instructions_count)
        local abslineinfo = table.create(intervals)

        local lastoffset = 0
        for j = 1, instructions_count do
            lastoffset += reader.read_u8();
            lineinfo[j] = lastoffset
        end

        local lastline = 0
        for j = 1, intervals do
            lastline += reader.read_u32();
            abslineinfo[j] = lastline % (2 ^ 32)
        end

        local instructionlineinfo = table.create(instructions_count)

        for i = 1, instructions_count do 
            table.insert(instructionlineinfo, abslineinfo[bit32.rshift(i - 1, linegaplog2) + 1] + lineinfo[i])
        end

        local cursor_end = reader.get_cursor();

        local out = buffer.create(cursor_end - cursor_start);
        buffer.copy(out, 0, bc, cursor_start, cursor_end - cursor_start);

        return out;
    end

    --[=[
        Reads a bytecode proto and returns the internal table representation.
    ]=]
    local function read_proto(): t.BytecodeProto
        local proto = {};

        proto.max_stack_size = reader.read_u8();
        proto.num_params = reader.read_u8();
        proto.num_upvalues = reader.read_u8();
        proto.is_vararg = reader.read_bool();
        proto.flags = {} :: any;

        local raw_flags = reader.read_u8();

        for flag, offset: unknown in constants.proto_flag do
            if bit32.extract(raw_flags, offset :: number) == 1 then
                table.insert(proto.flags, flag);
            end
        end

        local types_size = reader.read_varint();
        if types_size > 0 then
            local types = {} :: t.BytecodeProtoTypeInfo;

            local func_type_size = reader.read_varint();
            local upvals_type_size = reader.read_varint();
            local locals_type_size = reader.read_varint();
        
            types.func = reader.read_string(func_type_size);
        
            local upvalues = {};

            for i = 1, upvals_type_size do
                upvalues[i] = reader.read_u8();
            end

            types.upvalues = upvalues;

            local locals = {};

            for i = 1, locals_type_size do
                locals[i] = {
                    type = reader.read_u8(),
                    reg = reader.read_u8(),
                    start_pc = reader.read_varint(),
                    length = reader.read_varint(),
                };
            end

            types.locals = locals;

            proto.types = types;
        end

        local instruction_count = reader.read_varint();
        proto.instructions = reader.read_buffer(instruction_count * 4);
        proto.constants = reader.read_larray(read_constant);
        proto.protos = reader.read_larray(reader.read_varint);
        proto.line_defined = reader.read_varint();
        proto.debug_name = reader.read_varint();
        proto.line_info = reader.read_optional(read_line_info, instruction_count);
        proto.debug_info = reader.read_optional(read_debug_info);

        return proto;
    end

    --[=[
        Reads a bytecode chuck and returns the internal table representation.
    ]=]
    local function read_chunk(): t.BytecodeChunk
        local chunk = {};

        chunk.luau_version = reader.read_u8();
        if chunk.luau_version == 0 then
            error("provided bytecode chunk is invalid");
        end

        chunk.types_version = reader.read_u8();
        chunk.strings = reader.read_larray(reader.read_lstring);
        
        if chunk.types_version == 3 then
            chunk.userdata_types = {};
            while true do
                local i = reader.read_u8();
                if i == 0 then
                    break;
                end
                
                local name_ref = reader.read_varint();
                chunk.userdata_types[i] = name_ref;
            end
        end
        
        chunk.protos = reader.read_larray(read_proto);
        chunk.main_proto = reader.read_varint();

        return chunk;
    end

    return read_chunk();
end

return decode;