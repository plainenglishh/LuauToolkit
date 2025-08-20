--!native

local common = require("@luau_toolkit/common");
local t = require("./types");

--- Map of simple punctuation (single character with no ambiguity) to `TokenType`s.
local SIMPLE_PUNCTUATION: {t.TokenType} = {
    [string.byte("(")] = "OPEN_PAREN",
    [string.byte(")")] = "CLOSE_PAREN",
    [string.byte("]")] = "CLOSE_SBRACKET",
    [string.byte("{")] = "OPEN_CBRACKET",
    [string.byte("}")] = "CLOSE_CBRACKET",
    [string.byte("!")] = "EXCLAIM",
    [string.byte(";")] = "SEMICOLON",
    [string.byte(":")] = "COLON",
    [string.byte(",")] = "COMMA",
    [string.byte("+")] = "PLUS",
    [string.byte("*")] = "ASTERISK",
    [string.byte("^")] = "CARET",
    [string.byte("%")] = "PERCENT",
    [string.byte("#")] = "HASH",
    [string.byte("|")] = "VBAR",
    [string.byte("&")] = "AMPERSAND",
};

--- Map of keywords to `TokenType`s.
local KEYWORDS: {[string]: t.TokenType} = {
    ["function"] = "FUNCTION_KEYWORD" :: "FUNCTION_KEYWORD",
    ["let"] = "LET_KEYWORD" :: "LET_KEYWORD",
    ["macro"] = "MACRO_KEYWORD" :: "MACRO_KEYWORD",
    ["const"] = "CONST_KEYWORD" :: "CONST_KEYWORD",
    ["string"] = "STRING_KEYWORD" :: "STRING_KEYWORD",
    ["end"] = "END_KEYWORD" :: "END_KEYWORD",
    ["extern"] = "EXTERN_KEYWORD" :: "EXTERN_KEYWORD",
    ["for"] = "FOR_KEYWORD" :: "FOR_KEYWORD",
    ["do"] = "DO_KEYWORD" :: "DO_KEYWORD",
    ["if"] = "IF_KEYWORD" :: "IF_KEYWORD",
    ["then"] = "THEN_KEYWORD" :: "THEN_KEYWORD",
    ["else"] = "ELSE_KEYWORD" :: "ELSE_KEYWORD",
    ["elseif"] = "ELSEIF_KEYWORD" :: "ELSEIF_KEYWORD",
    ["and"] = "AND_KEYWORD" :: "AND_KEYWORD",
    ["or"]  = "OR_KEYWORD" :: "OR_KEYWORD",
    ["not"] = "NOT_KEYWORD" :: "NOT_KEYWORD",
};

--- Map of Luau whitespace (https://github.com/luau-lang/luau/blob/master/Ast/include/Luau/Lexer.h#L255).
local WHITESPACE = {
    [string.byte(" ")]  = true,
    [string.byte("\t")] = true,
    [string.byte("\r")] = true,
    [string.byte("\n")] = true,
    [string.byte("\v")] = true,
    [string.byte("\f")] = true,
};

local function is_alpha(char: number): boolean
    return (char >= 65 and char <= 90) or (char >= 97 and char <= 122);
end

local function is_numeric(char: number): boolean
    return char >= 48 and char <= 57;
end

local function is_alphanumeric(char: number): boolean
    return is_alpha(char) or is_numeric(char);
end

local function is_hex(char: number): boolean
    return is_numeric(char) or (char >= 65 and char <= 70) or (char >= 97 and char <= 102);
end

local function is_bin(char: number): boolean
    return char == 48 or char == 49;
end

local function parse_long_string(str: string): string
    str = string.gsub(str, "^\r", "");
    str = string.gsub(str, "^\n", "");
    return str;
end

type UnescapeStringResult = {
    ok: true,
    value: string,
} | {
    ok: false,
    error: string,
};

local function UnescapeStringResult(ok: boolean, value: string): UnescapeStringResult
    if ok then
        return { ok = true, value = value };
    else
        return { ok = false, error = value };
    end
end

local SIMPLE_ESCAPE_SEQUENCES = {
    [string.byte("a")] = "\a",
    [string.byte("f")] = "\f",
    [string.byte("n")] = "\n",
    [string.byte("r")] = "\r",
    [string.byte("t")] = "\t",
    [string.byte("v")] = "\v",
    [string.byte("\\")] = "\\",
    [string.byte("\"")] = "\"",
    [string.byte("'")] = "'",
    [string.byte("\n")] = "\n",
};

local function unescape_string(b: buffer): UnescapeStringResult
    local len = buffer.len(b);
    local cursor = 0;
    local characters: {number|string} = {};

    local function advance(by: number)
        cursor += by;
    end

    local function at_eof(position: number?)
        local position = position or cursor;
        return position >= len;
    end

    local function peek_char(n: number): number
        local cursor = cursor + (n - 1);
        return if cursor >= len then 0 else buffer.readu8(b, cursor);
    end

    local function substring(start: number, finish: number?): string
        local finish = finish or cursor;
        local count = math.min(finish - start, len - start);
        return buffer.readstring(b, math.max(start, 0), count);
    end

    while true do
        if at_eof() then
            break;
        end
        
        local char = peek_char(1);

        if char == string.byte("\\") then
            advance(1);
            local char = peek_char(1);

            if at_eof() then
                break;
            end


            if SIMPLE_ESCAPE_SEQUENCES[char] then
                table.insert(characters, SIMPLE_ESCAPE_SEQUENCES[char]);
                advance(1);
            elseif char == string.byte("\r") and peek_char(2) == string.byte("\n") then
                table.insert(characters, "\n");
                advance(2);
            elseif is_numeric(char) then
                local num_start = cursor;
                advance(1);

                for i = 1, 2 do
                    if at_eof() then
                        break;
                    end

                    if is_numeric(peek_char(1)) then
                        advance(1);
                    else
                        break;
                    end
                end

                local char = tonumber(substring(num_start)) or error("HOW DID THIS HAPPEN.");

                if char > 255 then
                    return UnescapeStringResult(false, "malformed escape sequence");
                end

                table.insert(characters, char);
            elseif char == string.byte("x") then
                advance(1);
                if not (is_hex(peek_char(1)) and is_hex(peek_char(2))) then
                    return UnescapeStringResult(false, "malformed escape sequence");
                end
                advance(2);
                table.insert(characters, tonumber(substring(cursor - 2), 16) or error("HOW DID THIS HAPPEN."));
            elseif char == string.byte("u") then
                advance(1);
                if peek_char(1) ~= string.byte("{") then
                    return UnescapeStringResult(false, "malformed escape sequence");
                end
                advance(1);

                local start = cursor;

                while true do
                    if at_eof() then
                        return UnescapeStringResult(false, "malformed escape sequence");
                    end

                    local char = peek_char(1);

                    if is_hex(char) then
                        advance(1);
                    elseif char == string.byte("}") then
                        if cursor == start then
                            return UnescapeStringResult(false, "malformed escape sequence");
                        else
                            local unicode_codepoint = tonumber(substring(start), 16) or error("INCOMPREHENSIBLE FAIL."); 
                            
                            if unicode_codepoint > 1112064 then
                                return UnescapeStringResult(false, "malformed escape sequence");
                            end

                            advance(1);
                            table.insert(characters, utf8.char(unicode_codepoint));
                            break;
                        end
                    else
                        return UnescapeStringResult(false, "malformed escape sequence");
                    end
                end
            elseif (char == string.byte("\r") and peek_char(2) == string.byte("\n")) then -- \n handled by SIMPLE_ESCAPE_SEQUENCES
                advance(2);
                table.insert(characters, "\n");
            elseif char == string.byte("z") then
                advance(1);
                while not at_eof() do
                    if WHITESPACE[peek_char(1)] then
                        advance(1);
                    else
                        break;
                    end
                end
            else
                advance(1);
                table.insert(characters, char);
            end
        else
            table.insert(characters, char);
            advance(1);
        end
    end

    local out = buffer.create(#characters);

    for i, v in characters do
        buffer.writeu8(out, i - 1, if type(v) == "number" then v else string.byte(v));
    end    

    return UnescapeStringResult(true, buffer.tostring(out));
end

local lexer = {};

function lexer.lex(src: string | buffer): t.LexerResult
    --[[
        Lexer notes:
        
        This lexer may use any level of lookahead. I'd like to use as little
        lookahead as possible, but many features like long comments and long
        strings make this difficult. It'd be too much effort for too
        little benefit to support stream-like inputs, so we only accept full
        complete documents.
    ]]

    local src = if type(src) == "buffer" then src else buffer.fromstring(src);
    local src_len = buffer.len(src);

    local ok = true;
    local tokens = {};
    local errors = {};

    local lexeme_start = 0;
    local cursor = 0;

    --- Returns a substring from the source buffer. Trims to buffer size.
    local function substring(start: number, finish: number?): string
        local finish = finish or cursor;
        local count = math.min(finish - start, src_len - start);
        return buffer.readstring(src, math.max(start, 0), math.max(count, 0));
    end
    
    local function substring_buf(start: number, finish: number?): buffer
        local finish = finish or cursor;
        local count = math.min(finish - start, src_len - start);
        local b = buffer.create(count);
        buffer.copy(b, 0, src, math.max(start, 0), math.max(count, 0));
        return b;
    end
    

    --- Returns whether we're at the end of the character stream.
    local function at_eof(position: number?): boolean
        return (position or cursor) >= src_len;
    end

    --- Emits a token into the token stream.
    local function emit_token(token_type: t.TokenType, literal: any?)
        local lexeme = if token_type == "EOF" then "" else substring(lexeme_start, cursor);
        table.insert(tokens, t._Token(token_type, lexeme, vector.create(lexeme_start, cursor), literal));
    end

    --- Emits an error token with a given message.
    local function emit_error(error_type: t.LexerErrorType, message: string)
        ok = false;
        table.insert(errors, t._LexerError(error_type, message, vector.create(lexeme_start, cursor)));
    end

    --[=[
        Returns the character `n` characters from the cursor, or `0` if beyond
        the buffer size.
    ]=]
    local function peek_char(n: number): number
        local cursor = cursor + (n - 1);
        return if cursor >= src_len then 0 else buffer.readu8(src, cursor);
    end

    --[=[
        Returns whether the `peek_char(1)`'d `[` is the beginning of a long
        bracket pair.

        Should only be called when the first `[` has been encountered. The
        beginning `[` should not be consumed before calling.
    ]=]
    local function is_long_bracket_open(): number?
        local i = 0;

        while true do
            local char = peek_char(i + 2);
            
            if char == string.byte("[") then
                return i;
            elseif char == string.byte("=") then 
                i += 1;
            else
                return nil;
            end
        end
    end

    --[[
        The following consumer functions consume a token and return
        the literal value if applicable. 
        
        - These functions do not emit the token themselves; responsibility for 
          emitting tokens lies with the caller.
        - These functions can assume the initial characters are valid (no need 
          to re-check the first two characters in a comment are `--`, for 
          example), but must ensure the rest of the token is valid. 
        - In the event of a malformed literal, the consumer function should emit
          an error, and return a `nil` value so the caller can emit an 
          appropriate error token.
    ]]

    --[=[
        Advances the cursor by `n`.
    ]=]
    local function consume(n: number)
        cursor += n;
    end

    --[=[
        Consumes whitespace.
    ]=]
    local function consume_whitespace()
        consume(1);

        while not at_eof() do
            if WHITESPACE[peek_char(1)] then
                consume(1);
            else
                break;
            end
        end
    end

    --[=[
        Consumes the rest of a line, excluding the line break characters.
    ]=]
    local function consume_line()
        while not at_eof() do
            local char = peek_char(1);
            
            if char == string.byte("\n") then
                return;
            elseif char == string.byte("\r") and peek_char(2) == string.byte("\n") then
                return;
            else
                consume(1);
            end
        end
    end

    --[=[
        Consumes a long bracket pair.

        Returns a vector representing the content span, or nil if no closing 
        pair was found.
    ]=]
    local function consume_long_brackets(eq_count: number): vector?
        consume(eq_count + 2); -- Consume opener
        local start = cursor;

        local close = `]{string.rep("=", eq_count)}]`;
        local close_len = #close;

        while true do
            if at_eof() then
                return nil;
            end

            local char = peek_char(1);
            
            if char == string.byte("]") and substring(cursor, cursor + close_len) == close then
                local stop = cursor;
                consume(close_len);
                return vector.create(start, stop);
            else
                consume(1);
            end
        end

        return nil;
    end

    --[=[
        Consumes a single or multi line comment.

        Returns the comments contents, or `nil` if unterminated.
    ]=]
    local function consume_comment(): string?
        consume(2);
        
        local char = peek_char(1);
        local long_bracket_ct = is_long_bracket_open();

        if char == string.byte("[") and long_bracket_ct then
            local content_span = consume_long_brackets(long_bracket_ct);
            
            if not content_span then
                emit_error("UNTERMINATED_COMMENT", "encountered unterminated comment");
                return nil;
            else
                return substring(content_span.x, content_span.y);
            end
        else
            local start = cursor;
            consume_line();
            local finish = cursor;
            return substring(start, finish);
        end
    end

    --[=[
        Consumes and returns an identifier.
    ]=]
    local function consume_identifier(): string
        local start = cursor;
        consume(1);

        while not at_eof() do
            local char = peek_char(1);
            if is_alphanumeric(char) or char == string.byte("_") then
                consume(1);
            else
                break;
            end
        end

        return substring(start);
    end

    --[=[
        Consumes, parses and returns a number literal.
    ]=]
    local function consume_number_literal(): number?
        local function decimal(): number?
            local start = cursor;
            local encountered_dot = false;
            local encountered_e = false;
            local hyphen_allowed = false;

            while not at_eof() do
                local char = peek_char(1);
                
                if is_numeric(char) or char == string.byte("_") then
                    consume(1);
                    hyphen_allowed = false;
                elseif char == string.byte(".") then
                    if encountered_dot then
                        return nil;
                    else
                        encountered_dot = true;
                        consume(1);
                    end
                elseif char == string.byte("e") or char == string.byte("E") then
                    if encountered_e then
                        return nil;
                    else
                        encountered_e = true;
                        encountered_dot = true; -- Dots no longer allowed.
                        hyphen_allowed = true;
                        consume(1);
                    end
                elseif char == string.byte("-") then
                    if hyphen_allowed then
                        consume(1);
                        hyphen_allowed = false;
                    else
                        return nil;
                    end
                else
                    break;
                end
            end

            local raw = substring(start);
            if raw == "" then
                return nil;
            end

            raw = string.gsub(raw, "_", "");

            return tonumber(raw, 10);
        end

        local function hexadecimal(): number?
            consume(2); -- adjust for prefix
            local start = cursor;

            while not at_eof() do
                local char = peek_char(1);
                
                if is_hex(char) or char == string.byte("_") then
                    consume(1);
                else
                    break;
                end
            end

            local raw = substring(start);
            if raw == "" then
                return nil;
            end

            raw = string.gsub(raw, "_", "");

            return tonumber(raw, 16);
        end

        local function binary(): number?
            consume(2); -- adjust for prefix
            
            local start = cursor;

            while not at_eof() do
                local char = peek_char(1);
                
                 if is_bin(char) or char == string.byte("_") then
                    consume(1);
                else
                    break;
                end
            end

            local raw = substring(start);
            if raw == "" then
                return nil;
            end

            raw = string.gsub(raw, "_", "");

            return tonumber(raw, 2);
        end

        local char = peek_char(1);
        local next_char = peek_char(2);

        if char == string.byte("0") and is_alpha(next_char) then
            if next_char == string.byte("x") or next_char == string.byte("X") then
                return hexadecimal();
            elseif next_char == string.byte("b") or next_char == string.byte("B") then
                return binary();
            else
                consume(1);
                return nil;
            end
        else
            return decimal();
        end
    end

    --[=[
        Consumes a single line string and returns its parsed contents.
    ]=]
    local function consume_short_string_literal(): string?
        local open_char = peek_char(1);
        consume(1);

        local content_start = cursor;
        
        while true do 
            if at_eof() then
                emit_error("MALFORMED_LITERAL", "unterminated string literal");
                break;
            end

            local char = peek_char(1);

            if char == open_char then
                consume(1);
                break;
            elseif char == string.byte("\\") then
                if peek_char(2) == string.byte("\n") then
                    consume(2);
                elseif peek_char(2) == string.byte("\r") and peek_char(3) == string.byte("\n") then
                    consume(3);
                elseif peek_char(2) == string.byte("z") then
                    consume(2);
                    if WHITESPACE[peek_char(1)] then
                        consume_whitespace();
                    end
                else
                    consume(2);
                end
            elseif char == string.byte("\n") or (char == string.byte("\r") and peek_char(2) == string.byte("\n")) then
                emit_error("MALFORMED_LITERAL", "unterminated string literal");
                return nil;
            else
                consume(1);
            end
        end
        
        if content_start == cursor then
            return "";            
        end
        
        local raw_str = substring_buf(content_start, cursor - 1);
        local str = unescape_string(raw_str);

        if str.ok then
            return str.value;
        else
            emit_error("MALFORMED_LITERAL", str.error);
            return nil;
        end
    end

    --[=[
        Consumes an import and returns its path members.
    ]=]
    local function consume_import(): {string}?
        local parts = {};
        
        while true do
            if at_eof() then
                break;
            end
        
            local char = peek_char(1);
            if char == string.byte(".") then
                consume(1);
                local next_char = peek_char(1);
                if is_alpha(next_char) or next_char == string.byte("_") then
                    table.insert(parts, consume_identifier());
                else
                    emit_error("MALFORMED_LITERAL", `expected identifier for import literal`);    
                    return nil;
                end
            else
                break;
            end
        end

        return parts;
    end

    local anti_loop = -1;

    while true do
        lexeme_start = cursor;
        
        if at_eof() then
            emit_token("EOF");
            break;
        end
        
        local char = peek_char(1);

        if cursor == anti_loop then
            local msg = common.StringBuilder.new();
            msg:writeln(`Internal Lexer Error: loop detected at position {cursor}`);
            msg:writeln(`|  character: \`{string.char(char)}\` (0x{string.format("%02X", char)})`);
            msg:writeln(`|  context:   '{substring(cursor - 5, cursor + 5)}`);
            msg:writeln(`|  last_token: {tokens[#tokens].type}`);
            error(msg:build());
        else
            anti_loop = cursor;
        end

        -- Whitespace
        if WHITESPACE[char] then
            consume_whitespace();
            emit_token("WHITESPACE");

        -- Punctuation
        elseif SIMPLE_PUNCTUATION[char] then
            consume(1);
            emit_token(SIMPLE_PUNCTUATION[char]);
        elseif char == string.byte("-") then
            if peek_char(2) == string.byte("-") then
                local contents = consume_comment();
                emit_token("COMMENT", contents);
            else
                consume(1);
                emit_token("HYPHEN");
            end
        elseif char == string.byte("@") then
            if peek_char(2) == string.byte("!") then
                consume(2);
                emit_token("AT_EXCLAIM");
            else
                consume(1);
                emit_token("AT");
            end
        elseif char == string.byte("=") then
            if peek_char(2) == string.byte("=") then
                consume(2);
                emit_token("DOUBLE_EQUALS");
            else
                consume(1);
                emit_token("EQUALS");
            end
        elseif char == string.byte("~") then
            if peek_char(2) == string.byte("=") then
                consume(2);
                emit_token("TILDE_EQUALS");
            else
                consume(1);
                emit_token("TILDE");
            end
        elseif char == string.byte("/") then
            if peek_char(2) == string.byte("/") then
                consume(2);
                emit_token("DOUBLE_SLASH");
            else
                consume(1);
                emit_token("SLASH");
            end
        elseif char == string.byte("<") then
            local next_char = peek_char(2);
            if next_char == string.byte("<") then
                consume(2);
                emit_token("DOUBLE_LT");
            elseif next_char == string.byte("=") then
                consume(2);
                emit_token("LT_EQUALS");
            else
                consume(1);
                emit_token("LT");
            end
        elseif char == string.byte(">") then
            local next_char = peek_char(2);
            if next_char == string.byte(">") then
                consume(2);
                emit_token("DOUBLE_GT");
            elseif next_char == string.byte("=") then
                consume(2);
                emit_token("GT_EQUALS");
            else
                consume(1);
                emit_token("GT");
            end

        -- Number Literals 
        elseif is_numeric(char) or (char == string.byte(".") and is_numeric(peek_char(2))) then
            local number = consume_number_literal();
            emit_token("NUMBER_LITERAL", number);

            if not number then
                emit_error("MALFORMED_LITERAL", "malformed number literal");
            end

        -- Dots (after number literal)
        elseif char == string.byte(".") then
            if peek_char(2) == string.byte(".") then
                if peek_char(3) == string.byte(".") then
                    consume(3);
                    emit_token("TRIPLE_DOT");
                else
                    consume(2);
                    emit_token("DOUBLE_DOT");
                end
            else
                consume(1);
                emit_token("DOT");
            end

        -- String Literals
        elseif char == string.byte("\"") or char == string.byte("'") then
            local str = consume_short_string_literal();
            emit_token("STRING_LITERAL", str);
        elseif char == string.byte("[") then
            local long_bracket_depth = is_long_bracket_open();

            if long_bracket_depth then
                local content_span = consume_long_brackets(long_bracket_depth);
                local content;
                if not content_span then
                    emit_error("UNTERMINATED_COMMENT", "encountered unterminated string");
                else
                    content = parse_long_string(substring(content_span.x, content_span.y));
                end
                
                emit_token("STRING_LITERAL", content);
            else
                consume(1);
                emit_token("OPEN_SBRACKET");
            end
            
        -- Identifiers/Keywords/Nil/Bool/Import
        elseif is_alpha(char) or char == string.byte("_") then
            local identifier = consume_identifier();

            if KEYWORDS[identifier] then
                emit_token(KEYWORDS[identifier]);
            elseif identifier == "nil" then
                emit_token("NIL_LITERAL", nil);
            elseif identifier == "true" then
                emit_token("BOOLEAN_LITERAL", true);
            elseif identifier == "false" then
                emit_token("BOOLEAN_LITERAL", false);
            elseif identifier == "_G" then
                local import = consume_import();
                emit_token("IMPORT_LITERAL", import);
            else
                emit_token("IDENTIFIER", identifier);
            end
        else
            consume(1);
            emit_token("UNEXPECTED");
            emit_error("UNEXPECTED_CHARACTER", `unexpected character '{char}'`);
        end
    end

    return {
        ok = ok,
        tokens = tokens,
        errors = errors,
    };
end

--[=[
    Reconstitutes a LASM token stream back into the original source string.
]=]
function lexer.reconstitute_tokens(tokens: {t.Token}|t.LexerResult): string
    local strings = {};

    for _, token in tokens do
        table.insert(strings, token.lexeme);
    end

    return table.concat(strings);
end

--[=[
    Strips a token stream of trivia tokens.
]=]
function lexer.strip_tokens(tokens: {t.Token}): {t.Token}
    local new_tokens = {};

    for _, token in tokens do
        if token.type == "WHITESPACE" or token.type == "COMMENT" then
            continue;
        else
            table.insert(new_tokens, token);
        end
    end

    return new_tokens;
end

return lexer;
