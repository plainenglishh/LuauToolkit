local common = require("@luau_toolkit/common");
local process = require("@lune/process");
local stdio = require("@lune/stdio");

local json = common.json;

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
    kind: "chapter",
    name: string,
    content: string,
    number: {number}?,
    sub_items: {BookItem},
    path: string?,
    source_path: string?,
    parent_names: {string},
};

export type Separator = {
    kind: "separator",
};

export type PartTitle = {
    kind: "part_title",
    title: string,
};

export type BookItem = Chapter | Separator | PartTitle;

export type Book = {
    sections: {BookItem},
};

local function decode_book(raw_book: any): Book
    local function decode_book_item(book_item: any): BookItem
        if book_item == "Separator" then 
            return { kind = "separator" };
        elseif book_item.Chapter then
            local sub_items: {BookItem} = {};

            for i: number, sub_item in book_item.Chapter.sub_items do
                sub_items[i] = decode_book_item(sub_item);
            end

            return {
                kind = "chapter",
                name = book_item.Chapter.name :: string,
                content = book_item.Chapter.content :: string,
                number = book_item.Chapter.number :: {number}?,
                sub_items = sub_items,
                path = book_item.Chapter.path :: string?,
                source_path = book_item.Chapter.source_path :: string?,
                parent_names = book_item.Chapter.parent_names :: {string},
            };
        elseif book_item.PartTitle then
            return { kind = "part_title", title = book_item.PartTitle :: string }
        else
            error("unknown book item");
        end
    end

    local sections: {BookItem} = {};
    for i: number, section in raw_book.sections do
        sections[i] = decode_book_item(section);
    end

    return {
        sections = sections
    };
end

local function encode_book(book: Book): string
    local function encode_book_item(book_item: BookItem): any
        if book_item.kind == "separator" then
            return "Separator";
        elseif book_item.kind == "part_title" then
            return { PartTitle = book_item.title };
        elseif book_item.kind == "chapter" then
            local sub_items = {};
            for i, book_item in book_item.sub_items do
                sub_items[i] = encode_book_item(book_item);
            end
            
            return {
                Chapter = {
                    name = book_item.name,
                    content = book_item.content,
                    number = json.set_json_type(book_item.number, "array"),
                    sub_items = json.set_json_type(sub_items, "array"),
                    path = book_item.path,
                    source_path = book_item.source_path,
                    parent_names = json.set_json_type(book_item.parent_names, "array"),
                },
            };
        else
            error(`invalid book_item {book_item.kind}`);
        end
    end
    
    local sections = {};
    for i, book_item in book.sections do
        sections[i] = encode_book_item(book_item);
    end

    local raw_book = {
        sections = json.set_json_type(sections, "array"),
        __non_exhaustive = common.json.null,
    };

    return buffer.tostring(json.encode(raw_book));
end

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
    local ctx: Context, raw_book: any = unpack(common.json.decode(raw) :: any);
    local book = decode_book(raw_book);

    for _, book_step in self._book_steps do
        book_step(ctx, book);
    end

    local function process_chapter(chapter: Chapter)
        for _, chapter_step in self._chapter_steps do
            chapter_step(ctx, chapter, book);
        end

        for _, sub_item in chapter.sub_items do
            if sub_item.kind == "chapter" then
                process_chapter(sub_item);
            end
        end
    end

    for _, section in book.sections do
        if section.kind == "chapter" then
            process_chapter(section);
        end
    end

    stdio.write(encode_book(book));
end

return Preprocessor;
