local misc = require("./misc");

local bytecode = {};

bytecode.encode = require("./encode");
bytecode.decode = require("./decode");
bytecode.opcodes = require("./opcodes");
bytecode.BytecodeBuilder = require("./BytecodeBuilder");
bytecode.get_opcode_info = misc.get_opcode_info;
bytecode.encode_import_id = misc.encode_import_id;
bytecode.decode_import_id = misc.decode_import_id;

return bytecode;
