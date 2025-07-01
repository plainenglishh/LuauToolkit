local loadstring = require("@luau_toolkit/loadstring")
local fs = require("@lune/fs");
local luau = require("@lune/luau");


local SAMPLE_FILES = "./tests/sample_files/";
local files = fs.readDir(SAMPLE_FILES);

for _, file in files do
    local source = fs.readFile(SAMPLE_FILES..file);
 
    for optimisation_level = 0, 0 do
        --for debug_level = 0, 2 do
            --for coverage_level = 0, 2 do
                local real_bc = buffer.fromstring(luau.compile(source, {
                    optimizationLevel = optimisation_level,
                    --debugLevel = debug_level,
                    --coverageLevel = coverage_level,
                }));

                local loaded = loadstring(real_bc, {
                    chunk_name = `@{file}`,
                    debug_level = 2,
                });

                loaded();

                --[[local ok, err = pcall();

                if not ok then
                    print(err);
                end]]
            --end
        --end
    end
end
