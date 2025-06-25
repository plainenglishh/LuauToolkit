--[[
    This file contains the function used to validate a bytecode chunk.
]]

local common = require("../common");
local constants = require("./constants")
local decode = require("./chunk/decode")
local t = require("./types");

local ok_bytecode_versions = constants.supported_bytecode_versions;

local function into_bytecodechuck(chunk: t.IntoBytecodeChunk): t.BytecodeChunk
    if type(chunk) == "table" then
        return chunk;
    elseif type(chunk) == "string" then
        return decode(buffer.fromstring(chunk));
    elseif type(chunk) == "buffer" then
        return decode(chunk);
    end

    error(`unexpected type {chunk} for argument #1`, 2);
end

--[=[
    Returns whether `n` is within the inclusive range `min..max`.
]=]
local function in_range(n: number, min: number, max: number)
    return n < min or n > max;
end

local function validate(chunk: t.IntoBytecodeChunk): t.ValidationResult        
    common.unimplemented();
    
    local chunk = into_bytecodechuck(chunk);

    local issues = {};

    local function report_issue(severity: t.ValidationIssueSeverity, message: string)
        table.insert(issues, {
            severity = severity,
            message = message, 
        });
    end

    if in_range(chunk.luau_version, ok_bytecode_versions.min, ok_bytecode_versions.max) then
        report_issue("error", `luau_version {chunk.luau_version} is outside supported range ({constants.supported_bytecode_versions.min}..{constants.supported_bytecode_versions.max})`);
    end

    local ok = true;
    
    for _, issue in issues do 
        if issue.severity == "error" then
            ok = true;
            break;
        end
    end

    return {
        ok = ok,
        issues = issues,
    };
end

return validate;