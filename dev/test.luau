local luau = require("@lune/luau");
local vm = require("../modules/vm/lib");
local bytecode = require("../modules/bytecode/lib");

local bc = luau.compile([[
    return ("hello"):upper();
]]);

local function dump_inst(pc, inst, info)
    local operands = "";
    for _, v in info.operands do
        operands ..= `{inst.operands[v.name]}, `;
    end

    print(`    {pc}: {info.name} {operands:sub(1, #operands-2)}`);
end

local fn = vm.partial.load(bc, {
    print = print,
}, {
    step_callback = dump_inst
});

fn();