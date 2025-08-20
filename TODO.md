# To-Do list

- [ ] Convert cross-module requires to be relative
- [ ] Benchmark Suite

## Documentation

- [ ] List instructions in luau_internals/bytecode

## Bytecode Module

- [ ] Chunk Validate
  - [ ] Metadata (valid versions)
  - [ ] Constants (do constants point to valid items)
  - [ ] Instructions (are jump offsets valid? referencing a register above the
        stack size? are arguments valid?)
  - [ ] No returns?
- [ ] Move `instructions.luau` to `instructions/init.luau` and move
      `instruction_metadata` to `instructions/metadata` (waiting for lune to fix
      requires). **INVOLVES FIXING UPDATE_OPCODES SCRIPT**
- [ ] Rework constant types + add table shapes
- [ ] Tests

## Loadstring Module

- [ ] use constant tables
- [ ] inline fastcalls?
- [ ] test with `luau_toolkit/vm_conformance`
- [ ] consider dispatch table rather than long if chain

## LASM Module

- [x] Write language spec
- [x] Write lexer
- [ ] Write parser

## VM Module

not started

## Lexer Module

not started

## Parser Module

not started

## Decompiler Module

- [ ] finish 'executable' decompilation target
