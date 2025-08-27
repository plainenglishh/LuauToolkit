local function strip_where(str: string): string
    local prefix, message = string.match(str, "^(.-):%d+: (.+)$");
    if not prefix or not message then
        return str;
    end

    return message;
end

return strip_where;