# luau-toolkit

Pure-luau library for assembling, processing, dissecting and executing luau bytecode.

> [!WARNING]  
> This library is work in progress and most features aren't implemented.

## Why

Fun and education mainly. As for why it's written exclusively in luau, I think
it'd be cool to have a full luau IDE implemented in roblox.

## Sister Projects

A number of libraries were written to assist in the development of luau-toolkit:

- [plainenglishh/byteparse](https://github.com/plainenglishh/byteparse), a library for serialising and deserialising binary data (used for bytecode encoding/decoding);
- plainenglishh/luau-jsonrpc\*, a library implementing JSON-RPC;
- plainenglishh/lspsdk\*, a library implementing the Language Server Protocol;
- plainenglishh/dapsdk\*, a library implementing the Debugger Adapter Protocol.

\* temporarily private until in a somewhat ready state.

## Notes

- For performance reasons, the IR encoder will not attempt to validate the
passed data and makes no guarantees that a successful call emits bytecode that can
be ran by a luau interpreter. It is the callers responsibility to ensure the
data is valid. No runtime checks will be performed by either the encoder or
decoder, except for those implemented in dependencies and the luau standard
library.