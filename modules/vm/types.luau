local bytecode = require("../bytecode");

export type VMError = {
    type: string,
    message: string,
    pc: number,
    proto: number,
    inst: bytecode.Instruction,
    chunk: bytecode.Chunk,
};

return {};