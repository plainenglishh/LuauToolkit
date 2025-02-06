local luau = require("@lune/luau");
local fs = require("@lune/fs");
local vm = require("../modules/vm/lib");
local bytecode = require("../modules/bytecode/lib");

local bc = luau.compile([[
    return(("AHHHHHHHHHH"):lower());
]], {
    optimizationLevel = 0,
});

local function dump_inst(pc, inst, info)
    local operands = "";
    for _, v in info.operands do
        operands ..= `{inst.operands[v.name]}, `;
    end

    print(`    {pc}: {info.name} {operands:sub(1, #operands-2)}`);
end

local fn = vm.new_partial.load(bc);

print({fn()})
