local t = require("@self/types");

local chunk = require("@self/chunk");
local instructions = require("@self/instructions");
local constants = require("@self/constants");
local import_id = require("@self/import_id");
local ops = require("@self/ops");
local BytecodeBuilder = require("@self/BytecodeBuilder");

--[=[
    Library for working with Luau bytecode.

    @class bytecode
]=]
local bytecode = {};

bytecode.encode = chunk.encode;
bytecode.decode = chunk.decode;
bytecode.validate = chunk.validate;
bytecode.instructions = instructions;
bytecode.constants = constants;
bytecode.import_id = import_id;
bytecode.ops = ops;
bytecode.BytecodeBuilder = BytecodeBuilder;

export type BytecodeBuilder = BytecodeBuilder.BytecodeBuilder;
--BEGIN_REEXPORTS
export type OperandName = t.OperandName;
export type OperandType = t.OperandType;
export type OperandMetadata = t.OperandMetadata;
export type OperandEncodingMode = t.OperandEncodingMode;
export type InstructionMetadata = t.InstructionMetadata;
export type InstructionName = t.InstructionName;
export type ConstantType = t.ConstantType;
export type ProtoFlag = t.ProtoFlag;
export type ProtoRef = t.ProtoRef;
export type StringRef = t.StringRef;
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
