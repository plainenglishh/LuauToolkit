local t = {};

--------------------------------------------------------------------------------
--  API
--------------------------------------------------------------------------------

export type luau_toolkit = {
    bytecode: {
        constants: {
            min_version: number,
            max_version: number,
            constant_types: {[number]: string},
            proto_flag: {[ProtoFlag]: number},
        },
        
        encode: (ir_chunk: IR_Chunk) -> buffer,
        decode: (bc: buffer|string) -> IR_Chunk,
        BytecodeBuilder: BytecodeBuilderImpl,
        get_opcode_info: (opcode: number|OpcodeName) -> OpcodeInfo?,
        encode_import_id: (path: {number}) -> number,
        decode_import_id: (id: number) -> {number},
        opcodes: {[number]: OpcodeInfo},
    },
    
    lasm: {
        tokenise: (src: string|buffer) -> LASM_TokeniseResult,
        parse: (tokens: {LASM_Token}) -> LASM_ParseResult,
    },
};


--------------------------------------------------------------------------------
--  Misc Types
--------------------------------------------------------------------------------

export type Span = {start: number, stop: number};

export type u8 = number;
export type u16 = number;
export type u32 = number;
export type i8 = number;
export type i16 = number;
export type i32 = number;
export type f32 = number;
export type f64 = number;
export type varint = number;


--------------------------------------------------------------------------------
--  Bytecode Types
--------------------------------------------------------------------------------

    export type OperandName = "a" | "b" | "c" | "d" | "e" | "aux";
    export type OperandMode = "abc" | "ad" | "e" | "none";
    export type OperandType = "register" | "jump_offset" | "constant" | "proto" | "number"; 

    export type OperandInfo = {
        name: string,
        type: {OperandType},
        description: string,
    };

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
        build_ir: (self: BytecodeBuilder) -> IR_Chunk,
        build_bc: (self: BytecodeBuilder) -> buffer,
    };

    export type BytecodeBuilder = typeof(setmetatable({} :: {
        _offset: number,
        _chunk: IR_Chunk,
        _proto: IR_Proto?,
        _proto_id: number?,
    }, {} :: BytecodeBuilderImpl));


    ----------------------------------------------------------------------------
    --  Bytecode IR Types
    ----------------------------------------------------------------------------

    --[=[
        Internal table representation of a bytecode chunk.
    ]=]
    export type IR_Chunk = {
        luau_version: u8,
        types_version: u8,
        strings: {string},
        userdata_types: {number}?,
        protos: {IR_Proto},
        main_proto: varint,
    };

    --[=[
        Internal table representation of a bytecode proto.
    ]=]
    export type IR_Proto = {
        max_stack_size: u8,
        num_params: u8,
        num_upvalues: u8,
        is_vararg: boolean,
        flags: {ProtoFlag},
        types: IR_ProtoTypeInfo?,
        instructions: {IR_Instruction},
        constants: {IR_Constant},
        protos: {varint},
        line_defined: varint,
        debug_name: varint,
        line_info: buffer?,
        debug_info: IR_ProtoDebugInfo?,
    };

    --[=[
        Internal table representation of a bytecode instruction.
    ]=]
    export type IR_Instruction = {
        opcode: u8,
        operands: {[string]: number},
    };

    --[=[
        Internal table representation of a bytecode constan
    ]=]
    export type IR_Constant = {
        type: ConstantType,
        value: any,
    };

    --[=[
        Internal table representation of a bytecode proto's debug information.
    ]=]
    export type IR_ProtoDebugInfo = {
        locals: {{
            name: varint,
            start_pc: varint,
            end_pc: varint,
            reg: u8,
        }},
        upvalues: {{
            name: varint,
        }},
    };

    --[=[
        Internal table representation of a bytecode proto's type information.
    ]=]
    export type IR_ProtoTypeInfo = {
        func: string,
        upvalues: {number},
        locals: {{
            type: u8,
            reg: u8,
            start_pc: varint,
            length: varint,
        }},
    };


--------------------------------------------------------------------------------
--  LASM Types
--------------------------------------------------------------------------------

    ----------------------------------------------------------------------------
    --  Tokeniser
    ----------------------------------------------------------------------------

    export type LASM_TokenType = 
        -- Punctuation --
        | "OPEN_PAREN"      | "CLOSE_PAREN"     | "OPEN_SBRACKET"   
        | "CLOSE_SBRACKET"  | "AT"              | "EXCLAIM"         
        | "EQ"              | "SEMICOLON"       | "DOT"
        | "COLON"           | "COMMA"
        -- Misc --
        | "IDENTIFIER"      | "EOF"
        -- Keywords --
        | "END_KEYWORD"     | "STRING_KEYWORD"  | "CONST_KEYWORD"   
        | "ALIAS_KEYWORD"   | "PROTO_KEYWORD"   | "ENV_KEYWORD"
        -- Literals --
        | "NIL_LITERAL"     | "BOOLEAN_LITERAL" | "STRING_LITERAL"
        | "NUMBER_LITERAL"  | "VECTOR_LITERAL"  | "IMPORT_LITERAL" ;

    export type LASM_Token = {
        type: LASM_TokenType,
        lexeme: string,
        literal: any?,
        span: {start: number, stop: number},
    };

    export type LASM_TokeniseError = {
        message: string,
        span: {start: number, stop: number},
    };

    export type LASM_TokeniseResult = {
        ok: boolean,
        tokens: {LASM_Token},
        errors: {LASM_TokeniseError},
    };


    ----------------------------------------------------------------------------
    --  Parser Types
    ----------------------------------------------------------------------------

    export type LASM_ParseError = {
        message: string,
        span: Span?,
    };

    export type LASM_ParseResult = {
        root: LASM_AstChunk,
        ok: boolean,
        errors: {LASM_ParseError},
    };

    export type LASM_AstIdentifier = {
        kind: "identifier",
        span: Span,
        value: string,
    };

    function t.LASM_AstIdentifier(span: Span, value: string): LASM_AstIdentifier
        return {
            kind = "identifier",
            span = span,
            value = value,
        };
    end

    export type LASM_AstLiteral = {
        kind: "literal",
        span: Span,
        value: any,
        type: string,
    };

    function t.LASM_AstLiteral(span: Span, value: any, _type: string?): LASM_AstLiteral
        return {
            kind = "literal",
            span = span,
            value = value,
            type = _type or type(value),
        };
    end

    export type LASM_AstValue = {
        kind: "value",
        span: Span,
        value: LASM_AstIdentifier | LASM_AstLiteral,
    };

    function t.LASM_AstValue(span: Span, value: LASM_AstIdentifier|LASM_AstLiteral): LASM_AstValue
        return {
            kind = "value",
            span = span,
            value = value,
        };
    end

    export type LASM_AstAttribute = {
        kind: "attribute",
        span: Span,
        name: string,
        value: LASM_AstLiteral?,
    };

    function t.LASM_AstAttribute(span: Span, name: string, value: LASM_AstLiteral?): LASM_AstAttribute
        return {
            kind = "attribute",
            span = span,
            name = name,
            value = value,
        };
    end

    export type LASM_AstConstDef = {
        kind: "const_def",
        span: Span,
        name: string,
        value: LASM_AstValue,
    };

    function t.LASM_AstConstDef(span: Span, name: string, value: LASM_AstValue): LASM_AstConstDef
        return {
            kind = "const_def",
            span = span,
            name = name,
            value = value,
        };
    end

    export type LASM_AstAliasDef = {
        kind: "alias_def",
        span: Span,
        name: string,
        value: LASM_AstValue,
    };

    function t.LASM_AstAliasDef(span: Span, name: string, value: LASM_AstValue): LASM_AstAliasDef
        return {
            kind = "alias_def",
            span = span,
            name = name,
            value = value,
        };
    end

    export type LASM_AstInstruction = {
        kind: "instruction",
        span: Span,
        opcode: string,
        operands: {LASM_AstValue},
        label: string?,
    };

    function t.LASM_AstInstruction(span: Span, opcode: string, operands: {LASM_AstValue}, label: string?): LASM_AstInstruction
        return {
            kind = "instruction",
            span = span,
            opcode = opcode,
            operands = operands,
            label = label,
        };
    end

    export type LASM_AstProtoDef = {
        kind: "proto_def",
        span: Span,
        name: string,
        metadata: {LASM_AstLiteral},
        attributes: {LASM_AstAttribute},
        body: {LASM_AstInstruction|LASM_AstAliasDef|LASM_AstConstDef}
    };

    function t.LASM_AstProtoDef(span: Span, name: string, attributes: {LASM_AstAttribute}, metadata: {LASM_AstLiteral}, body: {LASM_AstInstruction|LASM_AstAliasDef|LASM_AstConstDef}): LASM_AstProtoDef
        return {
            kind = "proto_def",
            span = span,
            name = name,
            metadata = metadata,
            attributes = attributes,
            body = body,
        };
    end

    export type LASM_AstStringDef = {
        kind: "string_def",
        span: Span,
        name: string,
        value: string,
    };

    function t.LASM_AstStringDef(span: Span, name: string, value: string): LASM_AstStringDef
        return {
            kind = "string_def",
            span = span,
            name = name,
            value = value,
        };
    end

    export type LASM_AstChunk = {
        kind: "chunk",
        span: Span,
        body: {LASM_AstAttribute|LASM_AstStringDef|LASM_AstProtoDef|LASM_AstAliasDef},
    };

    function t.LASM_AstChunk(span: Span, body: {LASM_AstAttribute|LASM_AstStringDef|LASM_AstProtoDef|LASM_AstAliasDef}): LASM_AstChunk
        return {
            kind = "chunk",
            span = span,
            body = body,
        };
    end


--------------------------------------------------------------------------------
--  Export
--------------------------------------------------------------------------------

return t;