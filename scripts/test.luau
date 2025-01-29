--!nolint LocalShadow

_G.BYTEPARSE_SUPPRESS_WARNINGS = true;

local stdio = require("@lune/stdio");
local serde = require("@lune/serde");
local luau = require("@lune/luau");
local luau_toolkit = require("../src/lib");

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

test("ir::{encode,decode}", function()
    local bc = luau.compile([[
        local HELLO_WORLD = "Hello, World!";

        local function print_hello_world(rep: number)
            print(string.rep(HELLO_WORLD, rep));
        end

        print_hello_world();
    ]], {
        optimizationLevel = 2,
        debugLevel = 2,
    });

    local ir_chunk = luau_toolkit.ir.decode(bc);
    luau_toolkit.ir.decode(luau_toolkit.ir.encode(ir_chunk)); -- Assume the fact it didn't panic means it worked for now.
end);

test("lasm::tokeniser::punctuation", function()
    local src = "()[]@!=;:.,";
    local res = luau_toolkit.lasm.tokeniser.tokenise(src);
    
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

    assert(#res.tokens == 11);
end);

test("lasm::tokeniser::number_literals", function()
    local src = "100 2_0_0 0.123 10_10.10_10 0b11111111 0b1000_0000 0xFFFF 0xFF_00";
    local res = luau_toolkit.lasm.tokeniser.tokenise(src);

    assert(res.ok);

    assert_token(res, 1, "NUMBER_LITERAL", 100);
    assert_token(res, 2, "NUMBER_LITERAL", 200);
    assert_token(res, 3, "NUMBER_LITERAL", 0.123);
    assert_token(res, 4, "NUMBER_LITERAL", 10_10.10_10);
    assert_token(res, 5, "NUMBER_LITERAL", 0b11111111);
    assert_token(res, 6, "NUMBER_LITERAL", 0b1000_0000);
    assert_token(res, 7, "NUMBER_LITERAL", 0xFFFF);
    assert_token(res, 8, "NUMBER_LITERAL", 0xFF_00);
    
    assert(#res.tokens == 8);
end);

test("lasm::tokeniser::string_literals", function()
    local src = [["Hello, World!" "he said \"hi\"!" "\x00\xFF" "hello\z   world"]];
    local res = luau_toolkit.lasm.tokeniser.tokenise(src);

    assert(res.ok);

    assert_token(res, 1, "STRING_LITERAL", "Hello, World!");
    assert_token(res, 2, "STRING_LITERAL", "he said \"hi\"!");
    assert_token(res, 3, "STRING_LITERAL", "\x00\xFF");
    assert_token(res, 4, "STRING_LITERAL", "helloworld");

    assert(#res.tokens == 4);
end);

test("lasm::tokeniser::vector_literals", function()
    local src = [[<1, 2, 3><1,>]];
    local res = luau_toolkit.lasm.tokeniser.tokenise(src);

    assert(res.ok);

    assert_token(res, 1, "VECTOR_LITERAL", {1, 2, 3});
    assert_token(res, 2, "VECTOR_LITERAL", {1});
    
    assert(#res.tokens == 2);
end);

test("lasm::tokeniser::import_literals", function()
    local src = [[env.print env.string.byte]];
    local res = luau_toolkit.lasm.tokeniser.tokenise(src);

    assert(res.ok);

    assert_token(res, 1, "IMPORT_LITERAL", {"print"});
    assert_token(res, 2, "IMPORT_LITERAL", {"string", "byte"});

    assert(#res.tokens == 2);
end);

test("lasm::tokeniser::boolean_literals", function()
    local src = [[true false]];
    local res = luau_toolkit.lasm.tokeniser.tokenise(src);

    assert(res.ok);

    assert_token(res, 1, "BOOLEAN_LITERAL", true);
    assert_token(res, 2, "BOOLEAN_LITERAL", false);

    assert(#res.tokens == 2);
end);

test("lasm::tokeniser::nil_literal", function()
    local src = [[nil]];
    local res = luau_toolkit.lasm.tokeniser.tokenise(src);

    assert(res.ok);

    assert_token(res, 1, "NIL_LITERAL");
    
    assert(#res.tokens == 1);
end);

test("lasm::tokeniser::keywords", function()
    local src = [[end string const alias proto env]];
    local res = luau_toolkit.lasm.tokeniser.tokenise(src);

    assert(res.ok);

    assert_token(res, 1, "END_KEYWORD");
    assert_token(res, 2, "STRING_KEYWORD");
    assert_token(res, 3, "CONST_KEYWORD");
    assert_token(res, 4, "ALIAS_KEYWORD");
    assert_token(res, 5, "PROTO_KEYWORD");
    assert_token(res, 6, "ENV_KEYWORD");

    assert(#res.tokens == 6);
end);

test("lasm::tokeniser::identifiers", function()
    local src = [[hello world]];
    local res = luau_toolkit.lasm.tokeniser.tokenise(src);

    assert(res.ok);

    assert_token(res, 1, "IDENTIFIER", "hello");
    assert_token(res, 2, "IDENTIFIER", "world");

    assert(#res.tokens == 2);
end);

test("lasm::tokeniser::comments", function()
    local src = "-- hello world\n--ahhhh\nend -- AHH!!!!";
    local res = luau_toolkit.lasm.tokeniser.tokenise(src);

    assert(res.ok);
    
    assert_token(res, 1, "END_KEYWORD");

    assert(#res.tokens == 1);
end);

test("lasm::tokeniser::nothing", function()
    local src = "    ";
    local res = luau_toolkit.lasm.tokeniser.tokenise(src);

    assert(res.ok);
    assert(#res.tokens == 0);
end);

test("lasm::tokeniser::doesnt_explode", function()
    local src = "- 0nXM Asshsdg23885234uv247htgrenhgoywg 1--=afasd fg;asd'; k end end end end const !!! AHHHHH!!!!!!!!!!";
    local res = luau_toolkit.lasm.tokeniser.tokenise(src);

    assert(not res.ok);
end);

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