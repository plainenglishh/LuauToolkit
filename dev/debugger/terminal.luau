local process = require("@lune/process");
local stdio = require("@lune/stdio");

local NEWLINE = string.byte("\n");
local SPACE = string.byte(" ");
local DASH = string.byte("-");
local PLUS = string.byte("+");
local BAR = string.byte("|");
local X = string.byte("X");

local function strip_ansi(str: string): string
    local a = str:gsub("\x1b%[[0-9;]*[A-Za-z]", "");
    return a;
end

local terminal = {};

--[=[
    Returns the terminal `width` and `height` as a tuple.
]=]
function terminal.size(): (number, number)
    local res = process.exec("cmd.exe", {"/C", "mode con:"});

    if not res.ok then 
        error("couldn't get terminal size")
    end

    local width = tonumber(string.match(res.stdout, "Columns:%s*(%d+)")) or error("couldn't get terminal size");
    local height = tonumber(string.match(res.stdout, "Lines:%s*(%d+)")) or error("couldn't get terminal size");

    return width, height;
end

type Entity = {
    position: vector,
    size: vector,
    z_offset: number,
    data: buffer,
};

export type TuiRawFrameOptions = {
    position: vector,
    size: vector,
    z_offset: number?,
    title: string?,
    data: buffer?,
};

export type TuiTextFrameOptions = {
    position: vector,
    size: vector,
    z_offset: number?,
    title: string?,
    text: string | buffer | {string}?,
    wrap_text: boolean?,
};

export type Tui = {
    debug_box: (position: vector, size: vector) -> (),
    raw_frame: (options: TuiRawFrameOptions) -> (),
    text_frame: (options: TuiTextFrameOptions) -> (),
    generate: () -> buffer,
    render: () -> (),
};


--[=[
    Creates a new `Tui` object.
]=]
function terminal.create_tui(width: number, height: number): Tui
    local entities: {Entity} = {};

    local function get_offset(x: number, y: number, width: number): number
        return (y * width) + x;
    end

    local function create_entity(position: vector, size: vector, z_offset: number?): Entity  
        local entity = {
            position = position,
            size = size,
            z_offset = z_offset or 0,
            data = buffer.create(size.x * size.y),
        };
        buffer.fill(entity.data, 0, SPACE);
        table.insert(entities, entity);
        return entity;
    end

    local tui = {};

    function tui.debug_box(position: vector, size: vector)
        local entity = create_entity(position, size);
        for i = 0, (size.x * size.y) - 1 do
            local n = string.byte(tostring(i % 10));
            buffer.writeu8(entity.data, i, n);
        end
    end

    function tui.raw_frame(options: TuiRawFrameOptions)
        local entity = create_entity(options.position, options.size, options.z_offset);
        
        --// draw borders
        buffer.writeu8(entity.data, get_offset(0, 0, entity.size.x), PLUS);
        buffer.writeu8(entity.data, get_offset(entity.size.x - 1, 0, entity.size.x), PLUS);
        buffer.writeu8(entity.data, get_offset(0, entity.size.y - 1, entity.size.x), PLUS);
        buffer.writeu8(entity.data, get_offset(entity.size.x - 1, entity.size.y - 1, entity.size.x), PLUS);

        buffer.fill(entity.data, 1, DASH, entity.size.x - 2);
        buffer.fill(entity.data, get_offset(1, entity.size.y - 1, entity.size.x), DASH, entity.size.x - 2);
    
        for i = 1, entity.size.y - 2 do
            buffer.writeu8(entity.data, get_offset(0, i, entity.size.x), BAR);
            buffer.writeu8(entity.data, get_offset(entity.size.x - 1, i, entity.size.x), BAR);
        end

        --// draw title
        if options.title then
            local title = `[ {options.title} ]`;
            local offset = (entity.size.x - #title) // 2;
            buffer.writestring(entity.data, offset, title);
        end

        --// draw data
        if options.data then
            local data_width, data_height = options.size.x - 2, options.size.y - 2;
            local expected_size = data_width * data_height;
            assert(buffer.len(options.data) == expected_size, "invalid data size");
            
            for row = 0, data_height - 1 do 
                local target_offset = get_offset(1, row + 1, options.size.x);
                local source_offset = get_offset(0, row, data_width);
                buffer.copy(entity.data, target_offset, options.data, source_offset, data_width);
            end
        end
    end

    -- fix woke alignment! control chars may play a role ?
    function tui.text_frame(options: TuiTextFrameOptions)
        local text: buffer;

        if type(options.text) == "nil" then
            text = buffer.create(0);
        elseif type(options.text) == "buffer" then
            text = options.text;
        elseif type(options.text) == "string" then
            text = buffer.fromstring(options.text);
        elseif type(options.text) == "table" then
            local lines = table.clone(options.text);
            for i, v in lines do 
                lines[i] = string.gsub(v, ".*(\r?\n)$", "");
            end
            text = buffer.fromstring(table.concat(options.text, "\n"));
        end
        
        local text_len = buffer.len(text);

        local data_width = options.size.x - 2;
        local data_height = options.size.y - 2;
        local data = buffer.create(data_width * data_height);
        buffer.fill(data, 0, SPACE);

        local x, y = 0, 0;
        local offset = 0;
        while offset < text_len do
            local char = buffer.readu8(text, offset);

            if y >= data_height then
                break;
            end

            if char == NEWLINE then
                x = 0;
                y += 1;
            elseif char == string.byte("\t") then
                x += 4;
            elseif x >= data_width then
                x = 0;
                y += 1;

                if not options.wrap_text then
                    while offset < text_len do
                        if buffer.readu8(text, offset) == NEWLINE then
                            break;
                        else  
                            offset += 1;
                        end
                    end
                end
            elseif char >= 32 and char <= 126 then
                buffer.writeu8(data, get_offset(x, y, data_width), char);
                x += 1;
            end

            offset += 1;
        end

        -- map grid over raw frame contents (just trim x and y).
        -- TODO: consider text alignment and padding, assume no padding and top-left align for now.

        tui.raw_frame({
            position = options.position,
            size = options.size,
            z_offset = options.z_offset,
            title = options.title,
            data = data,
        });
    end

    local fb = buffer.create(width * height);
    buffer.fill(fb, 0, SPACE);

    function tui.generate(): buffer
        table.sort(entities, function(a: Entity, b: Entity): boolean
            return a.z_offset > b.z_offset;
        end);
    
        for _, entity in entities do
            for row = 0, entity.size.y - 1 do
                local top_left = get_offset(entity.position.x, entity.position.y + row, width);
                buffer.copy(fb, top_left, entity.data, row * entity.size.x, entity.size.x);
            end
        end

        table.clear(entities);
        return fb;
    end

    function tui.render()
        stdio.write("\x1b[H"..buffer.tostring(tui.generate()));
    end

    return tui;
end

return terminal;
