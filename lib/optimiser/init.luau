export type Program = buffer | {[string]: buffer};
export type OptimiseOptions = {
    bundle: boolean?,
    optimisations: {
        --[=[
            Removes unused 
        ]=]
        dead_code_elimination: boolean?,
        constant_folding: boolean?,
    }?,
};

--[=[
    Library for optimising Luau projects.
]=]
local optimiser = {};

function optimiser.optimise(program: Program, options: OptimiseOptions?): Program

end

-- dead-code elimination

return optimiser;
