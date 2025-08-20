local t = {};

--- Function used to provide additional constant-folding in lieu of GETIMPORT instructions.
export type ConstantProvider = 
    & ((path: {string}) -> (true, any))
    & ((path: {string}) -> (false));

export type CompilerOptions = {
    --- Global Macros
    macros: {[string]: (...any) -> {--[[ AstInstruction ]]}}?,
    
    --- Globally defined values
    constants: {[string]: any},
};

export type LineCol = {
    line: number,
    col: number,
};

--[=[

]=]
export type TokenType = 
    -- Literal Tokens
    | "NIL_LITERAL"      -- `nil`       A nil literal
    | "BOOLEAN_LITERAL"  -- `true`      A boolean literal
    | "NUMBER_LITERAL"   -- `.12`       A number literal
    | "STRING_LITERAL"   -- `"hi"`      A string literal
    | "IMPORT_LITERAL"   -- `_G.print`  An import literal
    | "IDENTIFIER"       -- `_hello`    An identifier
    -- Keyword Tokens
    | "FUNCTION_KEYWORD" -- `function`  Declares a proto
    | "MACRO_KEYWORD"    -- `macro`     Declares a macro
    | "LET_KEYWORD"      -- `let`       Declares a binding
    | "CONST_KEYWORD"    -- `const`     Declares a constant table entry
    | "STRING_KEYWORD"   -- `string`    Declares a string table entry
    | "END_KEYWORD"      -- `end`       Ends a block
    | "EXTERN_KEYWORD"   -- `extern`    Declares a 'external function'
    | "FOR_KEYWORD"      -- `for`       Starts a for loop
    | "DO_KEYWORD"       -- `do`        Introduces a block following a for loop header
    | "IF_KEYWORD"       -- `if`        Starts an if statement / expression
    | "THEN_KEYWORD"     -- `then`      Introduces a block following if/elseif condition expression
    | "ELSE_KEYWORD"     -- `else`      Introduces a fallback else branch
    | "ELSEIF_KEYWORD"   -- `elseif`    Introduces a elseif branch
    | "AND_KEYWORD"      -- `and`       Logical AND operator
    | "OR_KEYWORD"       -- `or`        Logical OR operator
    | "NOT_KEYWORD"      -- `not`       Logical NOT operator
    -- Punctuation Tokens
    | "OPEN_PAREN"       -- `(`         Opens expression groups and proto arguments
    | "CLOSE_PAREN"      -- `)`         Closes expression groups and proto arguments
    | "OPEN_SBRACKET"    -- `[`         Opens vector literals, table literal keys and complex attributes
    | "CLOSE_SBRACKET"   -- `]`         Closes vector literals, table literal keys and complex attributes
    | "OPEN_CBRACKET"    -- `{`         Opens table literals
    | "CLOSE_CBRACKET"   -- `}`         Closes table literals
    | "EXCLAIM"          -- `!`         Macro suffix
    | "SEMICOLON"        -- `;`         Statement/field seperator
    | "COLON"            -- `:`         Preceeds an item type
    | "COMMA"            -- `,`         Parameter/field seperator
    | "PLUS"             -- `+`         Addition operator
    | "ASTERISK"         -- `*`         Multiplication operator
    | "CARET"            -- `^`         Exponent operator
    | "PERCENT"          -- `%`         Modulo operator
    | "HASH"             -- `#`         Length operator
    | "AMPERSAND"        -- `&`         Bitwise AND
    | "VBAR"             -- `|`         Open/closes vector literals
    | "HYPHEN"           -- `-`         Negation/subtraction operator
    | "DOT"              -- `.`         Index operator
    | "DOUBLE_DOT"       -- `..`        Concatenation operator
    | "TRIPLE_DOT"       -- `...`       MULTRET param or vararg function
    | "AT"               -- `@`         Opens a proto attribute
    | "AT_EXCLAIM"       -- `@!`        Opens a chunk attribute
    | "EQUALS"           -- `=`         Assignment operator
    | "DOUBLE_EQUALS"    -- `==`        Equality operator
    | "TILDE"            -- `~`         Bitwise NOT/XOR
    | "TILDE_EQUALS"     -- `~=`        Not-equality operator
    | "SLASH"            -- `/`         Division Operator
    | "DOUBLE_SLASH"     -- `//`        Integer Division Operator
    | "LT"               -- `<`         Less-than operator
    | "LT_EQUALS"        -- `<=`        Less-than-or-equal operator
    | "DOUBLE_LT"        -- `<<`        Logical left-shift operator
    | "GT"               -- `>`         Greater-than operator
    | "GT_EQUALS"        -- `>=`        Greater-than-or-equal operator
    | "DOUBLE_GT"        -- `>>`        Logical right-shift operator
    -- Trivia Tokens
    | "COMMENT"          --             A comment
    | "WHITESPACE"       --             Insignificant whitespace
    | "EOF"              --             Marks the end of a token stream
    -- Error Tokens
    | "UNEXPECTED"       --             An invalid token
    ;

--[=[

]=]
export type Token = {
    --[=[
        The token type.
    ]=]
    type: TokenType,
    
    --[=[
        The raw token text.
    ]=]
    lexeme: string,

    --[=[
        The literal value, if applicable.

        Applicable tokens:
        - `ERROR` (the error message),
        - `NIL_LITERAL`,
        - `BOOLEAN_LITERAL`,
        - `NUMBER_LITERAL`,
        - `VECTOR_LITERAL`,
        - `STRING_LITERAL`,
        - `IMPORT_LITERAL`,
        - `IDENTIFIER`,
        - `COMMENT` (the text, excluding `--` prefix, of the comment),
    ]=]
    literal: any,

    --[=[
        The portion of the source text the token comprises. 
        
        - `x` = Initial character
        - `y` = Final character
    ]=]
    span: vector,
};

function t._Token(token_type: TokenType, lexeme: string, span: vector, literal: any?): Token
    return {
        type = token_type,
        lexeme = lexeme,
        literal = literal,
        span = span,
    };
end

export type LexerErrorType = 
    "MALFORMED_LITERAL" | "UNEXPECTED_CHARACTER" | "UNTERMINATED_COMMENT";

export type LexerError = { 
    type: LexerErrorType,
    message: string,
    span: vector,
};

function t._LexerError(error_type: LexerErrorType, message: string, span: vector)
    return {
        type = error_type,
        message = message,
        span = span,
    };
end

export type LexerResult = {
    --[=[
        Whether the token stream contains `ERROR` tokens.

        It is safe to pass this to the parser even if `false`,
    ]=]
    ok: boolean,

    --[=[
        The token stream.
    ]=]
    tokens: {Token},

    --[=[
        Errors
    ]=]
    errors: {LexerError},
};

-----------------------------------------------------------

--[=[
    AST node representing an entire LASM document.
]=]
export type AstChunk = {
    kind: "AstChunk",
    location: vector,
    body: {AstProtoDecl | AstMacroDecl | AstStringDecl | AstAttribute | AstBindingDecl | AstExternDecl | AstConstDecl}
};

--[=[
    AST node representing either a function or chunk attribute.
]=]
export type AstAttribute = {
    kind: "AstAttribute",
    location: vector,
    name: string,
    arguments: {AstExpr},
};

--[=[
    AST node representing a string declaration.
]=]
export type AstStringDecl = {
    kind: "AstStringDecl",
    location: vector,
    name: string,
    value: AstExpr,
};

--[=[
    AST node representing an external function declaration.
]=]
export type AstExternDecl = {
    kind: "AstExternDecl",
    location: vector,
    name: string,
};

--[=[
    AST node representing a macro declaration.
]=]
export type AstMacroDecl = {
    kind: "AstMacroDecl",
    location: vector,
    name: string,
    parameters: {AstMacroParam},
    body: AstBlock,
};

--[=[
    AST node representing a macro parameter.
]=]
export type AstMacroParam = {
    kind: "AstMacroParam",
    location: vector,
    name: string,
    type: AstLasmType?,
};

--[=[
    AST node representing a proto declaration.
]=]
export type AstProtoDecl = {
    kind: "AstProtoDecl",
    location: vector,
    name: string,
    attributes: {AstAttribute},
    parameters: {AstProtoParam},
    vararg: boolean,
    return_type: AstLuauType?,
    body: AstBlock,
};

--[=[
    AST node representing a proto parameter.
]=]
export type AstProtoParam = {
    kind: "AstProtoParam",
    location: vector,
    name: string,
    type: AstLuauType?,
};

--[=[
    AST node representing a block.
]=]
export type AstBlock = {
    kind: "AstBlock",
    location: vector,
    body: {AstInstruction | AstBindingDecl | AstConstDecl | AstIfStat | AstForStat | AstDoStat},
};

--[=[
    AST node representing an emitted instruction.
]=]
export type AstInstruction = {
    kind: "AstInstruction",
    location: vector,
    label: AstLabelDecl?,
    name: string, -- Include `!`,
    args: {AstInsnArg},
};

--[=[
    AST node representing an instruction label.
]=]
export type AstLabelDecl = {
    kind: "AstLabelDecl",
    location: vector,
    name: string,
};

--[=[
    AST node representing an instruction argument.
]=]
export type AstInsnArg = {
    kind: "AstInsnArg",
    location: vector,
    body: "mulret" | AstExpr,
};

--[=[
    AST node representing a binding declaration.
]=]
export type AstBindingDecl = {
    kind: "AstBindingDecl",
    location: vector,
    name: string,
    type: AstLasmType?,
    value: AstExpr,
};

--[=[
    AST node representing a constant table entry declaration.
]=]
export type AstConstDecl = {
    kind: "AstConstDecl",
    location: vector,
    name: string,
    type: AstLuauType?,
    value: AstExpr,
};

--[=[
    AST node representing an if statement.
]=]
export type AstIfStat = {
    kind: "AstIfStat",
    location: vector,
    condition: AstExpr,
    then_body: AstBlock,
    else_body: AstBlock?,
};

--[=[
    AST node representing a for loop.
]=]
export type AstForStat = {
    kind: "AstForStat",
    location: vector,
    var_name: string, -- The identifier of the loop var,
    from: AstExpr,
    to: AstExpr,
    step: AstExpr?,
    body: AstBlock,
};

--[=[
    AST node representing a do block.
]=]
export type AstDoStat = {
    kind: "AstDoStat",
    location: vector,
    body: AstBlock,
};

--[=[
    AST node representing a luau type hint.
]=]
export type AstLuauType = {
    kind: "AstLuauType",
    location: vector,
    name: string,
    optional: boolean,
};

--[=[
    AST node representing a lasm type hint.
]=]
export type AstLasmType = {
    kind: "AstLasmType",
    location: vector,
    name: string,
};

--[=[
    AST node representing a literal value.
]=]
export type AstLiteral = {
    kind: "AstLiteral",
    location: vector,
} & ({
    type: "nil",
} | {
    type: "number",
    value: number,
} | {
    type: "string",
    value: string,
} | {
    type: "import",
    value: {string},
} | {
    type: "vector",
    value: AstVectorLiteral,
} | {
    type: "table",
    value: AstTableLiteral,
});

--[=[
    AST node representing a vector literal.
]=]
export type AstVectorLiteral = {
    kind: "AstVectorLiteral",
    location: vector,
    components: {AstExpr},
};

--[=[
    AST node representing a table literal.
]=]
export type AstTableLiteral = {
    kind: "AstTableLiteral",
    location: vector,
    fields: {AstTableField},
};

--[=[
    AST node representing a table field.
]=]
export type AstTableField = {
    kind: "AstTableField",
    location: vector,
    name: AstExpr|string?,
    value: AstExpr,
};

--[=[
    AST node representing an expression.
]=]
export type AstExpr = {
    kind: "AstExpr",
    location: vector,
} & ({
    type: "binop",
    op: "+" | "-" | "*" | "/" | "//" | "^" | "%" | "and" | "or" | "==" | "<" | "<=" | "<<" | ">" | ">=" | ">>" | ".." | "&" | "|" | "~",
    lhs: AstExpr,
    rhs: AstExpr
} | {
    type: "unop",
    op: "-" | "not" | "#" | "~",
    rhs: AstExpr,
} | {
    type: "group",
    expr: AstExpr,
} | {
    type: "literal",
    literal: AstLiteral,
} | {
    type: "identifier",
    identifier: string,
} | {
    type: "ifelse",
    condition: AstExpr,
    then_expr: AstExpr,
    else_expr: AstExpr,
});


-----------------------------------------------------------

--- Abstract 'TokenType' used solely for highlighting.
export type ColourType =
    | "nil" -- Nil literals
    | "boolean" -- Boolean Literals
    | "number" -- Number Literals
    | "string" -- String Literals
    | "import" -- Import Literal
    | "operator" 
    | "identifier" 
    | "keyword" 
    | "comment"
    | "error" -- Unknown / Unexpected Characters
    | "whitespace" -- pseudo colour type for whitespace
    ;

--- Highlighter Result
export type HighlightedSection = { content: string, colour: ColourType };
export type Highlighted = {HighlightedSection};
export type HighlightMode = "simple" | "advanced";

-----------------------------------------------------------

return t;
