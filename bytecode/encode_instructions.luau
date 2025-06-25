--[[
    This file contains the function used to encode an array of bytecode instructions.
]]

local byteparse = require("./byteparse");
local opcodes = require("./opcodes");
local t = require("./types");

local function encode(instructions: {t.BytecodeInstruction}): buffer
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

return encode;