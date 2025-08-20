local common = require("@luau_toolkit/common");
local StringBuilder = common.StringBuilder;

export type FunctionBuilder = typeof(setmetatable({} :: {
    _name: string?,
    _statements: {string},
}, {} :: FunctionBuilderImpl));

type FunctionBuilderImpl = {
    __index: FunctionBuilderImpl,
    new: () -> FunctionBuilder,
    set_name: (FunctionBuilder, name: string) -> (),
    add_statement: (FunctionBuilder, statement: string) -> (),
    build: (FunctionBuilder) -> string,
};

local FunctionBuilder = {};
FunctionBuilder.__index = FunctionBuilder;

function FunctionBuilder.new(): FunctionBuilder
    return setmetatable({
        _name = nil,
        _statements = {},
    }, FunctionBuilder);
end

function FunctionBuilder.set_name(self: FunctionBuilder, name: string?)
    self._name = name;
end

function FunctionBuilder.add_statement(self: FunctionBuilder, statement: string)
    table.insert(self._statements, statement);
end

function FunctionBuilder.build(self: FunctionBuilder): string
    local builder = StringBuilder.new();

    

    return builder:build();
end

return FunctionBuilder;
