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

function common.unimplemented()
    error("unimplemented", 2);
end
 
return common;
