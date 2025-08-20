local common = require("@luau_toolkit/common");
local t = require("./types");
local test_cases = require("./test_cases");

local function eq(a: any, b: any): boolean
    if type(a) ~= type(b) then 
        return false;
    end

    if type(a) == "buffer" then
        return buffer.tostring(a) == buffer.tostring(b);
    elseif type(a) == "table" then
        for k, v in a do
            if not eq(v, b[k]) then
                return false
            end
        end
        
        for k, _ in b do
            if a[k] == nil then
                return false
            end
        end
        
        return true;
    else
        return a == b;
    end
end

local testing = {};

function testing.run_test(test: t.TestCase, callback: t.TestCallback): t.TestResult
    local out_env = table.clone(test.env or {});
    local out_globals = table.clone(test.globals or common.stdlib);
    
    local ok, out_registers, out_pc, out_returns = pcall(
        callback, 
        out_env, 
        out_globals, 
        table.clone(test.args or {}),
        test.bc
    );

    if not ok then
        local err = tostring(out_registers);
        return {
            name = test.name,
            description = test.description,
            ok = false,
            issues = {t.Issue("error", "callback_errored", err)},
        };
    end

    local issues = {};
    local ok = true;

    local function report_issue(severity: "warn" | "error", type: string, message: string)
        table.insert(issues, t.Issue(severity, type, message));
        if severity == "error" then
            ok = false;
        end
    end

    if test.expected_env and not eq(test.expected_registers, out_registers) then
        report_issue("error", "mismatched_registers", "register array doesn't match expected registers");
    end

    if test.expected_pc and not eq(test.expected_pc, out_pc) then
        report_issue("error", "mismatched_pc", `pc {out_pc} doesn't match expected pc {test.expected_pc}`);
    end

    if test.expected_env and not eq(test.expected_env, out_env) then
        report_issue("error", "mismatched_env", "env doesn't match expected env");
    end

    if test.expected_globals and not eq(test.expected_globals, out_globals) then
        report_issue("error", "mismatched_globals", "globals doesn't match expected globals");
    end

    if test.expected_returns and not eq(test.expected_returns, out_returns) then
        report_issue("error", "mismatched_returns", "returns doesn't match expected returns");
    end

    return {
        name = test.name,
        description = test.description,
        ok = ok,
        issues = issues,
    };
end

function testing.run_tests(callback: t.TestCallback): t.TestsResult
    local results = {};
    local ok = true;

    for i, test: t.TestCase in test_cases do
        local result = testing.run_test(test, callback);
        if not result.ok then
            ok = false;
        end

        table.insert(results, result);
    end

    return {
        ok = ok,
        results = results,
    };
end

return testing;
