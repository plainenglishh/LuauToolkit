export type TokenType = 
    -- Punctuation --
    | "OPEN_PAREN"      | "CLOSE_PAREN"     | "OPEN_SBRACKET"   
    | "CLOSE_SBRACKET"  | "AT"              | "EXCLAIM"         
    | "EQ"              | "SEMICOLON"       | "DOT"
    | "COLON"           | "COMMA"
    -- Misc --
    | "IDENTIFIER"
    -- Keywords --
    | "END_KEYWORD"     | "STRING_KEYWORD"  | "CONST_KEYWORD"   
    | "ALIAS_KEYWORD"   | "PROTO_KEYWORD"   | "ENV_KEYWORD"
    -- Literals --
    | "NIL_LITERAL"     | "BOOLEAN_LITERAL" | "STRING_LITERAL"
    | "NUMBER_LITERAL"  | "VECTOR_LITERAL"  | "IMPORT_LITERAL" ;

local KEYWORDS: {[string]: TokenType} = {
    ["end"] = "END_KEYWORD",
    ["string"] = "STRING_KEYWORD",
    ["const"] = "CONST_KEYWORD",
    ["alias"] = "ALIAS_KEYWORD",
    ["proto"] = "PROTO_KEYWORD",
    ["env"] = "ENV_KEYWORD",
};

export type Token = {
    type: TokenType,
    lexeme: string,
    literal: any?,
    span: {start: number, stop: number},
};

export type TokeniseError = {
    message: string,
    span: {start: number, stop: number},
};

export type TokeniseResult = {
    ok: boolean,
    tokens: {Token},
    errors: {TokeniseError},
};

return function(src: string|buffer): TokeniseResult
    local src = if type(src) == "string" then buffer.fromstring(src) else src;
    local lexeme_start = 0;
    local cursor = 0;
    local tokens: {Token} = {};
    local errors: {TokeniseError} = {};

    local function emit_token(type: TokenType, literal: any?)
        table.insert(tokens, {
            type = type,
            lexeme = buffer.readstring(src, lexeme_start, cursor - lexeme_start),
            literal = literal,
            span = {
                start = lexeme_start,
                stop = cursor,
            },
        });
    end

    local function report_error(message: string)
        table.insert(errors, {
            message = message,
            span = {
                start = lexeme_start,
                stop = cursor,
            },
        });
    end

    --[=[
        Returns whether the cursor is at the end of the buffer.
    ]=]
    local function at_eof(location: number?): boolean
        local location = location or cursor;
        return location == buffer.len(src);
    end

    --[=[
        Advances by one character and returns it.
    ]=] 
    local function advance(): string
        local char = string.char(buffer.readu8(src, cursor));
        cursor += 1;
        return char;
    end

    --[=[
        Reads the next character without advancing.
    ]=]
    local function lookahead(): string
        if at_eof() then
            return "\0";
        end
        
        return string.char(buffer.readu8(src, cursor));
    end

    --[=[
        Advances and returns true if the next character matches the
        provided character.
    ]=]
    local function match(char: string): boolean
        if lookahead() == char then
            advance();
            return true;
        end

        return false;
    end
    
    --[=[
        Returns whether the passed character is a numeric digit.
    ]=]
    local function is_numeric(char: string): boolean
        local byte = string.byte(char);
        return byte >= 48 and byte <= 57;
    end

    --[=[
        Returns whether the passed character is a letter.
    ]=]
    local function is_alpha(char: string): boolean
        local byte = string.byte(string.lower(char));
        return (byte >= 97 and byte <= 122) or byte == 95;
    end

    --[=[
        Returns whether the passed character is alphabetical or '_'.
    ]=]
    local function is_alphanumeric(char: string): boolean
        return is_alpha(char) or is_numeric(char);
    end

    --[=[
        Returns whether a passed character is a hexadecimal digit.
    ]=]
    local function is_hex(char: string)
        local char = string.lower(char);
        local byte = string.byte(char);

        return is_numeric(char) or byte >= 97 and byte <= 102;
    end

    --[=[
        Returns whether the passed character is whitespace.
    ]=]
    local function is_whitespace(char: string): boolean
        local byte = string.byte(string.lower(char));
        return byte == 0x20 or byte == 0x09 or byte == 0x0D or byte == 0x0A;
    end

    --[=[
        Matches whitespace, discarding it.
    ]=]
    local function match_whitespace()
        while not at_eof() do
            if is_whitespace(lookahead()) then
                advance();
            else
                break;
            end
        end
    end

    --[=[
        Matches a string literal, returning it.
    ]=]
    local function match_string_literal(): string?
        if not match("\"") then
            return;
        end

        local stop;
        local escaped = false;
        local chars = {};

        while not at_eof() do
            if not escaped and match("\"") then
                stop = cursor;
                break;
            end

            if escaped then
                escaped = false;
                
                if match("x") or match("X") then
                    local hex_buf = {};

                    for i = 1, 2 do
                        if is_hex(lookahead()) then
                            table.insert(hex_buf, advance());
                        else
                            report_error(`expected hex digit`);
                        end
                    end

                    local byte = tonumber(table.concat(hex_buf, ""), 16) :: number;
                    table.insert(chars, string.char(byte));
                elseif match("z") then
                    match_whitespace();
                elseif lookahead() == "\"" then 
                    table.insert(chars, advance());
                end

                continue;
            end 

            if lookahead() == "\\" then
                escaped = true;
                advance();
                continue;
            end
            
            table.insert(chars, advance());
        end

        if not stop then
            report_error("expected '\"', got <EOF>");
            return;
        end

        return table.concat(chars, "");
    end

    local function match_digit(): string?
        if is_numeric(lookahead()) then
            return advance();
        end
        return;
    end

    --[=[
        Matches a number literal, returning it.
    ]=]
    local function match_number_literal(): number?
        local first_digit = match_digit();
        if not first_digit then
            return;
        end

        local mode_specifier: string?;
        if first_digit == "0" and is_alpha(lookahead()) then -- Mode prefixed
            first_digit = nil;
            mode_specifier = string.lower(advance());
        end

        local digits = {first_digit};
        local encountered_dot = false;

        while not at_eof() do
            local next_char = lookahead();
            if is_numeric(next_char) or (mode_specifier == "x" and is_hex(next_char)) then
                table.insert(digits, advance());
            elseif next_char == "_" then
                advance();
            elseif next_char == "." and not encountered_dot and not mode_specifier then
                encountered_dot = true;
                table.insert(digits, advance());
            else
                break;
            end
        end

        local str_literal = table.concat(digits, "");
        local radix = 10;
        if mode_specifier then
            if mode_specifier == "b" then
                radix = 2;
            elseif mode_specifier == "x" then
                radix = 16;
            else
                report_error(`unknown mode specifier '{mode_specifier}'`);
                radix = 10;
            end
        end

        local literal = tonumber(str_literal, radix);
        if not literal then
            report_error(`malformed number {str_literal}`);
        end

        return literal;
    end

    --[=[
        Matches a vector literal.
    ]=]
    local function match_vector_literal(): {number}?
        if not match("<") then
            return;
        end

        local components = {};
        local expecting_comma = false;
        local ended = false;

        while not at_eof() do
            match_whitespace();

            if match(">") then
                ended = true;
                break;
            end

            if expecting_comma then
                if match(",") then
                    expecting_comma = false;
                else
                    report_error(`expected COMMA`);
                    advance();
                end
                continue;
            end

            local num_literal = match_number_literal();
            if num_literal then
                table.insert(components, num_literal);
                expecting_comma = true;
            else
                report_error(`expected NUMBER_LITERAL`);
                continue;
            end
        end

        if not ended then
            report_error(`expected '>' to terminate VECTOR_LITERAL`);
            return;
        end

        return components;
    end

    --[=[
        Matches an identifier
    ]=]
    local function match_identifier(): string?
        local first_char;
        if is_alpha(lookahead()) then
            first_char = advance();
        else
            return;
        end

        local chars = {first_char};
        while not at_eof() do
            if is_alphanumeric(lookahead()) then
                table.insert(chars, advance());
            else
                break;
            end
        end

        return table.concat(chars, "");
    end

    --[=[
        Matches an import literal, presuming the `env` prefix has already been
        matched and consumed.
    ]=]
    local function match_import_literal(): {string}?
        if not match(".") then
            return;
        end

        local path = {};

        while not at_eof() do
            local path_component = match_identifier();
            if not path_component then
                report_error(`expected IDENTIFIER`);
                return;
            end

            table.insert(path, path_component);
            if not match(".") then
                break;
            end
        end

        return path;
    end

    match_whitespace();
    while true do
        match_whitespace();
        if at_eof() then
            break;
        end

        lexeme_start = cursor;
        if match("-") and lookahead() == "-" then -- COMMENT
            while not at_eof() do
                if lookahead() == "\n" then
                    break;
                else
                    advance();
                end
            end
        elseif match("(") then -- OPEN_PAREN
            emit_token("OPEN_PAREN");
        elseif match(")") then -- CLOSE_PAREN
            emit_token("CLOSE_PAREN");
        elseif match("[") then -- OPEN_SBRACKET
            emit_token("OPEN_SBRACKET");
        elseif match("]") then -- CLOSE_SBRACKET
            emit_token("CLOSE_SBRACKET");
        elseif match("@") then -- AT
            emit_token("AT");
        elseif match("!") then -- EXCLAIM
            emit_token("EXCLAIM");
        elseif match("=") then -- EQ
            emit_token("EQ");
        elseif match(";") then -- SEMICOLON
            emit_token("SEMICOLON");
        elseif match(":") then -- COLON
            emit_token("COLON");
        elseif match(".") then -- DOT
            emit_token("DOT");
        elseif match(",") then -- COMMA
            emit_token("COMMA");
        elseif lookahead() == "\"" then -- STRING_LITERAL
            local string_literal = match_string_literal();
            if string_literal then
                emit_token("STRING_LITERAL", string_literal);
            else
                report_error(`expected STRING_LITERAL`);
            end
        elseif is_numeric(lookahead()) then -- NUMBER_LITERAL
            local number_literal = match_number_literal();
            if number_literal then
                emit_token("NUMBER_LITERAL", number_literal);
            else
                report_error(`expected NUMBER_LITERAL`);
            end
        elseif lookahead() == "<" then  -- VECTOR_LITERAL    
            local vector_literal = match_vector_literal();
            if vector_literal then
                emit_token("VECTOR_LITERAL", vector_literal);
            else
                report_error(`expected VECTOR_LITERAL`);
            end
        else -- IDENTIFIER dependent
            local ident = match_identifier();
            if not ident then
                report_error(`unexpected character '{advance()}'`);
                continue;
            end

            if ident == "true" then
                emit_token("BOOLEAN_LITERAL", true);
                continue;
            elseif ident == "false" then
                emit_token("BOOLEAN_LITERAL", false);
                continue;
            elseif ident == "nil" then
                emit_token("NIL_LITERAL");
                continue;
            end

            local keyword_tok: TokenType = KEYWORDS[ident];
            if keyword_tok then
                if keyword_tok == "ENV_KEYWORD" then
                    local import_literal = match_import_literal();
                    if import_literal then
                        emit_token("IMPORT_LITERAL", import_literal);
                    else
                        emit_token("ENV_KEYWORD");
                    end
                else
                    emit_token(keyword_tok);
                end
                continue;
            end

            emit_token("IDENTIFIER", ident);
        end
    end

    return {
        ok = #errors == 0,
        tokens = tokens,
        errors = errors,
    };
end
