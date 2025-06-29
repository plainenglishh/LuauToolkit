# To-Do list

## Documentation

- [ ] List instructions in luau_internals/bytecode

## Bytecode Module

- [ ] Chunk Validate
- [ ] Rework BytecodeAssembler, add line/type info (use luau-org/luau bytecode
      builder for ref)
- [ ] Move `instructions.luau` to `instructions/init.luau` and move
      `instruction_metadata` to `instructions/metadata` (waiting for lune to fix
      requires). **INVOLVES FIXING UPDATE_OPCODES SCRIPT**
- [ ] Rework constant types + add table shapes

## Loadstring Module

- [ ] Make use of constant tables

## VM Module

- [ ] Rework VM
- [ ] VM Tests

## Lexer Module

- [ ] Needs starting (use Lexer.cpp as reference)
