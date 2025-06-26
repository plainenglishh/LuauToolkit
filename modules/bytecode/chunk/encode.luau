local byteparse = require("../byteparse");
local constants = require("../constants");
local t = require("../types");

--[=[
    Returns a constant type id from a constant type name.
    Errors if given an invalid constant type.
]=]
local function get_constant_type(constant_type: t.ConstantType): number
    for i, v in constants.constant_types do
        if v == constant_type then
            return i;
        end
    end

    error(`unknown constant type '{constant_type}'`, 2);
end

local function determine_span_length(lines: buffer): number
    local span = bit32.lshift(1, 24);
    local count = buffer.len(lines) / 4;

    local offset = 0; while offset < count do
        local next = offset;

        local min = buffer.readu32(lines, offset * 4);
        local max = min;
    
        while next < count and next < offset + span do
            min = math.min(min, buffer.readu32(lines, next * 4));
            max = math.max(max, buffer.readu32(lines, next * 4));

            if max - min > 255 then
                break;
            end

            next += 1;
        end

        if next < count and next - offset < span then
            span = bit32.lshift(1, math.log(next - offset, 2));
        end
        
        offset += span;
    end

    return span;
end

--[=[
    Encodes a Chunk to a buffer.

    NOTE: This function intentionally does **not** check for validity. 
          Run `bytecode.chunk.validate` beforehand if this is desired.
]=]
local function encode(chunk: t.Chunk): buffer
    local writer = byteparse.writer(100);

    local function write_constant(constant: t.Constant)
        writer.write_u8(get_constant_type(constant.type) or error("unknown constant type"));

        if constant.type == "nil" then
        elseif constant.type == "boolean" then
            writer.write_bool(constant.value);    
        elseif constant.type == "number" then
            writer.write_f64(constant.value);
        elseif constant.type == "string" then
            writer.write_varint(constant.value);
        elseif constant.type == "import" then
            writer.write_u32(constant.value);
        elseif constant.type == "table" then
            writer.write_varint(#constant.value);
            for _, v in constant.value do
                writer.write_varint(v);
            end
        elseif constant.type == "closure" then
            writer.write_varint(constant.value);
        elseif constant.type == "vector" then
            for _, v in constant.value do
                writer.write_f32(v);
            end
        end
    end

    local function write_debug_info(debug_info: t.ProtoDebugInfo)
        writer.write_varint(#debug_info.locals);
        for _, local_ in debug_info.locals do
            writer.write_varint(local_.name);
            writer.write_varint(local_.start_pc);
            writer.write_varint(local_.end_pc);
            writer.write_u8(local_.register);
        end

        writer.write_varint(#debug_info.upvalues);
        for _, upvalue in debug_info.upvalues do
            writer.write_varint(upvalue.name);
        end
    end

    local function write_line_info(lines: buffer)
        local count = buffer.len(lines) / 4;
        local span = determine_span_length(lines);

        local baseline_size = (count - 1) // span + 1;
        local baseline = buffer.create(baseline_size * 4);

        local offset = 0; while offset < count do
            local next = offset;
            local min = buffer.readu32(lines, offset * 4);

            while next < count and next < offset + span do
                min = math.min(min, buffer.readu32(lines, next * 4));
                next += 1;
            end

            buffer.writeu32(baseline, (offset // span) * 4, min);

            offset += span;
        end

        local logspan = math.log(span, 2);
        writer.write_u8(logspan);

        local last_offset = 0;
        for i = 0, count - 1 do
            local delta = buffer.readu32(lines, i * 4) - buffer.readu32(baseline, bit32.rshift(i, logspan) * 4);
            if not (delta >= 0 and delta <= 255) then
                error(`delta too large ({delta})`);
            end

            writer.write_u8(delta - last_offset);
            last_offset = delta;
        end

        local last_line = 0;
        for i = 0, baseline_size - 1 do
            local n = buffer.readu32(baseline, i * 4);
            writer.write_u32(n - last_line);
            last_line = n;
        end
    end

    local function write_type_info(type_info: t.ProtoTypeInfo?)
        if not type_info then
            writer.write_varint(0);
            return;
        end

        local temp_line_info = byteparse.writer(10);    
        temp_line_info.write_varint(#type_info.func);
        temp_line_info.write_varint(#type_info.upvalues);
        temp_line_info.write_varint(#type_info.locals);
    
        temp_line_info.write_string(type_info.func);

        for i, v in type_info.upvalues do
            temp_line_info.write_u8(v);
        end

        for i, v in type_info.locals do
            temp_line_info.write_u8(v.type);
            temp_line_info.write_u8(v.register);
            temp_line_info.write_varint(v.start_pc);
            temp_line_info.write_varint(v.length);
        end

        writer.write_varint(temp_line_info.get_size());
        writer.write_buffer(temp_line_info.to_buffer());
    end

    --[=[
        writes a bytecode proto and returns the internal table representation.
    ]=]
    local function write_proto(proto: t.Proto)
        writer.write_u8(proto.max_stack_size);
        writer.write_u8(proto.num_params);
        writer.write_u8(proto.num_upvalues);
        writer.write_bool(proto.is_vararg);

        local flags = 0;

        for _, flag: t.ProtoFlag in proto.flags do
            local offset = constants.proto_flag[flag :: any] or error(`unknown flag '{flag}'`);
            flags = bit32.replace(flags, 1, offset);
        end

        writer.write_u8(flags);
        write_type_info(proto.types);
        writer.write_varint(buffer.len(proto.instructions) / 4);
        writer.write_buffer(proto.instructions);
        writer.write_larray(proto.constants, write_constant);
        writer.write_larray(proto.child_protos, writer.write_varint);
        writer.write_varint(proto.line_defined);
        writer.write_varint(proto.debug_name);
        writer.write_optional(proto.line_info, write_line_info);
        writer.write_optional(proto.debug_info, write_debug_info);
    end

    --[=[
        writes a bytecode chuck and returns the internal table representation.
    ]=]
    local function write_chunk(chunk: t.Chunk)
        writer.write_u8(chunk.luau_version);
        writer.write_u8(chunk.types_version);
        writer.write_larray(chunk.strings, writer.write_lstring);

        if chunk.types_version == 3 then
            for i, t in chunk.userdata_types or ({} :: any) do
                writer.write_u8(8);
                writer.write_varint(t);
            end

            writer.write_u8(0);
        end
        
        writer.write_larray(chunk.protos, write_proto);
        writer.write_varint(chunk.main_proto);
    end

    write_chunk(chunk);

    return writer.to_buffer();
end

return encode;