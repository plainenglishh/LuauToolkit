local byteparse = require("@vendor/byteparse");

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

return {};