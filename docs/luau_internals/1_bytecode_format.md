# Chapter 2.1: Bytecode Format

## 1. Introduction

This chapter attempts to describe the Luau bytecode format up to version 6.

## 2. Definitions

### 2.1. Terms

| Term    | Meaning                                                                              |
| ------- | ------------------------------------------------------------------------------------ |
| proto   | The bytecode representation ('prototype') of a function.                             |
| closure | An instantiated function, regardless of upvalue use.                                 |
| upvalue | A value used by a function that belongs to an outside scope.                         |
| struct  | A data structure encoding a series of field values without any padding.              |
| enum    | A data structure representing a series of possible values represented by an integer. |

### 2.1. Type Notation

| Name      | Description                                                                                                                    |
| --------- | ------------------------------------------------------------------------------------------------------------------------------ |
| `boolean` | A true or false value. Encoded as a `u8` where zero is false and anything else is true.                                        |
| `u_`      | An unsigned integer `_` bits wide. E.g. `u8`, `u32`.                                                                           |
| `i_`      | An signed integer `_` bits wide. E.g. `i8`, `i32`.                                                                             |
| `f_`      | An IEEE 754 floating point `_` bits wide. E.g. `f32`, `f64`.                                                                   |
| `varint`  | A protobuf variable width integer.                                                                                             |
| `string`  | A length prefixed ASCII string. Length is encoded as a `varint`.                                                               |
| `buffer`  | A length prefixed blob of binary data. Length is encoded as a `varint`.                                                        |
| `{_}`     | A length prefixed array of `_`. Length is encoded as a `varint`. E.g. `{string}`.                                              |
| `_?`      | An optional value `_`, prefixed by a `boolean` indicating its present. E.g. `string?`.                                         |
| `_!`      | A value that uses special encoding that can't be represented by the aforementioned notation. See surrounding text for details. |

Any types not defined above will be defined in Section 3.

## 3. Structure

The encapsulating data structure, called the chunk, the contains metadata,
strings, function definitions, constants, instructions and type/debug
information required to execute the compiled program.

### 3.1. `Chunk`

The top level `Chunk` encodes the entire bytecode chunk, and is a struct with
the following fields:

| Field Name       | Type                                  | Meaning                                                                                                                                  |
| ---------------- | ------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------- |
| `luau_version`   | `u8`                                  | The bytecode version of the chunk. Tells the decoder how the rest of the chunk is encoded. A value of `0` indicates a compilation error. |
| `types_version`  | `u8`                                  | The bytecode type version of the chunk. Tells the decoder what type information is encoded.                                              |
| `strings`        | `{string}`                            | The string table. Encodes strings used by the chunk.                                                                                     |
| `userdata_types` | [`UserdataTypes!`](#32-userdatatypes) | **Only present when `types_version == 3`.** Tagged userdata type name table.                                                             |
| `protos`         | [`{Proto}`](#33-proto)                | The proto table. Encodes function definitions.                                                                                           |
| `main_proto`     | [`ProtoId`](#34-protoid)              | Indicates which function is the main function.                                                                                           |

### 3.2. `UserdataTypes`

The `UserdataTypes` encodes tagged userdata type names, and is encoded as a
null-terminated array of type name definitions.

The first value is a `u8` of the userdata tag it defines, incremented by `1`.
The second value is a [`StringRef`](#36-stringref) containing the type name.

### 3.3. `Proto`

A `Proto` encodes a function, and is a struct with the following fields:

| Field Name       | Type                                     | Meaning                                                                                            |
| ---------------- | ---------------------------------------- | -------------------------------------------------------------------------------------------------- |
| `max_stack_size` | `u8`                                     | How many registers, and therefore how large of a stack, the function uses.                         |
| `num_params`     | `u8`                                     | How many parameters the function accepts. Parameters occupy registers `R0` to `R{num_params - 1}`. |
| `num_upvalues`   | `u8`                                     | How many upvalues the function uses.                                                               |
| `is_vararg`      | `boolean`                                | Whether the function accepts varadic arguments.                                                    |
| `flags`          | [`ProtoFlags`](#35-protoflags)           | Bitfield containing function related flags.                                                        |
| `types`          | [`ProtoTypeInfo`](#37-prototypeinfo)     | Type information used to guide native code generation.                                             |
| `instructions`   | `buffer`                                 | The instructions buffer.                                                                           |
| `constants`      | [`{Constant}`](#39-constant)             | Constants used by the function.                                                                    |
| `child_protos`   | [`{ProtoId}`](#34-protoid)               | Child functions.                                                                                   |
| `line_defined`   | `varint`                                 | The line the function was defined on.                                                              |
| `debug_name`     | [`StringRef`](#36-stringref)             | The debug name of the function.                                                                    |
| `line_info`      | [`ProtoLineInfo?`](#312-protolineinfo)   | Instruction line information                                                                       |
| `debug_info`     | [`ProtoDebugInfo?`](#313-protodebuginfo) | Instruction type information.                                                                      |

### 3.4. `ProtoId`

A `ProtoId` is a `varint` that points to a [`Proto`](#33-proto) in the chunk
proto table.

### 3.5. `ProtoFlags`

A `ProtoFlags` is a bitfield containing the following fields:

| Bit Position | Flag              | Meaning                                                                                                                                                                                                |
| ------------ | ----------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `0`          | `native_module`   | When used on the main proto, indicates the chunk was compiled with `--!native`.                                                                                                                        |
| `1`          | `native_cold`     | Indicates the proto isn't profitable to compile using native code generation.                                                                                                                          |
| `2`          | `native_function` | When used on the main proto, indicates at least one function within the module uses the `attribute. (**assumed based on observed behaviour:** When used on non main protos, indicates` was used on it) |

### 3.6. `StringRef`

A `StringRef` is a `varint` that points to a string in the chunk string table.
`StringRef`s are one-indexed to allow `0` to act as a 'null' variant. The actual
index of a string would be `string_ref - 1`.

### 3.7. `ProtoTypeInfo`

A `ProtoTypeInfo` encodes type information for a [`Proto`](#33-proto), and
begins with a header struct with the following fields:

| Field Name        | Type     | Meaning                               |
| ----------------- | -------- | ------------------------------------- |
| `function_length` | `varint` | How long the function type string is. |
| `upvalue_count`   | `varint` | How many upvalue types there are.     |
| `local_count`     | `varint` | How many local types there are.       |

After the header, an array of ASCII characters _`function_length`_ bytes long
contains the functions type.

After the function type, an array _`upvalue_count`_ items long contains the
upvalue types, encoded as a [`BytecodeType`](#38-bytecodetype).

After the upvalue types, an array _`local_count`_ items long contains the local
types, encoded as:

| Field Name | Type                               | Meaning                                             |
| ---------- | ---------------------------------- | --------------------------------------------------- |
| `type`     | [`BytecodeType`](#38-bytecodetype) | The type of the local.                              |
| `register` | `u8`                               | The register the local uses.                        |
| `start_pc` | `varint`                           | The start of the locals existence, in instructions. |
| `length`   | `varint`                           | How many instructions the local exists for.         |

### 3.8. `BytecodeType`

A `BytecodeType` is a byte containing type information.

The first 7 bits of the `BytecodeType` are an enum of possible types. The last
bit indicates whether the type is optional.

The list of types are:

| Type                      | Meaning                                                          |
| ------------------------- | ---------------------------------------------------------------- |
| `0`                       | `nil`                                                            |
| `1`                       | `boolean`                                                        |
| `2`                       | `number`                                                         |
| `3`                       | `string`                                                         |
| `4`                       | `table`                                                          |
| `5`                       | `function`                                                       |
| `6`                       | `thread`                                                         |
| `7`                       | `userdata`                                                       |
| `8`                       | `vector`                                                         |
| `9`                       | `buffer`                                                         |
| `15`                      | `any`                                                            |
| `64`..`96` (`32` entries) | Tagged userdata types (See [`UserdataTypes`](#32-userdatatypes)) |

### 3.9. `Constant`

A `Constant` encodes a constant value.

The first byte of a constant encodes the constant type as an enum of:

| Type | Meaning   |
| ---- | --------- |
| `0`  | `nil`     |
| `1`  | `boolean` |
| `2`  | `number`  |
| `3`  | `vector`  |
| `4`  | `string`  |
| `5`  | `import`  |
| `6`  | `table`   |
| `7`  | `closure` |

The rest of the `Constant` depends on the constant type:

| Type      | Encoding                        |
| --------- | ------------------------------- |
| `nil`     | Nothing                         |
| `boolean` | `boolean`                       |
| `number`  | `f64`                           |
| `vector`  | Four `f32`s                     |
| `string`  | [`StringRef`](#36-stringref)    |
| `import`  | [`ImportId`](#311-importid)     |
| `table`   | [`TableShape`](#310-tableshape) |
| `closure` | [`ProtoId`](#34-protoid)        |

### 3.10. `TableShape`

A `TableShape` encodes the shape of a constant table as a length-prefixed array
of key-value pairs, where each element points to another constant table entry.

### 3.11. `ImportId`

An `ImportId` is a `u32` that encodes an import path (e.g. `string.format` or
`_G.hello.world`), as a series of constant IDs pointing to constant strings.

`ImportId`s are encoded as:

| Bit Position | Type  | Meaning                        |
| ------------ | ----- | ------------------------------ |
| `0`          | `u10` | The first path component.      |
| `10`         | `u10` | The second path component.     |
| `20`         | `u10` | The third path component.      |
| `30`         | `u2`  | The number of path components. |

### 3.12. `ProtoLineInfo`

A `ProtoLineInfo` encodes the line information of a [`Proto`](#33-proto)s
instructions.

This is [implementation defined](../../lib/bytecode/chunk/decode.luau).

### 3.13. `ProtoDebugInfo`

A `ProtoDebugInfo` encodes debugging information for a [`Proto`](#33-proto), and
contains the following fields:

| Field Name | Type        | Meaning                         |
| ---------- | ----------- | ------------------------------- |
| `locals`   | `{Local}`   | Debug information for locals.   |
| `upvalues` | `{Upvalue}` | Debug information for upvalues. |

where `Local` is:

| Field Name | Type        | Meaning                                     |
| ---------- | ----------- | ------------------------------------------- |
| `name`     | `StringRef` | The name of the local.                      |
| `start_pc` | `varint`    | The instruction the local first appears.    |
| `end_pc`   | `varint`    | The instruction the local stops being used. |
| `register` | `u8`        | The register the local uses.                |

and `Upvalue` is:

| Field Name | Type        | Meaning                  |
| ---------- | ----------- | ------------------------ |
| `name`     | `StringRef` | The name of the upvalue. |

## 4. Instructions Structure

An instruction buffer encodes instructions as a series of 32-bit words.

### 4.1. Instruction Word Structure

The first byte of an instruction contains the opcode.

The rest of the instruction contains its operands, which can be encoded in one
of the following modes:

| Mode  | Encoding                      |
| ----- | ----------------------------- |
| `abc` | Three `u8`s.                  |
| `ad`  | One `u8` followed by an `i16` |
| `e`   | One `i24`                     |

Some instructions have additional operands encoded in a follow up 'auxiliary'
instruction.

Other instructions, like `BREAK` and `NOP` have no operands at all. Internally,
LuauToolkit treats operand-less instructions as `abc` for simplicity's sake.

## 4.2. List of Instructions
