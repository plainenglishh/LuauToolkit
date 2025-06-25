# Security

## Current State of Security

The luau-toolkit library is a largely untested work-in-progress project. You
should not use this library where security is of major concern.

### Bytecode Module

The bytecode module is capable of emitting arbitrary bytecode. Unlike luau
source code, bytecode can iterate through the VMs registers to access and
interact with old uncleared objects.

### VM Module

The luau-toolkit VM module is a largely untested work-in-progress and therefore
cannot guarantee a safe sandbox.

When passed securely\* compiled bytecode, the luau-toolkit VMs shouldn't provide
access to any objects not accessible from the chunks environment table.

\* "securely" in this sense refers to bytecode compiled from the
`luau-lang/luau` compiler.

## Reporting Security Issues

To report any security issues, message me on Discord @plainengish
<203958045640884234>.
