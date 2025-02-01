local ir = require("./ir");
local other = require("./other");
local t = require("../typedefs");

local function add_to<T>(tbl: {T}, value: T, force: boolean?): number
    if force then
        local idx = table.find(tbl, value);
        if idx then
            return idx;
        end
    end

    local idx = #tbl + 1;
    tbl[idx] = value;
    return idx;
end

local BytecodeBuilder = {};
BytecodeBuilder.__index = BytecodeBuilder;

function BytecodeBuilder.new(): t.BytecodeBuilder
    return setmetatable({
        _offset = 0,
        _proto = nil,
        _proto_id = nil,
        _chunk = {
            luau_version = 6,
            types_version = 1,
            strings = {},
            protos = {},
            main_proto = -1,
        },
    }, BytecodeBuilder);
end

--// Chunk Methods

function BytecodeBuilder:set_version(version: number)
    self._chunk.luau_version = version;
end

function BytecodeBuilder:set_types_version(version: number)
    self._chunk.types_version = version;
end

function BytecodeBuilder:add_string(str: string, force: boolean?): number
    return add_to(self._chunk.strings, str, force);
end

function BytecodeBuilder:add_import(path: {string})
    local new_path = {};
    for i, v in path do
        new_path[i] = self:add_string(v);
    end

    return other.encode_import_id(new_path);
end

--// Proto Methods

function BytecodeBuilder:start_proto()
    if self._proto then
        error("already in a function", 2);
    end

    self._offset = 0;

    self._proto = {
        num_params = 0,
        num_upvalues = 0,
        is_vararg = false,
        flags = {},
        max_stack_size = 0,
        constants = {},
        instructions = {},
        protos = {},
        debug_name = 0,
        line_defined = 0,
    };

    local proto_id = math.clamp(#self._chunk.protos, 0, math.huge);
    self._proto_id = proto_id;
    return proto_id;
end

function BytecodeBuilder:get_proto_id(): number
    return self._proto_id or error("not in a function", 2);
end

function BytecodeBuilder:set_max_stack_size(value: number)
    if not self._proto then
        error("not in a function", 2);
    end

    self._proto.max_stack_size = value;
end

function BytecodeBuilder:set_num_params(value: number)
    if not self._proto then
        error("not in a function", 2);
    end

    self._proto.num_params = value;
end

function BytecodeBuilder:set_num_upvalues(value: number)
    if not self._proto then
        error("not in a function", 2);
    end

    self._proto.num_upvalues = value;
end

function BytecodeBuilder:set_is_vararg(value: boolean)
    if not self._proto then
        error("not in a function", 2);
    end

    self._proto.is_vararg = value;
end
function BytecodeBuilder:set_line_defined(value: number)
    if not self._proto then
        error("not in a function", 2);
    end

    self._proto.line_defined = value;
end

function BytecodeBuilder:set_debug_name(value: string): ()
    if not self._proto then
        error("not in a function", 2);
    end

    self._proto.debug_name = self:add_string(value);
end

function BytecodeBuilder:set_main(value: number?)
    self._chunk.main_proto = value or self._proto_id or error("");
end

function BytecodeBuilder:set_flag(flag: any, value: boolean)
    if not self._proto then
        error("not in a function", 2);
    end

    if value == true then
        if not table.find(self._proto.flags, flag) then
            table.insert(self._proto.flags, flag);
        end
    else
        local idx = table.find(self._proto.flags, flag);
        if idx then
            table.remove(self._proto.flags, idx);
        end
    end
end

function BytecodeBuilder:add_constant(type: any, value: any, force: boolean?): number
    if not self._proto then
        error("not in a function", 2);
    end

    if type == "closure" then
        value = add_to(self._proto.protos, value) - 1;
    end

    return add_to(self._proto.constants, {
        type = type,
        value = value,
    }, force) - 1;
end

function BytecodeBuilder:add_instruction(opname_or_code: number|any, ...: number): number
    local operands = {...};
    if not self._proto then
        error("not in a function", 2);
    end
    
    local offset = self._offset;
    local info = other.get_opcode_info(opname_or_code) or error("unknown opcode", 2);

    local inst_operands = {};
    local current = 1;

    for _, v in info.operands do
        inst_operands[string.lower(v.name)] = operands[current] or 0;
        current += 1;
    end

    table.insert(self._proto.instructions, {
        opcode = info.opcode,
        operands = inst_operands,
    });

    self._offset += info.size;

    return offset;
end

function BytecodeBuilder:get_offset(): number
    return self._offset;
end

function BytecodeBuilder:end_proto()
    if not self._proto then
        error("not in a function", 2);
    end

    table.insert(self._chunk.protos, table.clone(self._proto));
    local proto_id = self._proto_id or error("");
    self._proto = nil
    self._proto_id = nil;
    return proto_id;
end

function BytecodeBuilder:build_ir()
    if self._proto then
        error("unended function", 2);
    end

    if self._chunk.main_proto  == -1 then
        error("no main proto set", 2)
    end

    return table.clone(self._chunk);
end

function BytecodeBuilder:build_bc()
    return ir.encode(self:build_ir());
end

return (BytecodeBuilder :: any) :: t.BytecodeBuilderImpl;
