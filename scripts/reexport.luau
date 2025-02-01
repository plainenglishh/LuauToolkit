--[=[
    A script for automatically generating a table of metadata about luau
    bytecode using `Common/include/Luau/Bytecode.h`.
]=]

--!nonstrict

local net = require("@lune/net");
local fs = require("@lune/fs");

local typedefs = fs.readFile("./src/lib/typedefs.luau");
local reexports = "";

for name in string.gmatch(typedefs, "export type ([_%a][_%w]*)") do
    reexports ..= `export type {name} = t.{name};\n`;
end

local root = fs.readFile("./src/lib/init.luau");
root = string.gsub(root, "%-%-BEGIN_REEXPORTS(.-)%-%-END_REEXPORTS", "--BEGIN_REEXPORTS\n"..reexports.."--BEGIN_REEXPORTS");
fs.writeFile("./src/lib/init.luau", root);