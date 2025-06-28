--[[
    This script generates an if 'switch' for opcodes.
]]

local bytecode = require("@luau_toolkit/bytecode");

local string_builder = {};

local function write(str: string)
    table.insert(string_builder, str);
end

for i = 1, #bytecode.instructions.metadata + 1 do
    local op = i - 1;
    local metadata = bytecode.instructions.metadata[op];
    write(`{if op == 0 then "if" else "elseif"} op == {op} then -- {metadata.name}\n`);
end
write("else\nend\n");

local src = table.concat(string_builder, "");
print(src);