local common = {};

function common.find_from_0(haystack: {[number]: any}, needle: any): number?
    for i = 0, #haystack do
        if haystack[i] == needle then
            return i;
        end
    end

    return nil;
end

return common;