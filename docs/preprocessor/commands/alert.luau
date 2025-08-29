return function(mode: string, body: string): string
    return string.format(
        "<div class=\"mdbook-alerts mdbook-alerts-%s\"><p class=\"mdbook-alerts-title\"><span class=\"mdbook-alerts-icon\"></span>%s</p>%s</div>", 
        mode:lower(),
        mode:lower(), 
        body
    );
end