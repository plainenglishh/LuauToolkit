--!nolint LocalShadow

_G.BYTEPARSE_SUPPRESS_WARNINGS = true;

local stdio = require("@lune/stdio");
local serde = require("@lune/serde");
local fs = require("@lune/fs");
local luau = require("@lune/luau");

local _nil = nil :: any;

local tests = {};

type TestFn = (name: string, fn: () -> ()) -> ();
type TestGroupFn = (name: string, fn: (test: TestFn, test_group: TestGroupFn) -> ()) -> ();

local function test(name: string, fn: () -> ())
    table.insert(tests, {
        name = `{name}`,
        fn = fn,
    });
end

local function eq(a: any, b: any): boolean
    local ok, is_eq = pcall(function()
        return serde.encode("json", a) == serde.encode("json", b)
    end);
    return (a == b) or (ok and is_eq);
end

local function strip_spans(tbl: any)
    local new = {};

    for k, v in tbl do
        if k ~= "span" then
            new[k] = if type(v) == "table" then strip_spans(v) else v; 
        end
    end

    return new;
end

if type(vector) == "function" then
    local env = luau.load("return getfenv;")()(1);
    local vec_mt = {
        __eq = function(a, b)
            return (a.x == b.x) and (a.y == b.y) and (a.z == b.z) and (a.w == b.w);
        end
    };

    env.vector = {
        create = function(x: number, y: number, z: number, w: number)
            return setmetatable({
                x = x or 0,
                y = y or 0,
                z = z or 0,
                w = w or 0,
            }, vec_mt);
        end,
    };
end

local function assert_token(result, n: number, token: string, literal: any?)
    if not result.tokens[n] or result.tokens[n].type ~= token then
        if not result.tokens[n] then
            error(`expected {token} at #{n}, got nothing`, 2);
        else
            error(`expected {token} at #{n}, got {result.tokens[n].type}`, 2);
        end
    end

    if literal then
        if not eq(result.tokens[n].literal, literal) then
            error(`expected #{n}'s literal to be {stdio.format(literal)}, got {stdio.format(result.tokens[n].literal)}`, 2);
        end
    end
end

--------------------------------------------------------------------------------

local bytecode = require("@ltk/bytecode");
local vm = require("@ltk/vm");
local common = require("@ltk/common");

test("bytecode::{encode,decode}", function()
    local original_bc = luau.compile([[
        return "Hello, World!";
    ]], {
        optimizationLevel = 2,
        debugLevel = 2,
    });

    local ir_chunk = bytecode.decode(original_bc);
    local reencoded_bc = bytecode.encode(ir_chunk);

    local fn = luau.load(buffer.tostring(reencoded_bc));
    assert(fn and fn() == "Hello, World!");
end);

test("bytecode::{encode_import_id,decode_import_id}", function()
    local encoded = bytecode.encode_import_id({1, 2, 3});
    local decoded = bytecode.decode_import_id(encoded);

    assert(decoded[1] == 1);
    assert(decoded[2] == 2);
    assert(decoded[3] == 3);
end);

do --// partial VM
    local function vm_inspector(): (any, {pc: number, stack: {any}})
        local self = {};
        
        return {
            break_callback = function(_pc: number, _stack: {any})
                self.stack = _stack;
                self.pc = _pc + 1;
            end,
        }, self;
    end

    local function assert_stack(a: {any}, b: {any}, msg: string?)
        assert(#a == #b, `expected stacks to be of same size`);
        for i, v in b do
            if a[i] ~= v then
                error(msg or `expected key '{i}' in table A to be {v}, got {a[i]}`, 2);
            end
        end
    end

    for _, file in fs.readDir("./tests/vm") do
        test(`vm::partial::conformance::{file}`, function()
            local src = fs.readFile(`./tests/vm/{file}`);
            local bc = luau.compile(src);
    
            local stdlib = table.clone(common.stdlib);
            stdlib.print = function() end :: any;
            vm.partial.load(bc, {globals = stdlib, debug_prints = true })();
        end);
    end

    test("vm::partial::opcodes:nop", function()
        local chunk = bytecode.BytecodeBuilder.new();
        local inspect, vm_info = vm_inspector();

        chunk:start_proto()
            chunk:set_main();
            chunk:add_instruction("NOP");
            chunk:add_instruction("BREAK");
        chunk:end_proto();

        vm.partial.load(chunk:build_bc(), inspect)();

        assert(vm_info.pc == 2);
        assert_stack(vm_info.stack, {});
    end);

    test("vm::partial::opcodes:break", function()
        local chunk = bytecode.BytecodeBuilder.new();
        local inspect, vm_info = vm_inspector();

        chunk:start_proto()
            chunk:set_main();
            chunk:add_instruction("BREAK");
        chunk:end_proto();

        vm.partial.load(chunk:build_bc(), inspect)();

        assert(vm_info.pc == 1); -- if PC exists, then BREAK succeeded.
    end);

    test("vm::partial::opcodes:loadnil", function()
        local chunk = bytecode.BytecodeBuilder.new();
        local inspect, vm_info = vm_inspector();

        chunk:start_proto()
            chunk:set_main();
            chunk:add_instruction("LOADNIL", 0);
            chunk:add_instruction("LOADB", 1, 1, 0);
            chunk:add_instruction("BREAK");
        chunk:end_proto();

        vm.partial.load(chunk:build_bc(), inspect)();
        assert_stack(vm_info.stack, {nil, true});
    end);

    test("vm::partial::opcodes:loadb", function()
        local chunk = bytecode.BytecodeBuilder.new();
        local inspect, vm_info = vm_inspector();

        chunk:start_proto()
            chunk:set_main();
            chunk:add_instruction("LOADB", 0, 0, 0);
            chunk:add_instruction("LOADB", 1, 1, 1);
            chunk:add_instruction("LOADNIL", 1);
            chunk:add_instruction("BREAK");
        chunk:end_proto();

        vm.partial.load(chunk:build_bc(), inspect)();

        assert_stack(vm_info.stack, {false, true});
    end);

    test("vm::partial::opcodes:loadn", function()
        local chunk = bytecode.BytecodeBuilder.new();
        local inspect, vm_info = vm_inspector();

        chunk:start_proto()
            chunk:set_main();
            chunk:add_instruction("LOADN", 0, 128);
            chunk:add_instruction("LOADN", 1, 255);
            chunk:add_instruction("BREAK");
        chunk:end_proto();

        vm.partial.load(chunk:build_bc(), inspect)();

        assert_stack(vm_info.stack, {128, 255});
    end);

    test("vm::partial::opcodes:loadk", function()
        local chunk = bytecode.BytecodeBuilder.new();
        local inspect, vm_info = vm_inspector();

        chunk:start_proto()
            chunk:set_main();
            chunk:add_instruction("LOADK", 0, chunk:add_constant("number", 0.1));
            chunk:add_instruction("LOADK", 1, chunk:add_constant("vector", {1, 2, 3, 0}));
            chunk:add_instruction("LOADK", 2, chunk:add_constant("string", chunk:add_string("hubert")));
            chunk:add_instruction("BREAK");
        chunk:end_proto();

        vm.partial.load(chunk:build_bc(), inspect)();

        assert_stack(vm_info.stack, {0.1, vector.create(1, 2, 3), "hubert"});
    end);

    test("vm::partial::opcodes:move", function()
        local chunk = bytecode.BytecodeBuilder.new();
        local inspect, vm_info = vm_inspector();

        chunk:start_proto()
            chunk:set_main();
            chunk:add_instruction("LOADB", 0, 1, 0);
            chunk:add_instruction("MOVE", 1, 0);
            chunk:add_instruction("BREAK");
        chunk:end_proto();

        vm.partial.load(chunk:build_bc(), inspect)();

        assert_stack(vm_info.stack, {true, true});
    end);

    test("vm::partial::opcodes:getglobal", function()
        local chunk = bytecode.BytecodeBuilder.new();
        local inspect, vm_info = vm_inspector();

        local bob = newproxy();
        inspect.globals = { bob = bob };

        chunk:start_proto()
            chunk:set_main();
            chunk:add_instruction("GETGLOBAL", 0, chunk:add_constant("string", chunk:add_string("bob")));
            chunk:add_instruction("BREAK");
        chunk:end_proto();

        vm.partial.load(chunk:build_bc(), inspect)();

        assert_stack(vm_info.stack, {bob});
    end);

    test("vm::partial::opcodes:setglobal", function()
        local chunk = bytecode.BytecodeBuilder.new();
        local inspect, vm_info = vm_inspector();

        local globals = { set = false };
        inspect.globals = globals;

        chunk:start_proto()
            chunk:set_main();
            chunk:add_instruction("LOADB", 0, 1, 0);
            chunk:add_instruction("SETGLOBAL", 0, chunk:add_constant("string", chunk:add_string("set")));
            chunk:add_instruction("BREAK");
        chunk:end_proto();

        vm.partial.load(chunk:build_bc(), inspect)();

        assert_stack(vm_info.stack, {true});
        assert(globals.set == true);
    end);
end

--[==[]
test("lasm::tokenise::punctuation", function()
    local src = "()[]@!=;:.,";
    local res = luau_toolkit.lasm.tokenise(src);
    
    assert(res.ok);

    assert_token(res, 1, "OPEN_PAREN");
    assert_token(res, 2, "CLOSE_PAREN");
    assert_token(res, 3, "OPEN_SBRACKET");
    assert_token(res, 4, "CLOSE_SBRACKET");
    assert_token(res, 5, "AT");
    assert_token(res, 6, "EXCLAIM");
    assert_token(res, 7, "EQ");
    assert_token(res, 8, "SEMICOLON");
    assert_token(res, 9, "COLON");
    assert_token(res, 10, "DOT");
    assert_token(res, 11, "COMMA");
    assert_token(res, 12, "EOF");

    assert(#res.tokens == 12);
end);

test("lasm::tokenise::number_literals", function()
    local src = "100 2_0_0 0.123 10_10.10_10 0b11111111 0b1000_0000 0xFFFF 0xFF_00";
    local res = luau_toolkit.lasm.tokenise(src);

    assert(res.ok);

    assert_token(res, 1, "NUMBER_LITERAL", 100);
    assert_token(res, 2, "NUMBER_LITERAL", 200);
    assert_token(res, 3, "NUMBER_LITERAL", 0.123);
    assert_token(res, 4, "NUMBER_LITERAL", 10_10.10_10);
    assert_token(res, 5, "NUMBER_LITERAL", 0b11111111);
    assert_token(res, 6, "NUMBER_LITERAL", 0b1000_0000);
    assert_token(res, 7, "NUMBER_LITERAL", 0xFFFF);
    assert_token(res, 8, "NUMBER_LITERAL", 0xFF_00);
    assert_token(res, 9, "EOF");
    
    assert(#res.tokens == 9);
end);

test("lasm::tokenise::string_literals", function()
    local src = [["Hello, World!" "he said \"hi\"!" "\x00\xFF" "hello\z   world"]];
    local res = luau_toolkit.lasm.tokenise(src);

    assert(res.ok);

    assert_token(res, 1, "STRING_LITERAL", "Hello, World!");
    assert_token(res, 2, "STRING_LITERAL", "he said \"hi\"!");
    assert_token(res, 3, "STRING_LITERAL", "\x00\xFF");
    assert_token(res, 4, "STRING_LITERAL", "helloworld");
    assert_token(res, 5, "EOF");

    assert(#res.tokens == 5);
end);

test("lasm::tokenise::vector_literals", function()
    local src = [[<1, 2, 3><1,>]];
    local res = luau_toolkit.lasm.tokenise(src);

    assert(res.ok);

    assert_token(res, 1, "VECTOR_LITERAL", {1, 2, 3});
    assert_token(res, 2, "VECTOR_LITERAL", {1});
    assert_token(res, 3, "EOF");
    
    assert(#res.tokens == 3);
end);

test("lasm::tokenise::import_literals", function()
    local src = [[env.print env.string.byte]];
    local res = luau_toolkit.lasm.tokenise(src);

    assert(res.ok);

    assert_token(res, 1, "IMPORT_LITERAL", {"print"});
    assert_token(res, 2, "IMPORT_LITERAL", {"string", "byte"});
    assert_token(res, 3, "EOF");

    assert(#res.tokens == 3);
end);

test("lasm::tokenise::boolean_literals", function()
    local src = [[true false]];
    local res = luau_toolkit.lasm.tokenise(src);

    assert(res.ok);

    assert_token(res, 1, "BOOLEAN_LITERAL", true);
    assert_token(res, 2, "BOOLEAN_LITERAL", false);
    assert_token(res, 3, "EOF");

    assert(#res.tokens == 3);
end);

test("lasm::tokenise::nil_literal", function()
    local src = [[nil]];
    local res = luau_toolkit.lasm.tokenise(src);

    assert(res.ok);

    assert_token(res, 1, "NIL_LITERAL");
    assert_token(res, 2, "EOF");
    
    assert(#res.tokens == 2);
end);

test("lasm::tokenise::keywords", function()
    local src = [[end string const alias proto env]];
    local res = luau_toolkit.lasm.tokenise(src);

    assert(res.ok);

    assert_token(res, 1, "END_KEYWORD");
    assert_token(res, 2, "STRING_KEYWORD");
    assert_token(res, 3, "CONST_KEYWORD");
    assert_token(res, 4, "ALIAS_KEYWORD");
    assert_token(res, 5, "PROTO_KEYWORD");
    assert_token(res, 6, "ENV_KEYWORD");
    assert_token(res, 7, "EOF");

    assert(#res.tokens == 7);
end);

test("lasm::tokenise::identifiers", function()
    local src = [[hello world]];
    local res = luau_toolkit.lasm.tokenise(src);

    assert(res.ok);

    assert_token(res, 1, "IDENTIFIER", "hello");
    assert_token(res, 2, "IDENTIFIER", "world");
    assert_token(res, 3, "EOF");

    assert(#res.tokens == 3);
end);

test("lasm::tokenise::comments", function()
    local src = "-- hello world\n--ahhhh\nend -- AHH!!!!";
    local res = luau_toolkit.lasm.tokenise(src);

    assert(res.ok);
    
    assert_token(res, 1, "END_KEYWORD");
    assert_token(res, 2, "EOF");

    assert(#res.tokens == 2);
end);

test("lasm::tokenise::nothing", function()
    local src = "    ";
    local res = luau_toolkit.lasm.tokenise(src);

    assert_token(res, 1, "EOF");

    assert(res.ok);
    assert(#res.tokens == 1);
end);

test("lasm::tokenise::doesnt_explode", function()
    local src = "- 0nXM Asshsdg23885234uv247htgrenhgoywg 1--=afasd fg;asd'; k end end end end const !!! AHHHHH!!!!!!!!!!";
    local res = luau_toolkit.lasm.tokenise(src);

    assert(not res.ok);
end);

test("lasm::parse::nothing", function()
    local src = [[]];
    local res = luau_toolkit.lasm.parse(luau_toolkit.lasm.tokenise(src).tokens);
    assert(res.ok);

    assert_ast_eq(res.root, luau_toolkit.LASM_AstChunk(_nil, {}));
end);

test("lasm::parse::strings", function()
    local src = [[
        string S1 = "Hello, World!";
    ]]; 

    local res = luau_toolkit.lasm.parse(luau_toolkit.lasm.tokenise(src).tokens);
    assert(res.ok);

    assert_ast_eq(res.root, luau_toolkit.LASM_AstChunk(_nil, {
        luau_toolkit.LASM_AstStringDef(_nil, "S1", "Hello, World!");
    }));
end);

test("lasm::parse::proto", function()
    local src = [[
        proto P0() end
    ]]; 

    local res = luau_toolkit.lasm.parse(luau_toolkit.lasm.tokenise(src).tokens);
    assert(res.ok);

    assert_ast_eq(res.root, luau_toolkit.LASM_AstChunk(_nil, {
        luau_toolkit.LASM_AstProtoDef(_nil, "P0", {}, {}, {});
    }));
end);

test("lasm::parse::instructions", function()
    local src = [[
        proto P0()
            LOADB 0, true;
            LOADN 1, 0;
            L1: RETURN 0, 3;
        end
    ]]; 

    local res = luau_toolkit.lasm.parse(luau_toolkit.lasm.tokenise(src).tokens);
    
    assert(res.ok);

    assert_ast_eq(res.root, luau_toolkit.LASM_AstChunk(_nil, {
        luau_toolkit.LASM_AstProtoDef(_nil, "P0", {}, {}, {
            luau_toolkit.LASM_AstInstruction(_nil, "LOADB", {luau_toolkit.LASM_AstValue(_nil, luau_toolkit.LASM_AstLiteral(_nil, 0)), luau_toolkit.LASM_AstValue(_nil, luau_toolkit.LASM_AstLiteral(_nil, true))}),
            luau_toolkit.LASM_AstInstruction(_nil, "LOADN", {luau_toolkit.LASM_AstValue(_nil, luau_toolkit.LASM_AstLiteral(_nil, 1)), luau_toolkit.LASM_AstValue(_nil, luau_toolkit.LASM_AstLiteral(_nil, 0))}),
            luau_toolkit.LASM_AstInstruction(_nil, "RETURN", {luau_toolkit.LASM_AstValue(_nil, luau_toolkit.LASM_AstLiteral(_nil, 0)), luau_toolkit.LASM_AstValue(_nil, luau_toolkit.LASM_AstLiteral(_nil, 3))}, "L1"),
        });
    }));
end);


test("lasm::parse::constants", function()
    local src = [[
        string S1 = "Hello, World!";

        proto P0()
            const K0 = nil;
            const K1 = true;
            const K2 = 123;
            const K3 = S1;
            const K4 = env.print;
            const K5 = nil; -- Replace with tbl lit
            const K6 = P0;
            const K7 = <0, 1, 2>;
        end
    ]]; 

    local res = luau_toolkit.lasm.parse(luau_toolkit.lasm.tokenise(src).tokens);
    assert(res.ok);
    
    assert_ast_eq(res.root, luau_toolkit.LASM_AstChunk(_nil, {
        luau_toolkit.LASM_AstStringDef(_nil, "S1", "Hello, World!"),
        luau_toolkit.LASM_AstProtoDef(_nil, "P0", {}, {}, {
            luau_toolkit.LASM_AstConstDef(_nil, "K0", luau_toolkit.LASM_AstValue(_nil, luau_toolkit.LASM_AstLiteral(_nil, nil))),
            luau_toolkit.LASM_AstConstDef(_nil, "K1", luau_toolkit.LASM_AstValue(_nil, luau_toolkit.LASM_AstLiteral(_nil, true))),
            luau_toolkit.LASM_AstConstDef(_nil, "K2", luau_toolkit.LASM_AstValue(_nil, luau_toolkit.LASM_AstLiteral(_nil, 123))),
            luau_toolkit.LASM_AstConstDef(_nil, "K3", luau_toolkit.LASM_AstValue(_nil, luau_toolkit.LASM_AstIdentifier(_nil, "S1"))),
            luau_toolkit.LASM_AstConstDef(_nil, "K4", luau_toolkit.LASM_AstValue(_nil, luau_toolkit.LASM_AstLiteral(_nil, {"print"}, "import"))),
            luau_toolkit.LASM_AstConstDef(_nil, "K5", luau_toolkit.LASM_AstValue(_nil, luau_toolkit.LASM_AstLiteral(_nil, nil))),
            luau_toolkit.LASM_AstConstDef(_nil, "K6", luau_toolkit.LASM_AstValue(_nil, luau_toolkit.LASM_AstIdentifier(_nil, "P0"))),
            luau_toolkit.LASM_AstConstDef(_nil, "K7", luau_toolkit.LASM_AstValue(_nil, luau_toolkit.LASM_AstLiteral(_nil, {0, 1, 2}, "vector"))),
        }),
    }));
end);
]==]

--------------------------------------------------------------------------------

local function run_tests()
    local tests_passing = true;

    local longest = 0;
    for _, test in tests do
        if #test.name > longest then
            longest = #test.name;
        end
    end

    for _, test in tests do
        stdio.write(string.format(`%-{longest}s .. `, test.name));
        local ok, err = pcall(test.fn :: any);
        if ok then
            stdio.write(`{stdio.color("green")}pass{stdio.color("reset")}\n`);
        else
            tests_passing = false;
            stdio.write(`{stdio.color("red")}fail{stdio.color("reset")}\n`);
            print(tostring(err));
        end
    end
    
    print("");
    
    if tests_passing then
        print("tests passed");
    else 
        error("tests failed");
    end
end

run_tests();