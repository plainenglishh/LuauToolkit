local luau_toolkit = {};

luau_toolkit.ir = require("./ir");
luau_toolkit.lasm = require("./lasm");
luau_toolkit.bytecode_builder = require("./bytecode_builder");
luau_toolkit.constants = require("./constants");
luau_toolkit.opcodes = require("./opcodes");

return luau_toolkit;