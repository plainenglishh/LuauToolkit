local metadata = require("./instruction_metadata");
local t = require("./types");

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

@native
local function encode_instruction(insn: t.Instruction): (number, number?)
    local raw = insn.opcode;
    local mode: t.OperandEncodingMode, operands = insn.mode, insn.operands;

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

@native
local function decode_instruction(insn: number, next_insn: number?): t.Instruction
    local opcode = INSN_OP(insn);
    local operands = vector.zero;
    local aux;
    
    local info = metadata[opcode] or error(`unknown opcode {opcode}`);
    local mode: t.OperandEncodingMode = info.mode;

    if mode == "abc" then
        operands = vector.create(bit32.extract(insn, 8, 8), bit32.extract(insn, 16, 8), bit32.extract(insn, 24, 8));
    elseif mode == "ad" then
        operands = vector.create(bit32.extract(insn, 8, 8), i16(bit32.extract(insn, 16, 16)), 0);
    elseif mode == "e" then
        operands = vector.create(i24(bit32.extract(insn, 8, 24)), 0, 0);
    end

    if info.aux then
        aux = next_insn or error(`opcode {opcode} expects an auxillary instruction`, 2);
    end

    return {
        opcode = opcode,
        operands = operands,
        aux = aux,
        mode = mode,
    };
end

--[=[
    Library for encoding and decoding Luau bytecode instructions.
]=]
local instructions = {};

--[=[
    Returns information about an instruction.

    The `instruction` parameter can be:
      - an opcode number;
      - an instruction name; or
      - an `Instruction` object.
]=]
function instructions.get_metadata(instruction: number|string|t.Instruction): t.InstructionMetadata?
    if type(instruction) == "number" then
        return metadata[instruction];
    elseif type(instruction) == "string" then
        instruction = string.upper(instruction);
        for _, v in metadata do
            if v.name == instruction then
                return v;
            end
        end
    elseif type(instruction) == "table" then
        return metadata[instruction.opcode];
    end

    return;
end

--[=[
    Returns a text representation of an instruction.
]=]
function instructions.display(insn: number, next_insn: number?): string
    local instruction = decode_instruction(insn, next_insn);
    local info = instructions.get_metadata(instruction) or error("");

    local out = {info.name};

    if info.mode == "abc" then
        out[2] = `({instruction.operands.x}, {instruction.operands.y}, {instruction.operands.z}`;
    elseif info.mode == "ad" then
        out[2] = `({instruction.operands.x}, {instruction.operands.y}`;
    elseif info.mode == "e" then
        out[2] = `({instruction.operands.x}`;
    end

    if info.aux then
        out[3] = `, {next_insn})`;
    else
        out[3] = ")";
    end

    return table.concat(out);
end

@native
function instructions.decode_instruction(insn: number, next_insn: number?): t.Instruction
    return decode_instruction(insn, next_insn);
end

--[=[
    Decodes a buffer containing an array of instructions into an array of 
    `Instruction`s.
]=]
@native
function instructions.decode(insn_buffer: buffer): {t.Instruction}
    local size = buffer.len(insn_buffer);
    local count = size / 4;
    local insns = {};

    local insn;
    local next_insn: number? = buffer.readu32(insn_buffer, 0);

    local i = 1; while i <= count do
        insn = next_insn or error("overrun");
        next_insn = if i ~= count then buffer.readu32(insn_buffer, i * 4) else nil;

        local instruction = decode_instruction(insn, next_insn);
        table.insert(insns, instruction);

        if instruction.aux then  
            next_insn = if i + 1 ~= count then buffer.readu32(insn_buffer, (i + 1) * 4) else nil;
            i += 2;
        else
            i += 1;
        end
    end
    
    return insns;
end

--[=[
    Encodes a single `Instruction` as up to two `u32`-containing numbers.

    The first number contains the encoded instruction.
    The second contains the aux instruction, or nil if it doesn't have one.
]=]
@native
function instructions.encode_instruction(insn: t.Instruction): (number, number?)
    return encode_instruction(insn)
end

--[=[
    Encodes an array of `Instruction`s into a buffer.
]=]
@native
function instructions.encode(instructions: {t.Instruction}): buffer
    local buf = buffer.create(#instructions * 2 * 4); -- Assume every instruction as an aux insn, trim later.
    local cursor = 0;

    for i, insn in instructions do
        local raw, aux = encode_instruction(insn);
        buffer.writeu32(buf, cursor, raw); cursor += 4;

        if aux then
            buffer.writeu32(buf, cursor, aux); cursor += 4;
        end
    end

    local trimmed = buffer.create(cursor);
    buffer.copy(trimmed, 0, buf, 0, cursor);
    return trimmed;
end

--[=[
    Extracts the opcode from an instruction as a `u8`.
]=]
@native
function instructions.insn_op(insn: number): number
    return INSN_OP(insn);
end

--[=[
    Extracts the `A` operand from an instruction as a `u8`.
]=]
@native
function instructions.insn_a(insn: number): number
    return INSN_A(insn);
end

--[=[
    Extracts the `B` operand from an instruction as a `u8`.
]=]
@native
function instructions.insn_b(insn: number): number
    return INSN_B(insn);
end

--[=[
    Extracts the `C` operand from an instruction as a `u8`.
]=]
@native
function instructions.insn_c(insn: number): number
    return INSN_C(insn);
end

--[=[
    Extracts the `D` operand from an instruction as an `i16`.
]=]
@native
function instructions.insn_d(insn: number): number
    return INSN_D(insn);
end

--[=[
    Extracts the `E` operand from an instruction as an `i24`.
]=]
@native
function instructions.insn_e(insn: number): number
    return INSN_E(insn);
end

return instructions;
