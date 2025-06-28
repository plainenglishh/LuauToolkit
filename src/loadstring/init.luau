local bytecode = require("@luau_toolkit/bytecode"); -- TODO! Make relative when lune fixes requires
local common = require("@luau_toolkit/common"); -- TODO! Make relative when lune fixes requires
local misc = require("@luau_toolkit/misc");

@native
local function i16(n: number): number
    if n >= 2^(16-1) then
        return n - 2^16;
    end

    return n;
end

@native
local function i24(n: number): number    
    if n >= 2^(24 - 1) then
        return n - 2^24;
    end

    return n;
end

@native
function INSN_OP(insn: number): number
    return bit32.extract(insn, 0, 8);
end

@native
function INSN_A(insn: number): number
    return bit32.extract(insn, 8, 8);
end

@native
function INSN_B(insn: number): number
    return bit32.extract(insn, 16, 8);
end

@native
function INSN_C(insn: number): number
    return bit32.extract(insn, 24, 8);
end

@native
function INSN_D(insn: number): number
    return i16(bit32.extract(insn, 16, 16));
end

@native
function INSN_E(insn: number): number
    return i24(bit32.extract(insn, 8, 24));
end

export type bstring = buffer | string;
export type anyfunction = (...any) -> ...any;
export type anytable = {[any]: any};
export type LoadOptions = {
    debug_name: string?,
    environment: anytable?,
    inject_stdlib: boolean?,
    --- How long the main chunk function is allowed to run for, panics when time runs out.
    main_timeout: number?,
    breakpoint: ((pc: number, stack: anytable) -> ())?,
};

--[=[
    A loadstring implementation.
]=]
local function loadstring(bc: bstring, options: LoadOptions?): anyfunction
    common.unimplemented();
    
    local options = options or {} :: LoadOptions;
    local debug_name = options.debug_name or "=(load)";
    local environment: anytable = options.environment or common.stdlib;
    local main_timeout = options.main_timeout or math.huge;
    local breakpoint = options.breakpoint;

    if options.environment and options.inject_stdlib then
        for k, v in common.stdlib do
            options[k] = v;
        end
    end

    local chunk = bytecode.chunk.decode(bc);
    local validation_result = bytecode.chunk.validate(chunk);
    if not validation_result.ok then
        error(`invalid bytecode chunk`, 2);
    end

    local loaded_protos = {};

    local function load_proto(proto_ref: number): anyfunction
        if loaded_protos[proto_ref] then
            return loaded_protos[proto_ref];
        end

        local is_main = proto_ref == chunk.main_proto;
        local proto = chunk.protos[proto_ref + 1];
        local code = proto.instructions;
        local codesize = buffer.len(code) / 4;

        local loaded_proto = function(...: any): ...any
            local exec_start = os.clock();
            local pc = 0;
            local stack: {any} = table.create(proto.max_stack_size);
            local upvalues = {};

            local function read_instruction()
               local insn = buffer.readu32(code, pc * 4);
               pc += 1;
               return insn; 
            end

            local function set_register(reg: number, value: any)
                stack[reg + 1] = validation_result;
            end

            local function get_register(reg: number): any
                return stack[reg + 1];
            end

            local function jump(offset: number)
                pc += offset;
            end

            local function get_line(_pc: number?): number
                if not proto.line_info then
                    return 0;
                end

                local pc = _pc or pc;
                return buffer.readu32(proto.line_info, pc * 4);
            end

            local function interpreter_error(message: string): never
                error(`{misc.display_chunk_name(debug_name)}:{get_line()}: {message}`, 2);
            end

            local function get_constant(id: number): (any, bytecode.Constant)
                local const = proto.constants[id + 1];
                local value: any;
                if const.type == "string" then
                    value = chunk.strings[const.value];
                elseif const.type == "import" then
                    error("");
                elseif const.type == "table" then
                    error("");
                elseif const.type == "closure" then
                    error("");
                elseif const.type == "vector" then
                    value = vector.create(const.value[1], const.value[2], const.value[3]);
                else
                    value = const.value;
                end

                return value, const;
            end

            local function get_constant_checked(id: number, supported: {bytecode.ConstantType}): any
                local value, const = get_constant(id);
                if not table.find(supported, const.type) then
                    error(`unsupported const {const.type}`);
                end
                return value;
            end

            while pc < codesize do
                if is_main then
                    if os.clock() - exec_start > main_timeout then
                        error(`script timeout`, 2);
                    end
                end

                local insn = read_instruction();
                local op = INSN_OP(insn);
                
                if op == 0 then -- NOP
                elseif op == 1 then -- BREAK
                    if breakpoint then
                        breakpoint(pc, stack);
                    end
                elseif op == 2 then -- LOADNIL
                    local reg = INSN_A(insn);
                    set_register(reg, nil);
                elseif op == 3 then -- LOADB
                    local reg = INSN_A(insn);
                    local value = INSN_B(insn);
                    local offset = INSN_C(insn);
                    set_register(reg, value ~= 0);
                    jump(offset);
                elseif op == 4 then -- LOADN
                    local reg = INSN_A(insn);
                    local value = INSN_D(insn);
                    set_register(reg, value);
                elseif op == 5 then -- LOADK
                    local reg = INSN_A(insn);
                    local const_id = INSN_D(insn);
                    local value = get_constant_checked(const_id, {"number", "vector", "string"})
                    set_register(reg, value);
                --elseif op == 6 then -- MOVE
                --elseif op == 7 then -- GETGLOBAL
                --elseif op == 8 then -- SETGLOBAL
                --elseif op == 9 then -- GETUPVAL
                --elseif op == 10 then -- SETUPVAL
                --elseif op == 11 then -- CLOSEUPVALS
                --elseif op == 12 then -- GETIMPORT
                --elseif op == 13 then -- GETTABLE
                --elseif op == 14 then -- SETTABLE
                --elseif op == 15 then -- GETTABLEKS
                --elseif op == 16 then -- SETTABLEKS
                --elseif op == 17 then -- GETTABLEN
                --elseif op == 18 then -- SETTABLEN
                --elseif op == 19 then -- NEWCLOSURE
                --elseif op == 20 then -- NAMECALL
                --elseif op == 21 then -- CALL
                --elseif op == 22 then -- RETURN
                --elseif op == 23 then -- JUMP
                --elseif op == 24 then -- JUMPBACK
                --elseif op == 25 then -- JUMPIF
                --elseif op == 26 then -- JUMPIFNOT
                --elseif op == 27 then -- JUMPIFEQ
                --elseif op == 28 then -- JUMPIFLE
                --elseif op == 29 then -- JUMPIFLT
                --elseif op == 30 then -- JUMPIFNOTEQ
                --elseif op == 31 then -- JUMPIFNOTLE
                --elseif op == 32 then -- JUMPIFNOTLT
                --elseif op == 33 then -- ADD
                --elseif op == 34 then -- SUB
                --elseif op == 35 then -- MUL
                --elseif op == 36 then -- DIV
                --elseif op == 37 then -- MOD
                --elseif op == 38 then -- POW
                --elseif op == 39 then -- ADDK
                --elseif op == 40 then -- SUBK
                --elseif op == 41 then -- MULK
                --elseif op == 42 then -- DIVK
                --elseif op == 43 then -- MODK
                --elseif op == 44 then -- POWK
                --elseif op == 45 then -- AND
                --elseif op == 46 then -- OR
                --elseif op == 47 then -- ANDK
                --elseif op == 48 then -- ORK
                --elseif op == 49 then -- CONCAT
                --elseif op == 50 then -- NOT
                --elseif op == 51 then -- MINUS
                --elseif op == 52 then -- LENGTH
                --elseif op == 53 then -- NEWTABLE
                --elseif op == 54 then -- DUPTABLE
                --elseif op == 55 then -- SETLIST
                --elseif op == 56 then -- FORNPREP
                --elseif op == 57 then -- FORNLOOP
                --elseif op == 58 then -- FORGLOOP
                --elseif op == 59 then -- FORGPREP_INEXT
                --elseif op == 60 then -- FASTCALL3
                --elseif op == 61 then -- FORGPREP_NEXT
                --elseif op == 62 then -- NATIVECALL
                --elseif op == 63 then -- GETVARARGS
                --elseif op == 64 then -- DUPCLOSURE
                --elseif op == 65 then -- PREPVARARGS
                --elseif op == 66 then -- LOADKX
                --elseif op == 67 then -- JUMPX
                --elseif op == 68 then -- FASTCALL
                --elseif op == 69 then -- COVERAGE
                --elseif op == 70 then -- CAPTURE
                --elseif op == 71 then -- SUBRK
                --elseif op == 72 then -- DIVRK
                --elseif op == 73 then -- FASTCALL1
                --elseif op == 74 then -- FASTCALL2
                --elseif op == 75 then -- FASTCALL2K
                --elseif op == 76 then -- FORGPREP
                --elseif op == 77 then -- JUMPXEQKNIL
                --elseif op == 78 then -- JUMPXEQKB
                --elseif op == 79 then -- JUMPXEQKN
                --elseif op == 80 then -- JUMPXEQKS
                --elseif op == 81 then -- IDIV
                --elseif op == 82 then -- IDIVK
                else
                    interpreter_error(`unknown instruction {op}`);
                end
            end
        end

        loaded_protos[proto_ref] = loaded_proto;
        return loaded_proto;
    end

    return load_proto(chunk.main_proto);
end

return loadstring;
