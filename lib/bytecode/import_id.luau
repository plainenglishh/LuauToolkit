--[=[
    Library for encoding and decoding bytecode import IDs.

    @class bytecode.import_id
]=]
local import_id = {};

--[=[
    Encodes an import_id from an array of up to three string_id path members.

    @within bytecode.import_id
]=]
function import_id.encode(path: {number}): number
    local count = #path;
    assert(count <= 3, "too many path members");

    local id0 = path[1] or 0;
    local id1 = path[2] or 0;
    local id2 = path[3] or 0;

    local id = 0;
    id = bit32.replace(id, count, 30, 2);
    id = bit32.replace(id, id0, 20, 10);
    id = bit32.replace(id, id1, 10, 10);
    id = bit32.replace(id, id2, 0, 10);

    return id;
end

--[=[
    Decodes an import_id into an array of up to three string_id path members.

    @within bytecode.import_id
]=]
function import_id.decode(id: number): {number}
    local count = bit32.rshift(id, 30);
    local id0 = bit32.band(bit32.rshift(id, 20), 1023);
    local id1 = bit32.band(bit32.rshift(id, 10), 1023);
    local id2 = bit32.band(id, 1023);

    if count == 1 then
        return {id0};
    elseif count == 2 then
        return {id0, id1};
    elseif count == 3 then
        return {id0, id1, id2};
    else
        error("too many path members");
    end
end

return import_id;