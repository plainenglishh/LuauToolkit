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
bytecode.BytecodeAssembler = require("@self/BytecodeAssembler");
bytecode.opcodes = require("@self/opcodes");
bytecode.util = require("@self/util");
 
--BEGIN_REEXPORTS
export type OperandName = t.OperandName;
export type OperandType = t.OperandType;
export type OperandInfo = t.OperandInfo;
export type OperandMode = t.OperandMode;
export type OpcodeInfo = t.OpcodeInfo;
export type OpcodeName = t.OpcodeName;
export type ConstantType = t.ConstantType;
export type ProtoFlag = t.ProtoFlag;
export type BytecodeAssembler = t.BytecodeAssembler;
export type ProtoId = t.ProtoId;
export type StringId = t.StringId;
export type Chunk = t.Chunk;
export type Proto = t.Proto;
export type Instruction = t.Instruction;
export type Constant = t.Constant;
export type ProtoDebugInfo = t.ProtoDebugInfo;
export type ProtoTypeInfo = t.ProtoTypeInfo;
export type ValidationIssueSeverity = t.ValidationIssueSeverity;
export type ValidationIssue = t.ValidationIssue;
export type ValidationResult = t.ValidationResult;
export type bstring = t.bstring;
export type IntoChunk = t.IntoChunk;
--END_REEXPORTS

return bytecode;
