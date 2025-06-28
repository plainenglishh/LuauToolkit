# Chapter 1: Bytecode Format

## 1. Introduction

This document describes the Luau bytecode format. It is accurate up to bytecode
version `6`.

## 2. Types

This document refers to the following "types":

| Name      | Description                                                                             |
| --------- | --------------------------------------------------------------------------------------- |
| `boolean` | A true or false value. Encoded as a `u8` where zero is false and anything else is true. |
| `uX`      | An unsigned integer _X_ bits wide. E.g. `u8`, `u32`.                                    |
| `iX`      | An signed integer _X_ bits wide. E.g. `i8`, `i32`.                                      |
| `fX`      | An IEEE 754 floating point _X_ bits wide. E.g. `f32`, `f64`.                            |
| `varint`  | A protobuf variable width integer.                                                      |
| `string`  | A `varint` length prefixed ASCII string.                                                |
| `buffer`  | A `varint` length prefixed blob of binary data.                                         |
| `{T}`     | A `varint` length prefixed array of _T_.                                                |
| `T?`      | An optional value _T_, prefixed by a `boolean` indicating whether it's present.         |

## 3. Terms

This document makes use of the following terms:

| Term    | Meaning                                                                                |
| ------- | -------------------------------------------------------------------------------------- |
| proto   | The bytecode representation of a function. Used interchangeably with 'function'.       |
| upvalue | A variable that belongs to a parent scope.                                             |
| closure | A function that makes use of upvalues.                                                 |
| chunk   | A bytecode module, usually a single file. Used interchangeably with 'module'.          |
| struct  | A data structure containing a series of fields with varying types and with no padding. |
| enum    | A data structure representing a series of possible values, represented by an integer.  |

## 4. Chunk Structure

Bytecode is a data structure, referred to herein as a 'chunk', that contains the
metadata, function definitions, instructions and type/debug information, created
by a Luau compiler to be executed later by a Luau VM.

### 4.1. `Chunk`

The `Chunk` encodes the entire bytecode chunk, and is a struct with the
following fields:

| Field Name       | Type            | Meaning                                                                                                                                  |
| ---------------- | --------------- | ---------------------------------------------------------------------------------------------------------------------------------------- |
| `luau_version`   | `u8`            | The bytecode version of the chunk. Tells the decoder how the rest of the chunk is encoded. A value of `0` indicates a compilation error. |
| `types_version`  | `u8`            | The bytecode type version of the chunk. Tells the decoder what type information is encoded.                                              |
| `strings`        | `{string}`      | The string table. Encodes strings used by the chunk.                                                                                     |
| `userdata_types` | `UserdataTypes` | **Only present when `types_version == 3`.** Tagged userdata type name table.                                                             |
| `protos`         | `{Proto}`       | The proto table. Encodes function definitions.                                                                                           |
| `main_proto`     | `ProtoRef`      | Indicates which function is the main function.                                                                                           |

### 4.2. `UserdataTypes`

The `UserdataTypes` encodes tagged userdata type names, and is encoded as a
null-terminated array of pairs.

The first value is a `u8` key referring to the userdata tag it defines. As the
series of pairs is null terminated, the `u8` is incremented by one, and must be
decremented before use.

The second value is a `StringRef` pointing to the type name.

### 4.3. `Proto` and `ProtoRef`

A `Proto` encodes a function, and is a struct with the following fields:

| Field Name       | Type              | Meaning                                                                                            |
| ---------------- | ----------------- | -------------------------------------------------------------------------------------------------- |
| `max_stack_size` | `u8`              | How many registers, and therefore how large of a stack, the function uses.                         |
| `num_params`     | `u8`              | How many parameters the function accepts. Parameters occupy registers `R0` to `R{num_params - 1}`. |
| `num_upvalues`   | `u8`              | How many upvalues the function uses.                                                               |
| `is_vararg`      | `boolean`         | Whether the function accepts varadic arguments.                                                    |
| `flags`          | `ProtoFlags`      | Bitfield containing function related flags.                                                        |
| `types`          | `ProtoTypeInfo`   | Type information used to guide native code generation.                                             |
| `instructions`   | `buffer`          | The instructions buffer.                                                                           |
| `constants`      | `{Constant}`      | Constants used by the function.                                                                    |
| `child_protos`   | `{ProtoRef}`      | Child functions.                                                                                   |
| `line_defined`   | `varint`          | The line the function was defined on.                                                              |
| `debug_name`     | `StringRef`       | The debug name of the function.                                                                    |
| `line_info`      | `ProtoLineInfo?`  | Instruction line information                                                                       |
| `debug_info`     | `ProtoDebugInfo?` | Instruction type information.                                                                      |

A `ProtoRef` is a zero-indexed `varint` that points to a `Proto` within the
chunk proto table.

### 4.4. `ProtoFlags`

A `ProtoFlags` is a bitfield containing the following fields:

| Bit Position | Flag              | Meaning                                                                                                                                                                                                                  |
| ------------ | ----------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `0`          | `native_module`   | When used on the main proto, indicates the chunk was compiled with `--!native`.                                                                                                                                          |
| `1`          | `native_cold`     | Indicates the proto isn't profitable to compile using native code generation.                                                                                                                                            |
| `2`          | `native_function` | When used on the main proto, indicates at least one function within the module uses the `@native` attribute. (**assumed based on observed behaviour:** When used on non main protos, indicates `@native` was used on it) |

### 4.5. `StringRef`

A `StringRef` is a one-indexed `varint` that points to a `string` within the
chunk string table. `StringRef`s are one-indexed to allow `0` to act as a 'null'
variant; you should therefore decrement the `StringRef` by one when indexing a
zero-indexed array, such as the chunk string table.

### 4.6. `ProtoTypeInfo`

A `ProtoTypeInfo` encodes type information for a `Proto`, and begins with a
header struct with the following fields:

| Field Name        | Type     | Meaning                               |
| ----------------- | -------- | ------------------------------------- |
| `function_length` | `varint` | How long the function type string is. |
| `upvalue_count`   | `varint` | How many upvalue types there are.     |
| `local_count`     | `varint` | How many local types there are.       |

After the header, an array of ASCII characters _`function_length`_ bytes long
contains the functions type.

After the function type, an array _`upvalue_count`_ items long contains the
upvalue types, encoded as a `BytecodeType`.

After the upvalue types, an array _`local_count`_ items long contains the local
types, encoded as:

| Field Name | Type           | Meaning                                             |
| ---------- | -------------- | --------------------------------------------------- |
| `type`     | `BytecodeType` | The type of the local.                              |
| `register` | `u8`           | The register the local uses.                        |
| `start_pc` | `varint`       | The start of the locals existence, in instructions. |
| `length`   | `varint`       | How many instructions the local exists for.         |

### 4.7. `BytecodeType`

A `BytecodeType` is a byte containing type information.

The first 7 bits of the `BytecodeType` are an enum of possible types. The last
bit indicates whether the type is optional.

The list of types are:

| Type                      | Meaning                                     |
| ------------------------- | ------------------------------------------- |
| `0`                       | `nil`                                       |
| `1`                       | `boolean`                                   |
| `2`                       | `number`                                    |
| `3`                       | `string`                                    |
| `4`                       | `table`                                     |
| `5`                       | `function`                                  |
| `6`                       | `thread`                                    |
| `7`                       | `userdata`                                  |
| `8`                       | `vector`                                    |
| `9`                       | `buffer`                                    |
| `15`                      | `any`                                       |
| `64`..`96` (`32` entries) | Tagged userdata types (See `UserdataTypes`) |

### 4.8. `Constant`

A `Constant` encodes a constant value.

The first byte of a constant encodes its type as an enum.

Possible types are:

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

The rest of the `Constant` depends on its type:

| Type      | Encoding    |
| --------- | ----------- |
| `nil`     | Nothing     |
| `boolean` | `boolean`   |
| `number`  | `f64`       |
| `vector`  | Four `f32`s |
| `string`  | `StringRef` |
| `import`  | `ImportId`  |
| `table`   | See below   |
| `closure` | `ProtoRef`  |

#### TableShape

TODO:

### 4.9. `ProtoLineInfo`

A `ProtoLineInfo` encodes the line information of a `Proto`s instructions.

This is [implementation defined](../../src/bytecode/chunk/decode.luau).

### 4.10. `ProtoDebugInfo`

A `ProtoDebugInfo` encodes debugging information for a Proto, and contains the
following fields:

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

## 5. Instructions Structure

An instruction buffer encodes instructions as a series of 32-bit words.

### 5.1. Instruction Word Structure

The first byte of an instruction contains the opcode.

The rest of the instruction contains its operands, which can be encoded in one
of the following modes:

| Mode  | Encoding                      |
| ----- | ----------------------------- |
| `abc` | Three `u8`s.                  |
| `ad`  | One `u8` followed by an `i16` |
| `e`   | One `i24`                     |

Some instructions have additional arguments encoded in a follow up 'auxiliary'
instruction.

## 5.2. List of Instructions

TODO!
