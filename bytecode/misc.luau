local t = require("./types");
local opcodes = require("./opcodes");

local misc = {};

function misc.get_opcode_info(opcode: number|string): t.OpcodeInfo?
    if type(opcode) == "string" then
        for _, v in opcodes do
            if v.name == opcode then
                return v;
            end
        end
    else
        return opcodes[opcode];
    end

    return;
end

return misc;
