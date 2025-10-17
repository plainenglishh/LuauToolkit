--[=[
    Library containing functions to manipulate bytecode chunks.

    @class bytecode.ops
]=]
local ops = {};

ops.add_string = require("@self/add_string");
ops.strip_unused_strings = require("@self/strip_unused_strings");
ops.analyse_branches = require("@self/analyse_branches");
ops.patch_instructions = require("@self/patch_instructions");
ops.add_breakpoint = require("@self/add_breakpoint");
ops.get_closure_instantiation = require("@self/get_closure_instantiation");
ops.is_closure_cachable = require("@self/is_closure_cachable");

return ops;
