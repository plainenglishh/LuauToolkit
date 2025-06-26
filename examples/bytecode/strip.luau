--[[
    Lune example demonstrating the `bytecode` module.

    This script accepts a `.luauc` and strips all unnecessary from the chunk.  
]]

local process = require("@lune/process");
local stdio = require("@lune/stdio");
local bytecode = require("@luau_toolkit/bytecode");
local fs = require("@lune/fs")

local CLI_ERROR_PREFIX = `{stdio.color("red")}error: {stdio.color("reset")}`;

local function strip(bc: buffer|string): buffer
    local chunk = bytecode.chunk.decode(bc);

    chunk.userdata_types = nil;

    for _, proto in chunk.protos do
        proto.debug_name = 0;
        proto.debug_info = nil;
        proto.line_info = nil;
        proto.types = nil;
    end

    bytecode.util.strip_unused_strings(chunk);

    return bytecode.chunk.encode(chunk);
end

local function cli_error(message: string): never
    stdio.ewrite(CLI_ERROR_PREFIX .. message);
    return process.exit(1);
end

local function main(args: {string})
    local input = args[1] or cli_error("specify input as first argument");
    local output = args[2] or cli_error("specify input as second argument");

    if not fs.isFile(input) then
        cli_error(`file '{input}' doesn't exist`);
    end

    local bc = fs.readFile(input);
    local stripped_bc = strip(bc);
    fs.writeFile(output, stripped_bc);

    return 0;
end

main(process.args);