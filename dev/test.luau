local luau = require("@lune/luau");
local fs = require("@lune/fs");
local vm = require("../modules/vm/lib");
local bytecode = require("../modules/bytecode/lib");

local bc = luau.compile([[
    return math.atan(1);
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
    math = math,
}, {
    step_callback = dump_inst
});

local ok, err = pcall(fn);
if not ok then
    print(vm.display_vm_error(err));
else
    print({err});
end