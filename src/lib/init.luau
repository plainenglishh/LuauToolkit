local t = require("./typedefs");

local luau_toolkit = {};

luau_toolkit.bytecode = require("./bytecode");
--luau_toolkit.lasm = require("./lasm"); - temporarily shelved, needs proper design

--BEGIN_REEXPORTS
export type luau_toolkit = t.luau_toolkit;
export type Span = t.Span;
export type u8 = t.u8;
export type u16 = t.u16;
export type u32 = t.u32;
export type i8 = t.i8;
export type i16 = t.i16;
export type i32 = t.i32;
export type f32 = t.f32;
export type f64 = t.f64;
export type varint = t.varint;
export type OperandName = t.OperandName;
export type OperandMode = t.OperandMode;
export type OperandType = t.OperandType;
export type OperandInfo = t.OperandInfo;
export type OpcodeInfo = t.OpcodeInfo;
export type OpcodeName = t.OpcodeName;
export type ConstantType = t.ConstantType;
export type ProtoFlag = t.ProtoFlag;
export type BytecodeBuilderImpl = t.BytecodeBuilderImpl;
export type BytecodeBuilder = t.BytecodeBuilder;
export type IR_Chunk = t.IR_Chunk;
export type IR_Proto = t.IR_Proto;
export type IR_Instruction = t.IR_Instruction;
export type IR_Constant = t.IR_Constant;
export type IR_ProtoDebugInfo = t.IR_ProtoDebugInfo;
export type IR_ProtoTypeInfo = t.IR_ProtoTypeInfo;
export type LASM_TokenType = t.LASM_TokenType;
export type LASM_Token = t.LASM_Token;
export type LASM_TokeniseError = t.LASM_TokeniseError;
export type LASM_TokeniseResult = t.LASM_TokeniseResult;
export type LASM_ParseError = t.LASM_ParseError;
export type LASM_ParseResult = t.LASM_ParseResult;
export type LASM_AstIdentifier = t.LASM_AstIdentifier;
export type LASM_AstLiteral = t.LASM_AstLiteral;
export type LASM_AstValue = t.LASM_AstValue;
export type LASM_AstAttribute = t.LASM_AstAttribute;
export type LASM_AstConstDef = t.LASM_AstConstDef;
export type LASM_AstAliasDef = t.LASM_AstAliasDef;
export type LASM_AstInstruction = t.LASM_AstInstruction;
export type LASM_AstProtoDef = t.LASM_AstProtoDef;
export type LASM_AstStringDef = t.LASM_AstStringDef;
export type LASM_AstChunk = t.LASM_AstChunk;
luau_toolkit.LASM_AstIdentifier = t.LASM_AstIdentifier;
luau_toolkit.LASM_AstLiteral = t.LASM_AstLiteral;
luau_toolkit.LASM_AstValue = t.LASM_AstValue;
luau_toolkit.LASM_AstAttribute = t.LASM_AstAttribute;
luau_toolkit.LASM_AstConstDef = t.LASM_AstConstDef;
luau_toolkit.LASM_AstAliasDef = t.LASM_AstAliasDef;
luau_toolkit.LASM_AstInstruction = t.LASM_AstInstruction;
luau_toolkit.LASM_AstProtoDef = t.LASM_AstProtoDef;
luau_toolkit.LASM_AstStringDef = t.LASM_AstStringDef;
luau_toolkit.LASM_AstChunk = t.LASM_AstChunk;
--END_REEXPORTS

return luau_toolkit :: t.luau_toolkit;
