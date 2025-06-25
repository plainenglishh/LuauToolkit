# Luau-Toolkit

> [!WARNING]
> This library is work in progress. Many features aren't implemented yet and the
> API structure is subject to change.

A pure-luau library for working with luau, within luau.

## Luau Version

Each version of the library is designed to target a specific luau version. The
currently target version can be found in the [`.luau_version`](./.luau_version)
file.

## Modules

The library is split into _mostly_ separate modules:

| Name                      | Contents                                                | Dependencies\*\* | State              |
| ------------------------- | ------------------------------------------------------- | ---------------- | ------------------ |
| [`bytecode`](./bytecode/) | Functions and constants for working with Luau bytecode. | None             | Work in Progress   |
| [`vm`](./vm/)             | Luau virtual machine implementation                     | `bytecode`       | Work in Progress   |
| [`lexer`](./lexer/)       |                                                         |                  | Planned            |
| `parser`                  |                                                         |                  | In Consideration\* |
| `compiler`                |                                                         |                  | In Consideration\* |

\* In Consideration = Not for a _long_ time, if ever.

\*\* There is an additional hidden `common` module that contains shared items.
It should be assumed that all modules depend on this.
