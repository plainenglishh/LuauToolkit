--[[
    plainenglishh/json.luau v1.0.0
   
    Reasonably fast pure-Luau JSON library.
]]

--[[
    MIT License

    Copyright (c) 2025 plainenglish

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
]]

--!native

local VERSION = "v1.0.0"

type JsonArray = {JsonValue};
type JsonObject = {[string]: JsonValue};
export type JsonValue = nil | boolean | number | string | buffer | JsonArray | JsonObject;
export type JsonType = "null" | "boolean" | "number" | "string" | JsonTableType;
export type JsonTableType = "object" | "array";
export type Encoding = "ascii" | "utf8";

--[=[
    Options for `json.encode`.
]=]
export type JsonEncodeOptions = {
    --[=[
        Whether to pretty print the encoded JSON. When set to a number, 
        specifies the indent size in spaces. Assumes an indent size of `4` when
        set to `true`.
        
        Defaults to `false`.
    ]=]
    pretty: boolean|number?,

    --[=[
        Whether to skip escaping on `buffer` values. 
        
        Caller accepts responsibility to make sure the buffer contents are
        properly escaped if necessary.

        Defaults to `false`.
    ]=] 
    raw_buffers: boolean?,
};

--[=[
    Options for `json.decode`.
]=]
export type JsonDecodeOptions = {
    --[=[
        Whether to preserve objects and arrays using `json.set_json_type`.

        Defaults to `true`.
    ]=]
    preserve_table_types: boolean?,
};

local INITIAL_BUFFER_SIZE = 1024;
local BUFFER_EXPAND_RATE = 1.5;

local TABLE_TYPE_METAFIELD = "__jsontype";

local NULL_MAGIC = 0x6C6C756E; -- "null"
local TRUE_MAGIC = 0x65757274; -- "true"
local FALSE_MAGIC_2, FALSE_MAGIC_1  = 0x65, 0x736C6166; -- "false"
local ASCII_ESCAPE_MAGIC = 0x3030755C; -- "\u00"
local EMPTY_ARRAY_MAGIC = 0x5D5B;
local EMPTY_OBJECT_MAGIC = 0x7D7B;
local UC_ESCAPE_MAGIC = 0x755C; -- "\u"

local NEWLINE = string.byte("\n"); -- \n
local SPACE = string.byte(" "); -- SP
local QUOT = string.byte("\""); -- "
local COMMA = string.byte(","); -- ,
local COLON = string.byte(":"); -- :
local LSQUAREBRACKET = string.byte("["); -- [
local RSQUAREBRACKET = string.byte("]"); -- ]
local LCURLYBRACKET = string.byte("{"); -- {
local RCURLYBRACKET = string.byte("}");
local BACKSLASH = string.byte("\\");

local HEX_NIBBLES = { [0] = 0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x41, 0x42, 0x43, 0x44, 0x45, 0x46 };

local ESCAPE_PATTERN = "[\"\\%c]";
local ESCAPE_REPLACEMENTS = {
    [string.byte("\"")] = string.byte("\""),
    [string.byte("\\")] = string.byte("\\"),
    [string.byte("\b")] = string.byte("b"),
    [string.byte("\t")] = string.byte("t"),
    [string.byte("\n")] = string.byte("n"),
    [string.byte("\f")] = string.byte("f"),
    [string.byte("\r")] = string.byte("r"),
};

--- Escapes control and structural characters within a string.
local function escape(input: string --[[, encoding: Encoding]]): (buffer, number)
    local len = #input;

    if not string.match(input, ESCAPE_PATTERN) then
        return buffer.fromstring(input), len;
    end

    local input = buffer.fromstring(input);
    local b = buffer.create(len * 6); -- worst case

    local cursor = 0;

    for i = 0, len - 1 do
        local char = buffer.readu8(input, i);
        local replacement = ESCAPE_REPLACEMENTS[char];

        if replacement then
            buffer.writeu8(b, cursor, BACKSLASH);
            buffer.writeu8(b, cursor + 1, replacement);
            cursor += 2;
        else
            if char < 0x20 then
                buffer.writeu32(b, cursor, ASCII_ESCAPE_MAGIC);
                buffer.writeu8(b, cursor + 4, HEX_NIBBLES[bit32.band(bit32.rshift(char, 4), 0xF)]);
                buffer.writeu8(b, cursor + 5, HEX_NIBBLES[bit32.band(char, 0xF)]);
                cursor += 6;
            else
                buffer.writeu8(b, cursor, char);
                cursor += 1;
            end
        end
    end
    
    local trimmed = buffer.create(cursor);
    buffer.copy(trimmed, 0, b, 0, cursor);
    return trimmed, cursor;
end

--- Returns a metafield value for `tbl`.
local function get_metafield(tbl: any, field: string): any?
    local mt = getmetatable(tbl);
    if mt then
        return (mt :: any)[field];
    end

    return nil;
end

--- Sets a metafield value for `tbl`, creating a metatable if necessary.
local function set_metafield(tbl: any, field: string, value: any)
    local mt = getmetatable(tbl);
    if not mt then
        mt = {};
        setmetatable(tbl, mt);
    end

    (mt :: any)[field] = value;
end

--- Returns (1) whether `value` encodes to an object, and (2) whether it contains any values.
local function is_object(tbl: any): (boolean, boolean)
    local array = #tbl ~= 0;
    local map = next(tbl) ~= nil;

    if array then
        return false, true; -- Array
    elseif map then
        return true, true;
    else
        return get_metafield(tbl, TABLE_TYPE_METAFIELD) == "object", false;
    end
end

local WHITESPACE = {
    [string.byte(" ")]  = true,
    [string.byte("\t")] = true,
    [string.byte("\r")] = true,
    [string.byte("\n")] = true,
};

local UNESCAPE_REPLACEMENTS = {
    [string.byte("\"")] = string.byte("\""),
    [string.byte("\\")] = string.byte("\\"),
    [string.byte("/")] = string.byte("/"),
    [string.byte("b")] = string.byte("\b"),
    [string.byte("t")] = string.byte("\t"),
    [string.byte("n")] = string.byte("\n"),
    [string.byte("f")] = string.byte("\f"),
    [string.byte("r")] = string.byte("\r"),
};

--- Returns whether the passed ASCII byte is a `0..9` digit.
local function is_digit(char: number): boolean
    return char >= 48 and char <= 57;
end

--- Returns whether the passed codepoint is a high surrogate codepoint.
local function is_high_surrogate(codepoint: number)
    return codepoint >= 0xD800 and codepoint <= 0xDBFF;
end

--- Returns whether the passed codepoint is a low surrogate codepoint.
local function is_low_surrogate(codepoint: number)
    return codepoint >= 0xDC00 and codepoint <= 0xDFFF;
end

--- Combines two UTF-16 surrogate codepoints into a single codepoint.
local function combine_surrogates(high: number, low: number): number
    return 0x10000 + bit32.lshift(high - 0xD800, 10) + (low - 0xDC00)
end

--[=[
    Javascript Object Notation library.
]=]
local json = {};

json.VERSION = VERSION;

local null: nil = newproxy(true);
set_metafield(null, "__type", "null");
set_metafield(null, "__tostring", function() return "null"; end);

--[=[
    Null placeholder value.
]=]
json.null = null;

--[=[
    Sets the default table type for `tbl`.

    This function sets the `__jsontabletype` metafield to indicate to parsers
    what syntax to use for an empty structure (`{}` vs `[]`).

    Possible values:
    - `"object"`
    - `"array"`
    - `nil` (remove tag)
]=]
function json.set_json_type<T>(tbl: T, json_type: JsonTableType?): T
    set_metafield(tbl, TABLE_TYPE_METAFIELD, json_type);
    return tbl;
end

--[=[
    Returns the default table type for `tbl`.
]=]
function json.get_json_type(tbl: JsonArray | JsonObject): JsonTableType
    return get_metafield(tbl, TABLE_TYPE_METAFIELD) or "array";
end

--[=[
    Returns the JSON type a given value will encode to, or `nil` if it can't
    be encoded.
]=]
function json.typeof(value: JsonValue): JsonType?
    if type(value) == "boolean" then
        return "boolean";
    elseif type(value) == "number" then
        return "number";
    elseif type(value) == "string" then
        return "string";
    elseif type(value) == "table" then
        local is_object = is_object(value);
        return if is_object then "object" else "array";
    elseif value == null then
        return "null";
    end

    return nil;
end

--[=[
    Encodes a value as a JSON buffer.
]=]
function json.encode(value: JsonValue, options: JsonEncodeOptions?): buffer
    local options = options or {} :: JsonEncodeOptions;

    local pretty = options.pretty or false;
    local raw_buffers = options.raw_buffers or false;

    if type(pretty) == "boolean" then
        pretty = 4;
    end
    local pretty = pretty :: number;
    
    --local encoding: Encoding = options.encoding or "utf8";

    local b = buffer.create(INITIAL_BUFFER_SIZE);
    buffer.fill(b, 0, SPACE);
    local cursor = 0;
    local depth = 0;

    local function check_size(amount: number)
        local len = buffer.len(b);
        local needed = cursor + amount;
        if needed >= len then
            local new = buffer.create(needed * BUFFER_EXPAND_RATE);
            buffer.fill(new, 0, SPACE);
            buffer.copy(new, 0, b);
            b = new;
        end
    end

    local function write_byte(value: number)
        check_size(1);
        buffer.writeu8(b, cursor, value);
        cursor += 1;
    end

    local function write_newline()
        if not pretty then
            return;
        end

        write_byte(NEWLINE);
    end

    local function write_indent()
        if not pretty or depth == 0 then
            return;
        end

        --- We aren't writing anything here, so we dont need to call `check_size`.
        cursor += depth * pretty;
    end

    local function write_null()
        check_size(4);
        buffer.writeu32(b, cursor, NULL_MAGIC);
        cursor += 4;
    end

    local function write_boolean(value: boolean)
        if value then
            check_size(4);
            buffer.writeu32(b, cursor, TRUE_MAGIC);
            cursor += 4;
        else
            check_size(5);
            buffer.writeu32(b, cursor, FALSE_MAGIC_1);
            buffer.writeu8(b, cursor + 4, FALSE_MAGIC_2);
            cursor += 5;
        end
    end

    local function write_number(value: number)
        local str = tostring(value);
        local len = #str;
        check_size(len);
        buffer.writestring(b, cursor, str);
        cursor += len;
    end

    local function write_string(value: string)
        local value, inner_size = escape(value --[[, encoding]]);
        local outer_size = inner_size + 2;
        check_size(outer_size);
        buffer.writeu8(b, cursor, QUOT);
        buffer.copy(b, cursor + 1, value);
        buffer.writeu8(b, cursor + inner_size + 1, QUOT);
        cursor += outer_size;
    end

    local function write_buffer(value: buffer)
        if not raw_buffers then
            write_string(buffer.tostring(value));
            return;
        end

        local inner_size = buffer.len(value);
        local outer_size = inner_size + 2;
        check_size(outer_size);
        buffer.writeu8(b, cursor, QUOT);
        buffer.copy(b, cursor + 1, value);
        buffer.writeu8(b, cursor + inner_size + 1, QUOT);
        cursor += outer_size;
    end

    local write_value;

    local function write_array(value: JsonArray)
        write_byte(LSQUAREBRACKET);
        depth += 1;
        write_newline();

        local count = #value;
        for i, v: JsonValue in value do
            write_indent();
            write_value(v);
            if i ~= count then
                write_byte(COMMA);    
            end
            write_newline();
        end

        depth -= 1;
        write_indent();
        write_byte(RSQUAREBRACKET);
    end

    local function write_object(value: JsonObject)
        write_byte(LCURLYBRACKET);
        depth += 1;
        write_newline();

        local first = true;

        for k, v: JsonValue in value do
            if first then
                first = false;
            else
                write_byte(COMMA);
                write_newline();
            end

            write_indent();

            write_string(k);

            write_byte(COLON);
            if pretty then
                write_byte(SPACE);
            end

            write_value(v);
        end

        write_newline();

        depth -= 1;
        write_indent();
        write_byte(RCURLYBRACKET);        
    end

    local function write_table(value: any)
        local is_object, has_values = is_object(value);

        if is_object then
            if has_values then
                write_object(value);
            else
                buffer.writeu16(b, cursor, EMPTY_OBJECT_MAGIC);
                cursor += 2;
            end
        else
            if has_values then
                write_array(value);
            else
                buffer.writeu16(b, cursor, EMPTY_ARRAY_MAGIC);
                cursor += 2;
            end
        end
    end

    function write_value(value: JsonValue)
        if type(value) == "boolean" then
            write_boolean(value);
        elseif type(value) == "number" then
            write_number(value);
        elseif type(value) == "string" then
            write_string(value);
        elseif type(value) == "buffer" then
            write_buffer(value);
        elseif type(value) == "table" then
            write_table(value);
        elseif value == null then
            write_null();
        end
    end

    write_value(value);

    local trimmed = buffer.create(cursor);
    buffer.copy(trimmed, 0, b, 0, cursor);
    return trimmed;
end

--[=[
    Encodes an array of values as a [JSON Lines](https://jsonlines.org/) buffer.
]=]
function json.encode_lines(values: {JsonValue}): buffer
    local size = 0;
    local buffers: {buffer} = table.create(#values, nil :: any);

    for i, value in values do
        local encoded = json.encode(value, { pretty = false });
        buffers[i] = encoded;
        size += buffer.len(encoded) + 1;
    end

    local final = buffer.create(size);
    buffer.fill(final, 0, NEWLINE);
    
    local cursor = 0;
    for i, b in buffers do
        buffer.copy(final, cursor, b);
        cursor += buffer.len(b) + 1;
    end

    return final;
end

--[=[
    Decodes a JSON buffer into a value.

    Expects `input` to be `utf8` encoded.
]=]
function json.decode(input: buffer | string, options: JsonDecodeOptions?): JsonValue
    local input = if type(input) == "buffer" then input else buffer.fromstring(input);

    local options = options or {} :: JsonDecodeOptions;
    local preserve_table_types = if options.preserve_table_types == nil then true else options.preserve_table_types;

    local cursor = 0;
    local len = buffer.len(input);

    local function at_eof(): boolean
        return cursor >= len;
    end

    local function err_unexpected_char(char: number): never
        if char == 0 then
            error("unexpected <eof>", 2);
        else
            error(string.format("uexpected character 0x%2X [%s]", char, string.char(char)), 2);
        end
    end

    local function advance()
        cursor += 1;
    end

    local function retreat()
        cursor -= 1;
    end

    local function next_char(): number
        local char = if cursor < len then buffer.readu8(input, cursor) else 0;
        advance();
        return char;
    end

    local function expect(expected: number): number
        local char = next_char();
        if char == expected then
            return char;
        end

        err_unexpected_char(char);
        return 0;
    end

    local function discard_whitespace()
        while cursor < len do
            if WHITESPACE[buffer.readu8(input, cursor)] then
                advance();
            else
                break;
            end
        end
    end

    local string_buffer = buffer.create(buffer.len(input));

    local function read_string(): string
        local write_cursor = 0;

        local string_start = cursor;

        while true do
            local char = next_char();

            if char == QUOT then                
                if string_start == cursor then
                    return "";            
                end
                
                return buffer.readstring(string_buffer, 0, write_cursor);
            elseif char == BACKSLASH then
                local char = next_char();

                if UNESCAPE_REPLACEMENTS[char] then
                    buffer.writeu8(string_buffer, write_cursor, UNESCAPE_REPLACEMENTS[char]);
                    write_cursor += 1;
                elseif char == string.byte("u") then
                    if cursor + 4 > len then
                        error("expected unicode codepoint");
                    end

                    local high_surrogate = tonumber(buffer.readstring(input, cursor, 4), 16) or error("expected unicode codepoint"); cursor += 4;
                    local codepoint;

                    if is_high_surrogate(high_surrogate) then
                        if cursor + 6 > len or buffer.readu16(input, cursor) ~= UC_ESCAPE_MAGIC then
                            error("expected second surrogate");
                        end
                        cursor += 2;

                        local low_surrogate = tonumber(buffer.readstring(input, cursor, 4), 16) or error("expected unicode codepoint"); cursor += 4;
                        if not is_low_surrogate(low_surrogate) then
                            error("expected second surrogate");
                        end
                        codepoint = combine_surrogates(high_surrogate, low_surrogate);
                    else
                        codepoint = high_surrogate;
                    end

                    local encoded = utf8.char(codepoint);
                    local len = #encoded;
                    buffer.writestring(string_buffer, write_cursor, encoded);
                    write_cursor += len;
                else
                    error("invalid escape");
                end
            elseif char < 0x20 then
                error("malformed string");
            else
                buffer.writeu8(string_buffer, write_cursor, char);
                write_cursor += 1;
            end
        end
    end

    local function read_number(): number
        local number_start = cursor - 1;
        local encountered_dot = false;
        local encountered_e: boolean = false;

        while true do
            if at_eof() then
                break;
            end
            
            local char = next_char(1);

            if is_digit(char) then
                continue;
            end
            
            if char == string.byte(".") and not encountered_dot then
                encountered_dot = true;
            elseif (char == string.byte("e") or char == string.byte("E")) and not encountered_e then
                encountered_e = true;
                local char = next_char();
                if char == string.byte("-") or char == string.byte("+") then
                    char = next_char();
                end

                if not is_digit(char) then
                    error("expected exponent");
                end
            else
                retreat();
                break;
            end
        end

        local raw_number = buffer.readstring(input, number_start, cursor - number_start);
        return tonumber(raw_number) or error("malformed number");
    end

    local read_value;

    local function read_array(): JsonArray
        local array: JsonArray = table.create(256, nil :: any); -- Better to allocate a large block here than resize constantly in the hot loop.

        if preserve_table_types then
            set_metafield(array, TABLE_TYPE_METAFIELD, "array");
        end

        while true do
            discard_whitespace();

            local char = next_char();
            if char == RSQUAREBRACKET then
                return array;
            else
                retreat();
            end
            
            local value = read_value();
            table.insert(array, value);

            if next_char() ~= COMMA then
                retreat();
            end
        end
    end

    local function read_object(): JsonObject
        local object: JsonObject = {};

        if preserve_table_types then
            set_metafield(object, TABLE_TYPE_METAFIELD, "object");
        end

        while true do
            discard_whitespace();

            local char = next_char();
            if char == RCURLYBRACKET then
                return object;
            elseif char ~= QUOT then
                err_unexpected_char(char);
            end

            local key = read_string();
            discard_whitespace();
        
            expect(COLON);
            
            local value = read_value();

            object[key] = value;

            if next_char() ~= COMMA then
                retreat();
            end
        end
    end

    function read_value(): JsonValue
        discard_whitespace();

        local char = next_char();
        local value: JsonValue;

        if char == QUOT then
            value = read_string();
        elseif is_digit(char) or char == string.byte("-") then
            value = read_number();
        elseif char == LSQUAREBRACKET then
            value = read_array();
        elseif char == LCURLYBRACKET then
            value = read_object();
        elseif char == string.byte("t") then
            expect(string.byte("r"));
            expect(string.byte("u"));
            expect(string.byte("e"));
            value = true;
        elseif char == string.byte("f") then
            expect(string.byte("a"));
            expect(string.byte("l"));
            expect(string.byte("s"));
            expect(string.byte("e"));
            value = false;
        elseif char == string.byte("n") then
            expect(string.byte("u"));
            expect(string.byte("l"));
            expect(string.byte("l"));
            value = null;
        else
            err_unexpected_char(char);
        end

        discard_whitespace();
        return value;
    end

    local root = read_value();

    if not at_eof() then
        err_unexpected_char(next_char());
    end

    return root;
end

--[=[
    Decodes a [JSON Lines](https://jsonlines.org/) buffer into an array of values.
]=]
function json.decode_lines(input: buffer | string): {JsonValue}
    local input = if type(input) == "string" then input else buffer.tostring(input);
    local lines = string.split(input, "\n");
    if lines[#lines] == "" then
        table.remove(lines, #lines);
    end

    local values = {};
    
    for i, v in lines do
        values[i] = json.decode(v);
    end

    return values;
end

return json;