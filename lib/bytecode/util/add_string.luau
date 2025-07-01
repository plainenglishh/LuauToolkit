local t = require("../types");

--[=[
    Adds a string to a `Chunk`s string table, checking if it already exists, and
    returns the StringId.
]=]
local function add_string(chunk: t.Chunk, str: string): t.StringId
    for i, v in chunk.strings do
        if v == str then
            return i;
        end
    end

    local i = #chunk.strings + 1;
    chunk.strings[i] = str;
    return i;
end

return add_string;