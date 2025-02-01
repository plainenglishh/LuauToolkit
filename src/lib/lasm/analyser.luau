local t = require("../typedefs");
local tokeniser = require("./tokeniser");
local parser = require("./parser");
local bytecode = require("../bytecode");

export type AnalyseError = {
    message: string,
    span: t.Span?,
    severity: "warn"|"error",
};

export type AnalyseReport = {
    ok: false,
    diagnostics: {AnalyseError},
} | {
    ok: true,
    diagnostics: {AnalyseError},
    ir: t.IR_Chunk,
};

local SIGILS = {
    register = "R",
    constant = "K",
    proto = "P",
    string = "S",
    label = "L"
};

local function visit(t: {[any]: any}, ast_type: string|{string}, cb: (v: {[any]: any}) -> ())
    local ast_type = if type(ast_type) == "table" then ast_type else {ast_type};
    if table.find(ast_type, t.type) then
        cb(t);
    end

    for _, v in t do
        if type(v) == "table" then
            visit(v, ast_type, cb);
        end
    end
end

type Identifier = {
    type: "named",
    value: string,
    sigil: string,
} | {
    type: "numbered",
    value: number,
    sigil: string,
}; 

local function parse_identifier(ident: string): Identifier?
    local sigil = string.sub(ident, 1, 1);
    local body = string.sub(ident, 2);

    if string.sub(body, 1, 1) == "_" then
        return {
            type = "named",
            sigil = sigil,
            value = string.sub(body, 2),
        };
    else
        local num = tonumber(body);
        if not num then
            return;
        end

        return {
            type = "numbered",
            sigil = sigil,
            value = num,
        };
    end
end

return function(src: string|buffer): AnalyseReport
    local src = if type(src) == "string" then buffer.fromstring(src) else src;
    local diagnostics: {AnalyseError} = {};
    local errored = false;

    local function report(severity: "warn"|"error", message: string, span: t.Span?)
        if severity == "error" then
            errored = true; 
        end

        table.insert(diagnostics, {
            severity = severity,
            message = message,
            span = span,
        });
    end

    local tokeniser_result = tokeniser(src);
    for _, v in tokeniser_result.errors do
        report("error", v.message, v.span);
    end

    local parse_result = parser(tokeniser_result.tokens);
    for _, v in parse_result.errors do
        report("error", v.message, v.span);
    end

    if errored then
        return {
            ok = false,
            diagnostics = diagnostics,
        };
    end
    
    local root = parse_result.root;
    local bytecode = bytecode.BytecodeBuilder.new();

    local aliases = {
        proto = {},
        chunk = {},
    };

    local function resolve_alias(node: t.LASM_AstValue)
        while true do
            if node.value.kind == "literal" then
                return;
            end

            local alias = aliases.proto[node.value.value] or aliases.chunk[node.value.value];

            if alias then
                node.value = alias;
            else
                return;
            end
        end
    end

    local function resolve_aliases_in(tbl: any)
        visit(tbl, "value", resolve_alias);
    end

    local function define_alias(type: "chunk"|"proto", name: string, value: t.LASM_AstLiteral|t.LASM_AstIdentifier)
        if aliases.chunk[name] or aliases.proto[name] then
            report("error", `alias '{name}' already defined`);
            return;
        end
   
        aliases[type][name] = value;
    end


    local function process_chunk(chunk: t.LASM_AstChunk)
        

        local function process_proto(proto: t.LASM_AstProtoDef)
            local constants = {
                numbered = {},
                named = {},
            };
            
            aliases.proto = {};
    
            for _, stat in proto.body do
                if stat.kind == "alias_def" then
                    define_alias("proto", stat.name, stat.value.value);
                elseif stat.kind == "const_def" then 
                    
                end
    
    
            end
        end

        for _, stat in root.body do
            if stat.kind == "alias_def" then
                define_alias("chunk", stat.name, stat.value.value);
            elseif stat.kind == "proto_def" then
                process_proto(stat);
            elseif stat.kind == "string_def" then
                
            elseif stat.kind == "attribute" then
                
            end
        end
    end

    if errored then
        return {
            ok = false,
            diagnostics = diagnostics,
        };
    else
        return {
            ok = true,
            diagnostics = diagnostics,
            ir = bytecode:build_ir(),
        };
    end
end