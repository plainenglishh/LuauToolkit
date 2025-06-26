local t = require("../types");

local function strip_unreferenced_strings(chunk: t.BytecodeChunk)
    local function is_referenced(string_id: number)
        for _, proto in chunk.protos do
            if proto.debug_name == string_id then
                return true;
            end

            for _, const in proto.constants do
                if const.type == "string" and const.value == string_id then
                    return true;
                end
            end
        end

        return false;
    end

    local replacement_map = {};
    local new_string_table = {};

    for string_id, string_value in chunk.strings do
        if is_referenced(string_id) then
            local new_string_id = #new_string_table + 1;
            new_string_table[new_string_id] = string_value;
            replacement_map[string_id] = new_string_id;
        end
    end

    for _, proto in chunk.protos do
        if proto.debug_name ~= 0 then
            proto.debug_name = replacement_map[proto.debug_name] or error(`unknown string`);
        end

        for _, const in proto.constants do
            if const.type == "string" and const.value ~= 0 then
                const.value = replacement_map[const.value] or error(`unknown string`);
            end
        end
    end

    chunk.strings = new_string_table;
end

return strip_unreferenced_strings;