local Preprocessor = require("@self/preprocessor");
local commands = require("@self/commands");
local INJECT = require("@self/inject");

Preprocessor.new()
    :process_chapter(function(ctx: Preprocessor.Context, chapter: Preprocessor.Chapter, book: Preprocessor.Book)
        chapter.content = INJECT .. string.gsub(chapter.content,  "{{#(%w*)%s*(.-)}}", function(name: string, args: string): string
            local command = commands[name];
            if not command then
                return nil :: any;
            end

            return command(args);
        end :: any);
    end)
    :run();
