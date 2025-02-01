local t = require("../typedefs");

local lasm: typeof(({} :: t.luau_toolkit).lasm) = {
    parse = require("./parser");
    tokenise = require("./tokeniser");
};


return lasm;