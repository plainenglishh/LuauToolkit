local t = require("./types");
local chunk_lib = require("./chunk");
local instructions = require("./instructions")

local function disassemble(chunk: buffer | t.Chunk): string
    local chunk = if type(chunk) == "table" then chunk else chunk_lib.decode(chunk);
    local out: {string} = {};
    
    local function write(text: string)
        table.insert(out, text);
    end

    local function writeln(text: string)
        write(text);
        write("\n");
    end

    for i, proto in chunk.protos do
        local ref = i - 1;
        
        writeln(`Function #{ref}{if proto.debug_name ~= 0 then ` '{chunk.strings[proto.debug_name]}'` else ""}{if ref == chunk.main_proto then " (main)" else ""}`);

        local code = instructions.decode(proto.instructions);
        for _, v in code do
            writeln(`    {instructions.display(instructions.encode_instruction(v))}`); 
        end

        if i ~= #chunk.protos then
            writeln("");
        end
    end

    return table.concat(out, "");
end

return disassemble;
