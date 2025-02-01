--[[
    Outward facing facade of the bytecode module.
]]

local t = require("../typedefs");
local ir = require("./ir");
local other = require("./other");

local bytecode: t.API_Bytecode = {
    encode = ir.encode,
    decode = ir.decode,
    get_opcode_info = other.get_opcode_info,
    constants = require("./constants"),
    BytecodeBuilder = require("./BytecodeBuilder"),
    opcodes = require("./opcodes"),
};

return bytecode;
