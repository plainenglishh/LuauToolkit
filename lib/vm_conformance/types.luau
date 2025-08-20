local t = {};

export type Env = {[string]: any};

export type Registers = {any};

export type TestCase = {
    --- The name of the test case.
    name: string,

    --- A description of the test case.
    description: string,

    --- The bytecode chunk to be executed.
    bc: buffer,

    --- The initial environment, defaults to an empty array.
    env: Env?,

    --- The initial globals table, defaults to the Luau standard library as defined in `@luau_toolkit/common`.
    globals: Env?,

    --- The args given to the chunk.
    args: {any}?,

    --- What the expected register layout is.
    expected_registers: Registers?,

    --- What the expected pc is.
    expected_pc: number?,

    --- What the expected environment is.
    expected_env: Env?,

    --- What the expected globals table is.
    expected_globals: Env?,

    --- What the expected main returns is as a tuple.
    expected_returns: {any}?,
};
    
export type TestCallbackReturn = {
    registers: Registers,
    pc: number,
    env: Env,
    returns: {any},
};

export type TestCallback = (env: Env, globals: Env, args: {any}, bc: buffer) -> (Registers, number, {any});
export type Issue = {
    severity: "warn" | "error",
    type: string,
    message: string,
};

function t.Issue(severity: "warn" | "error", type: string, message: string): Issue
    return {
        severity = severity,
        type = type,
        message = message,
    };
end

export type TestResult = {
    name: string,
    description: string,
    ok: boolean,
    issues: {Issue},
};

export type TestsResult = {
    ok: boolean,
    results: {TestResult},
};

return t;