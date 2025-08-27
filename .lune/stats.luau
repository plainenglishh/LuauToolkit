local fs = require("@lune/fs");
local luau = require("@lune/luau");
local bytecode = require("@luau_toolkit/bytecode");

local SOURCES = {
    "./lib",
    "./bin"
};

local EXCLUDES = {
    "./lib/common/byteparse.luau",
    "./lib/common/int64.luau",
};

local function read_dir_recursive(path: string): {string}
    path = string.gsub(path, "/$", "");
    local files = {};

    local function recurse(path)
        if fs.isFile(path) then
            table.insert(files, path);
            return;
        end

        for _, elem in fs.readDir(path) do
            recurse(`{path}/{elem}`);
        end
    end

    recurse(path);

    return files;
end

local files = 0;
local lines = 0;
local functions = 0;
local instructions = 0;
local strings = 0;

for _, dir in SOURCES do
    for _, file in read_dir_recursive(dir) do
        if string.sub(file, -5) ~= ".luau" or table.find(EXCLUDES, file) then
            continue;
        end

        files += 1;
        local src = fs.readFile(file);

        lines += #string.split(src);
        local bc = luau.compile(src, {optimizationLevel = 2, debugLevel = 0});
        local chunk = bytecode.chunk.decode(bc);
        
        strings += #chunk.strings;

        for _, proto in chunk.protos do
            functions += 1;
            instructions += #bytecode.instructions.decode(proto.instructions);
        end
    end
end

print(`files:        {files}`);
print(`lines:        {lines}`);
print(`functions:    {functions}`);
print(`instructions: {instructions}`);
print(`strings:      {strings}`);