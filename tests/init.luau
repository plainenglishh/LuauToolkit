--[=[
    Test Suite
]=]

local fs = require("@lune/fs");
local process = require("@lune/process");
local stdio = require("@lune/stdio");

local HELP_TEXT = [[
Usage: lune run tests [options]

Options:
    --werror        Treat warnings as errors
    --help, -h      Display this text
]];

local GREEN = stdio.color("green");
local YELLOW = stdio.color("yellow");
local RED = stdio.color("red");
local BLUE = stdio.color("blue");
local DIM = stdio.style("dim");
local RESET = stdio.style("reset");

local TESTS_PATH = `./tests/{process.args[1] or ""}`;
local TESTS_ENDS_WITH = ".spec.luau";

if not fs.isDir(TESTS_PATH) then
    stdio.ewrite(`can't fine test directory '{TESTS_PATH}', are you sure you're running this from the project root?`);
    process.exit(1);
end

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

local function indent(str: string, indent: string): string
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
    return (path
        :gsub("%./tests/", "")
        :gsub("/", "::")
        :gsub("%.spec%.luau", ""));
end

local function trim(str: string)
    return str:gsub("^%s*", ""):gsub("%s*$", "")
end

--- Lune doubles it for some reason.
local function fix_trace(str: string)
    -- TODO
    return str;
end

local function get_tests(): {string}
    local files = read_dir_recursive(TESTS_PATH);
    local tests = filter(files, ends_with, TESTS_ENDS_WITH) :: {string};
    return tests;
end

local function main()
    local tests = get_tests();
    print(`running {BLUE}{#tests}{RESET} tests:`);

    local warns_enabled = true;
    if table.find(process.args, "--werror") then
        warns_enabled = false;
    end

    if table.find(process.args, "--help") or table.find(process.args, "-h") then
        stdio.write(HELP_TEXT);
        return;
    end


    local ok = true;
    for i, path in tests do
        if not ends_with(path, TESTS_ENDS_WITH) then
            continue;
        end
            
        stdio.write(`  - {pretty_path(path)} {RESET}...{RESET} `);

        local start = os.clock() * 1000;
        local test_res = process.exec("lune", {"run", path});
        local stop = os.clock() * 1000;
        local time_taken = math.round(stop - start);

        if test_res.code == 0 then
            stdio.write(`{GREEN}pass{RESET}`);
        elseif warns_enabled and test_res.code == 2 then
            stdio.write(`{YELLOW}warn{RESET}`);
        else
            ok = false;
            stdio.write(`{RED}fail{RESET}`);
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
end

main();

-- Don't return to prevent it from being mistakenly required instead of `api.luau`
