# Bytecode Format

## Types

This document refers to the following types:

| Name      | Description                                   |
| --------- | --------------------------------------------- |
| `boolean` | A true or false value. Encoded as a `u8`.     |
| `u_`      | An unsigned integer \_ bits wide.             |
| `i_`      | An signed integer \_ bits wide.               |
| `f?`      | An IEEE 754 floating point _?_ bits wide.     |
| `varint`  | A protobuf variable width integer.            |
| `string`  | A `varint` length prefixed ASCII string.      |
| `{T}`     | A `varint` length prefixed array of _T_.      |
| `T?`      | An optional value _T_, prefixed by a boolean. |

## Structure

### Chunk

The Chunk encases the entire bytecode chunk, and has the following fields:

| Field Name       | Type       | Meaning |
| ---------------- | ---------- | ------- |
| `luau_version`   | `u8`       |         |
| `types_version`  | `u8`       |         |
| `strings`        | `{string}` |         |
| `userdata_types` | `opaque`   |         |
| `protos`         | `{Proto}`  |         |
| `main_proto`     | `number`   |         |

### Proto

A Proto encodes a function, and has the following fields:

| Field Name          | Type              | Meaning |
| ------------------- | ----------------- | ------- |
| `max_stack_size`    | `u8`              |         |
| `num_params`        | `u8`              |         |
| `num_upvalues`      | `u8`              |         |
| `is_vararg`         | `boolean`         |         |
| `flags`             | `u8`              |         |
| `types`             | `ProtoTypeInfo`   |         |
| `instruction_count` | `varint`          |         |
| `instructions`      | `buffer`          |         |
| `constants`         | `{Constant}`      |         |
| `child_protos`      | `{varint}`        |         |
| `line_defined`      | `varint`          |         |
| `debug_name`        | `varint`          |         |
| `line_info`         | `ProtoLineInfo?`  |         |
| `debug_info`        | `ProtoDebugInfo?` |         |

#### Flags

TODO

### ProtoTypeInfo

A ProtoTypeInfo encodes type information for a Proto, and begins with the
following header fields:

| Field Name        | Type     | Meaning |
| ----------------- | -------- | ------- |
| `function_length` | `varint` |         |
| `upvalue_count`   | `varint` |         |
| `local_count`     | `varint` |         |

After the header, a string `function_length` bytes long contains the functions
type.

After the function type, an array `upvalue_count` items long contains the
upvalue types, encoded as a `u8`.

After the upvalue types, an array `local_count` items long contains the local
types, encoded as:

| Field Name | Type     | Meaning |
| ---------- | -------- | ------- |
| `type`     | `u8`     |         |
| `reg`      | `u8`     |         |
| `start_pc` | `varint` |         |
| `length`   | `varint` |         |

### Constant

A Constant encodes a constant value, and contains the following fields:

| Field Name | Type | Meaning |
| ---------- | ---- | ------- |

TODO

### ProtoLineInfo

delta encoding w/ interval anchors

### ProtoDebugInfo

A ProtoDebugInfo encodes debugging information for a Proto, and contains the
following fields:

| Field Name | Type        | Meaning |
| ---------- | ----------- | ------- |
| `locals`   | `{Local}`   |         |
| `upvalues` | `{Upvalue}` |         |

where Local is:

| Field Name | Type     | Meaning |
| ---------- | -------- | ------- |
| `name`     | `varint` |         |
| `start_pc` | `varint` |         |
| `end_pc`   | `varint` |         |
| `register` | `u8`     |         |

and Upvalue is:

| Field Name | Type     | Meaning |
| ---------- | -------- | ------- |
| `name`     | `varint` |         |
