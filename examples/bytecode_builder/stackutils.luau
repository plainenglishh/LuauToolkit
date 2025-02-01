--[[
    This example uses BytecodeBuilder to create a "stackutils" module, which returns
    as many values from the stack as it can.
]]

local luau = require("@lune/luau");
local luau_toolkit = require("../../src/lib");

local chunk = luau_toolkit.bytecode.BytecodeBuilder.new();

local P_get_snapshot = chunk:start_proto();
    chunk:set_max_stack_size(255);
    chunk:add_instruction("RETURN", 0, 0);
chunk:end_proto();

local P_dump_stack = chunk:start_proto();
    chunk:set_debug_name("dump_stack");
    chunk:add_instruction("NEWTABLE", 0);
    chunk:add_instruction("DUPCLOSURE", 1, chunk:add_constant("closure", P_get_snapshot));
    chunk:add_instruction("CALL", 1, 1, 0);
    chunk:add_instruction("SETLIST", 0, 2, 0, 1);
    chunk:add_instruction("RETURN", 0, 2);
chunk:end_proto();

local P_get_stack_size = chunk:start_proto();
    chunk:set_debug_name("get_stack_size");
    chunk:add_instruction("DUPCLOSURE", 0, chunk:add_constant("closure", P_dump_stack));
    chunk:add_instruction("CALL", 0, 1, 0);
    chunk:add_instruction("LENGTH", 1, 1);
    chunk:add_instruction("RETURN", 1, 2);
chunk:end_proto();

chunk:start_proto();
    chunk:set_main();
    chunk:set_debug_name("stack_utils");

    chunk:add_instruction("NEWTABLE", 0);
    
    chunk:add_instruction("LOADK", 1, chunk:add_constant("closure", P_dump_stack));
    chunk:add_instruction("SETTABLEKS", 1, 0, 0, chunk:add_constant("string", chunk:add_string("dump_stack")));

    chunk:add_instruction("LOADK", 1, chunk:add_constant("closure", P_get_stack_size));
    chunk:add_instruction("SETTABLEKS", 1, 0, 0, chunk:add_constant("string", chunk:add_string("get_stack_size")));

    chunk:add_instruction("RETURN", 0, 2);
chunk:end_proto();

print("building bytecode...");
local bytecode = chunk:build_bc();

print("loading bytecode chunk...");
local loaded_chunk = luau.load(buffer.tostring(bytecode));

print("running loaded chunk...");
local stack_utils = loaded_chunk();
print(stack_utils);

print("running `stack_utils.dump_stack`...");
print(stack_utils.dump_stack());

print("running `stack_utils.get_stack_size`...");
print(stack_utils.get_stack_size());
