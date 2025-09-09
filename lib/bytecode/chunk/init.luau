--[=[
    Library for encoding, decoding and validating Luau bytecode chunks.

    @class bytecode.chunk
]=]
local chunk = {};

chunk.encode = require("@self/encode");
chunk.decode = require("@self/decode");
chunk.validate = require("@self/validate");

return chunk;
