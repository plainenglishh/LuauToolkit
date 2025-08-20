local BytecodeAssembler = require("@luau_toolkit/bytecode").BytecodeBuilder;
local t = require("../types");

local chunk = BytecodeAssembler.new();
chunk:begin_function();
chunk:set_main();
chunk:end_function();
local bc = chunk:to_bytecode();

local test: t.TestCase = {
    name = "do_nothing",
    description = "Should do nothing.",
    bc = bc,
    
    env = {},
    globals = {},

    expected_pc = 0,
    expected_registers = {},
    expected_env = {},
    expected_globals = {},
    expected_returns = {},
};

return test;
