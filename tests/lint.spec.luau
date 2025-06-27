local fs = require("@lune/fs");
local process = require("@lune/process");
local stdio = require("@lune/stdio");

stdio.ewrite("temporarily disabled"); process.exit(2); -- Undo after new solver transition

local ok = true;

for _, module in fs.readDir("../modules/") do
    local path = "../modules/"..module;
    local res = process.exec("luau-analyze", {path});
    
    if not res.ok then
        ok = false;
        stdio.ewrite(res.stderr);
    end
end

if not ok then
    process.exit(2);
end
