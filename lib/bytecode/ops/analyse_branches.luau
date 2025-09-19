local instructions = require("../instructions");

local function from_i16(n: number): number
    if n >= 2^(16-1) then
        return n - 2^16;
    end

    return n;
end

local function from_i24(n: number): number    
    if n >= 2^(24 - 1) then
        return n - 2^24;
    end

    return n;
end

local function from_i32(n: number): number    
    if n >= 2^(32 - 1) then
        return n - 2^32;
    end

    return n;
end

function INSN_OP(insn: number): number
    return bit32.extract(insn, 0, 8);
end

function INSN_A(insn: number): number
    return bit32.extract(insn, 8, 8);
end

function INSN_B(insn: number): number
    return bit32.extract(insn, 16, 8);
end

function INSN_C(insn: number): number
    return bit32.extract(insn, 24, 8);
end

function INSN_D(insn: number): number
    return from_i16(bit32.extract(insn, 16, 16));
end

function INSN_E(insn: number): number
    return from_i24(bit32.extract(insn, 8, 24));
end

type JumpTarget = {
    start_pc: number,
    stop_pc: number,

    --- The branch index of the following branch (for fallthrough).
    next_branch: number?,
};

local function analyse_branches(code: buffer): {JumpTarget}
    local targets = {};

    local codesize = buffer.len(code) / 4;
    local pc = 0;

    local function next_insn(): number
        local insn = buffer.readu32(code, pc * 4);
        pc += 1;
        return insn; 
    end

    local function get_target(offset: number, adjust_for_aux: boolean?): number
        if adjust_for_aux then
            if offset < 0 then
                offset = offset;
            else
                offset = offset - 1;
            end
        end

        return pc + offset;
    end

    while pc < codesize do
        local insn = next_insn();
        local opcode = INSN_OP(insn);
        local meta = instructions.get_metadata(opcode) or error("wat");
        local aux = if meta.aux then next_insn() else 0;

        if not meta.has_jump then
            continue;
        end

        for _, operand in meta.operands do
            if not table.find(operand.type, "jump_offset") then
                continue;
            end

            local offset: number;
            if operand.name == "a" then
                offset = INSN_A(insn);
            elseif operand.name == "b" then
                offset = INSN_B(insn);
            elseif operand.name == "c" then
                offset = INSN_C(insn);
            elseif operand.name == "d" then
                offset = INSN_D(insn);
            elseif operand.name == "e" then
                offset = INSN_E(insn);
            elseif operand.name == "aux" then
                offset = from_i32(aux);
            else
                error(`unknown operand name {operand.name}`);
            end

            if (meta.aux and offset == 1) or (not meta.aux and offset == 0) then
                continue;
            end

            local target = get_target(offset, meta.aux);
            if not table.find(targets, target) then
                table.insert(targets, target);
            end
        end
    end

    table.insert(targets, codesize)
    table.sort(targets);

    local branches: {JumpTarget} = {};

    local previous_target = 0;
    for i = 1, #targets do
        local target = targets[i];
        local is_last = i == #targets;
        
        table.insert(branches, {
            start_pc = previous_target,
            stop_pc = target,
            next_branch = if is_last then nil else i + 1;
        });

        previous_target = target;
    end

    return branches;
end

return analyse_branches;