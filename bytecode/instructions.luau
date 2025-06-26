local byteparse = require("./byteparse");
local opcodes = require("./opcodes");
local t = require("./types");

--[=[
    Library for encoding and decoding Luau bytecode instructions.
]=]
local instructions = {};

--[=[
    Reinterprets an unsigned integer as a two's complement signed integer.
]=]
local function _reinterpret_signed(n: number, bitwidth: number): number
    if n >= 2 ^ (bitwidth - 1)  then
        return n - 2 ^ bitwidth;
    else
        return n;
    end
end

local function i16(n: number): number
    if n < 0x8000 then
        return n;
    else
        return n - 0x10000;
    end
end

local function i24(n: number): number    
    if n < 0x800000 then
        return n;
    else
        return n - 0x1000000;
    end
end

--[=[
    Decodes a buffer containing an array of instructions into an array of 
    `BytecodeInstruction`s.
]=]
function instructions.decode(insn_buffer: buffer): {t.BytecodeInstruction}
    local count = buffer.len(insn_buffer) / 4;
    local instructions = table.create(count);

    local skip_next = false;

    for i = 0, count - 1 do
        if skip_next then
            skip_next = false;
            continue;
        end

        local offset = i * 4;
        local raw = buffer.readu32(insn_buffer, offset);

        local opcode = bit32.extract(raw, 0, 8);
        local operands = vector.zero;
        local aux;
        
        local info = opcodes[opcode] or error(`unknown opcode {opcode}`);
        local mode: t.OperandMode = info.mode;

        if mode == "abc" then
            operands = vector.create(bit32.extract(raw, 8, 8), bit32.extract(raw, 16, 8), bit32.extract(raw, 24, 8));
        elseif mode == "ad" then
            operands = vector.create(bit32.extract(raw, 8, 8), i16(bit32.extract(raw, 16, 16)), 0);
        elseif mode == "e" then
            operands = vector.create(i24(bit32.extract(raw, 8, 24)), 0, 0);
        end

        if info.aux then
            aux = buffer.readu32(insn_buffer, offset + 4);
            skip_next = true;
        end

        table.insert(instructions, {
            opcode = opcode,
            operands = operands,
            aux = aux,
            mode = mode,
        });
    end

    return instructions;
end

--[=[
    Encodes a single `BytecodeInstruction` as up to two `u32`-containing numbers.

    The first number contains the encoded instruction.
    The second contains the aux instruction, or nil if it doesn't have one.
]=]
function instructions.encode_instruction(insn: t.BytecodeInstruction): (number, number?)
    local raw = insn.opcode;
    local mode: t.OperandMode, operands = insn.mode, insn.operands;

    if mode == "abc" then
        raw = bit32.replace(raw, operands.x or 0, 8, 8);
        raw = bit32.replace(raw, operands.y or 0, 16, 8);
        raw = bit32.replace(raw, operands.z or 0, 24, 8);
    elseif mode == "ad" then
        raw = bit32.replace(raw, operands.x or 0, 8, 8);
        raw = bit32.replace(raw, operands.y or 0, 16, 16);
    elseif mode == "e" then
        raw = bit32.replace(raw, operands.x or 0, 8, 24);
    end 

    return raw, insn.aux;
end

--[=[
    Encodes an array of `BytecodeInstruction`s into a buffer.
]=]
function instructions.encode(instructions: {t.BytecodeInstruction}): buffer
    local buf = buffer.create(#instructions * 2 * 4); -- Assume every instruction as an aux insn, trim later.
    local cursor = 0;

    for i, insn in instructions do
        local raw = insn.opcode;
        local mode: t.OperandMode, operands = insn.mode, insn.operands;

        if mode == "abc" then
            raw = bit32.replace(raw, operands.x or 0, 8, 8);
            raw = bit32.replace(raw, operands.y or 0, 16, 8);
            raw = bit32.replace(raw, operands.z or 0, 24, 8);
        elseif mode == "ad" then
            raw = bit32.replace(raw, operands.x or 0, 8, 8);
            raw = bit32.replace(raw, operands.y or 0, 16, 16);
        elseif mode == "e" then
            raw = bit32.replace(raw, operands.x or 0, 8, 24);
        end 

        buffer.writeu32(buf, cursor, raw); 
        cursor += 4;

        if insn.aux then
            buffer.writeu32(buf, cursor, insn.aux);
            cursor += 4;
        end
    end

    local trimmed = buffer.create(cursor);
    buffer.copy(trimmed, 0, buf, 0, cursor);
    return trimmed;
end

--[=[
    Extracts the opcode from an instruction as a `u8`.
]=]
function instructions.insn_op(insn: number): number
    return bit32.extract(insn, 0, 8);
end

--[=[
    Extracts the `A` operand from an instruction as a `u8`.
]=]
function instructions.insn_a(insn: number): number
    return bit32.extract(insn, 8, 8);
end

--[=[
    Extracts the `B` operand from an instruction as a `u8`.
]=]
function instructions.insn_b(insn: number): number
    return bit32.extract(insn, 16, 8);
end

--[=[
    Extracts the `C` operand from an instruction as a `u8`.
]=]
function instructions.insn_c(insn: number): number
    return bit32.extract(insn, 24, 8);
end

--[=[
    Extracts the `D` operand from an instruction as an `i16`.
]=]
function instructions.insn_d(insn: number): number
    local n = bit32.extract(insn, 16, 16);

    if n < 0x8000 then
        return n;
    else
        return n - 0x10000;
    end
end

--[=[
    Extracts the `E` operand from an instruction as an `i24`.
]=]
function instructions.insn_e(insn: number): number
    local n = bit32.extract(insn, 8, 24);
    
    if n < 0x800000 then
        return n;
    else
        return n - 0x1000000;
    end
end

return instructions;
