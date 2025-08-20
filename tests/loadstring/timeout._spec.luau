local loadstring = require("@luau_toolkit/loadstring")
local luau = require("@lune/luau")

local bc = luau.compile([[
local start = os.clock();
local inner_timeout = 2;

while true do
    local now = os.clock();
    if now - start >= inner_timeout then
        return;
    end
end
]], {
    optimizationLevel = 0,
    debugLevel = 2,
});

local loaded = loadstring(bc, {
    timeout = 1,
});

local ok, err = pcall(loaded);

if ok then
    error("script failed to timeout");
else
    if err ~= "script timeout" then
        error("script errored: "..err);
    end
end