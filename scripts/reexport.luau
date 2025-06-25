--[=[
    A script for automatically generating type reexports.
]=]

local fs = require("@lune/fs");

local paths = {
    "./Bytecode",
    "./VM",
};

for _, path in paths do
    local types = fs.readFile(`{path}/src/types.luau`);
    local reexports = "";
    local type_constructors = "";
    
    for name in string.gmatch(types, "export type ([_%a][_%w]*)") do
        reexports ..= `export type {name} = t.{name};\n`;
    end
    
    for name, args in string.gmatch(types, "function t%.([_%a][_%w]*)%((.-)%)") do
        type_constructors ..= `    {name}: ({args}) -> {name},\n`;
        reexports ..= `luau_toolkit.{name} = t.{name};\n`;
    end
    
    types = string.gsub(types, "%-%-BEGIN_TYPE_CONSTRUCTORS(.-)%-%-END_TYPE_CONSTRUCTORS", "--BEGIN_TYPE_CONSTRUCTORS\n"..type_constructors.."--END_TYPE_CONSTRUCTORS");
    fs.writeFile(`{path}/src/types.luau`, types);
    
    local root = fs.readFile(`{path}/init.luau`);
    root = string.gsub(root, "%-%-BEGIN_REEXPORTS(.-)%-%-END_REEXPORTS", "--BEGIN_REEXPORTS\n"..reexports.."--END_REEXPORTS");
    fs.writeFile(`{path}/init.luau`, root);
end

