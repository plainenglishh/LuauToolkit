local t = require("../types");
local get_closure_instantiation = require("./get_closure_instantiation");

--[=[
    Returns whether a closure is cachable.
]=]
local function is_closure_cachable(chunk: t.Chunk, proto: number | t.Proto): boolean
    local instantiation = get_closure_instantiation(chunk, proto);
    if not instantiation then
        return false;
    end
    
    return instantiation.type == "DUPCLOSURE";
end

return is_closure_cachable;
