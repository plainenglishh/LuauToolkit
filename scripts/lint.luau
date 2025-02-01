--depends on luau-analyze

local process = require("@lune/process");

print("linting...");

local res = process.spawn("luau-analyze", {"--mode=strict", "./src/lib/init.luau"});
if not res.ok then
    error(res.stderr);
end

print(res.stdout);
