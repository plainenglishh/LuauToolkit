# Security

## Current State of Security

The luau-toolkit library is a largely untested work-in-progress project. You
should not use this library where security is of major concern.

### Bytecode Module

The bytecode module is capable of emitting arbitrary bytecode. Unlike securely
compiled luau bytecode, arbitrary bytecode can iterate through the VMs registers
to access, and interact with, old uncleared objects.

### VM Module

The luau-toolkit VM module is a largely untested work-in-progress and therefore
cannot guarantee a safe sandbox.

When passed officially\* compiled bytecode, the luau-toolkit VMs shouldn't
provide access to any objects not accessible from the chunks environment table.

\* "official" in this sense refers to bytecode compiled from the
`luau-lang/luau` compiler.

## Reporting Security Issues
