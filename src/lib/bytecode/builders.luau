local common = require("../common");
local opcodes = require("./opcodes");
local other = require("./other");
local t = require("../types");


local FLAG_POSITION = {
    native_module = 0,
    native_cold = 1,
    native_function = 2,
};

local builders = {};

function builders.chunk(from: t.IRChunk?)
    local self: t.IRChunk = from or {
        luau_version = 6,
        types_version = 1,
        strings = {},
        userdata_types = nil,
        protos = {},
        main_proto = -1,
    };

    local builder = {};

    --[=[
        Adds a string to the string table, returning it's index.
    ]=]
    function builder.add_string(str: string, force_new: boolean?): number
        if not force_new then
            local id = table.find(self.strings, str);
            if id then
                return id;
            end
        end

        local id = #self.strings + 1;
        self.strings[id] = str;
        return id;
    end

    --[=[
        Adds a proto to the proto table, returning it's index.
    ]=]
    function builder.add_proto(proto: t.IRProto): number
        local id = #self.protos + 1;
        self.protos[id] = proto;
        return id - 1;
    end

    --[=[
        Sets the main proto to a given ID.
    ]=]
    function builder.set_main_proto(proto_id: number)
        self.main_proto = proto_id;
    end

    --[=[
        Sets the main proto to a given ID.
    ]=]
    function builder.set_luau_version(version: number)
        self.luau_version = version;
    end

    --[=[
        Sets the main proto to a given ID.
    ]=]
    function builder.set_types_version(version: number)
        self.types_version = version;
    end

    --[=[
        Adds a new userdata type from a given string_id, returning the types ID.
    ]=]
    function builder.add_userdata_type(string_id: number, force_new: boolean?): number
        if not self.userdata_types then
            self.userdata_types = {};
        end

        if not force_new then
            local id = table.find(self.userdata_types :: {number}, string_id);
            if id then
                return id - 1;
            end
        end

        local id = #self.userdata_types :: {number} + 1;
        (self.userdata_types :: {number})[id] = string_id;
        return id - 1;
    end

    --[=[
        Returns the built chunk.
    ]=]
    function builder.build(): t.IRChunk
        if self.main_proto == -1 then
            error("no main proto set", 2);
        end

        return common.deep_clone(self);
    end

    return builder;
end

function builders.proto(from: t.IRProto?)
    local last_inst_position = 0;
    local self: t.IRProto = from or {
        max_stack_size = 0,
        num_params = 0,
        num_upvalues = 0,
        is_varag = false,
        flags = 0,
        types = nil,
        instructions = {},
        constants = {},
        protos = {},
        line_defined = 0,
        debug_name = 0,
        line_info = nil,
        debug_info = nil,
    };

    local builder = {};

    function builder.set_max_stack_size(value: number)
        self.max_stack_size = value;
    end

    function builder.inc_max_stack_size(by: number?)
        self.max_stack_size += by or 1;
    end

    function builder.set_num_params(value: number)
        self.num_params = value;
    end

    function builder.inc_num_params(by: number?)
        self.num_params += by or 1;
    end

    function builder.set_num_upvalues(value: number)
        self.num_upvalues = value;
    end

    function builder.inc_num_upvalues(by: number?)
        self.num_upvalues += by or 1;
    end

    function builder.set_is_vararg(value: boolean)
        self.is_varag = value;
    end

    function builder.set_flag(flag: "native_module"|"native_cold"|"native_function", value: boolean)
        if FLAG_POSITION[flag] then
            self.flags = bit32.replace(self.flags, if value then 1 else 0, FLAG_POSITION[flag]);
        else
            error(`unknown flag '{flag}'`);
        end
    end

    --- TODO: Type Info

    --[=[
        Adds a new instruction, returning its position.
    ]=]
    function builder.add_instruction(name_or_id: opcodes.OpcodeName|number, operands: {number}?, aux: number?): number
        local info = other.get_opcode_info(name_or_id) or error(`unknown instruction '{name_or_id}'`);
        local operands = operands or {};

        if #operands > #info.operands then
            error(`too many operands, '{info.name}' only accepts {#info.operands} operands, got {#operands}`);
        end

        local ser_operands = {};

        if info.mode == "none" then
            -- nothing    
        elseif info.mode == "abc" then
            ser_operands.a = operands[1] or 0;
            ser_operands.b = operands[2] or 0;
            ser_operands.c = operands[3] or 0;
        elseif info.mode == "ad" then
            ser_operands.a = operands[1] or 0;
            ser_operands.d = operands[2] or 0;
        elseif info.mode == "e" then
            ser_operands.e = operands[1] or 0;
        end

        if info.aux then
            ser_operands.aux = aux or 0;
        end

        table.insert(self.instructions, {
            opcode = info.opcode,
            operands = ser_operands,
        });

        last_inst_position += if info.aux then 2 else 1;

        return last_inst_position;
    end

    function builder.add_constant(ktype: "nil" | "boolean" | "number" | "string" | "import" | "table" | "closure" | "vector", value: any, force_new: boolean?): number
        if not force_new then
            for i, v in self.constants do
                if v.type == ktype and v.value == value then
                    return i - 1;
                end
            end
        end

        local id = #self.constants + 1;
        self.constants[id] = {
            type = ktype,
            value = value,
        };

        return id - 1;
    end

    function builder.add_child_proto(proto_id: number, force_new: boolean?): number
        if not force_new then
            local id = table.find(self.protos, proto_id);
            if id then
                return id - 1;
            end
        end

        local id = #self.protos + 1;
        self.protos[id] = proto_id;
        return id - 1;
    end

    function builder.set_line_defined(line: number)
        self.line_defined = line;
    end

    function builder.set_debug_name(string_id: number)
        self.debug_name = string_id;
    end

    --[=[
        Returns the built chunk.
    ]=]
    function builder.build(): t.IRProto
        return common.deep_clone(self);
    end

    -- Todo:
    function builder.get_jump_offset_to(target_position: number): number
        return common.unimplemented();
    end

    function builder.set_line_info()
        return common.unimplemented();
    end

    function builder.set_debug_info()
        return common.unimplemented();
    end

    return builder;
end

return builders;
