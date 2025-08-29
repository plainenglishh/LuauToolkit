return function(args: string): string
    local parts = string.split(args, " ");
    local mode = string.lower(table.remove(parts, 1) or error("scott de wozzler"));
    local body = table.concat(parts, " ");

    return string.format(
        "<div class=\"mdbook-alerts mdbook-alerts-%s\"><p class=\"mdbook-alerts-title\"><span class=\"mdbook-alerts-icon\"></span>%s</p>%s</div>", 
        mode,
        mode, 
        body
    );
end