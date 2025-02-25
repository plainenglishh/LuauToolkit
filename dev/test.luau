--[[local function dump_inst(pc, inst, info)
    local operands = "";
    for _, v in info.operands do
        operands ..= `{inst.operands[v.name]}, `;
    end

    print(`    {pc}: {info.name} {operands:sub(1, #operands-2)}`);
end]]

local bytecode = require("../bytecode");
local fs = require("@lune/fs");

local luau = require("@lune/luau");
local vm = require("../vm");


--[=[]]
local bc = luau.compile([[
    for i = 1, 5000 do
        print("Department for Environment, Food and Rural Affairs");
    end
]], {
    optimizationLevel = 2,
});
--[=[]]
fs.writeFile("test.luauc", bc)

local bc = fs.readFile("test.luauc");
]=]

local chunk = bytecode.BytecodeBuilder.new();

chunk:start_proto();
    chunk:set_main();
    chunk:add_instruction("COVERAGE", 0);
    chunk:add_instruction("JUMP", -2);
chunk:end_proto();

local bc = chunk:build_bc();

local setup_start = os.clock();
local fn = vm.new_partial.load(bc);
local setup_stop = os.clock();

local run_start = os.clock();
fn();
local run_stop = os.clock();

print(`ltk:\n\tsetup: {(setup_stop - setup_start) * 1000}ms\n\trun: {(run_stop - run_start) * 1000}ms`);
