local luau = require("@lune/luau");
local Preprocessor = require("@self/preprocessor");
local commands = require("@self/commands");
local INJECT = require("@self/inject");

Preprocessor.new()
    :process_chapter(function(ctx: Preprocessor.Context, chapter: Preprocessor.Chapter, book: Preprocessor.Book)
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
    end)
    :run();
