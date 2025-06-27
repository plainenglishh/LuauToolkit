# Luau-Toolkit

> [!WARNING]
> This library is work in progress. Many features aren't implemented yet and the
> API structure is subject to change.

A library for working with luau, within luau.

## Modules

The library is split into _mostly_ separate modules:

| Name                      | Description                                                        | Dependencies\*\* |
| ------------------------- | ------------------------------------------------------------------ | ---------------- |
| [`bytecode`](./bytecode/) | **\[WIP]** Functions and constants for working with Luau bytecode. | None             |

<!--| [`vm`](./vm/)             | **\[WIP]** Luau virtual machine/interpreter implementations.       | `bytecode`       |-->
<!--| [`lexer`](./lexer/)       | **\[WIP]** Luau source code lexer.                                 |                  |-->
<!--| [`misc`](./misc/)         | **\[WIP]** Miscellaneous luau related items.                       | None             |-->
<!--| `parser`                  | **\[Not Started]** Luau source code parser.                        |                  |-->
<!--| `compiler`                | **\[Not Started/Unlikely]** Simple Luau compiler.                  |                  |-->
<!--| `decompiler`              |                                                                    | `bytecode`       |-->

\* In Consideration = Not for a _long_ time, if ever.

\*\* There is an additional hidden `common` module that contains shared items.
It should be assumed that all modules depend on this.

### Using Modules

To use a module, require it like so:

```luau
-- Assuming @luau_toolkit is aliased to the library root.
local bytecode = require("@luau_toolkit/bytecode");
...
```

## Luau Version

Each version of the library is designed to target a specific luau version. The
currently targeted version can be found in the
[`.luau_version`](./.luau_version) file.

## Testing

You can run the test suite with:

```bash
lune run tests
```
