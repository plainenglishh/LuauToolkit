--[=[
    A script for automatically generating type reexports.
]=]

local fs = require("@lune/fs");

local typedefs = fs.readFile("./src/lib/typedefs.luau");
local reexports = "";
local type_constructors = "";

for name in string.gmatch(typedefs, "export type ([_%a][_%w]*)") do
    reexports ..= `export type {name} = t.{name};\n`;
end

for name, args in string.gmatch(typedefs, "function t%.([_%a][_%w]*)%((.-)%)") do
    type_constructors ..= `    {name}: ({args}) -> {name},\n`;
    reexports ..= `luau_toolkit.{name} = t.{name};\n`;
end

typedefs = string.gsub(typedefs, "%-%-BEGIN_TYPE_CONSTRUCTORS(.-)%-%-END_TYPE_CONSTRUCTORS", "--BEGIN_TYPE_CONSTRUCTORS\n"..type_constructors.."--END_TYPE_CONSTRUCTORS");
fs.writeFile("./src/lib/typedefs.luau", typedefs);

local root = fs.readFile("./src/lib/init.luau");
root = string.gsub(root, "%-%-BEGIN_REEXPORTS(.-)%-%-END_REEXPORTS", "--BEGIN_REEXPORTS\n"..reexports.."--END_REEXPORTS");
fs.writeFile("./src/lib/init.luau", root);
