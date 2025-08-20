local loadstring = require("@luau_toolkit/loadstring");
local vm_conformance = require("@luau_toolkit/vm_conformance");
local process = require("@lune/process")
local stdio = require("@lune/stdio")

local result = vm_conformance.run_tests(function(env, globals, args, bc)
    local out_registers, out_pc;

    local loaded = loadstring(bc, {
        environment = env,
        globals = globals,
        main_exit_callback = function(pc, registers)
            out_registers = registers;
            out_pc = pc;
        end,
    });

    local returns = { loaded(unpack(args)) };
    return out_registers, out_pc, returns;
end);

if result.ok then
    return;
end

for _, result in result.results do
    stdio.ewrite(`{result.name}:\n|   {result.description}\n|\n`);
    for _, issue in result.issues do
        stdio.ewrite(`|   - [{issue.severity}/{issue.type}] {issue.message}\n`);
    end
    stdio.ewrite("\n");
end

process.exit(1);