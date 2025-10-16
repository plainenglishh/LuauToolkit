local instructions = require("../instructions");
local t = require("../types");

local function buffer_insert(original: buffer, insert: buffer, insert_at: number): buffer
    local insert_len = buffer.len(insert);
    local len = buffer.len(original) + insert_len;
    local b = buffer.create(len);

    buffer.copy(b, 0, original, 0, insert_at);
    buffer.copy(b, insert_at, insert, 0, insert_len);
    buffer.copy(b, insert_at + insert_len, original, insert_at);

    return b;
end

--[=[
    Inserts instructions into a function at a given PC.

    @within bytecode.ops
]=]
local function patch_instructions(proto: t.Proto, pc: number, inserted: buffer | {t.Instruction})
    local inserted = if type(inserted) == "buffer" then inserted else instructions.encode(inserted);
    proto.instructions = buffer_insert(proto.instructions, inserted, pc * 4);

    if proto.line_info then
        local line = buffer.readu32(proto.line_info, pc * 4);
        local len = buffer.len(inserted);
        local extra_line_info = buffer.create(len);
        
        for i = 0, len - 1, 4 do
            buffer.writeu32(extra_line_info, i, line);
        end

        proto.line_info = buffer_insert(proto.line_info, extra_line_info, pc * 4);
    end
end

return patch_instructions;
