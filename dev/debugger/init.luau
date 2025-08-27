--[[
    A simple debugger for testing `loadstring`.
]]
    
--!native
local LOG_SIZE = 10;
local INFO_SIZE = 10;

local bytecode = require("@luau_toolkit/bytecode");
local common = require("@luau_toolkit/common")
local fs = require("@lune/fs");
local luau = require("@lune/luau");
local process = require("@lune/process"); assert(process.os == "windows", "windows only for now -- sorry!");
local stdio = require("@lune/stdio");
local loadstring = require("@luau_toolkit/loadstring");
local terminal = require("@self/terminal");

local script_path = process.args[1];
local raw_src = fs.readFile(script_path);
local ok, bc = pcall(luau.compile, raw_src, {
    debugLevel = 2,
    optimizationLevel = 2,
} :: luau.CompileOptions);

if not ok then
    stdio.ewrite(bc);
    process.exit(1);
end

local chunk = bytecode.chunk.decode(bc);
local src = string.split(raw_src, "\n");


local luau_output_logs = {};

local function luau_output(msg: any)
    table.insert(luau_output_logs, tostring(msg));
end

local print_logs = {};
local function print(msg: any)
    table.insert(print_logs, tostring(msg));
end


local frame: loadstring.DebugFrame;
local vm = coroutine.create(function()
    local env: any = table.clone(common.stdlib);
    env.print = luau_output;
    loadstring(bc, {
        step = function(debug: loadstring.DebugFrame)
            frame = debug;
            coroutine.yield();
        end,
        env = env,
        debug_name = `@{script_path}`,
    })();
end);

coroutine.resume(vm);

local function step()
    if coroutine.status(vm) == "dead" then
        print("script has finished");
        return;
    end

    local ok, err = coroutine.resume(vm);
    if not ok then
        luau_output(string.gsub(err, "runtime error: ", ""));
    end

    if coroutine.status(vm) == "dead" then
        print("finished");
    end
end

local function handle_input()
    stdio.write("> ");
    local cmd = string.match(stdio.readLine(), "^%s*(.-)%s*$") or "";
    
    if cmd ~= "" then
        print("> " .. cmd);
    end

    if cmd:lower() == "q" then
        print("quitting debugger...");
        process.exit(0);
    elseif cmd:lower() == "s" or cmd == "" then
        step();
    elseif string.sub(cmd:lower(), 1, 1) == "r" then
        local raw = string.sub(cmd, 2, -1);
        local n = tonumber(raw);
        if not n then
            print(`invalid register '{raw}'`);
            return;
        end

        print(tostring(frame.registers[n + 1]));
    end
end

local width, height = terminal.size();
height -= 1;
local tui = terminal.create_tui(width, height);

local function update()    
    local proto = chunk.protos[frame.proto + 1];

    local bytecode_lines = {};
    local src_lines = {};
    
    local code = proto.instructions;
    local codesize = buffer.len(proto.instructions) / 4;

    local next_aux = false;
    for i = 0, codesize - 1 do
        if next_aux then
            next_aux = false;
            continue;
        end

        local insn = buffer.readu32(code, i * 4);
        local next_insn;
        if i + 1 < codesize then 
            next_insn = buffer.readu32(code, (i + 1) * 4);
        end
        
        local info = bytecode.instructions.decode_instruction(insn, next_insn);
        if info.aux then
            next_aux = true;
        end

        local metadata = bytecode.instructions.metadata[info.opcode];

        table.insert(bytecode_lines, string.format("%s%i: %s", if i == frame.pc then ">" else " ", i, metadata.name));
    end

    for line, text in src do 
        src_lines[line] = string.format("%s%i: %s", if line == frame.line then ">" else " ", line, text);
    end
    
    local ok, err = pcall(function()
        tui.text_frame({
            position = vector.create(0, 0),
            size = vector.create(math.round(width * 0.5), math.round(height * 0.5)),
            title = "bytecode",
            text = bytecode_lines,
        });

        tui.text_frame({
            position = vector.create(math.round(width * 0.5) - 1, 0),
            size = vector.create(math.round(width * 0.5) + 1, math.round(height * 0.5)),
            title = "source",
            text = src_lines,
        });

        tui.text_frame({
            position = vector.create(0, math.round(height * 0.5) - 1),
            size = vector.create(math.round(width * 0.5), math.round(height * 0.5) + 1),
            title = "console",
            text = print_logs,
            wrap_text = true
        });
        
        tui.text_frame({
            position = vector.create(math.round(width * 0.5) - 1, math.round(height * 0.5) - 1),
            size = vector.create(math.round(width * 0.5) + 1, math.round(height * 0.5) + 1),
            title = "output",
            text = luau_output_logs,
            wrap_text = true
        });

        tui.render();

        handle_input();
        return nil;
    end);
    if not ok then
        print(err);
        error()
    end
end

while true do
    update();
end
