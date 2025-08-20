local function cooerce_string(into: string | buffer): string
    return if type(into) == "buffer" then buffer.tostring(into) else into;
end

type StringBuilderImpl = {
    __index: StringBuilderImpl,
    new: (initial: string | {string}?) -> StringBuilder,
    write: (StringBuilder, str: string | buffer?) -> (),
    writeln: (StringBuilder, str: string | buffer?) -> (),
    writefmt: (StringBuilder, fmt: string, ...any) -> (),
    writelnfmt: (StringBuilder, fmt: string, ...any) -> (),
    build: (StringBuilder) -> string,
};

export type StringBuilder = setmetatable<{
    _strings: {string},
}, StringBuilderImpl>;


local StringBuilder = {};
StringBuilder.__index = StringBuilder;

function StringBuilder.new(initial: string | {string}?): StringBuilder
    local initial: {string} = if type(initial) == "table" then initial elseif type(initial) == "string" then {initial} else {};

    return setmetatable({
        _strings = initial,
    }, StringBuilder);
end

function StringBuilder.write(self: StringBuilder, str: string | buffer?)
    table.insert(self._strings, cooerce_string(str or ""));
end

function StringBuilder.writeln(self: StringBuilder, str: string | buffer?)
    self:write(str);
    table.insert(self._strings, "\n");
end

function StringBuilder.writefmt(self: StringBuilder, fmt: string, ...: any)
    local str: string = (string.format :: any)(cooerce_string(fmt), ...);
    self:write(str);
end

function StringBuilder.writelnfmt(self: StringBuilder, fmt: string, ...: any)
    self:writefmt(fmt, ...);
    table.insert(self._strings, "\n");
end

function StringBuilder.build(self: StringBuilder): string
    return table.concat(self._strings);
end

return StringBuilder;
