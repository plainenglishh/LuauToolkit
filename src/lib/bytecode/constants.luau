local t = require("../typedefs");

local constants: t.API_BytecodeConstants = {
    min_version = 4,
    max_version = 6,
    
    constant_types = {
        [0] = "nil",
        [1] = "boolean",
        [2] = "number",
        [3] = "string",
        [4] = "import",
        [5] = "table",
        [6] = "closure",
        [7] = "vector",
    },
    
    proto_flag = {
        native_module = bit32.lshift(1, 0),
        native_cold = bit32.lshift(1, 1), 
        native_function = bit32.lshift(1, 2),
    },
};

return constants;