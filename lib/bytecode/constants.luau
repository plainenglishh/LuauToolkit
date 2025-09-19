--!nocheck

--[=[
    Various bytecode related constants.

    @class bytecode.constants
]=]
local constants = {};

--[=[
    The range of supported bytecode versions. 
    Encoded as `luau_version` in `Chunk` objects.

    @interface supported_bytecode_versions
    @within bytecode.constants
]=]
constants.SUPPORTED_VERSIONS = { 
    min = 4, 
    max = 6, 
    target = 6 
};

--[=[
    Map of bytecode constant types.

    @interface constant_types
    @within bytecode.constants
]=]
constants.CONSTANT_TYPES = {
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
    Proto bitfield flags.

    @interface proto_flag
    @within bytecode.constants
]=]
constants.PROTO_FLAGS = {
    native_module = 0,
    native_cold = 1, 
    native_function = 2,
};

--[=[
    Map of builtin fastcall functions.

    @interface builtins
    @within bytecode.constants
]=]
local BUILTINS: {(...any) -> ...any} = {
    assert,
    math.abs,
    math.acos,
    math.asin,
    math.atan2,
    math.atan,
    math.ceil,
    math.cosh,
    math.cos,
    math.deg,
    math.exp,
    math.floor,
    math.fmod,
    math.frexp,
    math.ldexp,
    math.log10,
    math.log,
    math.max,
    math.min,
    math.modf,
    math.pow,
    math.rad,
    math.sinh,
    math.sin,
    math.sqrt,
    math.tanh,
    math.tan,
    bit32.arshift,
    bit32.band,
    bit32.bnot,
    bit32.bor,
    bit32.bxor,
    bit32.btest,
    bit32.extract,
    bit32.lrotate,
    bit32.lshift,
    bit32.replace,
    bit32.rrotate,
    bit32.rshift,
    type,
    string.byte,
    string.char,
    string.len,
    typeof,
    string.sub,
    math.clamp,
    math.sign,
    math.round,
    rawset,
    rawget,
    rawequal,
    table.insert,
    table.unpack,
    vector.create,
    bit32.countlz,
    bit32.countrz,
    select,
    rawlen,
    bit32.extract,
    getmetatable,
    setmetatable,
    tonumber,
    tostring,
    bit32.byteswap,
    buffer.readi8,
    buffer.readu8,
    buffer.writeu8,
    buffer.readi16,
    buffer.readu16,
    buffer.writeu16,
    buffer.readi32,
    buffer.readu32,
    buffer.writeu32,
    buffer.readf32,
    buffer.writef32,
    buffer.readf64,
    buffer.writef64,
    vector.magnitude,
    vector.normalize,
    vector.cross,
    vector.dot,
    vector.floor,
    vector.ceil,
    vector.abs,
    vector.sign,
    vector.clamp,
    vector.min,
    vector.max,
    math.lerp,
    vector.lerp,
};
constants.BUILTINS = BUILTINS;

local BUILTIN_NAMES = {
    "assert",
    "math.abs",
    "math.acos",
    "math.asin",
    "math.atan2",
    "math.atan",
    "math.ceil",
    "math.cosh",
    "math.cos",
    "math.deg",
    "math.exp",
    "math.floor",
    "math.fmod",
    "math.frexp",
    "math.ldexp",
    "math.log10",
    "math.log",
    "math.max",
    "math.min",
    "math.modf",
    "math.pow",
    "math.rad",
    "math.sinh",
    "math.sin",
    "math.sqrt",
    "math.tanh",
    "math.tan",
    "bit32.arshift",
    "bit32.band",
    "bit32.bnot",
    "bit32.bor",
    "bit32.bxor",
    "bit32.btest",
    "bit32.extract",
    "bit32.lrotate",
    "bit32.lshift",
    "bit32.replace",
    "bit32.rrotate",
    "bit32.rshift",
    "type",
    "string.byte",
    "string.char",
    "string.len",
    "typeof",
    "string.sub",
    "math.clamp",
    "math.sign",
    "math.round",
    "rawset",
    "rawget",
    "rawequal",
    "table.insert",
    "table.unpack",
    "vector.create",
    "bit32.countlz",
    "bit32.countrz",
    "select",
    "rawlen",
    "bit32.extract",
    "getmetatable",
    "setmetatable",
    "tonumber",
    "tostring",
    "bit32.byteswap",
    "buffer.readi8",
    "buffer.readu8",
    "buffer.writeu8",
    "buffer.readi16",
    "buffer.readu16",
    "buffer.writeu16",
    "buffer.readi32",
    "buffer.readu32",
    "buffer.writeu32",
    "buffer.readf32",
    "buffer.writef32",
    "buffer.readf64",
    "buffer.writef64",
    "vector.magnitude",
    "vector.normalize",
    "vector.cross",
    "vector.dot",
    "vector.floor",
    "vector.ceil",
    "vector.abs",
    "vector.sign",
    "vector.clamp",
    "vector.min",
    "vector.max",
    "math.lerp",
};

--[=[
    Names of builtin functions.

    @interface builtin_names
    @within bytecode.constants
]=]
constants.BUILTIN_NAMES = BUILTIN_NAMES;

return constants;
