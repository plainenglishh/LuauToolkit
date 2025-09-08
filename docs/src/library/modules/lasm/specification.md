# Luau Bytecode Assembly ("LASM") Reference

# 1. Introduction

This document serves as both a reference and the specification for the Luau
Bytecode Assembly Language ("LASM").

LASM is an assembly-style language for generating Luau Bytecode chunks. LASM is
a toy language for experimental use, and probably shouldn't be used in
production projects.

The structure of this document is loosely based on the
[Lua 5.1 Reference Manual](https://www.lua.org/manual/5.1/manual.html).

A prerequisite understanding of Luau is required before reading this document,
as it makes no attempt to redefine Luau concepts.

# 2. The Language

This section describes the syntax and semantics of LASM. This section describes
syntax using Extended BNF notation.

## 2.1. Lexical Conventions

This section describes the lexical conventions of the language. LASM is a case
sensitive language.

### 2.1.1. Identifiers

An identifier in LASM can be any string of letters, digits and underscores, not
beginning with a digit.

### 2.1.2. Keywords

The following keywords are reserved and cannot be used as identifiers:

- `function`;
- `macro`;
- `define`;
- `const`;
- `string`;
- `end`;
- `extern`;
- `for`;
- `do`;
- `if`;
- `then`;
- `else`;
- `elseif`;
- `and`;
- `or`;
- `not`.

### 2.1.3. Punctuation

The following strings denote punctuation tokens:

- `(`;
- `)`;
- `[`;
- `]`;
- `{`;
- `}`;
- `!`;
- `;`;
- `:`;
- `,`;
- `+`;
- `-`;
- `*`;
- `^`;
- `%`;
- `#`;
- `|`;
- `.`;
- `..`;
- `...`;
- `@`;
- `@!`;
- `=`;
- `==`;
- `~=`;
- `/`;
- `//`;
- `<`;
- `<=`;
- `<<`;
- `>`;
- `>=`;
- `>>`.

### 2.1.4. Literal Nil

A nil literal is written as `nil`.

### 2.1.5. Literal Booleans

A boolean literal is written as either `true` or `false`.

### 2.1.6. Literal Numbers

A number literal can be written with an optional decimal part and an optional
decimal exponent. LASM also accepts integer hexadecimal and binary constants by
prefixing them with `0x` and `0b` accordingly. Number literals may also include
embedded underscores.

Examples:

- `3`;
- `1_000`;
- `3.0`;
- `3.1416`;
- `314.16e-2`;
- `0.314_16E1`;
- `0x56`;
- `0XaaFF`;
- `0b0000_1111`.

### 2.1.7. Literal Strings

#### Single Line Strings

Single line literal strings are written with matching single (`'`) or double
quotes (`"`).

```plaintext
"Hello, World"

'Single line quotes instead'

"this has\"escape sequences\":\n\x2B\57" = this has "escape sequences":<LF>+9

"ahhh \
dsggsdgsd" = ahhh<LF>dsggsdgsd

"sdfgsdfg\z
    asgsdgsd" = sdfgsdfgasgsdgsd
```

Single line strings accept the following escape sequences:

| Escape Sequence                        | Meaning                                                                                                                       |
| -------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| `\a`                                   | Bell                                                                                                                          |
| `\f`                                   | Form Feed                                                                                                                     |
| `\n`                                   | Newline                                                                                                                       |
| `\r`                                   | Carriage Return                                                                                                               |
| `\t`                                   | Horizontal Tab                                                                                                                |
| `\v`                                   | Vertical Tab                                                                                                                  |
| `\\`                                   | Backslash                                                                                                                     |
| `\"`                                   | Double Quote                                                                                                                  |
| `\'`                                   | Single Quote                                                                                                                  |
| `\<LF>` `\<CR><LF>`                    | Multi line string within single line string. If you want to split a single line string over multiple lines, use `\z` instead. |
| `\z`                                   | Ignore all subsequent whitespace, including new-lines, until the next non-whitespace character.                               |
| `\<d>` (e.g `\127` or `\0`)            | Arbitrary ASCII decimal character `d`. Up to three decimal digits.                                                            |
| `\x<h>`(e.g `\xAB` for `0xAB`)         | Arbitrary ASCII hexadecimal character `h`.                                                                                    |
| `\u{<h>}` (e.g `\u{ABC}` for `U+0ABC`) | Arbitrary Unicode hexadecimal character `h`.                                                                                  |

#### Multi Line Strings

Multi line literal strings are written by matching `[[` and `]]` pairs. Any
number of `=` can be inserted between the brackets, and the string will only
terminate when matching a closing pair with the same amount of `=`.

If the opening bracket is immediately followed by a new line, the new line will
be ignored.

```plaintext
[[
    Hello, World
]]

[=[
    Embedded: [[
        AHHH 
    ]]

    [==[]==]
]=]
```

Multi line strings are 'literal', and do not accept escape sequences.

### 2.1.8. Comments

#### Single Line Comments

A single line comments begins with a double hyphen (`--`) and continue until the
line ends.

#### Multi Line Comments

A multi line comment begins with a double hyphen, followed by the same long
bracket syntax as a multi line string, and continues until the matching closing
bracket.

### 2.1.9. Vector Literals

A vector literal are written with a `<` and `>` angle bracket pair. Vector
components are written using the same syntax as number literals, and are
delimited with commas. Whitespace is permitted within vector literals. Examples
of literal vectors include:

```plaintext
<0.123, -0xFF, 1_000>

<1, 2, 3, 4>    -- Allowed even when running in a 3-wide environment, as vector constants always have 4 components regardless of VM vector size.
```

A vector literal can have to up to four components, with components defaulting
to `0`.

### 2.1.10. Table Literals

### 2.1.11. Import Literals

An import literal begins with an `_G` identifier, with all subsequent path
components also as identifiers prefixed with a `.`. Examples of literal imports
include:

```plaintext
_G.print    _G.string.sub   _G.game.workspace
```

## 2.2. Identifiers

## 2.3. Expressions and Statements

## 2.4. Protos (aka Functions)

A proto, known as 'function' in code, is a container for bytecode instructions
and constants, and maps to the Luau 'function' type when instantiated by
`NEWCLOSURE` and `DUPCLOSURE`. Each function is allocated up to 255 registers at
runtime. Proto are defined in the top level proto table.

A proto, while called a function in many places, is a distinct concept. A proto
can be seen as a 'blueprint' for a function. Functions are also referred to as
'closures', even if they use no upvalues (see `NEWCLOSURE` instruction).

```lasm
function P_new_table(): table
    NEWTABLE R0;
    RETURN R0, 1;
end
```

### Constant

A constant is a container for a constant value used within a function. Constants
can contain a nil, boolean, number, string, table, vector and even a closure.

Constants can also contain an import path, which is a shorthand for up to three
strings, representing an import path.

Constants are defined with:

```lasm
const <Identifier>[: <Type>] = <Expr>;
```

Constants can also be implicitly defined in instruction arguments.

```lasm
LOADK R0, 10;
```

Constants can also be declared at the top level scope, where it (and it's
dependent constants) will be copied into the functions in which its used. Global
constants cannot be given a specific index, and the given index may vary between
protos.

### Attributes

### Register

A register is a 'slot' that can contain a Luau value. Protos can use up to 255
registers.

## 2.5. Strings

A string is a series of 8-bit safe ASCII characters defined in the chunk level
string table. Strings are defined using the following syntax:

```lasm
string S_hello = "hello, world";
```

Strings can also be defined implicitly in the same places constants can be
defined, including implicitly within register arguments.

## 2.6. Macros and Bindings

- both kinds

## 2.7. Coercion

Items that point to indexes can be coerced to numbers, and vice versa.

```lasm
const K0: number = "" + 1;
```

# 3. Example Code

```lasm
--[=[
    Prints the contents of a register
]=]
define dbg(reg: register)
    GETIMPORT R254, _G.print;
    MOVE REG, R255;
    CALL R254, 1, 0;
    
    LOADNIL R254;
    LOADNIL R255;
end


function P_add(a: number, b: number): number
    ADD R0, a, b;
    dbg R0;
    RETURN R0, 1;
end

function P_block_forever()
    L0: JUMP L0;
end

function P_main(...): table -- Proto alias `main` is implicitly @main
    NEWTABLE R0;
    
    NEWCLOSURE R1, P_add;
    SETTABLEKS R1, R0, "add";

    NEWCLOSURE R1, P_block_forever;
    SETTABLEKS R1, R0, "block_forever";

    RETURN R0, 1;
end
```

# 4. Grammar, Precedence and Associativity

## 4.1. Grammar

The following is the EBNF grammar for LASM, defining lexing and parsing
requirements.

EBNF items are cased according to what structure they represent:

| Item Casing               | Meaning                                |
| ------------------------- | -------------------------------------- |
| `UpperCamelCase`          | Corresponds to a parse tree structure. |
| `SCREAMING_SNAKE_CASE`    | Corresponds to a lexer token.          |
| `snake_case` or `luacase` | Internal definition for brevity.       |

For brevity, the following abbreviations are used:

| Abbreviation | Meaning     |
| ------------ | ----------- |
| `Expr`       | Expression  |
| `Stat`       | Statement   |
| `Decl`       | Declaration |
| `Attr`       | Attribute   |

Note the following grammar is not intended to be fed to a parser generator, and
instead serves as a reference for writing handwritten parsers.

```ebnf
(* 
    Syntax Parse Tree 
*)
 
Chunk         = {chunk_stat} EOF; (* root *)
chunk_stat    = ProtoDecl | MacroDecl | StringDecl | chunk_attr | BindingDecl | ExternDecl | ConstDecl;

chunk_attr    = AT_EXCLAIM Attribute;
StringDecl    = STRING_KEYWORD IDENTIFIER EQUALS Expr SEMICOLON;
ExternDecl    = EXTERN_KEYWORD IDENTIFIER SEMICOLON;

MacroDecl     = MACRO_KEYWORD IDENTIFIER EXCLAIM macro_params Block END_KEYWORD;
macro_params  = OPEN_PAREN [MacroParam {COMMA MacroParam}] CLOSE_PAREN;
MacroParam    = IDENTIFIER [COLON LasmType];

ProtoDecl     = {proto_attr} PROTO_KEYWORD IDENTIFIER proto_params [COLON LuauType] Block END_KEYWORD;
proto_params  = OPEN_PAREN [ProtoParam {COMMA ProtoParam}] [COMMA TRIPLE_DOT] CLOSE_PAREN;
ProtoParam    = IDENTIFIER [COLON LuauType];
proto_attr    = AT Attribute;

Block         = {statement};
statement     = Instruction | BindingDecl | ConstDecl | IfStat | ForStat | DoStat;
Instruction   = [LabelDecl] IDENTIFIER [EXCLAIM] [insn_arg] {COMMA insn_arg} SEMICOLON;
LabelDecl     = IDENTIFIER COLON;
InsnArg       = Expr | TRIPLE_DOT; 
BindingDecl   = LET_KEYWORD IDENTIFIER [COLON LasmType] EQUALS Expr SEMICOLON;
ConstDecl     = CONST_KEYWORD IDENTIFIER [COLON LuauType] EQUALS Expr SEMICOLON; (* LuauTypes checked during analysis to prevent `type?` *)
IfStat        = IF_KEYWORD Expr THEN_KEYWORD Block {ELSEIF_KEYWORD Expr THEN_KEYWORD Block} [ELSE_KEYWORD Block] END_KEYWORD;
ForStat       = FOR_KEYWORD IDENTIFIER EQUALS Expr COMMA Expr [COMMA Expr] DO_KEYWORD Block END_KEYWORD;
DoStat        = DO_KEYWORD Block END_KEYWORD;

LuauType      = (IDENTIFIER | FUNCTION_KEYWORD | STRING_KEYWORD | NIL_LITERAL) ['?'];
LasmType      = IDENTIFIER | FUNCTION_KEYWORD | STRING_KEYWORD;

complex_attr  = IDENTIFIER OPEN_PAREN Expr {COMMA Expr} CLOSE_PAREN;
Attribute     = IDENTIFIER
              | OPEN_SBRACKET complex_attr {COMMA complex_attr} CLOSE_SBRACKET;

Literal       = NIL_LITERAL | BOOLEAN_LITERAL | NUMBER_LITERAL | STRING_LITERAL | IMPORT_LITERAL | VectorLiteral | TableLiteral;

VectorLiteral = OPEN_SBRACKET [Expr {COMMA Expr}] CLOSE_SBRACKET;

TableLiteral  = OPEN_CBRACKET TableField {field_sep TableField} [field_sep] CLOSE_CBRACKET;
TableField    = OPEN_SBRACKET Expr CLOSE_SBRACKET EQUALS Expr
              | IDENTIFIER EQUALS Expr 
              | Expr;
field_sep     = COMMA | SEMICOLON;

Expr          = simple_expr {bin_op Expr} | un_op simple_expr {bin_op Expr} | OPEN_PAREN Expr CLOSE_PAREN;
simple_expr   = Literal | IDENTIFIER | if_else_expr;
if_else_expr  = IF_KEYWORD Expr THEN_KEYWORD Expr {ELSEIF_KEYWORD Expr THEN_KEYWORD Expr} ELSE_KEYWORD Expr;
bin_op        = PLUS | HYPHEN | ASTERISK | SLASH | DOUBLE_SLASH | CARET | PERCENT | AND_KEYWORD | OR_KEYWORD | DOUBLE_EQUALS | LT | LT_EQUALS | DOUBLE_LT | GT | GT_EQUALS | DOUBLE_GT | DOUBLE_DOT | AMPERSAND | VBAR | TILDE;
un_op         = HYPHEN | NOT_KEYWORD | HASH | TILDE;


(* 
    Tokens
*)

(* Literal Tokens *)
NIL_LITERAL     = 'nil';
BOOLEAN_LITERAL = 'true' | 'false';
NUMBER_LITERAL  = ? See section 2.1.6 ?;
STRING_LITERAL  = ? See section 2.1.7 ?;
IMPORT_LITERAL  = '_G' {'.' IDENTIFIER}; (* Imports are literals because we have no concept of indexing, so `_G.etc` would be a strange edgecase otherwise *)
IDENTIFIER      = ('_' | alpha) {'_' | alphanumeric};

(* Keyword Tokens *)
FUNCTION_KEYWORD = 'function';
MACRO_KEYWORD    = 'macro';
LET_KEYWORD      = 'let';
CONST_KEYWORD    = 'const';
STRING_KEYWORD   = 'string';
END_KEYWORD      = 'end';
EXTERN_KEYWORD   = 'extern';
FOR_KEYWORD      = 'for';
DO_KEYWORD       = 'do';
IF_KEYWORD       = 'if';
THEN_KEYWORD     = 'then';
ELSE_KEYWORD     = 'else';
ELSEIF_KEYWORD   = 'elseif';
AND_KEYWORD      = 'and';
OR_KEYWORD       = 'or';
NOT_KEYWORD      = 'not';

(* Punctuation Tokens *)
OPEN_PAREN     = '(';
CLOSE_PAREN    = ')';
CLOSE_SBRACKET = ']';
OPEN_CBRACKET  = '{';
CLOSE_CBRACKET = '}';
EXCLAIM        = '!';
SEMICOLON      = ';';
COLON          = ':';
COMMA          = ',';
PLUS           = '+';
ASTERISK       = '*';
CARET          = '^';
PERCENT        = '%';
HASH           = '#';
VBAR           = '|';

OPEN_SBRACKET  = '[';
HYPHEN         = '-';

DOT            = '.';
DOUBLE_DOT     = '..';
TRIPLE_DOT     = '...';

AT             = '@';
AT_EXCLAIM     = '@!';

EQUALS         = '=';
DOUBLE_EQUALS  = '==';

TILDE          = '~';
TILDE_EQUALS   = '~=';

SLASH          = '/';
DOUBLE_SLASH   = '//';

LT             = '<';
LT_EQUALS      = '<=';
DOUBLE_LT      = '<<';

GT             = '>';
GT_EQUALS      = '>=';
DOUBLE_GT      = '>>';


(* Trivia Tokens, ignored during parsing *)
COMMENT    = ? See section 2.1.8 ?;
WHITESPACE = ? Any whitespace ?;
EOF        = ? Appended to the token stream to mark its conclusion ?;

(* Error Tokens *)
UNEXPECTED = ? Error token emitted when encounting a series of characters that don't belong to any valid token. Allows for lossless lexing even in error states. ?;


(* 
    Misc Defintions 
*)

alphanumeric = alpha | numeric;
alpha = ? any alphabetical character, capitalised or not ?;
numeric = ? any digit (0-9) ?;
```

## 4.2. Precedence

## 4.3. Associativity
