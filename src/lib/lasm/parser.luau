local tokeniser = require("./tokeniser");
local t = require("../types");

export type ParseError = {
    message: string,
    span: t.Span?,
};

export type ParseResult = {
    root: t.AstChunk,
    ok: boolean,
    errors: {ParseError},
};

--[=[
    A recursive descent parser for a LASM token stream.
]=]
return function(tokens: {tokeniser.Token}): ParseResult
    local cursor = 1;
    local errors: {ParseError} = {};

    local function at_eof(): boolean
        return (tokens[cursor] and tokens[cursor].type == "EOF") or cursor > #tokens;
    end

    --[=[
        Reports an error.
    ]=]
    local function report_error(message: string, span: t.Span?)
        table.insert(errors, {
            message = message,
            span = span or (tokens[cursor] and tokens[cursor].span),
        });
    end

    --[=[
        Measures a distance in the parser.
    ]=]
    local function measure(): () -> t.Span
        local start = cursor;
        return function(): t.Span
            local stop = cursor;
            local start_tok = tokens[start] or tokens[#tokens];
            local stop_tok = tokens[stop] or tokens[#tokens];

            return { 
                start = start_tok.span.start, 
                stop = stop_tok.span.stop 
            };
        end
    end

    --[=[
        Returns the current token as a span.
    ]=]
    local function here(): t.Span
        return { start = tokens[cursor].span.start, stop = tokens[cursor].span.stop }; 
    end

    --[=[
        Returns the next token and advances the cursor.
    ]=]
    local function advance(): tokeniser.Token
        local tok = tokens[cursor];
        cursor += 1;
        return tok or error("end reached");
    end

    local function backtrack()
        cursor -= 1;
    end

    --[=[
        Returns the next token without advancing the cursor.
    ]=]
    local function lookahead(): tokeniser.Token?
        return tokens[cursor];
    end

    --[=[
        Returns the next token and advances the cursor if it matches.
    ]=]
    local function match(...: tokeniser.TokenType): tokeniser.Token?
        local next_tok = lookahead();
        if not next_tok then
            return;
        end

        for _, tok: tokeniser.TokenType in {...} do
            if next_tok.type == tok then
                advance();
                return next_tok;
            end
        end

        return;
    end

    --[=[
        Returns the next token and reports an error if it doesn't match.
    ]=]
    local function expect(...: tokeniser.TokenType): tokeniser.Token?
        local tok = match(...);
        if tok then
            return tok;
        end

        local tok = lookahead();
        report_error(`expected {table.concat({...}, ", ")}, got {tok and tok.type or "<EOF>"}`)
        return;
    end

    local function match_identifier(): t.AstIdentifier?
        local tok = match("IDENTIFIER");
        if not tok then
            return;
        end

        return t.AstIdentifier(tok.span, tok.lexeme);
    end

    local function match_literal(): t.AstLiteral?
        local tok = match("NIL_LITERAL", "BOOLEAN_LITERAL", "STRING_LITERAL", "NUMBER_LITERAL", "VECTOR_LITERAL", "IMPORT_LITERAL");
        if not tok then
            return;
        end

        local lit_type;

        if tok.type == "VECTOR_LITERAL" then
            lit_type = "vector";
        elseif tok.type == "IMPORT_LITERAL" then
            lit_type = "import";
        end

        return t.AstLiteral(tok.span, tok.literal, lit_type);
    end

    local function match_value(): t.AstValue?
        local inner = match_identifier() or match_literal();
        if not inner then
            return;
        end

        return t.AstValue(inner.span, inner);
    end
    
    local function match_attribute(kind: "proto"|"chunk"): t.AstAttribute?
        local span = measure();
        if not match("AT") then
            return;
        end

        if kind == "chunk" and not match("EXCLAIM") then
            backtrack();
            return;
        end

        local is_complex = match("OPEN_SBRACKET");

        local name = expect("IDENTIFIER");
        if not name then
            return;
        end

        local value;
        if is_complex then
            if not expect("EQ") then
                return;
            end

            value = match_literal();
            if not value then
                report_error("expected value", here());
                return;
            end

            if not expect("CLOSE_SBRACKET") then
                return;
            end
        end

        return t.AstAttribute(span(), name.lexeme, value);
    end
    
    local function match_const_def(): t.AstConstDef?
        local span = measure();
        if not match("CONST_KEYWORD") then
            return;
        end

        local name = expect("IDENTIFIER");
        if not name then
            return;
        end

        if not expect("EQ") then
            return;
        end

        local value = match_value();
        if not value then
            report_error("expected value", here());
            return;
        end

        if not expect("SEMICOLON") then
            return;
        end

        return t.AstConstDef(span(), name.lexeme, value);
    end

    local function match_alias_def(): t.AstAliasDef?
        local span = measure();
        if not match("ALIAS_KEYWORD") then
            return;
        end

        local name = expect("IDENTIFIER");
        if not name then
            return;
        end

        if not expect("EQ") then
            return;
        end

        local value = match_value();
        if not value then
            report_error("expected value", here());
            return;
        end

        if not expect("SEMICOLON") then
            return;
        end

        return t.AstAliasDef(span(), name.lexeme, value);
    end

    local function match_instruction(): t.AstInstruction?
        local span = measure();
        local label = match("IDENTIFIER");
        if not label then
            return;
        end

        local opcode;
        if not match("COLON") then
            opcode = label;
            label = nil;
        else
            local maybe_opcode = expect("IDENTIFIER");
            if not maybe_opcode then
                return;
            end

            opcode = maybe_opcode;
        end

        local operands = {};
        local expecting_comma = false;

        while true do
            if at_eof() then
                report_error(`unexpected EOF`, here());
                return;
            end

            if match("SEMICOLON") then
                break;
            end

            if expecting_comma then
                if not expect("COMMA") then
                    return;
                end
            end

            local operand = match_value();
            if not operand then
                report_error(`expected operand`, here());
                return;
            end

            table.insert(operands, operand);
            expecting_comma = true;
        end

        return t.AstInstruction(span(), opcode.lexeme, operands, if label then label.lexeme else nil);
    end

    local function match_proto_def(): t.AstProtoDef?
        local span = measure();
        local attributes = {};
        while true do
            local attr = match_attribute("proto");
            if attr then
                table.insert(attributes, attr);
            else
                break;
            end  
        end

        if #attributes > 0 then
            if not expect("PROTO_KEYWORD") then
                return;
            end
        else
            if not match("PROTO_KEYWORD") then
                return;
            end
        end

        local name = expect("IDENTIFIER");
        if not name then
            return;
        end

        if not expect("OPEN_PAREN") then
            return;
        end

        local metadata = {};
        local expecting_comma = false;

        while true do
            if at_eof() then
                report_error(`unexpected EOF`, here());
                return;
            end

            if match("CLOSE_PAREN") then
                break;
            end

            if expecting_comma then
                if not expect("COMMA") then
                    return;
                end
            end

            local value = match_literal();
            if not value then
                report_error(`expected literal`, here());
                return;
            end

            table.insert(metadata, value);
            expecting_comma = true;
        end

        local body = {};

        while true do
            if at_eof() then
                report_error(`unexpected EOF`, here());
                return;
            end

            if match("END_KEYWORD") then
                break;
            end

            local err_prior = #errors;
            local stat = match_instruction() or match_alias_def() or match_const_def();
            if not stat then
                if #errors == err_prior then
                    report_error(`unexpected token {advance().type}, missing semicolon?`);
                end
                continue;
            end

            table.insert(body, stat);
        end

        return t.AstProtoDef(span(), name.lexeme, attributes, metadata, body);
    end

    local function match_string_def(): t.AstStringDef?
        local span = measure();
        if not match("STRING_KEYWORD") then
            return;
        end

        local name = expect("IDENTIFIER");
        if not name then
            return;
        end

        if not expect("EQ") then
            return;
        end

        local value = expect("STRING_LITERAL");
        if not value then
            report_error("expected STRING_LITERAL", here());
            return;
        end

        if not expect("SEMICOLON") then
            return;
        end

        return t.AstStringDef(span(), name.lexeme, value.literal :: string);
    end
    
    local function match_chunk(): t.AstChunk?
        local span = measure();
        local body = {};

        while not at_eof() do
            local stat = match_attribute("chunk") or match_string_def() or match_proto_def() or match_alias_def();
            if not stat then
                report_error(`unexpected token {advance().type}`);
                continue;
            end

            table.insert(body, stat);
        end
    
        return t.AstChunk(span(), body);
    end

    return {
        ok = #errors == 0,
        root = match_chunk() or error(""),
        errors = errors,
    };
end
