local BytecodeAssembler = require("@luau_toolkit/bytecode").BytecodeAssembler;
local t = require("../types");

local chunk = BytecodeAssembler.new();
chunk:begin_function();
chunk:set_main();

local a_key = chunk:add_constant("string", chunk:add_string("a"));

chunk:emit_instruction("NEWTABLE", 0, 0, 0, 0);
chunk:emit_instruction("GETGLOBAL", 1, 0, 0, a_key);
chunk:emit_instruction("SETTABLEN", 1, 0, 0);

chunk:emit_instruction("GETIMPORT", 1, chunk:add_constant("import", chunk:add_import("b")), chunk:add_import("b"));
chunk:emit_instruction("SETGLOBAL", 1, 0, a_key)

chunk:end_function();
local bc = chunk:assemble();

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
