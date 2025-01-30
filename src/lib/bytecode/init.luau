--[[
    Outward facing facade of the bytecode module.
]]

local constants = require("./constants");
local ir = require("./ir");
local opcodes = require("./opcodes");
local other = require("./other");
local builders = require("./builders");

local bytecode = {};

bytecode.encode = ir.encode;
bytecode.decode = ir.decode;
bytecode.constants = constants;
bytecode.opcodes = opcodes;
bytecode.builders = builders;
bytecode.get_opcode_info = other.get_opcode_info;

return bytecode;
