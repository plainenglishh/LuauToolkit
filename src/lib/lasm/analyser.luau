local t = require("../typedefs");
local tokeniser = require("./tokeniser");
local parser = require("./parser");

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

return function(src: string|buffer): AnalyseReport
    local src = if type(src) == "string" then buffer.fromstring(src) else src;
    local diagnostics: {AnalyseError} = {};

    local function report(severity: "warn"|"error", message: string, span: t.Span?)
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

    --// TODO: BYTECODE BUILDER

    if #diagnostics == 0 then
        return {
            ok = false,
            diagnostics = {},
        };
    else
        return {
            ok = false,
            diagnostics = diagnostics,
        };
    end
end