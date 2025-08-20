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
- [X] Rewrite BytecodeAssembler
      - [X] New solver compatibility
      - [X] Emit custom instructions `emit_abc`, `emit_ad` and `emit_e`, keep `emit_instruction` for higher level use.
      - [X] type/line number encoding
- [ ] Move `instructions.luau` to `instructions/init.luau` and move
      `instruction_metadata` to `instructions/metadata` (waiting for lune to fix
      requires). **INVOLVES FIXING UPDATE_OPCODES SCRIPT**
- [ ] Rework constant types + add table shapes
- [ ] 

## Loadstring Module

- [ ] hook `coroutine.running` to pretend generalised iter is on the correct
      thread (? if thats a good idea in the first place ?)
- [ ] Make use of constant tables
- [ ] Comprehensive Testing using `luau_toolkit/vm_conformance`
- [ ] consider dispatch table at proto (accessing state via upvalues) or global level (accessing state via params)

## LASM Module

- [x] Write language spec
- [x] Write lexer
- [ ] Write parser

## VM Module

- [ ] Rework VM
- [ ] VM Tests

## Lexer Module

- [ ] Needs starting (use Lexer.cpp as reference)

## Parser Module

- [ ] random luau program generator example (funny)

## Decompiler Module

- [ ] Needs starting
