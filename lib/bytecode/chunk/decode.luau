--!native

local common = require("@luau_toolkit/common");
local constants = require("../constants");
local t = require("../types");

local byteparse = common.byteparse;

--[=[
    Decodes a bytecode chunk into a `Chunk` object.

    NOTE: This function intentionally does **not** check for validity. 
          Run `bytecode.chunk.validate` beforehand if this is desired.
]=]
local function decode(bc: t.bstring): t.Chunk
    local bytecode = if type(bc) == "string" then buffer.fromstring(bc) else bc;
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
            local tbl = table.create(length, 0);

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
        local locals = reader.read_larray(function()
            return {
                name = reader.read_varint(),
                start_pc = reader.read_varint(),
                end_pc = reader.read_varint(),
                register = reader.read_u8(),
            };
        end);

        local upvalues = reader.read_larray(function()
            return {
                name = reader.read_varint(),
            };
        end);

        return {
            locals = locals,
            upvalues = upvalues,
        };
    end

    local function read_line_info(instruction_count: number): buffer
        local logspan = reader.read_u8();
        local interval_count = bit32.rshift(instruction_count - 1, logspan) + 1;
        
        local deltas = table.create(instruction_count, 0);
        local intervals = table.create(interval_count, 0);

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
        local max_stack_size = reader.read_u8();
        local num_params = reader.read_u8();
        local num_upvalues = reader.read_u8();
        local is_vararg = reader.read_bool();
        local flags = {};

        local raw_flags = reader.read_u8();

        for flag, offset in constants.proto_flag :: {[string]: number} do
            if bit32.extract(raw_flags, offset) == 1 then
                table.insert(flags, flag);
            end
        end

        local types_size = reader.read_varint();
        local types;
        if types_size > 0 then
            types = {};

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
        end

        local instruction_count: number = reader.read_varint();
        local instructions = reader.read_buffer(instruction_count * 4);
        local constants = reader.read_larray(read_constant);
        local child_protos = reader.read_larray(reader.read_varint);
        local line_defined: number = reader.read_varint();
        local debug_name: number = reader.read_varint();
        local line_info: buffer? = reader.read_optional(read_line_info, instruction_count) :: buffer?;
        local debug_info = reader.read_optional(read_debug_info);

        return {
            max_stack_size = max_stack_size,
            num_params = num_params,
            num_upvalues = num_upvalues,
            is_vararg = is_vararg,
            flags = flags,
            types = types,
            instructions = instructions,
            constants = constants,
            child_protos = child_protos,
            line_defined = line_defined,
            debug_name = debug_name,
            line_info = line_info,
            debug_info = debug_info,
        };
    end

    --[=[
        Reads a bytecode chuck and returns the internal table representation.
    ]=]
    local function read_chunk(): t.Chunk
        local luau_version = reader.read_u8();
        if luau_version == 0 then
            error("provided bytecode chunk is invalid");
        end

        local types_version = reader.read_u8();
        local strings = reader.read_larray(reader.read_lstring);
        
        local userdata_types;
        if types_version == 3 then
            userdata_types = {};
            while true do
                local i = reader.read_u8();
                if i == 0 then
                    break;
                end
                
                local name_ref = reader.read_varint();
                userdata_types[i] = name_ref;
            end
        end

        local protos = reader.read_larray(read_proto);
        local main_proto = reader.read_varint();

        return {
            luau_version = luau_version,
            types_version = types_version,
            strings = strings,
            userdata_types = userdata_types,
            protos = protos,
            main_proto = main_proto,
        };
    end

    return read_chunk();
end

return decode;