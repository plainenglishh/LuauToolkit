local byteparse = require("../byteparse");
local constants = require("../constants");
local t = require("../types");

--[=[
    Decodes a bytecode chunk into a `Chunk` object.

    NOTE: This function intentionally does **not** check for validity. 
          Run `bytecode.chunk.validate` beforehand if this is desired.
]=]
local function decode(bytecode: t.bstring): t.Chunk
    local bytecode = if type(bytecode) == "string" then buffer.fromstring(bytecode) else bytecode;
    local reader = byteparse.reader(bytecode);

    local function read_constant(): t.Constant
        local constant_type = reader.read_u8();
        local constant_type_name = constants.constant_types[constant_type];

        local constant: t.Constant = {
            type = constant_type_name :: any,
            value = nil,
        };

        if constant_type_name == "nil" then
            constant.value = nil;
        elseif constant_type_name == "boolean" then
            constant.value = reader.read_bool();    
        elseif constant_type_name == "number" then
            constant.value = reader.read_f64();
        elseif constant_type_name == "string" then
            constant.value = reader.read_varint();
        elseif constant_type_name == "import" then
            constant.value = reader.read_u32();
        elseif constant_type_name == "table" then
            local length = reader.read_varint();
            local tbl = table.create(length);

            for i = 1, length do
                tbl[i] = reader.read_varint();
            end

            constant.value = tbl;
        elseif constant_type_name == "closure" then
            constant.value = reader.read_varint();
        elseif constant_type_name == "vector" then
            constant.value = { reader.read_f32(), reader.read_f32(), reader.read_f32(), reader.read_f32() };
        end

        return constant;
    end

    local function read_debug_info(): t.ProtoDebugInfo
        local debug_info = {};

        debug_info.locals = reader.read_larray(function()
            return {
                name = reader.read_varint(),
                start_pc = reader.read_varint(),
                end_pc = reader.read_varint(),
                register = reader.read_u8(),
            };
        end);

        debug_info.upvalues = reader.read_larray(function()
            return {
                name = reader.read_varint(),
            };
        end);

        return debug_info;
    end

    local function read_line_info(instruction_count: number): buffer
        local logspan = reader.read_u8();
        local interval_count = bit32.rshift(instruction_count - 1, logspan) + 1;
        
        local deltas = table.create(instruction_count);
        local intervals = table.create(interval_count);

        local last_delta = 0;
        for i = 1, instruction_count do
            last_delta = (last_delta + reader.read_u8()) % 256;
            deltas[i] = last_delta;
        end

        local last_interval = 0;
        for i = 1, interval_count do
            last_interval += reader.read_u32();
            intervals[i] = last_interval % (2 ^ 32);
        end

        local line_info = buffer.create(instruction_count * 4);
        for i = 0, instruction_count - 1 do
            local line = intervals[(i // 2^logspan) + 1] + deltas[i + 1];
            buffer.writeu32(line_info, i * 4, line);
        end

        return line_info;
    end

    --[=[
        Reads a bytecode proto and returns the internal table representation.
    ]=]
    local function read_proto(): t.Proto
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
            local types = {} :: t.ProtoTypeInfo;

            local function_length = reader.read_varint();
            local upvalue_count = reader.read_varint();
            local local_count = reader.read_varint();
        
            types.func = reader.read_string(function_length);
        
            local upvalues = {};

            for i = 1, upvalue_count do
                upvalues[i] = reader.read_u8();
            end

            types.upvalues = upvalues;

            local locals = {};

            for i = 1, local_count do
                locals[i] = {
                    type = reader.read_u8(),
                    register = reader.read_u8(),
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
        proto.child_protos = reader.read_larray(reader.read_varint);
        proto.line_defined = reader.read_varint();
        proto.debug_name = reader.read_varint();
        proto.line_info = reader.read_optional(read_line_info, instruction_count);
        proto.debug_info = reader.read_optional(read_debug_info);

        return proto;
    end

    --[=[
        Reads a bytecode chuck and returns the internal table representation.
    ]=]
    local function read_chunk(): t.Chunk
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