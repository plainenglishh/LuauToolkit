--[=[
    Shared testing utility functions.
]=]
local testing = {};

function testing.assert_eq(a: any, b: any, message: string?)
    assert(type(a) == type(b), message);

    if type(a) == "buffer" then
        assert(buffer.tostring(a) == buffer.tostring(b), message);
    elseif type(a) == "table" then
        error("todo");
    else
        assert(a == b, message);
    end
end

return testing;
