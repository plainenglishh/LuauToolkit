local byteparse = require("@vendor/byteparse");

local t = {};

--[=[
    Internal table representation of a bytecode chunk.
]=]
export type IRChunk = {
    luau_version: byteparse.u8,
    types_version: byteparse.u8,
    strings: {string},
    userdata_types: {number}?,
    protos: {IRProto},
    main_proto: byteparse.varint,
};

--[=[
    Internal table representation of a bytecode proto.
]=]
export type IRProto = {
    max_stack_size: byteparse.u8,
    num_params: byteparse.u8,
    num_upvalues: byteparse.u8,
    is_varag: boolean,
    flags: byteparse.u8,
    types: IRProtoTypeInfo?,
    instructions: {IRInstruction},
    constants: {IRConstant},
    protos: {byteparse.varint},
    line_defined: byteparse.varint,
    debug_name: byteparse.varint,
    line_info: buffer?,
    debug_info: IRProtoDebugInfo?,
};

--[=[
    Internal table representation of a bytecode instruction.
]=]
export type IRInstruction = {
    opcode: byteparse.u8,
    operands: {[string]: number},
};

--[=[
    Internal table representation of a bytecode constant.
]=]
export type IRConstant = {
    type: "nil" | "boolean" | "number" | "string" | "import" | "table" | "closure" | "vector",
    value: any,
};

--[=[
    Internal table representation of a bytecode proto's debug information.
]=]
export type IRProtoDebugInfo = {
    locals: {{
        name: byteparse.varint,
        start_pc: byteparse.varint,
        end_pc: byteparse.varint,
        reg: byteparse.u8,
    }},
    upvalues: {{
        name: byteparse.varint,
    }},
};

--[=[
    Internal table representation of a bytecode proto's type information.
]=]
export type IRProtoTypeInfo = {
    func: string,
    upvalues: {number},
    locals: {{
        type: byteparse.u8,
        reg: byteparse.u8,
        start_pc: byteparse.varint,
        length: byteparse.varint,
    }},
};

export type Span = {start: number, stop: number};

export type AstIdentifier = {
    kind: "identifier",
    span: Span,
    value: string,
};

function t.AstIdentifier(span: Span, value: string): AstIdentifier
    return {
        kind = "identifier",
        span = span,
        value = value,
    };
end

export type AstLiteral = {
    kind: "literal",
    span: Span,
    value: any,
    type: string,
};

function t.AstLiteral(span: Span, value: any, _type: string?): AstLiteral
    return {
        kind = "literal",
        span = span,
        value = value,
        type = _type or type(value),
    };
end

export type AstValue = {
    kind: "value",
    span: Span,
    value: AstIdentifier | AstLiteral,
};

function t.AstValue(span: Span, value: AstIdentifier|AstLiteral): AstValue
    return {
        kind = "value",
        span = span,
        value = value,
    };
end

export type AstAttribute = {
    kind: "attribute",
    span: Span,
    name: string,
    value: AstLiteral?,
};

function t.AstAttribute(span: Span, name: string, value: AstLiteral?): AstAttribute
    return {
        kind = "attribute",
        span = span,
        name = name,
        value = value,
    };
end

export type AstConstDef = {
    kind: "const_def",
    span: Span,
    name: string,
    value: AstValue,
};

function t.AstConstDef(span: Span, name: string, value: AstValue): AstConstDef
    return {
        kind = "const_def",
        span = span,
        name = name,
        value = value,
    };
end

export type AstAliasDef = {
    kind: "alias_def",
    span: Span,
    name: string,
    value: AstValue,
};

function t.AstAliasDef(span: Span, name: string, value: AstValue): AstAliasDef
    return {
        kind = "alias_def",
        span = span,
        name = name,
        value = value,
    };
end

export type AstInstruction = {
    kind: "instruction",
    span: Span,
    opcode: string,
    operands: {AstValue},
    label: string?,
};

function t.AstInstruction(span: Span, opcode: string, operands: {AstValue}, label: string?): AstInstruction
    return {
        kind = "instruction",
        span = span,
        opcode = opcode,
        operands = operands,
        label = label,
    };
end

export type AstProtoDef = {
    kind: "proto_def",
    span: Span,
    name: string,
    metadata: {AstLiteral},
    attributes: {AstAttribute},
    body: {AstInstruction|AstAliasDef|AstConstDef}
};

function t.AstProtoDef(span: Span, name: string, attributes: {AstAttribute}, metadata: {AstLiteral}, body: {AstInstruction|AstAliasDef|AstConstDef}): AstProtoDef
    return {
        kind = "proto_def",
        span = span,
        name = name,
        metadata = metadata,
        attributes = attributes,
        body = body,
    };
end

export type AstStringDef = {
    kind: "string_def",
    span: Span,
    name: string,
    value: string,
};

function t.AstStringDef(span: Span, name: string, value: string): AstStringDef
    return {
        kind = "string_def",
        span = span,
        name = name,
        value = value,
    };
end

export type AstChunk = {
    kind: "chunk",
    span: Span,
    body: {AstAttribute|AstStringDef|AstProtoDef|AstAliasDef},
};

function t.AstChunk(span: Span, body: {AstAttribute|AstStringDef|AstProtoDef|AstAliasDef}): AstChunk
    return {
        kind = "chunk",
        span = span,
        body = body,
    };
end

return t;