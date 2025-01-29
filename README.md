# luauc-toolkit

Pure-luau library for assembling, processing, dissecting and executing luau bytecode.

> [!WARNING]  
> This library is work in progress and most features aren't implemented.

## Notes

- For performance reasons, the IR encoder will not attempt to validate the
passed data and makes no guarantees that a successful call emits bytecode that can
be ran by a luau interpreter. It is the callers responsibility to ensure the
data is valid. No runtime checks will be performed by either the encoder or
decoder, except for those implemented in dependencies and the luau standard
library.