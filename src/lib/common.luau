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

--[=[
    Builds a string
]=]
function common.string_builder()
    local strings = {};

    local builder = {};

    function builder.write(str: string)
        table.insert(strings, str);
    end

    function builder.writeln(str: string)
        builder.write(str);
        builder.write("\n");
    end

    function builder.write_to(other)
        for _, v in strings do
            other.write(v);
        end
    end

    function builder.build(): string
        return table.concat(strings, "");
    end

    return builder;
end

return common;