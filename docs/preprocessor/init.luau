local luau = require("@lune/luau");
local mdbook = require("@mdbook.luau/");
local commands = require("@self/commands");
local alert = require("@self/commands/alert")
local INJECT = require("@self/inject");

local preprocessor = mdbook.Preprocessor.new("ltk_docs");

for _, chapter in preprocessor:chapters() do
    if chapter.source_path == nil then
        return;
    end

    local resolved = {};

    for source in string.gmatch(chapter.content, "```luau $\r?\n(.-)```") do
        local prefix = "";
        if string.sub(source, 1, 1) == "=" then
            prefix = "return ";
            source = string.sub(source, 2);
        end

        local result = luau.load(prefix .. source, {
            environment = commands :: any,
            injectGlobals = true,
            debugName = `@{chapter.source_path}`,
        })();
            
        if type(result) == "buffer" then
            resolved[source] = buffer.tostring(result);
        else
            resolved[source] = tostring(result);
        end
    end

    chapter.content = INJECT .. string.gsub(chapter.content, "```luau $\r?\n(.-)```", function(source: string): string
        return resolved[source] or alert("CAUTION", `Failed to execute Luau script:\n\`\`\`luau\n{source}\`\`\``);
    end :: any);
end

preprocessor:finish();
