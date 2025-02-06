local luau = require("@lune/luau");
local fs = require("@lune/fs");
local vm = require("../modules/vm/lib");
local bytecode = require("../modules/bytecode/lib");

local bc = luau.compile([[
    local function test()
        print("hi from test");
    end

    test();
]]);

local function dump_inst(pc, inst, info)
    local operands = "";
    for _, v in info.operands do
        operands ..= `{inst.operands[v.name]}, `;
    end

    print(`    {pc}: {info.name} {operands:sub(1, #operands-2)}`);
end

local fn = vm.new_partial.load(bc);

local ok, err = pcall(function()
    return {fn()};
end);

if not ok then
    print(vm.display_vm_error(err :: any));
else
    print(err);
end