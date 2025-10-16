--!native

local common = require("../common");
local constants = require("./constants");
local t = require("./types");

local byteparse = common.byteparse;

local chunk = {};

--[=[
    Decodes a bytecode chunk into a `Chunk` object.

    NOTE: This function intentionally does **not** check for validity. 
          Run `bytecode.validate` beforehand if this is desired.

    @within bytecode.chunk
]=]
function chunk.decode(bc: t.bstring): t.Chunk    
    local bytecode = if type(bc) == "string" then buffer.fromstring(bc) else bc;
    local reader = byteparse.reader(bytecode);

    local function read_constant(): t.Constant
        local constant_type = reader.read_u8();
        local constant_type_name = constants.CONSTANT_TYPES[constant_type];

        local constant: t.Constant = {
            type = constant_type_name :: any,
            value = nil,
        };

        if constant_type_name == "nil" then
            constant.value = nil;
        elseif constant_type_name == "boolean" then
            constant.value = reader.read_bool();    
        elseif constant_type_name == "number" then
            constant.value = reader.read_f64();
        elseif constant_type_name == "string" then
            constant.value = reader.read_varint();
        elseif constant_type_name == "import" then
            constant.value = reader.read_u32();
        elseif constant_type_name == "table" then
            local length = reader.read_varint();
            local tbl = table.create(length, 0);

            for i = 1, length do
                tbl[i] = reader.read_varint();
            end

            constant.value = tbl;
        elseif constant_type_name == "closure" then
            constant.value = reader.read_varint();
        elseif constant_type_name == "vector" then
            constant.value = { reader.read_f32(), reader.read_f32(), reader.read_f32(), reader.read_f32() };
        end

        return constant;
    end

    local function read_debug_info(): t.ProtoDebugInfo
        local locals = reader.read_larray(function()
            return {
                name = reader.read_varint(),
                start_pc = reader.read_varint(),
                end_pc = reader.read_varint(),
                register = reader.read_u8(),
            };
        end);

        local upvalues = reader.read_larray(function()
            return {
                name = reader.read_varint(),
            };
        end);

        return {
            locals = locals,
            upvalues = upvalues,
        };
    end

    local function read_line_info(instruction_count: number): buffer
        local logspan = reader.read_u8();
        local interval_count = bit32.rshift(instruction_count - 1, logspan) + 1;
        
        local deltas = table.create(instruction_count, 0);
        local intervals = table.create(interval_count, 0);

        local last_delta = 0;
        for i = 1, instruction_count do
            last_delta = (last_delta + reader.read_u8()) % 256;
            deltas[i] = last_delta;
        end

        local last_interval = 0;
        for i = 1, interval_count do
            last_interval += reader.read_u32();
            intervals[i] = last_interval % (2 ^ 32);
        end

        local line_info = buffer.create(instruction_count * 4);
        for i = 0, instruction_count - 1 do
            local line = intervals[(i // 2^logspan) + 1] + deltas[i + 1];
            buffer.writeu32(line_info, i * 4, line);
        end

        return line_info;
    end

    --[[
        Reads a bytecode proto and returns the internal table representation.
    ]]
    local function read_proto(): t.Proto
        local max_stack_size = reader.read_u8();
        local num_params = reader.read_u8();
        local num_upvalues = reader.read_u8();
        local is_vararg = reader.read_bool();
        local flags: {string} = {};

        local raw_flags = reader.read_u8();

        for flag, offset in constants.PROTO_FLAGS :: {[string]: number} do
            if bit32.extract(raw_flags, offset) == 1 then
                table.insert(flags, flag);
            end
        end

        local types_size = reader.read_varint();
        local types;
        if types_size > 0 then
            types = {};

            local function_length = reader.read_varint();
            local upvalue_count = reader.read_varint();
            local local_count = reader.read_varint();
        
            types.func = reader.read_string(function_length);
        
            local upvalues = {};

            for i = 1, upvalue_count do
                upvalues[i] = reader.read_u8();
            end

            types.upvalues = upvalues;

            local locals = {};

            for i = 1, local_count do
                locals[i] = {
                    type = reader.read_u8(),
                    register = reader.read_u8(),
                    start_pc = reader.read_varint(),
                    length = reader.read_varint(),
                };
            end

            types.locals = locals;
        end

        local instruction_count: number = reader.read_varint();
        local instructions = reader.read_buffer(instruction_count * 4);
        local constants = reader.read_larray(read_constant);
        local child_protos = reader.read_larray(reader.read_varint);
        local line_defined: number = reader.read_varint();
        local debug_name: number = reader.read_varint();
        local line_info: buffer? = reader.read_optional(read_line_info, instruction_count) :: buffer?;
        local debug_info = reader.read_optional(read_debug_info);

        return {
            max_stack_size = max_stack_size,
            num_params = num_params,
            num_upvalues = num_upvalues,
            is_vararg = is_vararg,
            flags = flags :: {t.ProtoFlag},
            types = types,
            instructions = instructions,
            constants = constants,
            child_protos = child_protos,
            line_defined = line_defined,
            debug_name = debug_name,
            line_info = line_info,
            debug_info = debug_info,
        };
    end

    --[[
        Reads a bytecode chuck and returns the internal table representation.
    ]]
    local function read_chunk(): t.Chunk
        local luau_version = reader.read_u8();
        if luau_version == 0 then
            error("provided bytecode chunk is invalid");
        end

        local types_version = reader.read_u8();
        local strings = reader.read_larray(reader.read_lstring);
        
        local userdata_types;
        if types_version == 3 then
            userdata_types = {};
            while true do
                local i = reader.read_u8();
                if i == 0 then
                    break;
                end
                
                local name_ref = reader.read_varint();
                userdata_types[i] = name_ref;
            end
        end

        local protos = reader.read_larray(read_proto);
        local main_proto = reader.read_varint();

        return {
            luau_version = luau_version,
            types_version = types_version,
            strings = strings,
            userdata_types = userdata_types,
            protos = protos,
            main_proto = main_proto,
        };
    end

    return read_chunk();
end

--[[
    Returns a constant type id from a constant type name.
    Errors if given an invalid constant type.
]]
local function get_constant_type(constant_type: t.ConstantType): number
    for i, v in constants.CONSTANT_TYPES do
        if v == constant_type then
            return i;
        end
    end

    error(`unknown constant type '{constant_type}'`, 2);
end

local function determine_span_length(lines: buffer): number
    local span = bit32.lshift(1, 24);
    local count = buffer.len(lines) / 4;

    local offset = 0; while offset < count do
        local next = offset;

        local min = buffer.readu32(lines, offset * 4);
        local max = min;
    
        while next < count and next < offset + span do
            min = math.min(min, buffer.readu32(lines, next * 4));
            max = math.max(max, buffer.readu32(lines, next * 4));

            if max - min > 255 then
                break;
            end

            next += 1;
        end

        if next < count and next - offset < span then
            span = bit32.lshift(1, math.log(next - offset, 2));
        end
        
        offset += span;
    end

    return span;
end

--[=[
    Encodes a Chunk to a buffer.

    NOTE: This function intentionally does **not** check for validity. 
          Run `bytecode.validate` beforehand if this is desired.

    @within bytecode.chunk
]=]
function chunk.encode(chunk: t.Chunk): buffer
    local writer = byteparse.writer(100);

    local function write_constant(constant: t.Constant)
        writer.write_u8(get_constant_type(constant.type) or error("unknown constant type"));

        if constant.type == "nil" then
        elseif constant.type == "boolean" then
            writer.write_bool(constant.value);    
        elseif constant.type == "number" then
            writer.write_f64(constant.value);
        elseif constant.type == "string" then
            writer.write_varint(constant.value);
        elseif constant.type == "import" then
            writer.write_u32(constant.value);
        elseif constant.type == "table" then
            writer.write_varint(#constant.value);
            for _, v in constant.value do
                writer.write_varint(v);
            end
        elseif constant.type == "closure" then
            writer.write_varint(constant.value);
        elseif constant.type == "vector" then
            for _, v in constant.value do
                writer.write_f32(v);
            end
        end
    end

    local function write_debug_info(debug_info: t.ProtoDebugInfo)
        writer.write_varint(#debug_info.locals);
        for _, local_ in debug_info.locals do
            writer.write_varint(local_.name);
            writer.write_varint(local_.start_pc);
            writer.write_varint(local_.end_pc);
            writer.write_u8(local_.register);
        end

        writer.write_varint(#debug_info.upvalues);
        for _, upvalue in debug_info.upvalues do
            writer.write_varint(upvalue.name);
        end
    end

    local function write_line_info(lines: buffer)
        local count = buffer.len(lines) / 4;
        local span = determine_span_length(lines);

        local baseline_size = (count - 1) // span + 1;
        local baseline = buffer.create(baseline_size * 4);

        local offset = 0; while offset < count do
            local next = offset;
            local min = buffer.readu32(lines, offset * 4);

            while next < count and next < offset + span do
                min = math.min(min, buffer.readu32(lines, next * 4));
                next += 1;
            end

            buffer.writeu32(baseline, (offset // span) * 4, min);

            offset += span;
        end

        local logspan = math.log(span, 2);
        writer.write_u8(logspan);

        local last_offset = 0;
        for i = 0, count - 1 do
            local delta = buffer.readu32(lines, i * 4) - buffer.readu32(baseline, bit32.rshift(i, logspan) * 4);
            if not (delta >= 0 and delta <= 255) then
                error(`delta too large ({delta})`);
            end

            writer.write_u8(delta - last_offset);
            last_offset = delta;
        end

        local last_line = 0;
        for i = 0, baseline_size - 1 do
            local n = buffer.readu32(baseline, i * 4);
            writer.write_u32(n - last_line);
            last_line = n;
        end
    end

    local function write_type_info(type_info: t.ProtoTypeInfo?)
        if not type_info then
            writer.write_varint(0);
            return;
        end

        local temp_line_info = byteparse.writer(10);    
        temp_line_info.write_varint(#type_info.func);
        temp_line_info.write_varint(#type_info.upvalues);
        temp_line_info.write_varint(#type_info.locals);
    
        temp_line_info.write_string(type_info.func);

        for i, v in type_info.upvalues do
            temp_line_info.write_u8(v);
        end

        for i, v in type_info.locals do
            temp_line_info.write_u8(v.type);
            temp_line_info.write_u8(v.register);
            temp_line_info.write_varint(v.start_pc);
            temp_line_info.write_varint(v.length);
        end

        writer.write_varint(temp_line_info.get_size());
        writer.write_buffer(temp_line_info.to_buffer());
    end

    --[[
        writes a bytecode proto and returns the internal table representation.
    ]]
    local function write_proto(proto: t.Proto)
        writer.write_u8(proto.max_stack_size);
        writer.write_u8(proto.num_params);
        writer.write_u8(proto.num_upvalues);
        writer.write_bool(proto.is_vararg);

        local flags = 0;

        for _, flag: t.ProtoFlag in proto.flags do
            local offset = (constants.PROTO_FLAGS :: {[string]: number})[flag] or error(`unknown flag '{flag}'`);
            flags = bit32.replace(flags, 1, offset);
        end

        writer.write_u8(flags);
        write_type_info(proto.types);
        writer.write_varint(buffer.len(proto.instructions) / 4);
        writer.write_buffer(proto.instructions);
        writer.write_larray(proto.constants, write_constant);
        writer.write_larray(proto.child_protos, writer.write_varint);
        writer.write_varint(proto.line_defined);
        writer.write_varint(proto.debug_name);
        writer.write_optional(proto.line_info, write_line_info);
        writer.write_optional(proto.debug_info, write_debug_info);
    end

    --[[
        writes a bytecode chuck and returns the internal table representation.
    ]]
    local function write_chunk(chunk: t.Chunk)
        writer.write_u8(chunk.luau_version);
        writer.write_u8(chunk.types_version);
        writer.write_larray(chunk.strings, writer.write_lstring, nil);

        if chunk.types_version == 3 then
            for i, t in chunk.userdata_types or ({} :: any) do
                writer.write_u8(8);
                writer.write_varint(t);
            end

            writer.write_u8(0);
        end
        
        writer.write_larray(chunk.protos, write_proto);
        writer.write_varint(chunk.main_proto);
    end

    write_chunk(chunk);

    return writer.to_buffer();
end

--[[
    Validations to do:
    - Check jump offsets point to a valid instruction (that is, not an aux or out of bounds)
    - Versions/metadata are valid
    - References point to existing objects (strings, protos, constants)
    - Protos have return instructions
    - Instruction arguments
]]

type ReportIssueFn = (severity: t.ValidationIssueSeverity, message: string, note: string?) -> ();

--[[
    Returns whether `n` is within the inclusive range `min..max`.
]]
local function in_range(n: number, min: number, max: number)
    return n < min or n > max;
end

local function ValidationResult(issues: {t.ValidationIssue}): t.ValidationResult
    local ok = true;
    
    for _, issue in issues do 
        if issue.severity == "error" then
            ok = false;
            break;
        end
    end

    return {
        ok = ok,
        issues = issues,
    };
end

local function validate_proto(chunk: t.Chunk, proto_id: number, proto: t.Proto, report_issue: ReportIssueFn)
    
end

local function validate_chunk(chunk: t.Chunk, report_issue: ReportIssueFn)
    if in_range(chunk.luau_version, constants.SUPPORTED_VERSIONS.min, constants.SUPPORTED_VERSIONS.max) then
        report_issue("error", `luau_version ({chunk.luau_version}) is outside supported range ({constants.SUPPORTED_VERSIONS.min}..{constants.SUPPORTED_VERSIONS.max})`);
    end

    --todo: types_version
    --todo: userdata_types

    if not chunk.protos[chunk.main_proto + 1] then
        report_issue("error", `main_proto ({chunk.main_proto}) points to a non-existant proto`)
    end

    for proto_id, proto in chunk.protos do
        validate_proto(chunk, proto_id - 1, proto, report_issue);
    end
end

--[=[
    Checks a given bytecode chunk for issues.

    ### Safety

    This function does not ensure a bytecode chunk is _safe_, it just checks for
    common issues.

    @within bytecode.chunk
]=]
function chunk.validate(bc: t.IntoChunk): t.ValidationResult        
    local issues = {};

    local function report_issue(severity: t.ValidationIssueSeverity, message: string, note: string?)
        table.insert(issues, {
            severity = severity,
            message = message,
            note = note,
        });
    end
   
    report_issue("warn", "`bytecode.validate` is incomplete", "do not take a lack of issues to mean a bytecode chunk is safe"); --common.unimplemented();

    local maybechunk = bc;
    local decoded;
    if type(maybechunk) == "string" or type(maybechunk) == "buffer" then
        local ok, chunk_or_err = pcall(chunk.decode, maybechunk);
        
        if ok then
            decoded = chunk_or_err;
        else
            report_issue("error", `error when decoding chunk: {chunk_or_err}`, "this usually means the decoder was fed a non-bytecode buffer, a 'count' varint was too long or a struct had too few fields.");
            return ValidationResult(issues); -- No further diagnostics possible.
        end
    else 
        decoded = maybechunk;
    end

    validate_chunk(decoded, report_issue)
    return ValidationResult(issues);
end

return chunk;