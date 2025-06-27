local fs = require("@lune/fs");
local luau = require("@lune/luau");
local bytecode = require("@luau_toolkit/bytecode");
local testing = require("@testing/utils");

local SAMPLE_FILES = "./tests/sample_files/";
local files = fs.readDir(SAMPLE_FILES);

for _, file in files do
    local source = fs.readFile(SAMPLE_FILES..file);
 
    for optimisation_level = 0, 2 do
        for debug_level = 0, 2 do
            for coverage_level = 0, 2 do
                local bc = buffer.fromstring(luau.compile(source, {
                    optimizationLevel = optimisation_level,
                    debugLevel = debug_level,
                    coverageLevel = coverage_level,
                }));

                local chunk = bytecode.chunk.decode(bc);
                
                for _, proto in chunk.protos do
                    proto.instructions = bytecode.instructions.encode(bytecode.instructions.decode(proto.instructions));
                end

                local serde_bc = bytecode.chunk.encode(chunk);
                testing.assert_eq(bc, serde_bc, `not equal! file="{file}", optimisation_level={optimisation_level}, debug_level={debug_level}, coverage_level={coverage_level}`);
            end
        end
    end
end
