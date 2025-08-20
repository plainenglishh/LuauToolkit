--[=[
    Parses aliases from a .luaurc
]=]
local function parse_aliases(luaurc: string): {[string]: string}
    -- It's messy, but it works... I'm not pulling in an entire JSON parser.
    local alias_inner = string.match(luaurc, "\"aliases\"%s*:%s*{(.-)}");
    if not alias_inner then
        return {};
    end

    local aliases = {};
    for alias, value in string.gmatch(alias_inner, "\"(.-)\"%s*:%s*\"(.-)\",?") do
        aliases[alias] = value;
    end
    
    return aliases;
end

export type ResolverOptions = {
    project_root: string,
    read_file: (path: string) -> string,
    read_dir: (path: string) -> {string},
};

export type Resolver = setmetatable<{
    _options: ResolverOptions,
}, {
    __index: getmetatable<Resolver>,
    new: (options: ResolverOptions) -> Resolver,
    _read_file: (self: Resolver, path: string) -> string,
    _read_dir: (self: Resolver, path: string) -> {string},
    resolve: (self: Resolver, src_path: string, require_path: string) -> (boolean, string),
}>;

local Resolver = {};
Resolver.__index = Resolver;

function Resolver.new(options: ResolverOptions): Resolver
    return setmetatable({
        _options = options,
    }, Resolver);
end

function Resolver._read_file(self: Resolver, path: string): string
    return self._options.read_file(path);
end

function Resolver._read_dir(self: Resolver, path: string): {string}
    return self._options.read_dir(path);
end

function Resolver.resolve(self: Resolver, src_path: string, require_path: string): (boolean, string)
    return false, "unimplemented";
end

return Resolver;
