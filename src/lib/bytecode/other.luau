local opcodes = require("./opcodes");
local other = {};

--[=[
    Returns opcode info from an opcode name or id.
]=]
function other.get_opcode_info(opcode: number|opcodes.OpcodeName): opcodes.OpcodeInfo?
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

return other;