local t = require("../types");
local patch_instructions = require("./patch_instructions");

local BREAK = buffer.create(4);
buffer.writeu32(BREAK, 0, 0x00000001);

local function get_proto_for_line(chunk: t.Chunk, line: number): t.Proto?
    for _, proto in chunk.protos do
        if not proto.line_info then
            continue;
        end

        local len = buffer.len(proto.line_info);
        if len == 0 then
            continue;
        end

        local min, max = buffer.readu32(proto.line_info, 0), buffer.readu32(proto.line_info, len - 4);
        if line >= min and line <= max then
            return proto;
        end
    end

    return nil;
end

local function get_pc_for_line(proto: t.Proto, line: number): number
    local line_info = proto.line_info or error("expected line info");

    for offset = 0, buffer.len(line_info) - 1, 4 do
        if buffer.readu32(line_info, offset) == line then
            return offset / 4;
        end
    end

    return 0;
end

--[=[
    Inserts a breakpoint to a line.

    @within bytecode.ops
]=]
local function add_breakpoint(chunk: t.Chunk, line: number)
    local proto = get_proto_for_line(chunk, line) or error(`can't get function for line`);
    local pc = get_pc_for_line(proto, line);

    if pc == 0 then 
        pc += 1; -- Insert after `PREPVARARGS`
    end

    patch_instructions(proto, pc, BREAK);
end

return add_breakpoint;
