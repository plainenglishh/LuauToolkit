local luau = require("@lune/luau");
local mdbook = require("@mdbook.luau/");
local commands = require("@self/commands");
local INJECT = require("@self/inject");

local preprocessor = mdbook.Preprocessor.new("ltk_docs");

for _, chapter in preprocessor:chapters() do
    chapter.content = INJECT .. string.gsub(chapter.content, "```luau $\r?\n(.-)```", function(source: string): string
        local prefix = "";
        if string.sub(source, 1, 1) == "=" then
            prefix = "return ";
            source = string.sub(source, 2);
        end

        local result = luau.load(prefix .. source, {
            environment = commands :: any,
            injectGlobals = true,
            debugName = "=command",
        })();
            
        if type(result) == "buffer" then
            return buffer.tostring(result);
        else
            return tostring(result);
        end
    end :: any);
end

preprocessor:finish();
