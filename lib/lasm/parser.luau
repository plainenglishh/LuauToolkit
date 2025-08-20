local t = require("./types");
local lexer = require("./lexer");

--[=[
    Pratt parser for parsing expressions.
]=]
local function parse_expr(tokens: {t.Token}, cursor: number): (number, t.AstExpr?)
    local root = nil;



    return cursor, root;
end

parse_expr({}, 1)

local parser = {};

function parser.parse(src: string | buffer | t.LexerResult)
    local lexer_result = if type(src) == "table" then src else lexer.lex(src);
    local ok = lexer_result.ok;

    local cursor = 0;

    local function expr()
        
    end
end

return parser;
