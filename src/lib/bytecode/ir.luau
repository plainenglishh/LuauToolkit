local byteparse = require("@vendor/byteparse");
local opcodes = require("./opcodes");
local constants = require("./constants");
local common = require("../common");
local t = require("../types");

local ir = {};

--[=[
    Decode a bytecode chunk into it's internal table representation.
]=]
function ir.decode(bc: buffer|string)
    local bc = if type(bc) == "string" then buffer.fromstring(bc) else bc;
    local reader = byteparse.reader(bc);

    local function read_instruction(): t.IRInstruction
        local raw = reader.read_u32();
        local instruction = {};

        instruction.opcode = bit32.extract(raw, 0, 8);
        
        local info = opcodes[instruction.opcode] or error("unknown opcode");

        instruction.operands = {};

        if info.mode == "abc" then
            instruction.operands.a = bit32.extract(raw, 8, 8);
            instruction.operands.b = bit32.extract(raw, 16, 8);
            instruction.operands.c = bit32.extract(raw, 24, 8);
        elseif info.mode == "ad" then
            instruction.operands.a = bit32.extract(raw, 8, 8);
            instruction.operands.d = bit32.extract(raw, 16, 16);
        elseif info.mode == "e" then
            instruction.operands.e = bit32.extract(raw, 8, 24);
        end

        if info.aux then
            instruction.operands.aux = reader.read_u32();
        end

        return instruction;
    end

    local function read_constant(): t.IRConstant
        local ktype_id = reader.read_u8();
        local ktype = constants.constant_types[ktype_id];

        local constant: t.IRConstant = {
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

    local function read_debug_info(): t.IRProtoDebugInfo
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
    local function read_proto(): t.IRProto
        local proto = {};

        proto.max_stack_size = reader.read_u8();
        proto.num_params = reader.read_u8();
        proto.num_upvalues = reader.read_u8();
        proto.is_varag = reader.read_bool();
        proto.flags = reader.read_u8();

        local types_size = reader.read_varint();
        if types_size > 0 then
            local types = {} :: t.IRProtoTypeInfo;

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
        proto.instructions = table.create(instruction_count);
        local skip_next = false;
        for i = 1, instruction_count do
            if skip_next then
                skip_next = false;
                continue;
            end

            local insn = read_instruction();
            proto.instructions[i] = insn;
            
            if insn.operands.aux then
                skip_next = true;
            end
        end

        
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
    local function read_chunk(): t.IRChunk
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

--[=[
    Encode a bytecode table representation object into a bytecode chunk.
]=]
function ir.encode(ir_chunk: t.IRChunk): buffer
    local writer = byteparse.writer(100);

    local function write_instruction(inst: t.IRInstruction)
        local raw = 0;
        local data = opcodes[inst.opcode];

        raw = bit32.replace(raw, inst.opcode, 0, 8);

        if data.mode == "abc" then
            raw = bit32.replace(raw, inst.operands.a, 8, 8);
            raw = bit32.replace(raw, inst.operands.b, 16, 8);
            raw = bit32.replace(raw, inst.operands.c, 24, 8);
        elseif data.mode == "ad" then
            raw = bit32.replace(raw, inst.operands.a, 8, 8);
            raw = bit32.replace(raw, inst.operands.d, 16, 16);
        elseif data.mode == "e" then
            raw = bit32.replace(raw, inst.operands.e, 8, 24);
        end 

        writer.write_u32(raw);

        if inst.operands.aux then
            writer.write_u32(inst.operands.aux);
        end
    end

    local function write_constant(const: t.IRConstant)
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

    local function write_debug_info(dbg: t.IRProtoDebugInfo)
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

    local function write_type_info(type_info: t.IRProtoTypeInfo)
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
    local function write_proto(proto: t.IRProto)
        writer.write_u8(proto.max_stack_size);
        writer.write_u8(proto.num_params);
        writer.write_u8(proto.num_upvalues);
        writer.write_bool(proto.is_varag);
        writer.write_u8(proto.flags);

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
    local function write_chunk(chunk: t.IRChunk)
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

    write_chunk(ir_chunk);

    return writer.to_buffer();
end

return ir;