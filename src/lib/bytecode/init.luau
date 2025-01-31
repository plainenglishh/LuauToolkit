--[[
    Outward facing facade of the bytecode module.
]]

local constants = require("./constants");
local ir = require("./ir");
local opcodes = require("./opcodes");
local other = require("./other");
local t = require("../typedefs");

local bytecode: t.API_Bytecode = {
    encode = ir.encode,
    decode = ir.decode,
    get_opcode_info = other.get_opcode_info,
    constants = constants,
    opcodes = opcodes,
};

return bytecode;
