local MODULE_DEPENDENCIES = {
    bytecode = { "common" },
    common = {},
    lasm = { "bytecode", "common" },
    lexer = { "common" },
    loadstring = { "bytecode", "common" },
    sourcegen = { "common" },
    decompiler = { "bytecode", "common", "sourcegen" },
    vm_conformance = { "bytecode", "common" },
};

