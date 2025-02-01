--!nolint LocalShadow

_G.BYTEPARSE_SUPPRESS_WARNINGS = true;

local stdio = require("@lune/stdio");
local serde = require("@lune/serde");
local luau = require("@lune/luau");
local luau_toolkit = require("../src/lib");
local t = require("../src/lib/typedefs");


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

local function assert_ast_eq(a: t.LASM_AstChunk, b: t.LASM_AstChunk)
    a = strip_spans(a);
    b = strip_spans(b);
    assert(eq(a, b))
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

test("bytecode::{encode,decode}", function()
    local original_bc = luau.compile([[
        return "Hello, World!";
    ]], {
        optimizationLevel = 2,
        debugLevel = 2,
    });

    local ir_chunk = luau_toolkit.bytecode.decode(original_bc);
    local reencoded_bc = luau_toolkit.bytecode.encode(ir_chunk);

    local fn = luau.load(buffer.tostring(reencoded_bc));
    assert(fn and fn() == "Hello, World!");
end);

test("bytecode::{encode_import_id,decode_import_id}", function()
    local encoded = luau_toolkit.bytecode.encode_import_id({1, 2, 3});
    local decoded = luau_toolkit.bytecode.decode_import_id(encoded);

    assert(decoded[1] == 1);
    assert(decoded[2] == 2);
    assert(decoded[3] == 3);
end);


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

    assert_ast_eq(res.root, t.LASM_AstChunk(_nil, {}));
end);

test("lasm::parse::strings", function()
    local src = [[
        string S1 = "Hello, World!";
    ]]; 

    local res = luau_toolkit.lasm.parse(luau_toolkit.lasm.tokenise(src).tokens);
    assert(res.ok);

    assert_ast_eq(res.root, t.LASM_AstChunk(_nil, {
        t.LASM_AstStringDef(_nil, "S1", "Hello, World!");
    }));
end);

test("lasm::parse::proto", function()
    local src = [[
        proto P0() end
    ]]; 

    local res = luau_toolkit.lasm.parse(luau_toolkit.lasm.tokenise(src).tokens);
    assert(res.ok);

    assert_ast_eq(res.root, t.LASM_AstChunk(_nil, {
        t.LASM_AstProtoDef(_nil, "P0", {}, {}, {});
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

    assert_ast_eq(res.root, t.LASM_AstChunk(_nil, {
        t.LASM_AstProtoDef(_nil, "P0", {}, {}, {
            t.LASM_AstInstruction(_nil, "LOADB", {t.LASM_AstValue(_nil, t.LASM_AstLiteral(_nil, 0)), t.LASM_AstValue(_nil, t.LASM_AstLiteral(_nil, true))}),
            t.LASM_AstInstruction(_nil, "LOADN", {t.LASM_AstValue(_nil, t.LASM_AstLiteral(_nil, 1)), t.LASM_AstValue(_nil, t.LASM_AstLiteral(_nil, 0))}),
            t.LASM_AstInstruction(_nil, "RETURN", {t.LASM_AstValue(_nil, t.LASM_AstLiteral(_nil, 0)), t.LASM_AstValue(_nil, t.LASM_AstLiteral(_nil, 3))}, "L1"),
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
    
    assert_ast_eq(res.root, t.LASM_AstChunk(_nil, {
        t.LASM_AstStringDef(_nil, "S1", "Hello, World!"),
        t.LASM_AstProtoDef(_nil, "P0", {}, {}, {
            t.LASM_AstConstDef(_nil, "K0", t.LASM_AstValue(_nil, t.LASM_AstLiteral(_nil, nil))),
            t.LASM_AstConstDef(_nil, "K1", t.LASM_AstValue(_nil, t.LASM_AstLiteral(_nil, true))),
            t.LASM_AstConstDef(_nil, "K2", t.LASM_AstValue(_nil, t.LASM_AstLiteral(_nil, 123))),
            t.LASM_AstConstDef(_nil, "K3", t.LASM_AstValue(_nil, t.LASM_AstIdentifier(_nil, "S1"))),
            t.LASM_AstConstDef(_nil, "K4", t.LASM_AstValue(_nil, t.LASM_AstLiteral(_nil, {"print"}, "import"))),
            t.LASM_AstConstDef(_nil, "K5", t.LASM_AstValue(_nil, t.LASM_AstLiteral(_nil, nil))),
            t.LASM_AstConstDef(_nil, "K6", t.LASM_AstValue(_nil, t.LASM_AstIdentifier(_nil, "P0"))),
            t.LASM_AstConstDef(_nil, "K7", t.LASM_AstValue(_nil, t.LASM_AstLiteral(_nil, {0, 1, 2}, "vector"))),
        }),
    }));
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