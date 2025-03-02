--[[local function dump_inst(pc, inst, info)
    local operands = "";
    for _, v in info.operands do
        operands ..= `{inst.operands[v.name]}, `;
    end

    print(`    {pc}: {info.name} {operands:sub(1, #operands-2)}`);
end]]

local luau = require("@lune/luau");
local bytecode = require("@ltk/bytecode");
local vm = require("@ltk/vm");
local common = require("@ltk/common");

local bc = luau.compile([[    
    local function bob(...)
        print(...);
        return "blah", "wah";
    end

    local wehh = {bob("wopp", "plop")};
    print(wehh);
]], {
    optimizationLevel = 0,
});


local fn = vm.partial.load(bc, { globals = common.stdlib, debug_prints = false, });
fn();

--local setup_start = os.clock();
--local setup_stop = os.clock();
--local run_start = os.clock();
--local run_stop = os.clock();
--print(`ltk:\n\trun: {(run_stop - run_start) * 1000}ms`);
