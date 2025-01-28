--!nolint ForRange

local common = {};

--[=[
    Panics when called, indicating the called operation isn't implemented.
]=]
function common.unimplemented()
    error("unimplemented", 2);
end

--[=[
    Searches a table starting at index 0 instead of 1.
]=]
function common.find_from_0(haystack: {[number]: string}, needle: string): number?
    for i = 0, #haystack do
        if haystack[i] == needle then
            return i;
        end
    end

    return nil;
end

return common;