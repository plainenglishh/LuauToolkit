# Security

## Security Considerations

The luau-toolkit library is a largely untested work-in-progress project intended
for experimental use only.

### Bytecode Module

The `bytecode` module is capable of creating arbitrary bytecode chunks, which
unlike source code, can't be properly sandboxed.

Furthermore, `bytecode.decode` doesn't fully validate the decoded chunk and may
throw errors, or even return a malformed `Chunk`, when passed an invalid
bytecode chunk.

### VM & Loadstring Module

The VM implementations shouldn't be able to access any objects not explicitly
passed to them (by either the environment/global tables or as arguments). You
should still avoid accepting untrusted bytecode.

## Reporting Security Issues

To report security issues, message me on Discord @plainenglish
<203958045640884234>. Don't hesitate to reach out to report vulnerabilities,
even if they're seemingly minor, or only effect old/wip versions.
