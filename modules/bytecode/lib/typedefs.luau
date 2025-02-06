export type OperandName = "a" | "b" | "c" | "d" | "e" | "aux";
export type OperandMode = "abc" | "ad" | "e" | "none";

--[=[
    The type of an operand.
]=]
export type OperandType = "register" | "jump_offset" | "constant" | "proto" | "number"; 

--[=[
    Metadata about an instruction operand.
]=]
export type OperandInfo = {
    name: string,
    type: {OperandType},
    description: string,
};

--[=[
    Metadata about a bytecode instruction.
]=]
export type OpcodeInfo = {
    name: string,
    opcode: number,
    mode: OperandMode,
    aux: boolean,
    description: string,
    operands: {OperandInfo},
    size: number,
};

export type OpcodeName =
    | "NOP"                  | "BREAK"                | "LOADNIL"             
    | "LOADB"                | "LOADN"                | "LOADK"               
    | "MOVE"                 | "GETGLOBAL"            | "SETGLOBAL"           
    | "GETUPVAL"             | "SETUPVAL"             | "CLOSEUPVALS"         
    | "GETIMPORT"            | "GETTABLE"             | "SETTABLE"            
    | "GETTABLEKS"           | "SETTABLEKS"           | "GETTABLEN"           
    | "SETTABLEN"            | "NEWCLOSURE"           | "NAMECALL"            
    | "CALL"                 | "RETURN"               | "JUMP"                
    | "JUMPBACK"             | "JUMPIF"               | "JUMPIFNOT"           
    | "JUMPIFEQ"             | "JUMPIFLE"             | "JUMPIFLT"            
    | "JUMPIFNOTEQ"          | "JUMPIFNOTLE"          | "JUMPIFNOTLT"         
    | "ADD"                  | "SUB"                  | "MUL"                 
    | "DIV"                  | "MOD"                  | "POW"                 
    | "ADDK"                 | "SUBK"                 | "MULK"                
    | "DIVK"                 | "MODK"                 | "POWK"                
    | "AND"                  | "OR"                   | "ANDK"                
    | "ORK"                  | "CONCAT"               | "NOT"                 
    | "MINUS"                | "LENGTH"               | "NEWTABLE"            
    | "DUPTABLE"             | "SETLIST"              | "FORNPREP"            
    | "FORNLOOP"             | "FORGLOOP"             | "FORGPREP_INEXT"      
    | "FASTCALL3"            | "FORGPREP_NEXT"        | "NATIVECALL"          
    | "GETVARARGS"           | "DUPCLOSURE"           | "PREPVARARGS"         
    | "LOADKX"               | "JUMPX"                | "FASTCALL"            
    | "COVERAGE"             | "CAPTURE"              | "SUBRK"               
    | "DIVRK"                | "FASTCALL1"            | "FASTCALL2"           
    | "FASTCALL2K"           | "FORGPREP"             | "JUMPXEQKNIL"         
    | "JUMPXEQKB"            | "JUMPXEQKN"            | "JUMPXEQKS"           
    | "IDIV"                 | "IDIVK"                ;

export type ConstantType = 
    | "nil" | "boolean" | "number" | "string" | "import" | "table" | "closure" | "vector";

export type ProtoFlag = 
    | "native_module" | "native_cold" | "native_function";


----------------------------------------------------------------------------
--  Bytecode Builder Types
----------------------------------------------------------------------------

export type BytecodeBuilderImpl = {
    __index: BytecodeBuilderImpl,

    new: () -> BytecodeBuilder,
    set_version: (self: BytecodeBuilder, version: number) -> (),
    set_types_version: (self: BytecodeBuilder, version: number) -> (),
    add_string: (self: BytecodeBuilder, str: string, force: boolean?) -> number,
    add_import: (self: BytecodeBuilder, ...string) -> number,
    start_proto: (self: BytecodeBuilder) -> number,
    get_proto_id: (self: BytecodeBuilder) -> number,
    set_max_stack_size: (self: BytecodeBuilder, value: number) -> (),
    set_num_params: (self: BytecodeBuilder, value: number) -> (),
    set_num_upvalues: (self: BytecodeBuilder, value: number) -> (),
    set_is_vararg: (self: BytecodeBuilder, value: boolean) -> (),
    set_line_defined: (self: BytecodeBuilder, value: number) -> (),
    set_debug_name: (self: BytecodeBuilder, name: string) -> (),
    set_main: (self: BytecodeBuilder, proto: number?) -> (),
    set_flag: (self: BytecodeBuilder, flag: ProtoFlag, value: boolean) -> (),
    add_constant: (self: BytecodeBuilder, type: ConstantType, value: any, force: boolean?) -> number,
    add_instruction: (self: BytecodeBuilder, opname_or_code: OpcodeName|number, ...number) -> number,
    get_offset: (self: BytecodeBuilder) -> number,
    end_proto: (self: BytecodeBuilder) -> number,
    build_ir: (self: BytecodeBuilder) -> BytecodeChunk,
    build_bc: (self: BytecodeBuilder) -> buffer,
};

export type BytecodeBuilder = typeof(setmetatable({} :: {
    _offset: number,
    _chunk: BytecodeChunk,
    _proto: BytecodeProto?,
    _proto_id: number?,
}, {} :: BytecodeBuilderImpl));

--[=[
    Internal table representation of a bytecode chunk.
]=]
export type BytecodeChunk = {
    luau_version: number,
    types_version: number,
    strings: {string},
    userdata_types: {number}?,
    protos: {BytecodeProto},
    main_proto: number,
};

--[=[
    Internal table representation of a bytecode proto.
]=]
export type BytecodeProto = {
    max_stack_size: number,
    num_params: number,
    num_upvalues: number,
    is_vararg: boolean,
    flags: {ProtoFlag},
    types: BytecodeProtoTypeInfo?,
    instructions: {BytecodeInstruction},
    _raw_instructions: buffer?,
    constants: {BytecodeConstant},
    protos: {number},
    line_defined: number,
    debug_name: number,
    line_info: buffer?,
    debug_info: BytecodeProtoDebugInfo?,
};

--[=[
    Internal table representation of a bytecode instruction.
]=]
export type BytecodeInstruction = {
    opcode: number,
    operands: {[string]: number},
};

--[=[
    Internal table representation of a bytecode constan
]=]
export type BytecodeConstant = {
    type: ConstantType,
    value: any,
};

--[=[
    Internal table representation of a bytecode proto's debug information.
]=]
export type BytecodeProtoDebugInfo = {
    locals: {{
        name: number,
        start_pc: number,
        end_pc: number,
        reg: number,
    }},
    upvalues: {{
        name: number,
    }},
};

--[=[
    Internal table representation of a bytecode proto's type information.
]=]
export type BytecodeProtoTypeInfo = {
    func: string,
    upvalues: {number},
    locals: {{
        type: number,
        reg: number,
        start_pc: number,
        length: number,
    }},
};

return {};
