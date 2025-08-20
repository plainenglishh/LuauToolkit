local common = require("@luau_toolkit/common");
local lexer = require("./lexer")
local t = require("./types");

local TOKEN_TYPE_TO_COLOUR_TYPE: {[t.TokenType]: string} = {
    NIL_LITERAL = "nil",
    BOOLEAN_LITERAL = "boolean",
    NUMBER_LITERAL = "number",
    STRING_LITERAL = "string",
    IMPORT_LITERAL = "import",
    IDENTIFIER = "identifier",

    FUNCTION_KEYWORD = "keyword",
    MACRO_KEYWORD = "keyword",
    LOCAL_KEYWORD = "keyword",
    CONST_KEYWORD = "keyword",
    STRING_KEYWORD = "keyword",
    END_KEYWORD = "keyword",
    EXTERN_KEYWORD = "keyword",
    FOR_KEYWORD = "keyword",
    DO_KEYWORD = "keyword",
    IF_KEYWORD = "keyword",
    THEN_KEYWORD = "keyword",
    ELSE_KEYWORD = "keyword",
    ELSEIF_KEYWORD = "keyword",
    AND_KEYWORD = "keyword",
    OR_KEYWORD = "keyword",
    NOT_KEYWORD = "keyword",

    OPEN_PAREN = "operator",
    CLOSE_PAREN = "operator",
    OPEN_SBRACKET = "operator",
    CLOSE_SBRACKET = "operator",
    OPEN_CBRACKET = "operator",
    CLOSE_CBRACKET = "operator",
    EXCLAIM = "operator",
    SEMICOLON = "operator",
    COLON = "operator",
    COMMA = "operator",
    PLUS = "operator",
    ASTERISK = "operator",
    CARET = "operator",
    PERCENT = "operator",
    HASH = "operator",
    VBAR = "operator",
    HYPHEN = "operator",
    DOT = "operator",
    DOUBLE_DOT = "operator",
    TRIPLE_DOT = "operator",
    AT = "operator",
    AT_EXCLAIM = "operator",
    EQUALS = "operator",
    DOUBLE_EQUALS = "operator",
    TILDE_EQUALS = "operator",
    SLASH = "operator",
    DOUBLE_SLASH = "operator",
    LT = "operator",
    LT_EQUALS = "operator",
    DOUBLE_LT = "operator",
    GT = "operator",
    GT_EQUALS = "operator",
    DOUBLE_GT = "operator",

    COMMENT = "comment",
    WHITESPACE = "whitespace",
    EOF = "whitespace",

    UNEXPECTED = "error",
};

type AnsiColourMap = {[t.ColourType]: number|{number}};

local DEFAULT_ANSI_COLOUR_MAP: AnsiColourMap = {
    ["nil"] = 94,
    ["boolean"] = 94,
    ["number"] = 95,
    ["string"] = 92,
    ["import"] = 94,
    ["operator"] = 30,
    ["identifier"] = 0,
    ["keyword"] = {94, 1},
    ["comment"] = 2,
    ["error"] = {97, 101},
};

--- Syntax Highlighting for LASM
local highlighter = {};

--[=[
    Simple highlighter that only lexes a document.
]=]
function highlighter.simple_highlight(src: string | buffer): t.Highlighted
    local lexer_result = lexer.lex(src);
    local highlighted = {};

    for _, token in lexer_result.tokens do
        table.insert(highlighted, {
           content = token.lexeme,
           colour = TOKEN_TYPE_TO_COLOUR_TYPE[token.type], 
        });
    end

    return highlighted;
end

--[=[
    Formats a highlighted document into ANSI colours.
]=]
function highlighter.highlight_ansi(src: string | buffer | t.Highlighted, colour_map: AnsiColourMap?, mode: t.HighlightMode?): string
    local colour_map = colour_map or DEFAULT_ANSI_COLOUR_MAP;
    local mode: t.HighlightMode = mode or "simple";

    local highlighted;
    
    if type(src) == "string" or type(src) == "buffer" then
        if mode == "simple" then
            highlighted = highlighter.simple_highlight(src);
        --elseif mode == "advanced" then -- FALLTHROUGH
        else
            error("unsupported highlighter mode");
        end
    elseif type(src) == "table" then
        highlighted = src;
    else
        error("unexpected argument");
    end

    local builder = common.StringBuilder.new();

    for _, span in highlighted do 
        if span.colour == "whitespace" then
            builder:write(span.content);
            continue;
        end

        local styles = colour_map[span.colour];
        local styles: {number} = if type(styles) == "table" then styles else {styles};

        builder:write("\u{001B}[0");
        for i, code in styles do
            builder:write(`;{code}`);
        end
        builder:write(`m`);
        builder:write(span.content);
        builder:write("\u{001B}[0m");
    end

    return builder:build();
end

return highlighter;
