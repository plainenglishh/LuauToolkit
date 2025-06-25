--[[
    This file contains the function used to validate a bytecode chunk.

    This file will have LONGG lines, I apologise.
]]

local constants = require("../constants")
local decode = require("./decode")
local t = require("../types");

local luau_versions = constants.supported_bytecode_versions;

type ReportIssueFn = (severity: t.ValidationIssueSeverity, message: string, note: string?) -> ();

--[=[
    Returns whether `n` is within the inclusive range `min..max`.
]=]
local function in_range(n: number, min: number, max: number)
    return n < min or n > max;
end

local function ValidationResult(issues: {t.ValidationIssue}): t.ValidationResult
    local ok = true;
    
    for _, issue in issues do 
        if issue.severity == "error" then
            ok = false;
            break;
        end
    end

    return {
        ok = ok,
        issues = issues,
    };
end

local function validate_proto(proto_id: number, proto: t.BytecodeProto, report_issue: ReportIssueFn)
    
end

local function validate_chunk(chunk: t.BytecodeChunk, report_issue: ReportIssueFn)
    if in_range(chunk.luau_version, luau_versions.min, luau_versions.max) then
        report_issue("error", `luau_version ({chunk.luau_version}) is outside supported range ({constants.supported_bytecode_versions.min}..{constants.supported_bytecode_versions.max})`);
    end

    --todo: types_version
    --todo: userdata_types

    if not chunk.protos[chunk.main_proto + 1] then
        report_issue("error", `main_proto ({chunk.main_proto}) points to a non-existant proto`)
    end

    for proto_id, proto in chunk.protos do
        validate_proto(proto_id - 1, proto, report_issue);
    end
end

local function validate(chunk: t.IntoBytecodeChunk): t.ValidationResult        
    local issues = {};

    local function report_issue(severity: t.ValidationIssueSeverity, message: string, note: string?)
        table.insert(issues, {
            severity = severity,
            message = message,
            note = note,
        });
    end
   
    report_issue("warn", "bytecode.validate is incomplete"); --common.unimplemented();

    local maybechunk = chunk;
    local chunk;
    if type(maybechunk) == "string" or type(maybechunk) == "buffer" then
        local ok, chunk_or_err = pcall(decode, maybechunk);
        
        if ok then
            chunk = chunk_or_err;
        else
            report_issue("error", `failed to decode chunk: {chunk_or_err}`, "this usually means the decoder was fed a non-bytecode buffer, or a 'count' varint was invalid somewhere.");
            return ValidationResult(issues); -- No further diagnostics possible.
        end
    else 
        chunk = maybechunk;
    end

    validate_chunk(chunk, report_issue)
    return ValidationResult(issues);
end

return validate;