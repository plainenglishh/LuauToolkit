local t = require("./types");
local opcodes = require("./opcodes");

--[=[
    Internal library used to hold functions that are needed in other parts of 
    the module, but also need to be exported at the top level.
]=]
local misc = {};

--[=[
    Returns the `bytecode.opcodes` entry for a given opcode.
]=]
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
