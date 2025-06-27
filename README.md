# Luau-Toolkit

> [!WARNING]
> This library is work in progress. Many features aren't implemented yet and the
> API structure is subject to change.

A library for working with luau, within luau.

## Usage

### Installation

To install `luau_toolkit`, copy the `src/` directory to wherever you'd like to
install the library and rename it to `luau_toolkit`.

Optionally create an `@luau_toolkit` alias in your `.luaurc`:

```json
{
    ...
    "aliases": {
        "luau_toolkit": "./path/to/library"
    },
    ...
}
```

### Modules

The library is split into _mostly_ separate modules:

| Module     | Contents                                                | Dependencies |                                                                         |
| ---------- | ------------------------------------------------------- | ------------ | ----------------------------------------------------------------------- |
| `bytecode` | Functions and constants for working with Luau bytecode. | None         | [`[ docs ]`](./docs/bytecode/index.md)<br/>[`[ src ]`](./src/bytecode/) |

<!--| [`vm`](./src/vm/)             | **\[WIP]** Luau virtual machine/interpreter implementations.       | `bytecode`       |-->
<!--| [`lexer`](./src/lexer/)       | **\[WIP]** Luau source code lexer.                                 |                  |-->
<!--| [`misc`](./src/misc/)         | **\[WIP]** Miscellaneous luau related items.                       | None             |-->
<!--| `parser`                  | **\[Not Started]** Luau source code parser.                        |                  |-->
<!--| `compiler`                | **\[Not Started/Unlikely]** Simple Luau compiler.                  |                  |-->
<!--| `decompiler`              |                                                                    | `bytecode`       |-->

To access a module

## Luau Version

Each version of the library is designed to target a specific luau version. The
currently targeted version can be found in the
[`.luau_version`](./.luau_version) file.

## Documentation

Documentation can be found [here](./docs/index.md).

## Examples

A series of examples can be found under the `examples/` directory.

You can run an example with:

```bash
lune run examples/<path_to_example> [args]

# eg:
lune run examples/bytecode/strip chunk.luauc stripped.luauc
```

## Testing

You can run the test suite with:

```bash
lune run tests
```

Optionally specify `--werror` to treat "warnings" as failed tests.
