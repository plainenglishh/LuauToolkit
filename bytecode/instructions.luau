--[[
    This file contains the function used to encode an array of bytecode instructions.
]]

local byteparse = require("./byteparse");
local opcodes = require("./opcodes");
local t = require("./types");

--[=[
    Reinterprets an unsigned integer as a two's complement signed integer.
]=]
local function reinterpret_signed(n: number, bitwidth: number): number
    if n >= 2 ^ (bitwidth - 1)  then
        return n - 2 ^ bitwidth;
    else
        return n;
    end
end

local instructions = {};

function instructions.decode(raw_instructions: buffer): {t.BytecodeInstruction}
    local reader = byteparse.reader(raw_instructions);

    local function read_instruction(): t.BytecodeInstruction
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
            instruction.operands.d = reinterpret_signed(bit32.extract(raw, 16, 16), 16);
        elseif info.mode == "e" then
            instruction.operands.e = reinterpret_signed(bit32.extract(raw, 8, 24), 24);
        end

        if info.aux then
            instruction.operands.aux = reader.read_u32();
        end

        return instruction;
    end
    
    local instruction_count = buffer.len(raw_instructions) / 4;
    local instructions = table.create(instruction_count);

    local skip_next = false;
    for i = 1, instruction_count do
        if skip_next then
            skip_next = false;
            continue;
        end

        local instruction = read_instruction();
        table.insert(instructions, instruction);
        
        if instruction.operands.aux then
            skip_next = true; -- Aux instructions are parsed already.
        end
    end

    return instructions;
end

function instructions.encode(instructions: {t.BytecodeInstruction}): buffer
    local writer = byteparse.writer(1024);

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
    
    for i, inst in instructions do
        write_instruction(inst);
    end

    return writer.to_buffer();
end

return instructions;