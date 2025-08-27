local fs = require("@lune/fs");
local process = require("@lune/process")

local DARKLUA_CONFIG = [[
{
    "bundle": {
        "require_mode": "luau",
        "modules_identifier": "_MODULES"
    },
    "rules": []
}
]];

if not fs.isDir("./dist") then
    fs.writeDir("./dist");
end

local function build_lib()
    if not fs.isDir("./dist/lib") then
        fs.writeDir("./dist/lib");
    end

    fs.writeFile("./dist/lib/darklua.json", DARKLUA_CONFIG);

    for _, module in fs.readDir("./lib") do
        if fs.isFile("./lib/"..module) or module == "common" then
            continue;
        end

        process.exec("darklua", {"process", "lib/"..module.."/init.luau", "dist/lib/"..module..".luau", "-c", "./dist/lib/darklua.json"}, {stdio="forward"});
    end

    fs.removeFile("./dist/lib/darklua.json");
end

local function build_bin()
    if not fs.isDir("./dist/bin") then
        fs.writeDir("./dist/bin");
    end

    fs.writeFile("./dist/bin/darklua.json", DARKLUA_CONFIG);

    for _, module in fs.readDir("./bin") do
        if fs.isFile("./bin/"..module) then
            continue;
        end

        process.exec("darklua", {"process", "bin/"..module.."/init.luau", "dist/bin/"..module..".luau", "-c", "./dist/bin/darklua.json"}, {stdio="forward"});
        process.exec("lune", {"build", "dist/bin/"..module..".luau", "-o", "dist/bin/"..module}, {stdio="forward"});
    end

    fs.removeFile("./dist/bin/darklua.json");
end

build_lib();
build_bin();
