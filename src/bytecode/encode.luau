--[[
    Encodes a bytecode chunk
]]

local byteparse = require("./byteparse");
local opcodes = require("./opcodes");
local common = require("./common");
local constants = require("./constants");
local t = require("./typedefs");

return function(Bytecodechunk: t.BytecodeChunk): buffer
    local writer = byteparse.writer(100);

    local function write_instruction(inst: t.BytecodeInstruction)
        local raw = 0;
        local data = opcodes[inst.opcode];

        raw = bit32.replace(raw, inst.opcode, 0, 8);

        if data.mode == "abc" then
            raw = bit32.replace(raw, inst.operands.a or 0, 8, 8);
            raw = bit32.replace(raw, inst.operands.b or 0, 16, 8);
            raw = bit32.replace(raw, inst.operands.c or 0, 24, 8);
        elseif data.mode == "ad" then
            raw = bit32.replace(raw, inst.operands.a or 0, 8, 8);
            raw = bit32.replace(raw, inst.operands.d or 0, 16, 16);
        elseif data.mode == "e" then
            raw = bit32.replace(raw, inst.operands.e or 0, 8, 24);
        end 

        writer.write_u32(raw);

        if inst.operands.aux then
            writer.write_u32(inst.operands.aux);
        end
    end

    local function write_constant(const: t.BytecodeConstant)
        writer.write_u8(common.find_from_0(constants.constant_types, const.type) or error("unknown constant type"));

        if const.type == "nil" then
        elseif const.type == "boolean" then
            writer.write_bool(const.value);    
        elseif const.type == "number" then
            writer.write_f64(const.value);
        elseif const.type == "string" then
            writer.write_varint(const.value);
        elseif const.type == "import" then
            writer.write_u32(const.value);
        elseif const.type == "table" then
            writer.write_varint(#const.value);
            for _, v in const.value do
                writer.write_varint(v);
            end
        elseif const.type == "closure" then
            writer.write_varint(const.value);
        elseif const.type == "vector" then
            for _, v in const.value do
                writer.write_f32(v);
            end
        end
    end

    local function write_debug_info(dbg: t.BytecodeProtoDebugInfo)
        writer.write_varint(#dbg.locals);
        for _, l in dbg.locals do
            writer.write_varint(l.name);
            writer.write_varint(l.start_pc);
            writer.write_varint(l.end_pc);
            writer.write_u8(l.reg);
        end

        writer.write_varint(#dbg.upvalues);
        for _, uv in dbg.upvalues do
            writer.write_varint(uv.name);
        end
    end

    local function write_line_info(lineinfo: buffer)
        writer.write_buffer(lineinfo);
    end

    local function write_type_info(type_info: t.BytecodeProtoTypeInfo)
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
            temp_line_info.write_u8(v.reg);
            temp_line_info.write_varint(v.start_pc);
            temp_line_info.write_varint(v.length);
        end

        writer.write_varint(temp_line_info.get_size());
        writer.write_buffer(temp_line_info.to_buffer());
    end

    --[=[
        writes a bytecode proto and returns the internal table representation.
    ]=]
    local function write_proto(proto: t.BytecodeProto)
        writer.write_u8(proto.max_stack_size);
        writer.write_u8(proto.num_params);
        writer.write_u8(proto.num_upvalues);
        writer.write_bool(proto.is_vararg);

        local flags = 0;

        for _, flag in proto.flags do
            local offset = constants.proto_flag[flag :: any] or error(`unknown flag '{flag}'`);
            flags = bit32.replace(flags, 1, offset);
        end

        writer.write_u8(flags);

        if proto.types then
            write_type_info(proto.types);
        else
            writer.write_varint(0);
        end
    
        local instruction_count = 0;
        for _, inst in proto.instructions do
            instruction_count += 1;
            if inst.operands.aux then
                instruction_count += 1;
            end
        end

        writer.write_varint(instruction_count);
        for i, inst in proto.instructions do
            write_instruction(inst);
        end

        writer.write_larray(proto.constants, write_constant);
        writer.write_larray(proto.protos, writer.write_varint);

        writer.write_varint(proto.line_defined);
        writer.write_varint(proto.debug_name);
        
        writer.write_optional(proto.line_info, write_line_info);
        writer.write_optional(proto.debug_info, write_debug_info);
    end

    --[=[
        writes a bytecode chuck and returns the internal table representation.
    ]=]
    local function write_chunk(chunk: t.BytecodeChunk)
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

    write_chunk(Bytecodechunk);

    return writer.to_buffer();
end
