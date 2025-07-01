local testing = require("@testing/utils");
local bytecode = require("@luau_toolkit/bytecode");
local loadstring = require("@luau_toolkit/loadstring");
local luau = require("@lune/luau")

type Constant = {
    type: bytecode.ConstantType,
    value: any,
};

type TestInstruction = {
    instructions: {any},
    expected_stack: {any},
    expected_pc: number,
    expected_returns: {any},
    expected_env: {[any]: any}?,
    args: {any}?,
    constants: {Constant}?,
    env: {[any]: any}?,
    strings: {string}?,
};

local function test_instruction(options: TestInstruction)
    local args: {any} = options.args or {};
    local constants: {Constant} = options.constants or {};
    local strings: {string} = options.strings or {};

    local chunk = bytecode.BytecodeAssembler.new();

    for i, v in strings do
        chunk:add_string(v, true);
    end

    chunk:begin_function();
    chunk:set_main();
    chunk:set_num_params(#args);

    for i, v in constants do
        chunk:add_constant(v.type, v.value);
    end
    
    for _, insn in options.instructions do
        if type(insn) == "string" then
            insn = {insn};
        end
        
        chunk:emit_instruction(unpack(insn));
    end

    chunk:end_function();
    local bc = chunk:assemble();
    local pc, stack;
    local env = table.clone(options.env or {});
    local loaded = loadstring(bc, {
        environment = env,
        main_return_callback = function(_pc, _stack)
            pc = _pc;
            stack = _stack;
        end,
    });
    local returns = { loaded(unpack(args)) };
    testing.assert_eq(pc, options.expected_pc, `invalid pc`);
    testing.assert_eq(stack, options.expected_stack, `invalid stack`);
    testing.assert_eq(returns, options.expected_returns, `invalid returns`);
    if options.expected_env then
        testing.assert_eq(env, options.expected_env, `invalid returns`);
    end
end

local userdata = newproxy();

--// NOP
test_instruction({
    instructions = {
        "NOP",
        {"RETURN", 0, 1},
    },
    expected_pc = 2,
    expected_stack = {},
    expected_returns = {},
});

--// BREAK
do
    local break_ran = false;
    local chunk = bytecode.BytecodeAssembler.new();
    chunk:begin_function();
    chunk:set_main();
    chunk:emit_instruction("BREAK");
    chunk:emit_instruction("RETURN", 0, 1);
    chunk:end_function();
    loadstring(chunk:assemble(), {
        breakpoint = function()
            break_ran = true;
        end
    })();
    assert(break_ran, "BREAK callback didnt work")
end

--// LOADNIL
test_instruction({
    instructions = {
        {"LOADNIL", 0},
        {"RETURN", 0, 1},
    },
    expected_pc = 2,
    expected_stack = {nil},
    expected_returns = {},
});

--// LOADB
test_instruction({
    instructions = {
        {"LOADB", 0, 0},
        {"LOADB", 1, 1},
        {"RETURN", 0, 1},
    },
    expected_pc = 3,
    expected_stack = {false, true},
    expected_returns = {},
});

--// LOADN
test_instruction({
    instructions = {
        {"LOADN", 0, 255},
        {"LOADN", 1, 0},
        {"LOADN", 2, 127},
        {"RETURN", 0, 1},
    },
    expected_pc = 4,
    expected_stack = {255, 0, 127},
    expected_returns = {},
});

--// LOADK
test_instruction({
    instructions = {
        {"LOADK", 0, 0},
        {"LOADK", 1, 1},
        {"LOADK", 2, 2},
        {"RETURN", 0, 1},
    },
    expected_pc = 4,
    expected_stack = {255, "Hello, World!", vector.create(0, 1, 2)},
    expected_returns = {},
    constants = {
        { type = "number", value = 255 },
        { type = "string", value = 1 },
        { type = "vector", value = {0, 1, 2, 3} },
    },
    strings = {
        "Hello, World!"
    },
});

--// MOVE
test_instruction({
    instructions = {
        {"LOADN", 0, 255},
        {"MOVE", 1, 0},
        {"RETURN", 0, 1},
    },
    expected_pc = 3,
    expected_stack = {255, 255},
    expected_returns = {},
});

--// GETGLOBAL
test_instruction({
    instructions = {
        {"GETGLOBAL", 0, 0, 0},
        {"RETURN", 0, 1},
    },
    expected_pc = 3,
    expected_stack = {userdata},
    expected_returns = {},
    constants = {
        { type = "string", value = 1 },
    },
    strings = {"userdata"},
    env = {
        userdata = userdata,
    }
});

--// SETGLOBAL
test_instruction({
    instructions = {
        {"SETGLOBAL", 0, 0, 1},
        {"RETURN", 0, 1},
    },
    expected_pc = 3,
    expected_stack = {userdata},
    expected_env = { userdata = userdata, },
    expected_returns = {},
    constants = {
        { type = "string", value = 1 },
    },
    strings = {
        "userdata",
    },
    args = {userdata},
});

--// GETUPVAL/SETUPVAL/CLOSEUPVALS
do
    local bc = luau.compile([[
        local function Box(n: number)
            local inner = 0;

            local function get(): number  -- GETUPVAL
                return inner;
            end

            local function set(val: number) -- SETUPVAL
                inner = val;
            end

            local function add(amount: number) -- GETUPVAL/SETUPVAL
                inner += amount;
            end

            return { get = get, set = set, add = add }; -- CLOSEUPVALS
        end
        
        local value = Box(0);
        value.set(5); -- 5
        value.add(1); -- 6
        value.add(-2); -- 4
        return value.get(); -- 4
    ]], {
        optimizationLevel = 0,
        debugLevel = 2,
    });

    local res = { loadstring(bc)() };
    testing.assert_eq(res, {4});
end

--// GETIMPORT
test_instruction({
    instructions = {
        {"GETIMPORT", 0, 3, bytecode.import_id.encode({0, 1, 2})},
        {"RETURN", 0, 1},
    },
    expected_pc = 3,
    expected_stack = {userdata},
    expected_returns = {},
    constants = {
        { type = "string", value = 1 },
        { type = "string", value = 2 },
        { type = "string", value = 3 },
        { type = "import", value = bytecode.import_id.encode({0, 1, 2}) },
    },
    strings = {
        "root",
        "hello",
        "world",
    },
    env = {
        root = { hello = { world = userdata } },
    }
});

--// GETTABLE
test_instruction({
    instructions = {
        {"LOADN", 1, 1},
        {"GETTABLE", 0, 0, 1},
        {"RETURN", 0, 1},
    },
    expected_pc = 3,
    expected_stack = { true, 1 },
    expected_returns = {},
    args = {
        { true },
    }
});

--// SETTABLE
test_instruction({
    instructions = {
        {"LOADN", 1, 1},
        {"LOADB", 2, 1},
        {"SETTABLE", 2, 0, 1},
        {"GETTABLE", 0, 0, 1},
        {"RETURN", 0, 1},
    },
    expected_pc = 5,
    expected_stack = { true, 1, true },
    expected_returns = {},
    args = {
        { false },
    }
});

--// GETTABLEKS
test_instruction({
    instructions = {
        {"GETTABLEKS", 0, 0, 0},
        {"RETURN", 0, 1},
    },
    expected_pc = 3,
    expected_stack = { true },
    expected_returns = {},
    constants = {
        { type = "string", value = 1 },
    },
    strings = { "hi" },
    args = {
        { hi = true, },
    }
});

--// SETTABLEKS
test_instruction({
    instructions = {
        {"LOADB", 1, 0},
        {"SETTABLEKS", 1, 0, 0, 0},
        {"GETTABLEKS", 0, 0, 0, 0},
        {"RETURN", 0, 1},
    },
    expected_pc = 6,
    expected_stack = { false, false },
    expected_returns = {},
    constants = {
        { type = "string", value = 1 },
    },
    strings = { "hi" },
    args = {
        { hi = true, },
    }
});

--// GETTABLEN
test_instruction({
    instructions = {
        {"GETTABLEN", 0, 0, 0},
        {"RETURN", 0, 1},
    },
    expected_pc = 2,
    expected_stack = { true },
    expected_returns = {},
    args = {
        { true, },
    }
});

--// SETTABLEN
test_instruction({
    instructions = {
        {"LOADB", 1, 0},
        {"SETTABLEN", 1, 0, 0},
        {"GETTABLEN", 0, 0, 0},
        {"RETURN", 0, 1},
    },
    expected_pc = 4,
    expected_stack = { false, false },
    expected_returns = {},
    args = {
        { true, },
    }
});

--// NEWCLOSURE + CALL
do
    local bc = luau.compile([[
        local function abc()
            return true, "AHHH";
        end
        
        return abc();
    ]], {
        optimizationLevel = 0,
        debugLevel = 2,
    });

    local res = { loadstring(bc)() };
    testing.assert_eq(res, {true, "AHHH"});
end

--// JUMP
test_instruction({
    instructions = {
        {"JUMP", 0, 1},
        {"RETURN", 1, 0, 0},
        {"LOADB", 0, 1},
        {"RETURN", 0, 2},
    },
    expected_pc = 4,
    expected_stack = { true },
    expected_returns = { true },
});

--// JUMPBACK
test_instruction({
    instructions = {
        {"JUMPBACK", 0, 1},
        {"RETURN", 1, 0, 0},
        {"LOADB", 0, 1},
        {"RETURN", 0, 2},
    },
    expected_pc = 4,
    expected_stack = { true },
    expected_returns = { true },
});

--// JUMPIF
test_instruction({
    instructions = {
        {"JUMPIF", 0, 1},
        {"RETURN", 1, 0, 0},
        {"LOADB", 0, 1},
        {"RETURN", 0, 2},
    },
    expected_pc = 4,
    expected_stack = { true },
    expected_returns = { true },
    args = { true },
});

--// JUMPIFNOT
test_instruction({
    instructions = {
        {"JUMPIFNOT", 0, 1},
        {"RETURN", 1, 0, 0},
        {"LOADB", 0, 1},
        {"RETURN", 0, 2},
    },
    expected_pc = 4,
    expected_stack = { true },
    expected_returns = { true },
    args = { false },
});

--// JUMPIFEQ
test_instruction({
    instructions = {
        {"JUMPIFEQ", 0, 2, 1},
        {"RETURN", 1, 0},
        {"LOADB", 0, 1},
        {"RETURN", 0, 2},
    },
    expected_pc = 5,
    expected_stack = { true, 1 },
    expected_returns = { true },
    args = { 1, 1 },
});

--// JUMPIFLE
test_instruction({
    instructions = {
        {"JUMPIFLE", 0, 2, 1},
        {"RETURN", 1, 0},
        {"LOADB", 0, 1},
        {"RETURN", 0, 2},
    },
    expected_pc = 5,
    expected_stack = { true, 1 },
    expected_returns = { true },
    args = { 1, 1 },
});

--// JUMPIFLT
test_instruction({
    instructions = {
        {"JUMPIFLT", 0, 2, 1},
        {"RETURN", 1, 0},
        {"LOADB", 0, 1},
        {"RETURN", 0, 2},
    },
    expected_pc = 5,
    expected_stack = { true, 2 },
    expected_returns = { true },
    args = { 1, 2 },
});

--// JUMPIFNOTEQ
test_instruction({
    instructions = {
        {"JUMPIFNOTEQ", 0, 2, 1},
        {"RETURN", 1, 0},
        {"LOADB", 0, 1},
        {"RETURN", 0, 2},
    },
    expected_pc = 5,
    expected_stack = { true, 2 },
    expected_returns = { true },
    args = { 1, 2 },
});

--// JUMPIFNOTLE
test_instruction({
    instructions = {
        {"JUMPIFNOTLE", 0, 2, 1},
        {"RETURN", 1, 0},
        {"LOADB", 0, 1},
        {"RETURN", 0, 2},
    },
    expected_pc = 5,
    expected_stack = { true, 1 },
    expected_returns = { true },
    args = { 2, 1, },
});

--// JUMPIFNOTLT
test_instruction({
    instructions = {
        {"JUMPIFNOTLT", 0, 2, 1},
        {"RETURN", 1, 0},
        {"LOADB", 0, 1},
        {"RETURN", 0, 2},
    },
    expected_pc = 5,
    expected_stack = { true, 1 },
    expected_returns = { true },
    args = { 2, 1, },
});

--// ADD
test_instruction({
    instructions = {
        {"ADD", 0, 0, 1},
        {"RETURN", 0, 1},
    },
    expected_pc = 2,
    expected_stack = { 4, 2, },
    expected_returns = {},
    args = { 2, 2, },
});

--// SUB
test_instruction({
    instructions = {
        {"SUB", 0, 0, 1},
        {"RETURN", 0, 1},
    },
    expected_pc = 2,
    expected_stack = { 1, 2, },
    expected_returns = {},
    args = { 3, 2, },
});

--// MUL
test_instruction({
    instructions = {
        {"MUL", 0, 0, 1},
        {"RETURN", 0, 1},
    },
    expected_pc = 2,
    expected_stack = { 20, 2, },
    expected_returns = {},
    args = { 10, 2, },
});

--// DIV
test_instruction({
    instructions = {
        {"DIV", 0, 0, 1},
        {"RETURN", 0, 1},
    },
    expected_pc = 2,
    expected_stack = { 5, 2, },
    expected_returns = {},
    args = { 10, 2, },
});

--// DIV
test_instruction({
    instructions = {
        {"POW", 0, 0, 1},
        {"RETURN", 0, 1},
    },
    expected_pc = 2,
    expected_stack = { 100, 2, },
    expected_returns = {},
    args = { 10, 2, },
});

--// ADDK
test_instruction({
    instructions = {
        {"ADDK", 0, 0, 0},
        {"RETURN", 0, 1},
    },
    expected_pc = 2,
    expected_stack = { 15, },
    expected_returns = {},
    args = { 10 },
    constants = { { type = "number", value = 5 }},
});

--// SUBK
test_instruction({
    instructions = {
        {"SUBK", 0, 0, 0},
        {"RETURN", 0, 1},
    },
    expected_pc = 2,
    expected_stack = { 5, },
    expected_returns = {},
    args = { 10 },
    constants = { { type = "number", value = 5 }},
});

--// MULK
test_instruction({
    instructions = {
        {"MULK", 0, 0, 0},
        {"RETURN", 0, 1},
    },
    expected_pc = 2,
    expected_stack = { 50, },
    expected_returns = {},
    args = { 10 },
    constants = { { type = "number", value = 5 }},
});

--// DIVK
test_instruction({
    instructions = {
        {"DIVK", 0, 0, 0},
        {"RETURN", 0, 1},
    },
    expected_pc = 2,
    expected_stack = { 2, },
    expected_returns = {},
    args = { 10 },
    constants = { { type = "number", value = 5 }},
});

--// MODK
test_instruction({
    instructions = {
        {"MODK", 0, 0, 0},
        {"RETURN", 0, 1},
    },
    expected_pc = 2,
    expected_stack = { 10 % 5, },
    expected_returns = {},
    args = { 10 },
    constants = { { type = "number", value = 5 }},
});

--// POWK
test_instruction({
    instructions = {
        {"POWK", 0, 0, 0},
        {"RETURN", 0, 1},
    },
    expected_pc = 2,
    expected_stack = { 10 ^ 5, },
    expected_returns = {},
    args = { 10 },
    constants = { { type = "number", value = 5 }},
});

--// AND
test_instruction({
    instructions = {
        {"AND", 0, 0, 1},
        {"RETURN", 0, 1},
    },
    expected_pc = 2,
    expected_stack = { true, true, },
    expected_returns = {},
    args = { true, true },
});

--// OR
test_instruction({
    instructions = {
        {"OR", 0, 0, 1},
        {"RETURN", 0, 1},
    },
    expected_pc = 2,
    expected_stack = { true, false, },
    expected_returns = {},
    args = { true, false },
});

--// ANDK
test_instruction({
    instructions = {
        {"ANDK", 0, 0, 0},
        {"RETURN", 0, 1},
    },
    expected_pc = 2,
    expected_stack = { true, },
    expected_returns = {},
    args = { true },
    constants = { { type = "boolean", value = true }},
});

--// ORK
test_instruction({
    instructions = {
        {"ORK", 0, 0, 0},
        {"RETURN", 0, 1},
    },
    expected_pc = 2,
    expected_stack = { true, },
    expected_returns = {},
    args = { true },
    constants = { { type = "boolean", value = false }},
});

--// NOT
test_instruction({
    instructions = {
        {"NOT", 0, 0},
        {"RETURN", 0, 1},
    },
    expected_pc = 2,
    expected_stack = { false },
    expected_returns = {},
    args = { true },
});

--// MINUS
test_instruction({
    instructions = {
        {"MINUS", 0, 0},
        {"RETURN", 0, 1},
    },
    expected_pc = 2,
    expected_stack = { -1 },
    expected_returns = {},
    args = { 1 },
});

--// LENGTH
test_instruction({
    instructions = {
        {"LENGTH", 0, 0},
        {"RETURN", 0, 1},
    },
    expected_pc = 2,
    expected_stack = { 3 },
    expected_returns = {},
    args = { {1, 2, 3} },
});

--// NEWTABLE
test_instruction({
    instructions = {
        {"NEWTABLE", 0, 0, 0, 0},
        {"RETURN", 0, 1},
    },
    expected_pc = 3,
    expected_stack = { {} },
    expected_returns = {},
});

-- Skip DUPTABLE

--// SETLIST
test_instruction({
    instructions = {
        {"SETLIST", 0, 1, 0, 1},
        {"RETURN", 0, 1},
    },
    expected_pc = 3,
    expected_stack = { {1, 2, 3}, 1, 2, 3 },
    expected_returns = {},
    args = { {}, 1, 2, 3, },
});

test_instruction({
    instructions = {
        {"SETLIST", 0, 1, 4, 1},
        {"RETURN", 0, 1},
    },
    expected_pc = 3,
    expected_stack = { {1, 2, 3}, 1, 2, 3 },
    expected_returns = {},
    args = { {}, 1, 2, 3, },
});

--// FORNPREP/FORNLOOP
do
    local bc = luau.compile([[
        local a = 0;
        for i = 1, 1000, 2 do
            a += i;
        end
        return a;
    ]], {
        optimizationLevel = 0,
        debugLevel = 2,
    });

    local res = { loadstring(bc)() };
    testing.assert_eq(res, {250000});
end