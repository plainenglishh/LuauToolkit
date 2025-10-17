local instructions = require("../instructions");
local t = require("../types");

local NEWCLOSURE = 19;
local DUPCLOSURE = 64;

type Instantiation = {
    proto: number,
    pc: number,
    type: "DUPCLOSURE" | "NEWCLOSURE",
};

--[=[
    Returns where and how a closure is created.
]=]
local function get_closure_instantiation(chunk: t.Chunk, proto: number | t.Proto): Instantiation?
    local proto_ref = if type(proto) == "number" then proto else table.find(chunk.protos, proto) or error("orphaned proto") - 1;

    if proto_ref == chunk.main_proto then
        return nil;
    end

    for i, proto in chunk.protos do
        local code = proto.instructions;
        local code_size = buffer.len(code) // 4;

        for pc = 0, code_size - 1 do
            local insn = buffer.readu32(code, pc * 4);
            local op = instructions.insn_op(insn);
            local d = instructions.insn_d(insn);
            if op == NEWCLOSURE and proto.child_protos[d + 1] == proto_ref then
                return {
                    proto = i - 1,
                    pc = pc,
                    type = "NEWCLOSURE",
                };
            elseif op == DUPCLOSURE and (proto.constants[d + 1] or {} :: any).value == proto_ref then
                return {
                    proto = i - 1,
                    pc = pc,
                    type = "DUPCLOSURE",
                };
            end
        end
    end

    return error(`cant find instantiation for {proto_ref}`);
end

return get_closure_instantiation;
