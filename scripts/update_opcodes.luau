--[=[
    A script for automatically generating a table of metadata about luau
    bytecode using `Common/include/Luau/Bytecode.h`.
]=]

--!nonstrict

local net = require("@lune/net");
local fs = require("@lune/fs");
 
local HEADER = [=[
local t = require("../typedefs");
]=];

local BYTECODE_H_URL = "https://raw.githubusercontent.com/luau-lang/luau/refs/heads/master/Common/include/Luau/Bytecode.h";

--[=[
    Trims whitespace from the beginning of a string.
]=]
local function trim_start(str: string)
    local lines = {};

    for _, line in string.split(str, "\n") do
        line = string.gsub(line, "^(%s+)", "");
        table.insert(lines, line)
    end

    return table.concat(lines, "\n");
end

type Opcode = {
    opcode: number,
    name: string,
    operands: {{
        name: string,
        desc: string,
        type: {string},
    }},
    desc: string,
};

--[=[
    Extracts information about opcodes from `Bytecode.h`.
]=]
local function extract_opcodes(file: string): {Opcode}
    --- Keywords used to determine an operands type from its documentation.
    --- any [^_] negations are used to weed out false positives.
    --- (e.e "constant table index" being misidentified as a number for SETLIST's table index)
    local docs_type_keywords = {
        register = {"register"},
        number = {
            "count", "[^td] value", "predicted slot index", "^value", "upvalue index",
            "index%-1 %(index is 1%.%.256%)", "size", "[^t] table index", "^table index",
            "builtin function id", "number of",
            "capture type"
        },
        jump_offset = {"jump offset"},
        constant = {"constant"},
        proto = {"proto"},
    };
    
    local lines = trim_start(file)
        :match("enum LuauOpcode%s{(.-)LOP__COUNT.-};")
        :gsub("IDIVK compute", "IDIVK: compute") -- Fix typo preventing IDIVK from being correctly identified (TODO: find a way to identify cases like this and panic)
        :split("\n");
        
    --[=[
        Determines an operands type using its documentation.
        This is rather hacky, but I really can't be bothered going through all
        83 opcodes to do this manually.
    ]=]
    local function get_type_from_docs(docs: string): string|{string}
        local types = {};
        for type, keywords in docs_type_keywords do
            for _, keyword in keywords do
                if string.find(docs, keyword) then
                    if not table.find(types, type) then
                        table.insert(types, type);
                    end
                end
            end
        end
    
        if #types == 1 then
            return types[1];
        elseif #types == 0 then
            return error(`unable to determine operand type from "{docs}"`);
        else
            return types;
        end
    end

    local current: Opcode?;

    local opcodes = {};
    local opcode_count = 0;

    for _, line in lines do
        if string.gsub(line, "%s", "") == "" then
            current = nil;
            continue;
        end
    
        if string.sub(line, 1, 2) == "//" then
            local name = string.match(line, "^// (.-): ");
    
            if name then
                if current then
                    local description = string.match(line, "^// .-: (.+)") or error("no description");
                    local types = get_type_from_docs(description);
    
                    if type(types) == "table" then
                        local new_types = "{";
                        for _, v in types do
                            new_types ..= `"{v}",`
                        end
                        new_types ..= "}";
                        types = new_types;
                    else
                        types = `\{"{types}"}`;
                    end
                    
                    table.insert(current.operands, {
                        name = name,
                        desc = description,
                        type = types,
                    });
                else
                    current = {
                        opcode = opcode_count,
                        name = "",
                        operands = {},
                        desc = string.match(line, "^// .-: (.+)"),
                    };
                end
            else
                if current then
                    local text = string.match(line, "^// (.+)") or error("no text?");
                    current.desc ..= "\n" .. text;
                end
            end
        else
            if current then
                local name = string.match(line, "^LOP_(.-),") or error("no name? maybe stray blank line? ".. line);
                current.name = name;
                current.opcode = opcode_count;
                table.insert(opcodes, table.clone(current));
                opcode_count += 1;
            else
                error(``);
            end
        end
    end

    return opcodes;
end

local function generate(bytecode_h: string): string
    local output = {};

    local function write(fmt: string, ...)
        if #{...} == 0 then
            table.insert(output, fmt);
        else
            table.insert(output, string.format(fmt, ...));
        end
    end

    local function write_line(str: string?, indentation: number?)
        if indentation then
            write(string.rep(" ", indentation * 4)..(str or "").."\n");
        else
            write((str or "").."\n");
        end
    end

    --[=[
        Escapes a string so it can be used in a string literal.
    ]=]
    local function escape_for_strlit(str: string): string
        str = string.gsub(str, "\n", "\\n");
        str = string.gsub(str, "\"", "\\\"");
        return str;
    end

    --[=[
        Writes the OpcodeName type from an array of opcodes.
    ]=]
    local function write_opcode_name_type(opcodes: {Opcode})
        write("--[[\nuse for types.luau:\n\nexport type OpcodeName =\n   ");
        for i,  opcode in opcodes do
            write(" | %-22s", '"'..opcode.name..'"');
            if i % 3 == 0 then
                write("\n   ");
            end
        end
        write(" ;\n]]\n\n");
    end

    --[=[
        Writes a table containing opcode information.
    ]=]
    local function write_opcodes(opcodes: {Opcode})
        write("local opcodes: {[number]: t.OpcodeInfo} = {\n");
        for i, opcode in opcodes do
            local has_aux = false;
            local operands = "";
            local mode = "none";
        
            for op_num, v in opcode.operands do
                if v.name == "AUX" then
                    has_aux = true;
                end
                
                if v.name == "A" or v.name == "B" or  v.name == "C" then -- AD uses A, but D always falls after A in documentation so it gets corrected later.
                    mode = "abc";
                elseif v.name == "D" then
                    mode = "ad";
                elseif v.name == "E" then
                    mode = "e";
                end
        
                operands ..= `\n            --- {v.name}: {v.desc}`;
                operands ..= `\n            \{`;
                operands ..= ` name = "{v.name:lower()}",`;
                operands ..= ` type = {v.type},`;
                operands ..= ` description = "{escape_for_strlit(v.desc)}" },`;
                if op_num ~= #opcode.operands then
                    operands ..= "\n";
                end
            end
        
            if #opcode.operands > 0 then
                operands ..= "\n        ";
            end
        
            write_line("--[=[", 1);
            write_line(`{opcode.name}: {opcode.desc:gsub("\n", "\n        ")}`, 2);
            write_line("]=]", 1);
            write_line(`[{opcode.opcode}] = \{`, 1);
            write_line(`name = "{opcode.name}",`, 2);
            write_line(`opcode = {opcode.opcode},`, 2);
            write_line(`mode = "{mode}",`, 2);
            write_line(`aux = {has_aux},`, 2);
            write_line(`description = "{escape_for_strlit(opcode.desc)}",`, 2);
            write_line(`operands = \{{operands}},`, 2);
            write_line(`size = {if has_aux then 2 else 1},`, 2);
            write_line("},", 1);
        
            if i ~= #opcodes then
                write_line();
            end
        end
        write( "};\n\n");
    end

    write("-- This file is autogenerated, see scripts/update_opcodes.luau\n\n");
    write(HEADER.."\n");
    local opcodes = extract_opcodes(bytecode_h);
    write_opcode_name_type(opcodes);
    write_opcodes(opcodes)
    write("\nreturn opcodes;");

    --[[local opcode_grammar = "Paste the following line in lasm.tmLanguage.json:\n\n\\\\b(";
    for i, op in opcodes do
        opcode_grammar ..= `{op.name}|{op.name:lower()}`;
        if i ~= #opcodes then
            opcode_grammar ..= "|";
        end
    end
    opcode_grammar ..= ")\\\\b";
    fs.writeFile("./vsc-lasm/opcodes.txt", opcode_grammar);]]

    return table.concat(output);
end

local bytecode_h_res = net.request(BYTECODE_H_URL);
if not bytecode_h_res.ok then
    error("unable to get bytecode.h");
end

local bytecode_h =  bytecode_h_res.body;

fs.writeFile("./src/lib/bytecode/opcodes.luau", generate(bytecode_h));