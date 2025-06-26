# Security

## Current State of Security

The luau-toolkit library is a largely untested work-in-progress project intended
for experimental use only. You should not use this library where security is of
any concern.

### Bytecode Module

The `bytecode` module is capable of creating arbitrary bytecode chunks. Unlike
luau source code, arbitrary bytecode can iterate through the VMs registers to
access and interact with old uncleared objects.

Furthermore, the `bytecode.decode` function doesn't yet validate a given chunks
validity. When given invalid data, it can either throw an error or return an
invalid `Chunk` object.

### VM Module

The `vm` module is a largely untested work-in-progress and therefore cannot
guarantee a safe sandbox.

When passed officially\* compiled bytecode, the virtual machines _shouldn't_ be
able access to any objects not accessible from the given environment table.

\* Refers to bytecode compiled using the official `luau-lang/luau` compiler.

## Reporting Security Issues

Even though I can't guarantee the library is secure, I aim to promptly fix any
vulnerabilities brought to my attention.

To report security issues, message me on Discord @plainenglish
<203958045640884234>. Don't hesitate to reach out to report vulnerabilities,
even if they're seemingly minor, or only effect old/wip versions.
