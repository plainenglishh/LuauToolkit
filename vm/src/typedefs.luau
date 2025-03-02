local bytecode = require("../../bytecode");

export type VMError = {
    type: string,
    message: string,
    pc: number,
    proto: number,
    inst: bytecode.BytecodeInstruction,
    chunk: bytecode.BytecodeChunk,
};

return {};