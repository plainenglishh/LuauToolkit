--[=[
    Run an example
]=]

local process = require("@lune/process");
local fs = require("@lune/fs");

local example = process.args[1] or error("specify example");
local example_path = "./examples/"..example..".luau";

if not fs.isFile(example_path) then
    error(`unknown example '{example}'`);
end

process.spawn("lune", {"run", example_path}, {
    stdio = "forward",
});