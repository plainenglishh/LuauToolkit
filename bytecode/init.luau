local misc = require("@self/misc");
local t = require("@self/types");

--[=[
    Library for working with Luau bytecode.
]=]
local bytecode = {};

bytecode.chunk = require("@self/chunk");
bytecode.instructions = require("@self/instructions");
bytecode.constants = require("@self/constants");
bytecode.import_id = require("@self/import_id");
bytecode.get_opcode_info = misc.get_opcode_info;

--[=[
    Builder class for generating bytecode chunks.
]=]
bytecode.BytecodeAssembler = require("@self/BytecodeAssembler");

--[=[
    Array of information about Luau opcodes.
]=]
bytecode.opcodes = require("@self/opcodes");
 
--BEGIN_REEXPORTS
export type OperandName = t.OperandName;
export type OperandMode = t.OperandMode;
export type OperandType = t.OperandType;
export type OperandInfo = t.OperandInfo;
export type OpcodeInfo = t.OpcodeInfo;
export type OpcodeName = t.OpcodeName;
export type ConstantType = t.ConstantType;
export type ProtoFlag = t.ProtoFlag;
export type BytecodeAssemblerImpl = t.BytecodeAssembler;
export type BytecodeAssembler = t.BytecodeAssembler;
export type BytecodeChunk = t.BytecodeChunk;
export type BytecodeProto = t.BytecodeProto;
export type BytecodeInstruction = t.BytecodeInstruction;
export type BytecodeConstant = t.BytecodeConstant;
export type BytecodeProtoDebugInfo = t.BytecodeProtoDebugInfo;
export type BytecodeProtoTypeInfo = t.BytecodeProtoTypeInfo;
--END_REEXPORTS

return bytecode;
