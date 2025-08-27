# Luau-Toolkit

A library for working with Luau from within Luau.

> [!WARNING]
> This library is work in progress. Many features aren't implemented and the API
> structure is subject to change.

## Contents

### Modules

The library is split into the following modules:

| Module     | Description                            |                                                                                                                                                        |
| ---------- | -------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `bytecode` | Module for working with Luau bytecode. | [`[docs]`](https://luau-toolkit.plainenglish.xyz/modules/bytecode_module.html)<br/>[`[src]`](./lib/bytecode/)<br/>[`[examples]`](./examples/bytecode/) |

<!--
| `loadstring`     | \[WIP] Lightweight loadstring implementation.                  | [`[docs]`](./docs/modules/loadstring.md)<br/>[`[src]`](./lib/loadstring/)<br/>[`[examples]`](./examples/loadstring/)             |
| `vm_conformance` | \[WIP] Luau VM conformance test cases.                         | [`[docs]`](./docs/modules/vm_conformance.md)<br/>[`[src]`](./lib/vm_conformance/)<br/>[`[examples]`](./examples/vm_conformance/) |

| `lasm`           | Luau Bytecode Assembler.                                | [`[docs]`](./docs/modules/lasm.md)<br/>[`[src]`](./lib/lasm/)<br/>[`[examples]`](./examples/lasm/)                               |
| `decompiler`     | Luau Bytecode Decompiler.                               | [`[docs]`](./docs/modules/decompiler.md)<br/>[`[src]`](./lib/decompiler/)<br/>[`[examples]`](./examples/decompiler/)             |
| `sourcegen`      | Source Code Generation Utilities.                       | [`[docs]`](./docs/modules/sourcegen.md)<br/>[`[src]`](./lib/sourcegen/)<br/>[`[examples]`](./examples/sourcegen/)                |
| `vm`             | Luau virtual machine/interpreter implementations.       |                                                                                                                                  |
| `lexer`          | Luau source code lexer.                                 |                                                                                                                                  |
| `common`         | Miscellaneous luau related items.                       |                                                                                                                                  |
| `parser`         | Luau source code parser.                                |                                                                                                                                  |
| `compiler`       | Simple Luau compiler.                                   |                                                                                                                                  |
| `decompiler`     |                                                         |                                                                                                                                  |
| `debugger`       |                                                         |                                                                                                                                  |
-->
<!-- Only advertise modules when they're in a 'ready' state. -->

### Binaries

Some modules also have command line applications, accessible under the
[`bin/`](./bin/) directory.

### Examples

A series of examples can be found under the [`examples/`](./examples/)
directory.

You can run an example with:

```bash
lune run examples/<path_to_example> [args]

# eg:
lune run examples/bytecode/strip chunk.luauc stripped.luauc
```

## Documentation

Documentation can be found [here](./docs/index.md).

## Installation

To install `luau_toolkit`, copy the [`lib/`](./lib) directory to wherever you'd
like to install the library, and rename it to `luau_toolkit`.

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

## Testing

Tests can be found under the [`tests/`](./tests/) directory.

You can run the test suite with:

```bash
lune run tests
```

You can also run individual tests:

```bash
lune run tests/loadstring/vm_conformance.spec.luau
```

Optionally specify `--werror` to treat "warnings" as failed tests.
