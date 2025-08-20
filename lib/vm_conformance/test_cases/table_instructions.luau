local BytecodeAssembler = require("@luau_toolkit/bytecode").BytecodeBuilder;
local t = require("../types");

local chunk = BytecodeAssembler.new();
chunk:begin_function();
chunk:set_main();

local a_key = chunk:add_constant_string("a");

chunk:emit_abc("NEWTABLE", 0, 0, 0, 0);
chunk:emit_abc("GETGLOBAL", 1, 0, 0, a_key);
chunk:emit_abc("SETTABLEN", 1, 0, 0);

chunk:emit_ad("GETIMPORT", 1, chunk:add_constant_import({"b"}));
chunk:emit_abc("SETGLOBAL", 1, 0, a_key);

chunk:end_function();
local bc = chunk:to_bytecode();

local test: t.TestCase = {
    name = "table_instructions",
    description = "Tests table related instructios, including environment",
    bc = bc,
    
    env = {  },
    globals = { a = true, b = 1 },

    expected_pc = 9,
    expected_registers = {
        { true },
        1,
    },
    expected_env = { a = 1 },
    expected_globals = { a = true, b = 1 },
    expected_returns = {},
};

return test;
