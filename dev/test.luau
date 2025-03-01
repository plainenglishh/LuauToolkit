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
local vm = require("@ltk/vm");
local common = require("@ltk/common");

local bc = luau.compile([[    
    for i, v in ipairs({ "a", "b", "c" }) do
        print(i, v);
    end
]], {
    optimizationLevel = 2,
});

local fn = vm.partial.load(bc, { globals = common.stdlib, debug_prints = false, });
fn();

--local setup_start = os.clock();
--local setup_stop = os.clock();
--local run_start = os.clock();
--local run_stop = os.clock();
--print(`ltk:\n\tsetup: {(setup_stop - setup_start) * 1000}ms\n\trun: {(run_stop - run_start) * 1000}ms`);
