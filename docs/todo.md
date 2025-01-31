# Todo

- [X] Come up with a proper API design;
     - [X] Split into modules;
     - [X] Create external typedefs;
- [ ] Bytecode Toolkit -- Toolkit for working with bytecode
    - [X] Intermediate Representation ("IR") -- Luau table representation of bytecode chunks
        - [X] Encoder
        - [X] Decoder
    - [X] Luau Bytecode Assembly\* ("LASM") Assembler -- Creating custom bytecode chunks with a library DSL
        - [X] Formal Grammar
        - [ ] CodeGenerator class
        - [X] Tokeniser
        - [X] Parser (not fully tested)
        - [ ] Analyser (to convert AST to IR using BytecodeGenerator)
        - [ ] `P` VSC Textmate Grammar
        - [ ] `??` a very basic LSP (using lspsdk)
    - [X] Disassembler (emits LASM source from a given bytecode chunk/ir)
    - [ ] `?` A bytecode interpeter?
    - [ ] BytecodeBuilder class (emits IR)
    - [ ] Optimiser
        - [ ] `P` Strip debug info
        - [ ] `??` Inlining
        - [ ] `???` Unrolling
    - [ ] `??` Decompiler (using luau CodeGenerator)
- [ ] Source Code Toolkit (Toolkit for working with source code)
    - [ ] `??` Tokeniser
    - [ ] `??` Parser
    - [ ] `??` CodeGenerator class (emits source code)
    - [ ] `???` Prettier/processor?
    - [ ] `???` Basic Obfuscator?
    - [ ] `???` Compiler (emits IR using BytecodeBuilder)
- [ ] Virtual Machine
    - [ ] `??` 'partial' VM (interprets bytecode instructions and runs them on the VM running the library, similar to fiu),
    - [ ] `???` 'full' VM (interprets bytecode instructions in an isolated pure-luau implemented VM)\*\*


\* assembly language for luau bytecode, created for this library.
\*\* just for fun; 'partial' VM would likely be more performant and 'full' vm would be overblown for practically all use cases. this wouldnt be a 1-1 recreation of the luau VM for obvious reasons, just hopefully similar enough for most code to work.

||Meaning|
|-|-|
||planned|
|`?`|most likely|
|`??`|maybe|
|`???`|probably not|
|`P`|prototype completed|