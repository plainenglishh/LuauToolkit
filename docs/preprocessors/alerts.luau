local Preprocessor = require("./preprocessor");

local function process(ctx: Preprocessor.Context, book: Preprocessor.Book): Preprocessor.Book
    return book;
end

Preprocessor.new()
    :process_book(process)
    :run();