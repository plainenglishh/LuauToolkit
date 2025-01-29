--!nolint LocalShadow

_G.BYTEPARSE_SUPPRESS_WARNINGS = true;

local stdio = require("@lune/stdio");
local luau = require("@lune/luau");
local luauc_toolkit = require("../src/lib");

local tests = {};

type TestFn = (name: string, fn: () -> ()) -> ();
type TestGroupFn = (name: string, fn: (test: TestFn, test_group: TestGroupFn) -> ()) -> ();

local function test(name: string, fn: () -> ())
    table.insert(tests, {
        name = `{name}`,
        fn = fn,
    });
end

--------------------------------------------------------------------------------

test("library::ir::{encode,decode}", function()
    local bc = luau.compile([[
        local HELLO_WORLD = "Hello, World!";

        local function print_hello_world(rep: number)
            print(string.rep(HELLO_WORLD, rep));
        end

        print_hello_world();
    ]], {
        optimizationLevel = 2,
        debugLevel = 2,
    });

    local ir_chunk = luauc_toolkit.ir.decode(bc);
    luauc_toolkit.ir.decode(luauc_toolkit.ir.encode(ir_chunk)); -- Assume the fact it didn't panic means it worked for now.
end);

--------------------------------------------------------------------------------

local function run_tests()
    local tests_passing = true;

    local longest = 0;
    for _, test in tests do
        if #test.name > longest then
            longest = #test.name;
        end
    end

    for _, test in tests do
        stdio.write(string.format(`%-{longest}s .. `, test.name));
        local ok, err = pcall(test.fn :: any);
        if ok then
            stdio.write(`{stdio.color("green")}pass{stdio.color("reset")}\n`);
        else
            tests_passing = false;
            stdio.write(`{stdio.color("red")}fail{stdio.color("reset")}\n`);
            print(tostring(err):split("\n")[1]);
        end
    end
    
    print("");
    
    if tests_passing then
        print("tests passed");
    else 
        error("tests failed");
    end
end

run_tests();