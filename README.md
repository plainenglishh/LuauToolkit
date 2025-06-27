# Luau-Toolkit

A library for working with luau, within luau.

> [!WARNING]
> This library is work in progress. Many features aren't implemented and the API
> structure is subject to change.

## Usage

### Installation

To install `luau_toolkit`, copy the [`src/`](./src) directory to wherever you'd
like to install the library and rename it to `luau_toolkit`.

Optionally, create an `@luau_toolkit` alias in your `.luaurc` file to make the
library accessible with `require("@luau_toolkit/<module>")`:

```jsonc
{
    //...
    "aliases": {
        "luau_toolkit": "./path/to/library"
    }
    //...
}
```

### Modules

The library is split into the following modules:

| Module     | Contents                                                | Dependencies |                                                                         |
| ---------- | ------------------------------------------------------- | ------------ | ----------------------------------------------------------------------- |
| `bytecode` | Functions and constants for working with Luau bytecode. | None         | [`[ docs ]`](./docs/bytecode/index.md)<br/>[`[ src ]`](./src/bytecode/) |

<!--| [`vm`](./src/vm/)             | **\[WIP]** Luau virtual machine/interpreter implementations.       | `bytecode`       |-->
<!--| [`lexer`](./src/lexer/)       | **\[WIP]** Luau source code lexer.                                 |                  |-->
<!--| [`misc`](./src/misc/)         | **\[WIP]** Miscellaneous luau related items.                       | None             |-->
<!--| `parser`                  | **\[Not Started]** Luau source code parser.                        |                  |-->
<!--| `compiler`                | **\[Not Started/Unlikely]** Simple Luau compiler.                  |                  |-->
<!--| `decompiler`              |                                                                    | `bytecode`       |-->

This is so you can choose to pull in the minimum amount of modules you need. As
such, there is no central `init.luau` file for the library. You should instead
access each module individually:

```luau
local bytecode = require("@luau_toolkit/bytecode");
local lexer = require("@luau_toolkit/lexer");
...
```

Some modules may depend on others, as described in the 'Dependencies' column, so
be careful to not remove any modules you indirectly depend on.

Modules that depend on other modules access them with relative paths (e.g.
`../bytecode`), so make sure they stay within the same directory. Use the
installation steps described above to ensure this.

## Luau Version

Every version of the library is tagged to specific luau version. The library
should be able to run under and work with the tagged version.

The currently targeted version can be found in the
[`.luau_version`](./.luau_version) file.

## Documentation

Documentation can be found [here](./docs/index.md).

## Examples

A series of examples can be found under the [`examples/`](./examples/)
directory.

You can run an example with:

```bash
lune run examples/<path_to_example> [args]

# eg:
lune run examples/bytecode/strip chunk.luauc stripped.luauc
```

## Testing

Tests can be found under the [`tests/`](./tests/) directory.

You can run the test suite with:

```bash
lune run tests
```

Optionally specify `--werror` to treat "warnings" as failed tests.
