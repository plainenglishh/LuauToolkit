local t = require("../typedefs");

local lasm: t.API_Lasm = {
    parse = require("./parser");
    tokenise = require("./tokeniser");
};


return lasm;