local t = require("./typedefs");

local luau_toolkit: t.luau_toolkit = {
    bytecode = require("./bytecode");
    lasm = require("./lasm");
};

return luau_toolkit;
