local BytecodeAssembler = require("@luau_toolkit/bytecode").BytecodeAssembler;
local t = require("../types");

local chunk = BytecodeAssembler.new();
chunk:begin_function();
chunk:set_main();

chunk:emit_instruction("LOADNIL", 0);
chunk:emit_instruction("LOADB", 1, 0, 0);
chunk:emit_instruction("LOADB", 2, 1, 0);
chunk:emit_instruction("LOADN", 3, 12345);
chunk:emit_instruction("LOADN", 4, -15);
chunk:emit_instruction("LOADK", 5, chunk:add_constant("number", 0.12345));
chunk:emit_instruction("LOADK", 6, chunk:add_constant("vector", {1, 2, 3, 0}));
chunk:emit_instruction("LOADK", 7, chunk:add_constant("string", chunk:add_string("Hello,")));
chunk:emit_instruction("LOADKX", 8, 0, 0, chunk:add_constant("string", chunk:add_string("World!")));
chunk:emit_instruction("MOVE", 9, 2);

chunk:end_function();
local bc = chunk:assemble();

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
