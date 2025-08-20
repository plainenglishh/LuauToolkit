local common = {};

function common.get_table_parts(tbl: {[any]: any})
    local array_part = {};
    local hash_part = {};
    local next_num = 0;

    local hash_size = 0;
    local array_size = 0;

    for k, v in tbl do
        if type(k) == "number" then
            next_num += 1;
            
            if next_num == k then
                array_size += 1;
                array_part[k] = v;
            else
                hash_size += 1;
                hash_part[hash_size] = {k, v};
            end
        else
            hash_size += 1;
            hash_part[hash_size] = {k, v};
        end
    end

    return {
        hash = hash_part,
        array = array_part,
        hash_size = hash_size,
        array_size = array_size,
    };
end

function common.display_chunk_name(chunk_name: string): string
    local prefix = string.sub(chunk_name, 1, 1);
    if prefix == "=" or prefix == "@" then
        return string.sub(chunk_name, 2);
    end

    return `[string "{chunk_name}"]`;
end

function common.strip_error_prefix(str: string): string
    local prefix, message = string.match(str, "^(.-):%d+: (.+)$");
    if not prefix or not message then
        return str;
    end

    return message;
end

function common.unimplemented()
    error("unimplemented", 2);
end

common.stdlib = require("@self/stdlib");
common.iteration = require("@self/iteration");
common.confusables = require("@self/confusables");

local StringBuilder = require("@self/StringBuilder");
export type StringBuilder = StringBuilder.StringBuilder;
common.StringBuilder = StringBuilder;

--common.hash = require("@self/hash");
common.VECTOR_SIZE = require("@self/vector_size").vector_size;

--// Vendored Dependencies
common.int64 = require("@self/int64");
common.byteparse = require("@self/byteparse");

return common;
