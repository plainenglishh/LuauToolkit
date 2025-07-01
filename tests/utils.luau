--[=[
    Shared testing utility functions.
]=]
local testing = {};

local function eq(a: any, b: any): boolean
    if type(a) ~= type(b) then 
        return false;
    end

    if type(a) == "buffer" then
        return buffer.tostring(a) == buffer.tostring(b);
    elseif type(a) == "table" then
        for k, v in a do
            if not eq(v, b[k]) then
                return false
            end
        end
        
        for k, _ in b do
            if a[k] == nil then
                return false
            end
        end
        
        return true;
    else
        return a == b;
    end
end

function testing.assert_eq(a: any, b: any, message: string?)
    assert(eq(a, b), message);
end

return testing;
