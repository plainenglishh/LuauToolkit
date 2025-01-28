--!nolint ForRange

--[=[
    Bytecode related constants and metadata.
]=]
local constants = {};

--[=[
    The minimum supported bytecode version by luautils.
]=]
constants.min_version = 4;

--[=[
    The maximum supported bytecode version by luautils.
]=]
constants.max_version = 6;

--[=[
    A map of constant types
]=]
constants.constant_types = {
    [0] = "nil",
    [1] = "boolean",
    [2] = "number",
    [3] = "string",
    [4] = "import",
    [5] = "table",
    [6] = "closure",
    [7] = "vector",
};

--[=[
    proto flag bitmask
]=]
constants.proto_flag = {
    --- used to tag main proto for modules with --!native
    native_module = bit32.lshift(1, 0),

    --- used to tag individual protos as not profitable to compile natively
    native_cold = bit32.lshift(1, 1),

    --- used to tag main proto for modules that have at least one function with native attribute
    native_function = bit32.lshift(1, 2),
};

return constants;