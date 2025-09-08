# LuauToolkit

A collection of various Luau-related libraries.

> [!WARNING]
> LuauToolkit is deeply unstable and is far from production ready.

## Structure

### Modules

The library is split into the following:

| Module     | Description                                   |                                                                                                                                                                |
| ---------- | --------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `bytecode` | \[WIP] Module for working with Luau bytecode. | [`[docs]`](https://luau-toolkit.plainenglish.xyz/library/modules/bytecode_module.html)<br/>[`[src]`](./lib/bytecode/)<br/>[`[examples]`](./examples/bytecode/) |

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

Documentation can be found [here](https://luau-toolkit.plainenglish.xyz/).

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
