--[[
    This example uses BytecodeBuilder to create a "loop forever" function, that
    infinitely loops using jump instructions.
]]

local luau = require("@lune/luau");
local luau_toolkit = require("../../src/lib");

local chunk = luau_toolkit.bytecode.BytecodeBuilder.new();

chunk:start_proto();
    chunk:set_main();
    chunk:set_debug_name("loop_forever");
    local I_print = chunk:add_import("print");

    chunk:add_instruction("GETIMPORT", 0, chunk:add_constant("import", I_print), I_print);
    chunk:add_instruction("LOADK", 1, chunk:add_constant("string", chunk:add_string("looping...")));

    local L0 = chunk:add_instruction("CALL", 0, 2, 1);
    chunk:add_instruction("JUMP", L0 - (chunk:get_offset() + 1));
chunk:end_proto();

print("building bytecode...");
local bytecode = chunk:build_bc();

print("loading bytecode chunk...");
local loaded_chunk = luau.load(buffer.tostring(bytecode));

print("running loaded chunk...");
loaded_chunk();

