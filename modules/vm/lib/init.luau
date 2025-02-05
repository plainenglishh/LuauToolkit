local t = require("./typedefs");
local bytecode = require("../../bytecode/lib");

local ERR_START = "\u{001b}[0;1;31m";
local BOLD = "\u{001b}[1m";
local RESET = "\u{001b}[0m";
local GREY = "\u{001b}[30m"

local vm = {};

vm.partial = require("./partial");

local function display_instruction(inst: bytecode.BytecodeInstruction)
    local info = bytecode.get_opcode_info(inst.opcode);
    if not info then
        return `Invalid Instruction {inst.opcode}`;
    end

    local operands = "";
    for _, v in info.operands do
        operands ..= `{inst.operands[v.name]}, `;
    end

    return `{info.name} {operands:sub(1, #operands-2)}`;
end

function vm.display_vm_error(err: t.VMError): string
    if type(err) == "string" then
        return err;
    end

    local lines = {
        `{ERR_START}error:{RESET} {err.type}: {err.message}`,
        `{GREY}--> proto #{err.proto}{RESET}`,
        `{GREY}{err.pc} | {RESET}{display_instruction(err.inst)}`
    };

    return table.concat(lines, "\n");
end

return vm;