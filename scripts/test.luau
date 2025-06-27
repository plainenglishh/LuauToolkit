--[=[
    Test Suite
]=]

local fs = require("@lune/fs");
local process = require("@lune/process");
local stdio = require("@lune/stdio")

local GREEN = stdio.color("green");
local RED = stdio.color("red");
local BLUE = stdio.color("blue");
local DIM = stdio.style("dim");
local RESET = stdio.style("reset");

local TESTS_PATH = "./tests/";
local TESTS_ENDS_WITH = ".spec.luau";

local function read_dir_recursive(path: string): {string}
    path = string.gsub(path, "/$", "");
    local files = {};

    local function recurse(path)
        if fs.isFile(path) then
            table.insert(files, path);
            return;
        end

        for _, elem in fs.readDir(path) do
            recurse(`{path}/{elem}`);
        end
    end

    recurse(path);

    return files;
end

local function indent(str: string, indent: string)
    local lines = string.split(str, "\n");
    for i, v in lines do
        lines[i] = indent .. v;
    end
    return table.concat(lines, "\n");
end

local function ends_with(str: string, with: string): boolean
    return string.sub(str, #str - #with + 1) == with;
end

local function directory_of(path: string): (string, string)
    path = string.gsub(path, "\\", "/");
    local parts = string.split(path, "/");
    local removed = table.remove(parts, #parts) or error("");
    return table.concat(parts, "/"), removed;
end

local function filter<T, B...>(array: {T}, filter_fn: (T, B...) -> boolean, ...: B...): {T}
    local new = {};

    for _, v in array do
        if filter_fn(v, ...) then
            table.insert(new, v);
        end
    end

    return new;
end

local function pretty_path(path: string): string
    return path
        :gsub("%./tests/", "")
        :gsub("/", "::")
        :gsub("%.spec%.luau", "");
end

local function trim(str: string)
    return str:gsub("^%s*", ""):gsub("%s*$", "")
end

--- Lune doubles it for some reason.
local function fix_trace(str: string)
    local len = #str;
    return string.sub(str, 0, len // 2);
end

local tests = filter(read_dir_recursive(TESTS_PATH), ends_with, TESTS_ENDS_WITH);
local test_count = #tests;

print(`running {BLUE}{test_count}{RESET} tests:`);

local ok = true;
for i, path in tests do
    if not ends_with(path, TESTS_ENDS_WITH) then
        continue;
    end
        
    stdio.write(`  - {pretty_path(path)} {RESET}...{RESET} `);
    local cwd, name = directory_of(path);

    local start = os.clock() * 1000;
    local test_res = process.exec("lune", {"run", name}, {
        cwd = cwd,
    });
    local stop = os.clock() * 1000;
    local time_taken = math.round(stop - start);

    if not test_res.ok then
        ok = false;
        stdio.write(`{RED}fail{RESET}`);
    else
        stdio.write(`{GREEN}pass{RESET}`);
    end

    stdio.write(` {DIM}({time_taken}ms){RESET}\n`);

    if not test_res.ok then
        stdio.write(DIM);
        print(indent(trim(fix_trace(test_res.stderr)), "    | "));
        stdio.write(RESET);
    end
end

if ok then
    print(`\n test suite {GREEN}passed{RESET}`);
    process.exit(0);
else
    print(`\ntest suite {RED}failed{RESET}`);
    process.exit(1);
end

