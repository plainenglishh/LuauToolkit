local t = require("../typedefs");
local bytecode = require("../bytecode");
local common = require("../common");

export type AnalyseError = {
    message: string,
    span: t.Span?,
    severity: "warn"|"error",
};

export type AnalyseReport = {
    ok: boolean,
    diagnostics: {AnalyseError},
    root: t.LASM_AstChunk?,
};

local SIGILS = {
    register = "R",
    constant = "K",
    proto = "P",
    string = "S",
    label = "L",
    extern = "E",
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
    local sigil: string = string.sub(ident, 1, 1);
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

return function(ast_chunk: t.LASM_AstChunk): AnalyseReport
    local ast_chunk = common.deep_clone(ast_chunk);
    local diagnostics: {AnalyseError} = {};
    
    local function report(severity: "warn"|"error", message: string, span: t.Span?)
        table.insert(diagnostics, {
            severity = severity,
            message = message,
            span = span,
        });
    end

    return {
        ok = #diagnostics == 0,
        diagnostics = diagnostics,
        
    };
end