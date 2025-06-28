--[=[
    Miscellaneous luau related items.
]=]
local misc = {};

function misc.display_chunk_name(chunk_name: string): string
    local prefix = string.sub(chunk_name, 1, 1);
    if prefix == "=" or prefix == "@" then
        return string.sub(chunk_name, 2);
    end

    return `[string "{chunk_name}"]`;
end

return misc;
