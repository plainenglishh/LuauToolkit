--[=[
    Module for programmatically generating Luau source code.
]=]
local sourcegen = {};

local FunctionBuilder = require("@self/FunctionBuilder");
export type FunctionBuilder = FunctionBuilder.FunctionBuilder;
sourcegen.FunctionBuilder = FunctionBuilder;

return sourcegen;
