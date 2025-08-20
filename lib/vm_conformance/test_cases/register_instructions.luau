local BytecodeAssembler = require("@luau_toolkit/bytecode").BytecodeBuilder;
local t = require("../types");

local chunk = BytecodeAssembler.new();
chunk:begin_function();
chunk:set_main();

chunk:emit_abc("LOADNIL", 0);
chunk:emit_abc("LOADB", 1, 0, 0);
chunk:emit_abc("LOADB", 2, 1, 0);
chunk:emit_ad("LOADN", 3, 12345);
chunk:emit_ad("LOADN", 4, -15);
chunk:emit_ad("LOADK", 5, chunk:add_constant_number(0.12345));
chunk:emit_ad("LOADK", 6, chunk:add_constant_vector({1, 2, 3, 0}));
chunk:emit_ad("LOADK", 7, chunk:add_constant_string("Hello,"));
chunk:emit_abc("LOADKX", 8, 0, 0, chunk:add_constant_string("World!"));
chunk:emit_abc("MOVE", 9, 2);

chunk:end_function();
local bc = chunk:to_bytecode();

local test: t.TestCase = {
    name = "register_instructions",
    description = "Tests simple LOAD* and MOVE register instructions.",
    bc = bc,
    
    env = {},
    globals = {},

    expected_pc = 11,
    expected_registers = {
        nil,
        false,
        true,
        12345,
        -15,
        0.12345,
        vector.create(1, 2, 3),
        "Hello,",
        "World!",
        true
    },
    expected_env = {},
    expected_globals = {},
    expected_returns = {},
};

return test;
