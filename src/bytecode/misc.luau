--[[
    Miscellaneous utility functions for interacting with bytecode.
]]

local t = require("./typedefs");
local opcodes = require("./opcodes");

local misc = {};

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

function misc.encode_import_id(path: {number}): number
    local count = #path;
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

function misc.decode_import_id(id: number): {number}
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
        error("invalid count");
    end
end

return misc;
