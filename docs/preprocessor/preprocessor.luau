local process = require("@lune/process")
local serde = require("@lune/serde")
local stdio = require("@lune/stdio")

export type Context = {
    read root: string,
    read config: {
        read book: {
            read authors: {string},
            read language: string,
            read multilingual: boolean,
            read src: string,
            read title: string,
        },
        read build: {
            read ["build-dir"]: string,
            read ["create-missing"]: string,
            read ["extra-watch-dirs"]: {string},
            read ["use-default-preprocessors"]: boolean,
        },
        read preprocessor: {[string]: {
            read command: string,
        }
    }},
    read renderer: string,
    read mdbook_version: string,
};

export type Chapter = {
    name: string,
    content: string,
    number: {number}?,
    sub_items: {{Chapter: Chapter}},
    path: string,
    source_path: string,
    parent_names: {string},
};

export type Book = {
    sections: {{Chapter: Chapter}},
};

local function supports(renderers: {string}?)
    if process.args[1] ~= "supports" then
        return;
    end

    if not renderers then
        process.exit(0);
        return;
    end

    local renderer = process.args[2];
    if not table.find(renderers, renderer) then
        process.exit(1);
    else
        process.exit(0);
    end
end

export type BookProcessor = (ctx: Context, book: Book) -> ();
export type ChapterProcessor = (ctx: Context, chapter: Chapter, book: Book) -> ();

export type Preprocessor = setmetatable<{
    _supports: {string}?,
    _book_steps: {BookProcessor},
    _chapter_steps: {ChapterProcessor},
}, {
    __index: getmetatable<Preprocessor>,

    new: () -> Preprocessor,
    supports: (self: Preprocessor, renderers: {string}) -> Preprocessor,
    process_book: (self: Preprocessor, processor: BookProcessor) -> Preprocessor,
    process_chapter: (self: Preprocessor, processor: ChapterProcessor) -> Preprocessor,
    run: (self: Preprocessor) -> (),
}>;

local Preprocessor = {};
Preprocessor.__index = Preprocessor;

function Preprocessor.new(): Preprocessor
    return setmetatable({
        _supports = nil :: {string}?,
        _book_steps = {},
        _chapter_steps = {},
    }, Preprocessor);
end

function Preprocessor.supports(self: Preprocessor, renders: {string}): Preprocessor
    self._supports = renders;
    return self;
end

function Preprocessor.process_book(self: Preprocessor, processor: BookProcessor): Preprocessor
    table.insert(self._book_steps, processor);
    return self;
end

function Preprocessor.process_chapter(self: Preprocessor, processor: ChapterProcessor): Preprocessor
    table.insert(self._chapter_steps, processor);
    return self;
end

function Preprocessor.run(self: Preprocessor)
    supports(self._supports);

    local raw = stdio.readToEnd();  
    local ctx: Context, book: Book = unpack(serde.decode("json", raw));

    for _, processor in self._book_steps do
        processor(ctx, book);
    end

    local function process_chapter(chapter: Chapter)
        for _, processor in self._chapter_steps do
            processor(ctx, chapter, book);
        end

        for _, sub_chapter in chapter.sub_items do
            process_chapter(sub_chapter.Chapter);
        end
    end

    for _, section in book.sections do
        process_chapter(section.Chapter);
    end

    (book :: any)["__non_exhaustive"] = "null";
    local encoded = serde.encode("json", book, true);
    encoded = encoded:gsub(`"parent_names": \{}`, `"parent_names": []`);
    encoded = encoded:gsub(`"sub_items": \{}`, `"sub_items": []`);
    encoded = encoded:gsub(`"__non_exhaustive": "null"`, `"__non_exhaustive": null`);
    stdio.write(encoded);
end

return Preprocessor;
