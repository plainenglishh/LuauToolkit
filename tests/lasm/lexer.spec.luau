--!native

local lasm = require("@luau_toolkit/lasm");
local testing = require("@testing/utils");

local function fuzz_input()
    for i = 1, 100 do
        print(`---------- fuzz test {i}`);
        local original = buffer.create(10000);
        for offset = 0, 10000 - 1 do
            buffer.writeu8(original, offset, math.random(0, 255));
        end

        local res = lasm.lexer.lex(original);
        local reconstituted = buffer.fromstring(lasm.lexer.reconstitute_tokens(res.tokens));
        testing.assert_eq(original, reconstituted, "expected reconstituted to be equal to original"); -- Means all tokens are accounted for and none are duplicated
    end
end

local function all_tokens()
    local src = [==========[
        nil
        true false
        0 .10e-10 0b1100_1100 0xFF00_FF00 
        "Hello, World" "\a\f\n\r\t\v\\\"\'\
\041\x45\z
    \u{007E}\kahhh" [[ahhhhh]] [=[ multiline [[inner]] ]=] [[
bob]]
        _G.WHAT _G.print.com
        ident_example _ahhhhh a27
        function macro let const string end extern for do if then else elseif and or not
        ()]{}!;:,+*^%#|&
        [-
        . .. ... .....
        @ @!
        = == ===
        ~ ~= 
        / // ///
        < <= << <<<
        > >= >> >>>
    ]==========];

    local res = lasm.lexer.lex(src);
    if not res.ok then
        print(res.errors)
        error("expected lexer result to be okay");
    end

    local tokens = lasm.lexer.strip_tokens(res.tokens);

    local i = 1;
    local function check_token(type: string, literal: any?)
        local token = tokens[i];
        i += 1;

        if token.type ~= type then
            print(token);
            error(`expected token {i} to be {type}`, 2);
        end

        if literal ~= nil and not testing.eq(literal, token.literal) then
            print(token);
            error(`expected token {i} to have literal value {literal}`);
        end
    end

    check_token("NIL_LITERAL");

    check_token("BOOLEAN_LITERAL", true);
    check_token("BOOLEAN_LITERAL", false);
    
    check_token("NUMBER_LITERAL", 0);
    check_token("NUMBER_LITERAL", .10e-10);
    check_token("NUMBER_LITERAL", 0b1100_1100);
    check_token("NUMBER_LITERAL", 0xFF00_FF00);

    check_token("STRING_LITERAL", "Hello, World");
    check_token("STRING_LITERAL", "\a\f\n\r\t\v\\\"\'\n\041\x45\x7Ekahhh");
    check_token("STRING_LITERAL", "ahhhhh");
    check_token("STRING_LITERAL", " multiline [[inner]] ");
    check_token("STRING_LITERAL", "bob");

    check_token("IMPORT_LITERAL", {"WHAT"});
    check_token("IMPORT_LITERAL", {"print", "com"});

    check_token("IDENTIFIER", "ident_example");
    check_token("IDENTIFIER", "_ahhhhh");
    check_token("IDENTIFIER", "a27");

    check_token("FUNCTION_KEYWORD");
    check_token("MACRO_KEYWORD");
    check_token("LET_KEYWORD");
    check_token("CONST_KEYWORD");
    check_token("STRING_KEYWORD");
    check_token("END_KEYWORD");
    check_token("EXTERN_KEYWORD");
    check_token("FOR_KEYWORD");
    check_token("DO_KEYWORD");
    check_token("IF_KEYWORD");
    check_token("THEN_KEYWORD");
    check_token("ELSE_KEYWORD");
    check_token("ELSEIF_KEYWORD");
    check_token("AND_KEYWORD");
    check_token("OR_KEYWORD");
    check_token("NOT_KEYWORD");
    
    check_token("OPEN_PAREN");
    check_token("CLOSE_PAREN");
    check_token("CLOSE_SBRACKET");
    check_token("OPEN_CBRACKET");
    check_token("CLOSE_CBRACKET");
    check_token("EXCLAIM");
    check_token("SEMICOLON");
    check_token("COLON");
    check_token("COMMA");
    check_token("PLUS");
    check_token("ASTERISK");
    check_token("CARET");
    check_token("PERCENT");
    check_token("HASH");
    check_token("VBAR");
    check_token("AMPERSAND");

    check_token("OPEN_SBRACKET");
    check_token("HYPHEN");

    check_token("DOT");
    check_token("DOUBLE_DOT");
    check_token("TRIPLE_DOT");
    check_token("TRIPLE_DOT");
    check_token("DOUBLE_DOT");

    check_token("AT");
    check_token("AT_EXCLAIM")

    check_token("EQUALS");
    check_token("DOUBLE_EQUALS");
    check_token("DOUBLE_EQUALS");
    check_token("EQUALS");

    check_token("TILDE");
    check_token("TILDE_EQUALS");

    check_token("SLASH");
    check_token("DOUBLE_SLASH");
    check_token("DOUBLE_SLASH");
    check_token("SLASH");

    check_token("LT");
    check_token("LT_EQUALS");
    check_token("DOUBLE_LT");
    check_token("DOUBLE_LT");
    check_token("LT");

    check_token("GT");
    check_token("GT_EQUALS");
    check_token("DOUBLE_GT");
    check_token("DOUBLE_GT");
    check_token("GT");

    check_token("EOF");
end

all_tokens();
fuzz_input();