local process = require("@lune/process");
local stdio = require("@lune/stdio");

stdio.ewrite("temporarily disabled"); process.exit(2); -- Undo after new solver transition

local function starts_with(str: string, with: string)
    return string.sub(str, 0, #with) == with;
end

local res = process.exec("luau-analyze", {"--mode=strict", "--formatter=gnu", "./lib/"});
local lines = string.split(res.stderr, "\n");
for _, line in lines do
    if not starts_with(line, "./lib/") then
        continue;
    end

    stdio.ewrite(line.."\n");
end

if not res.ok then
    process.exit(1);
elseif res.stderr ~= "" then
    process.exit(2);
end
