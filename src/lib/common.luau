--!nolint ForRange

local opcodes = require("./opcodes");

local common = {};

--[=[
    Panics when called, indicating the called operation isn't implemented.
]=]
function common.unimplemented(): never
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

--[=[
    Deep Clone a table.
]=]
function common.deep_clone(tbl: {[any]: any}): {[any]: any}
    local new = {};

    for k, v in tbl do
        new[k] = if type(v) == "table" then common.deep_clone(v) else v;
    end

    return new;
end

--[=[
    Returns opcode info from an opcode name or id.
]=]
function common.get_opcode_info(opcode: number|opcodes.OpcodeName): opcodes.OpcodeInfo?
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

return common;