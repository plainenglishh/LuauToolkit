--!native

--[[
    This is a prototype!

    Todo:
    - Pick a better name
    - Add namespace for internal vars as to not conflict with GET/SETGLOBAL
    - Use string escapes rather than surrounding strings with long brackets.
    - Multret
    - Upvalues

    Potential optimisations:
    - handle fastcalls properly
]]

local bytecode = require("@luau_toolkit/bytecode");

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

local function to_i24(n: number): number    
    if n < 0 then
        return n + 2^24;
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

type Branch = {
    start_pc: number,
    stop_pc: number,

    --- The branch index of the following branch (for fallthrough).
    next_branch: number?,
};

type SourceBuilder = {
    writeln: (str: string?) -> (),
    indent: (by: number?) -> (),
    dedent: (by: number?) -> (),
};

export type Options = {
    mode: "executable",
};

--[=[
    Divides an instruction buffer into 'branches' according to jump targets.
]=]
local function analyse_branches(code: buffer): {Branch}
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
        local meta = bytecode.instructions.get_metadata(opcode) or error("wat");
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

    local branches: {Branch} = {};

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

local HEADER = [[
--!nolint
--!optimize 2

local function iterate(...: any): () -> {any}?
	local thread = coroutine.create(function(...: any)
        for v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22, v23, v24, v25, v26, v27, v28, v29, v30, v31, v32, v33, v34, v35, v36, v37, v38, v39, v40, v41, v42, v43, v44, v45, v46, v47, v48, v49, v50, v51, v52, v53, v54, v55, v56, v57, v58, v59, v60, v61, v62, v63, v64, v65, v66, v67, v68, v69, v70, v71, v72, v73, v74, v75, v76, v77, v78, v79, v80, v81, v82, v83, v84, v85, v86, v87, v88, v89, v90, v91, v92, v93, v94, v95, v96, v97, v98, v99, v100, v101, v102, v103, v104, v105, v106, v107, v108, v109, v110, v111, v112, v113, v114, v115, v116, v117, v118, v119, v120, v121, v122, v123, v124, v125, v126, v127, v128, v129, v130, v131, v132, v133, v134, v135, v136, v137, v138, v139, v140, v141, v142, v143, v144, v145, v146, v147, v148, v149, v150, v151, v152, v153, v154, v155, v156, v157, v158, v159, v160, v161, v162, v163, v164, v165, v166, v167, v168, v169, v170, v171, v172, v173, v174, v175, v176, v177, v178, v179, v180, v181, v182, v183, v184, v185, v186, v187, v188, v189, v190, v191, v192, v193, v194, v195, v196, v197, v198 in ... do
            coroutine.yield({ v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22, v23, v24, v25, v26, v27, v28, v29, v30, v31, v32, v33, v34, v35, v36, v37, v38, v39, v40, v41, v42, v43, v44, v45, v46, v47, v48, v49, v50, v51, v52, v53, v54, v55, v56, v57, v58, v59, v60, v61, v62, v63, v64, v65, v66, v67, v68, v69, v70, v71, v72, v73, v74, v75, v76, v77, v78, v79, v80, v81, v82, v83, v84, v85, v86, v87, v88, v89, v90, v91, v92, v93, v94, v95, v96, v97, v98, v99, v100, v101, v102, v103, v104, v105, v106, v107, v108, v109, v110, v111, v112, v113, v114, v115, v116, v117, v118, v119, v120, v121, v122, v123, v124, v125, v126, v127, v128, v129, v130, v131, v132, v133, v134, v135, v136, v137, v138, v139, v140, v141, v142, v143, v144, v145, v146, v147, v148, v149, v150, v151, v152, v153, v154, v155, v156, v157, v158, v159, v160, v161, v162, v163, v164, v165, v166, v167, v168, v169, v170, v171, v172, v173, v174, v175, v176, v177, v178, v179, v180, v181, v182, v183, v184, v185, v186, v187, v188, v189, v190, v191, v192, v193, v194, v195, v196, v197, v198 });
        end
    end);

    local iter_values = { ... };
    local first_iteration = true;

    return function(): {any}?
        if coroutine.status(thread) == "dead" then
            return nil;
        end

        local ok, values: any = coroutine.resume(
            thread, 
            if first_iteration then unpack(iter_values) else nil
        );

        if not ok then
            return error(values, 2);
        end

        if not values then
            return nil;
        end

        return values;
    end
end

]];

local function decompile_instructions(src: SourceBuilder, chunk: bytecode.Chunk, proto: bytecode.Proto, start_pc: number, stop_pc: number, branches: {Branch})
    local pc = start_pc;
    local code = proto.instructions;

    local function get_branch(offset: number, adjust_for_aux: boolean?): Branch
        if adjust_for_aux then
            if offset < 0 then
                offset = offset;
            else
                offset = offset - 1;
            end
        end

        local start_pc = pc + offset;

        for i, v in branches do
            if v.start_pc == start_pc then
                return v;
            end
        end
        
        error("invalid branch, are you accounting for AUX or properly skipping 0 jumps");
    end

    local function next_insn(): number
        local insn = buffer.readu32(code, pc * 4);
        pc += 1;
        return insn; 
    end

    local function jump(offset: number, adjust_for_aux: boolean)
        if (adjust_for_aux and offset == 1) or (not adjust_for_aux and offset == 0) then
            return;
        end
        src.writeln(`do jump_dispatch = {get_branch(offset, adjust_for_aux).start_pc}; continue; end`);
    end

    local function skip()
        src.writeln("-- Instruction Skipped; no effect.");
    end

    --[[local function fastcall(id: number, args: {string})
        src.writeln("");
        --local builtin = bytecode.constants.builtin_names[id];
        --src.writeln("");
    end]]

    local function get_string(const_ref: number)
        return `S{proto.constants[const_ref + 1].value}`;
    end

    while pc < stop_pc do
        local insn = next_insn();
        local opcode = INSN_OP(insn);
        local meta = bytecode.instructions.get_metadata(opcode) or error("");

        src.writeln(`--// Instruction {meta.name} (pc={pc}):`)

        if opcode == 0 then -- NOP
            skip();
        elseif opcode == 1 then -- BREAK
            skip();
        elseif opcode == 2 then -- LOADNIL
            src.writeln(`R[{INSN_A(insn) + 1}] = nil;`);
        elseif opcode == 3 then -- LOADB
            src.writeln(`R[{INSN_A(insn) + 1}] = {INSN_B(insn) ~= 0};`);
            jump(INSN_C(insn), false);
        elseif opcode == 4 then -- LOADN
            src.writeln(`R[{INSN_A(insn) + 1}] = {INSN_D(insn)};`);
        elseif opcode == 5 then -- LOADK
            src.writeln(`R[{INSN_A(insn) + 1}] = K{INSN_D(insn)};`);
        elseif opcode == 6 then -- MOVE
            src.writeln(`R[{INSN_A(insn) + 1}] = R[{INSN_B(insn) + 1}];`);
        elseif opcode == 7 then -- GETGLOBAL
            local name = chunk.strings[proto.constants[next_insn() + 1].value];
            src.writeln(`R[{INSN_A(insn) + 1}] = {name};`);
        elseif opcode == 8 then -- SETGLOBAL
            src.writeln(`{get_string(next_insn())} = R[{INSN_A(insn) + 1}];`);
        elseif opcode == 9 then -- GETUPVAL
            error("upvalue");
        elseif opcode == 10 then -- SETUPVAL
            error("upvalue");
        elseif opcode == 11 then -- CLOSEUPVALS
            error("upvalue");
        elseif opcode == 12 then -- GETIMPORT
            src.writeln(`R[{INSN_A(insn) + 1}] = K{INSN_D(insn)}`);
            next_insn();
        elseif opcode == 13 then -- GETTABLE
            src.writeln(`R[{INSN_A(insn) + 1}] = R[{INSN_B(insn) + 1}][R[{INSN_C(insn) + 1}]]`);
        elseif opcode == 14 then -- SETTABLE
            src.writeln(`R[{INSN_B(insn) + 1}][R[{INSN_C(insn) + 1}]] = R[{INSN_A(insn) + 1}]`);
        elseif opcode == 15 then -- GETTABLEKS
            src.writeln(`R[{INSN_A(insn) + 1}] = R[{INSN_B(insn) + 1}][{get_string(next_insn())}]`);
        elseif opcode == 16 then -- SETTABLEKS
            src.writeln(`R[{INSN_B(insn) + 1}][{get_string(next_insn())}] = R[{INSN_A(insn) + 1}]`);
        elseif opcode == 17 then -- GETTABLEN
            src.writeln(`R[{INSN_A(insn) + 1}] = R[{INSN_B(insn) + 1}][{INSN_C(insn) + 1}]`);
        elseif opcode == 18 then -- SETTABLEN
            src.writeln(`R[{INSN_B(insn) + 1}][{INSN_C(insn) + 1}] = R[{INSN_A(insn) + 1}]`);
        elseif opcode == 19 then -- NEWCLOSURE
            local target = INSN_A(insn);
            local child_proto_id = INSN_D(insn);
            local proto_ref = proto.child_protos[child_proto_id + 1];
            --local upvalues = {};

            while true do
                if pc == stop_pc then
                    break;
                end

                local insn = next_insn();
                local op = INSN_OP(insn);
                if op ~= 70 then
                    pc -= 1;
                    break;
                end

                error("upvalue");
            end

            src.writeln(`R[{target + 1}] = P{proto_ref};`)
        elseif opcode == 20 then -- NAMECALL
            local target = INSN_A(insn);
            local source = INSN_B(insn);
            local key = get_string(next_insn());
            src.writeln("do");
            src.indent();
            src.writeln(`local object = R[{source + 1}];`);
            src.writeln(`local namecall_fn = object[{key}];`);
            src.writeln(`R[{target + 1}] = namecall_fn;`);
            src.writeln(`R[{target + 2}] = object;`);
            src.dedent();
            src.writeln("end");
        elseif opcode == 21 then -- CALL
            local func = INSN_A(insn);
            local arg_count = INSN_B(insn) - 1;
            local ret_count = INSN_C(insn) - 1;

            if arg_count == -1 or ret_count == -1 then
                src.writeln("do");
                src.indent();
            end

            local callsite;
            if arg_count == -1 then
                src.writeln(`local args: \{any} = table.create(top - {func + 2});`);
                src.writeln(`table.move(R, {func + 2}, top - 1, 1, args);`);
                callsite = `R[{func + 1}](unpack(args))`;
            else
                local args = "";
                for i = 1, arg_count do
                    if i ~= 1 then
                    args ..= ", ";
                end
                    args ..= `R[{func + i + 1}]`;
                end
                
                callsite = `R[{func + 1}]({args})`;
            end        

            if ret_count == -1 then
                src.writeln(`local results = \{ {callsite} };`)
                src.writeln(`table.move(results, 1, #results, {func + 1}, R);`)
                src.writeln(`top = {func + 1} + #results;`)
            else
                if ret_count > 0 then
                    local assignments = "";
                    for i = 1, ret_count do
                        if i ~= 1 then
                            assignments ..= ",";
                        end
                        assignments ..= `R[{func + i}]`;
                    end
                    
                    src.writeln(`{assignments} = {callsite};`);
                else
                    src.writeln(`{callsite};`);
                end
            end

            if arg_count == -1 or ret_count == -1 then
                src.dedent();
                src.writeln("end");
            end
        elseif opcode == 22 then -- RETURN
            local results_start = INSN_A(insn);
            local results_count = INSN_B(insn) - 1;

            if results_count == -1 then
                src.writeln("do");
                src.indent();
                src.writeln(`local results: \{any} = table.create(top - {results_start + 1});`);
                src.writeln(`table.move(R, {results_start + 1}, top - 1, 1, results);`);
                src.writeln("return unpack(results);")
                src.dedent();
                src.writeln("end");
            else
                local args = "";
                for i = 1, results_count do
                    if i ~= 1 then
                        args ..= ",";
                    end
    
                    args ..= " ";
                    args ..= `R[{results_start + i}]`;
                end
    
                src.writeln(`do return{args}; end`);
            end
        elseif opcode == 23 then -- JUMP
            jump(INSN_D(insn), false);
        elseif opcode == 24 then -- JUMPBACK
            jump(INSN_D(insn), false);
        elseif opcode == 25 then -- JUMPIF
            src.writeln(`if R[{INSN_A(insn) + 1}] then`)
            src.indent();
            jump(INSN_D(insn), false);
            src.dedent();
            src.writeln("end");
        elseif opcode == 26 then -- JUMPIFNOT
            src.writeln(`if not R[{INSN_A(insn) + 1}] then`)
            src.indent();
            jump(INSN_D(insn), false);
            src.dedent();
            src.writeln("end");
        elseif opcode == 27 then -- JUMPIFEQ
            src.writeln(`if R[{INSN_A(insn) + 1}] == R[{next_insn() + 1}] then`);
            src.indent();
            jump(INSN_D(insn), true);
            src.dedent();
            src.writeln("end");
        elseif opcode == 28 then -- JUMPIFLE
            src.writeln(`if R[{INSN_A(insn) + 1}] <= R[{next_insn() + 1}] then`);
            src.indent();
            jump(INSN_D(insn), true);
            src.dedent();
            src.writeln("end");
        elseif opcode == 29 then -- JUMPIFLT
            src.writeln(`if R[{INSN_A(insn) + 1}] < R[{next_insn() + 1}] then`);
            src.indent();
            jump(INSN_D(insn), true);
            src.dedent();
            src.writeln("end");
        elseif opcode == 30 then -- JUMPIFNOTEQ
            src.writeln(`if R[{INSN_A(insn) + 1}] ~= R[{next_insn() + 1}] then`);
            src.indent();
            jump(INSN_D(insn), true);
            src.dedent();
            src.writeln("end");
        elseif opcode == 31 then -- JUMPIFNOTLE
            src.writeln(`if R[{INSN_A(insn) + 1}] > R[{next_insn() + 1}] then`);
            src.indent();
            jump(INSN_D(insn), true)
            src.dedent();
            src.writeln("end");
        elseif opcode == 32 then -- JUMPIFNOTLT
            src.writeln(`if R[{INSN_A(insn) + 1}] >= R[{next_insn() + 1}] then`);
            src.indent();
            jump(INSN_D(insn), true);
            src.dedent();
            src.writeln("end");
        elseif opcode == 33 then -- ADD
            src.writeln(`R[{INSN_A(insn) + 1}] = R{INSN_B(insn) + 1} + R{INSN_C(insn) + 1}`);
        elseif opcode == 34 then -- SUB
            src.writeln(`R[{INSN_A(insn) + 1}] = R{INSN_B(insn) + 1} - R{INSN_C(insn) + 1}`);
        elseif opcode == 35 then -- MUL
            src.writeln(`R[{INSN_A(insn) + 1}] = R{INSN_B(insn) + 1} * R{INSN_C(insn) + 1}`);
        elseif opcode == 36 then -- DIV
            src.writeln(`R[{INSN_A(insn) + 1}] = R{INSN_B(insn) + 1} / R{INSN_C(insn) + 1}`);
        elseif opcode == 37 then -- MOD
            src.writeln(`R[{INSN_A(insn) + 1}] = R{INSN_B(insn) + 1} % R{INSN_C(insn) + 1}`);
        elseif opcode == 38 then -- POW
            src.writeln(`R[{INSN_A(insn) + 1}] = R{INSN_B(insn) + 1} % R{INSN_C(insn) + 1}`);
        elseif opcode == 39 then -- ADDK
            src.writeln(`R[{INSN_A(insn) + 1}] = R[{INSN_B(insn) + 1}] + K{INSN_C(insn)}`);
        elseif opcode == 40 then -- SUBK
            src.writeln(`R[{INSN_A(insn) + 1}] = R[{INSN_B(insn) + 1}] / K{INSN_C(insn)}`);
        elseif opcode == 41 then -- MULK
            src.writeln(`R[{INSN_A(insn) + 1}] = R[{INSN_B(insn) + 1}] * K{INSN_C(insn)}`);
        elseif opcode == 42 then -- DIVK
            src.writeln(`R[{INSN_A(insn) + 1}] = R[{INSN_B(insn) + 1}] / K{INSN_C(insn)}`);
        elseif opcode == 43 then -- MODK
            src.writeln(`R[{INSN_A(insn) + 1}] = R[{INSN_B(insn) + 1}] % K{INSN_C(insn)}`);
        elseif opcode == 44 then -- POWK
            src.writeln(`R[{INSN_A(insn) + 1}] = R[{INSN_B(insn) + 1}] ^ K{INSN_C(insn)}`);
        elseif opcode == 45 then -- AND
            src.writeln(`R[{INSN_A(insn) + 1}] = R{INSN_B(insn) + 1} and R{INSN_C(insn) + 1}`);
        elseif opcode == 46 then -- OR
            src.writeln(`R[{INSN_A(insn) + 1}] = R{INSN_B(insn) + 1} or R{INSN_C(insn) + 1}`);
        elseif opcode == 47 then -- ANDK
            src.writeln(`R[{INSN_A(insn) + 1}] = R[{INSN_B(insn) + 1}] and K{INSN_C(insn)}`);
        elseif opcode == 48 then -- ORK
            src.writeln(`R[{INSN_A(insn) + 1}] = R[{INSN_B(insn) + 1}] or K{INSN_C(insn)}`);
        elseif opcode == 49 then -- CONCAT
            src.writeln(`R[{INSN_A(insn) + 1}] = table.concat(R, "", {INSN_B(insn) + 1}, {INSN_C(insn) + 1})`);
        elseif opcode == 50 then -- NOT
            src.writeln(`R[{INSN_A(insn) + 1}] = not R[{INSN_B(insn) + 1}]`);
        elseif opcode == 51 then -- MINUS
            src.writeln(`R[{INSN_A(insn) + 1}] = -R[{INSN_B(insn) + 1}]`);
        elseif opcode == 52 then -- LENGTH
            src.writeln(`R[{INSN_A(insn) + 1}] = #R[{INSN_B(insn) + 1}]`);
        elseif opcode == 53 then -- NEWTABLE
            src.writeln(`R[{INSN_A(insn) + 1}] = table.create({next_insn()})`);
        elseif opcode == 54 then -- DUPTABLE
            src.writeln(`R[{INSN_A(insn) + 1}] = K{INSN_D(insn)}`);
        elseif opcode == 55 then -- SETLIST
            local start_idx = next_insn();
            local start = INSN_A(insn);
            local count = INSN_C(insn) - 1;
            
            if count == -1 then
                src.writeln(`table.move(R, {start + 2}, top - 1, {start_idx}, R[{INSN_A(insn) + 1}]);`);
            else
                src.writeln(`table.move(R, {start + 2}, {count + start + 1}, {start_idx}, R[{INSN_A(insn) + 1}]);`);
            end
        elseif opcode == 56 then -- FORNPREP
            local ra = INSN_A(insn);
            local limit = ra + 0;
            local index = ra + 2;

            src.writeln("do");
            src.indent();
            src.writeln(`if R[{index + 1}] > R[{limit + 1}] then`);
            src.indent();
            jump(INSN_D(insn), false);
            src.dedent();
            src.writeln("end");
            src.dedent();
            src.writeln("end");
        elseif opcode == 57 then -- FORNLOOP
            local ra = INSN_A(insn);
            local limit = ra + 0;
            local step = ra + 1;
            local index = ra + 2;
            local variable = ra + 3;
            src.writeln("do");
            src.indent();
            src.writeln(`R[{index + 1}] += R[{step + 1}]`);
            src.writeln(`R[{variable + 1}] = R[{index + 1}]`);
            src.writeln(`if R[{index + 1}] <= R[{limit + 1}] then`);
            src.indent();
            jump(INSN_D(insn), false);
            src.dedent();
            src.writeln("end");
            src.dedent();
            src.writeln("end");
        --elseif opcode == 58 then -- FORGLOOP
        --elseif opcode == 59 then -- FORGPREP_INEXT
        elseif opcode == 60 then -- FASTCALL3
            skip();
        --elseif opcode == 61 then -- FORGPREP_NEXT
        elseif opcode == 62 then -- NATIVECALL
            src.writeln(`error("can't native call")`);
        elseif opcode == 63 then -- GETVARARGS
            local start = INSN_A(insn);
            local count = INSN_B(insn) - 1;
            
            if count == -1 then
                src.writeln("do");
                src.indent();
                src.writeln(`local count = #args - {proto.num_params};`);
                src.writeln(`table.move(args, {start + 1}, {start + 1} + count, 1, R);`);
                src.writeln(`top = {start + 1} + count;`);
                src.dedent();
                src.writeln("end");
            else
                src.writeln(`table.move(args, {start + 1}, {start + 1 + count}, 1, R);`);
            end
        elseif opcode == 64 then -- DUPCLOSURE
            src.writeln(`R[{INSN_A(insn) + 1}] = K{INSN_D(insn)}`);
        elseif opcode == 65 then -- PREPVARARGS
            skip();
        elseif opcode == 66 then -- LOADKX
            src.writeln(`R[{INSN_A(insn) + 1}] = K{next_insn(insn)}`);
        elseif opcode == 67 then -- JUMPX
            jump(INSN_E(insn), false);
        elseif opcode == 68 then -- FASTCALL
            skip();
        elseif opcode == 69 then -- COVERAGE
            skip();
        elseif opcode == 70 then -- CAPTURE
            error("unhandled upvalue");
        elseif opcode == 71 then -- SUBRK
            src.writeln(`R[{INSN_A(insn) + 1}] = K{INSN_C(insn)} - R[{INSN_B(insn) + 1}]`);
        elseif opcode == 72 then -- DIVRK
            src.writeln(`R[{INSN_A(insn) + 1}] = K{INSN_C(insn)} / R[{INSN_B(insn) + 1}]`);
        elseif opcode == 73 then -- FASTCALL1
            skip();
        elseif opcode == 74 then -- FASTCALL2
            skip();
        elseif opcode == 75 then -- FASTCALL2K
            skip();
        --elseif opcode == 76 then -- FORGPREP
        --elseif opcode == 77 then -- JUMPXEQKNIL
        --elseif opcode == 78 then -- JUMPXEQKB
        --elseif opcode == 79 then -- JUMPXEQKN
        --elseif opcode == 80 then -- JUMPXEQKS
        elseif opcode == 81 then -- IDIV
            src.writeln(`R[{INSN_A(insn) + 1}] = R{INSN_B(insn) + 1} // R{INSN_C(insn) + 1}`);
        elseif opcode == 82 then -- IDIVK
            src.writeln(`R[{INSN_A(insn) + 1}] = R[{INSN_B(insn) + 1}] // K{INSN_C(insn)}`);
        else
            src.writeln(`error("unhandled {meta.name} instruction")`);
        end
        
        if pc < stop_pc then
            src.writeln()
        end
    end
end

local function decompile_proto(src: SourceBuilder, proto_ref: number, chunk: bytecode.Chunk)
    local proto = chunk.protos[proto_ref + 1];
    
    src.writeln(`local function P{proto_ref}(...: any): (...any)`);
    src.indent();
    src.writeln(`local top = {proto.max_stack_size};`);
    src.writeln(`local R: \{any} = table.create({proto.max_stack_size});`);
    src.writeln("local args = { ... };");
    if proto.num_params > 0 then
        src.writeln(`table.move(args, 1, {proto.num_params}, 1, R);`);
    end

    src.writeln();

    for i, const in proto.constants do
        local const_ref = i - 1;
        
        local const_value;
        local const_type;
        if const.type == "nil" then
            const_value = "nil";
            const_type = "nil";
        elseif const.type == "boolean" then
            const_value = tostring(const.value);
            const_type = "boolean";
        elseif const.type == "number" then
            const_value = tostring(const.value);
            const_type = "number";
        elseif const.type == "vector" then
            const_value = `vector.create({const.value[1]}, {const.value[2]}, {const.value[3]}, {const.value[4]})`;
            const_type = "vector";
        elseif const.type == "string" then
            const_value = `S{const.value}`;
            const_type = "string"; -- Consider making singleton
        elseif const.type == "import" then
            const_value = "";
            for i, v in bytecode.import_id.decode(const.value) do
                if i ~= 1 then
                    const_value ..= ".";
                end

                local path_member = chunk.strings[proto.constants[v + 1].value];
                const_value ..= path_member;
            end
            const_type = "any";
        elseif const.type == "closure" then
            const_value = `P{const.value}`;
            const_type = "(...any) -> ...any";
        elseif const.type == "table" then
            const_value = "{}";
            const_type = "{[any]: any}";
        else
            const_value = `error("unsupported constant type '{const.type}'")`;
        end

        src.writeln(`local K{const_ref}: {const_type} = {const_value};`);
    end

    if #proto.constants > 0 then
        src.writeln();
    end
    
    src.writeln(`local jump_dispatch = 0;\n`);
    src.writeln("while true do");
    src.indent();
        
    local branches = analyse_branches(proto.instructions);
    for i, branch in branches do
        src.writeln(`{if i == 1 then "if" else "elseif"} jump_dispatch == {branch.start_pc} then`);
        src.indent();
        
        decompile_instructions(src, chunk, proto, branch.start_pc, branch.stop_pc, branches);
        
        src.writeln();
        if branch.next_branch then
            src.writeln(`jump_dispatch = {branches[branch.next_branch].start_pc}; continue;`);
        else
            src.writeln(`break;`);
        end

        src.dedent();
    end
    
    src.writeln(`end`);
    src.dedent();
    src.writeln(`end`);

    src.dedent();
    src.writeln("end\n");    
end

local function decompile_chunk(src: SourceBuilder, chunk: bytecode.Chunk)
    for i, content in chunk.strings do
        src.writeln(`local S{i}: string = {string.format("%q", content)};`); -- TODO! bracket collisions
    end

    src.writeln();

    for i, _ in chunk.protos do
        local proto_ref = i - 1;
        decompile_proto(src, proto_ref, chunk);
    end

    src.writeln(`return P{chunk.main_proto}(...);`)
end

local function executable_decompile(chunk: bytecode.Chunk, options: Options): string
    local strings = {HEADER};
    local indent_level = 0;
    local src = {
        write = function(str: string)
            table.insert(strings, str);
        end,

        writeln = function(str: string?)
            table.insert(strings, string.rep(" ", indent_level * 4));
            table.insert(strings, str or "");
            table.insert(strings, "\n");
        end,

        indent = function(by: number?)
            indent_level += by or 1;
        end,

        dedent = function(by: number?)
            indent_level -= by or 1;
        end
    };

    decompile_chunk(src, chunk);

    return table.concat(strings, "");
end

return executable_decompile;