--[=[
    Library for decompiling Luau bytecode chunks.
]=]
local decompiler = {};

local bytecode = require("@luau_toolkit/bytecode")
local executable_decompile = require("@self/executable");

export type DecompilerOptions = executable_decompile.Options;

local DEFAULT_DECOMPILER_OPTIONS: DecompilerOptions = { 
    mode = "executable" :: "executable" 
};

--[=[
    Decompiles a Luau bytecode chunk into a source code representation.    

    ## Decompilation Modes

    ### 1. `executable`

    The `executable` decompilation mode emits source that when executed has the
    same functionality as the input bytecode. This mode converts instructions to
    equivalent statements, and is not intended for analysis or reverse 
    engineering.
]=]
function decompiler.decompile(chunk: string | buffer | bytecode.Chunk, options: DecompilerOptions?): string
    local chunk = if type(chunk) == "table" then chunk else bytecode.chunk.decode(chunk);
    local options = options or DEFAULT_DECOMPILER_OPTIONS;

    if options.mode == "executable" then
        return executable_decompile(chunk, options :: executable_decompile.Options)
    else
        error(`unknown decompilation mode '{options.mode}'`, 2);
    end
end

return decompiler;
