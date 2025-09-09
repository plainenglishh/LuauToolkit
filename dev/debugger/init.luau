--[[
    A simple debugger for testing `loadstring`.
]]
    
--!native


local bytecode = require("@luau_toolkit/bytecode");
local common = require("@luau_toolkit/common");
local loadstring = require("@luau_toolkit/loadstring");
local fs = require("@lune/fs");
local luau = require("@lune/luau");
local stdio = require("@lune/stdio");
local terminal = require("@self/terminal");

local process = require("@lune/process"); assert(process.os == "windows", "windows only for now -- sorry!");

local script_path = process.args[1] or error("specify script to debug");
local raw_src = fs.readFile(script_path);
local ok, bc = pcall(luau.compile :: any, raw_src, {
    debugLevel = 2,
    optimizationLevel = 1,
} :: luau.CompileOptions);

if not ok then
    stdio.ewrite(bc);
    process.exit(1);
end

local src = string.split(raw_src, "\n");

local luau_output_logs = {};

local function luau_output(...)
    table.insert(luau_output_logs, table.concat({...}, " "));
end

local repl_logs = {};
local function write(msg: any)
    table.insert(repl_logs, tostring(msg));
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
        write("script has finished");
        return;
    end

    local ok, err = coroutine.resume(vm :: any);
    if not ok then
        luau_output(string.gsub(err, "runtime error: ", ""));
    end

    if coroutine.status(vm) == "dead" then
        write("finished");
    end
end

local function pcall_or(...: {any}): (boolean, any)
    local ok, err
    for _, v in {...} do
        local callable: any = table.remove(v, 1);
        ok, err = pcall(callable, unpack(v));
        if ok then
            return true, err;
        end
    end

    return false, err;
end

local function format(values: {[number]: any, n: number}): string
    local output = {};
    for i = 1, values.n - 1 do -- First value is pcall success
        table.insert(output, stdio.format(values[i]));
    end

    return table.concat(output, "");
end

local function wrap_array(tbl: any, start_idx: number, name: string): any
    return setmetatable({}, {
        __index = function(_, idx)
            if type(idx) ~= "number" then 
                error("attempt to index array with non-number");
            end

            return tbl[1 + (idx - start_idx)];
        end,
        __newindex = function(_, idx, value)
            if type(idx) ~= "number" then 
                error("attempt to index array with non-number");
            end
            
            tbl[1 + (idx - start_idx)] = value;
        end,
        __tostring = `<{name}>`,
    })
end

local function repl()
    stdio.write("> ");

    local src = string.match(stdio.readLine(), "^%s*(.-)%s*$") or "";
    local cmd = string.lower(src);

    if src ~= "" then
        write("> " .. src);
    end

    if cmd == "exit" then
        write("quitting debugger...");
        process.exit(0);
    elseif cmd == "step" or src == "" then
        step();
    else
        local ok, repl_src = pcall_or({luau.compile, "return " .. src}, {luau.compile, src});
        if not ok then
            write(repl_src);
            return;
        end

        local values = table.pack(pcall(function()
            return luau.load(repl_src, {
                environment = {
                    R = wrap_array(frame.registers, 0, "registers"),
                    K = wrap_array(frame.constants, 0, "constants"),
                    U = wrap_array(frame.upvalues, 0, "upvalues"),
                    print = luau_output,
                },
                injectGlobals = true,
                debugName = "=repl",
            })();
        end));

        local ok = table.remove(values, 1);
        local err = values[1];

        if not ok then
            write(err, 1);
            return;
        else
            if values.n > 1 then 
                write(format(values));
            end
        end
    end
end

local width, height = terminal.size();
height -= 1;
local tui = terminal.create_tui(width, height);

local function update()    
    local proto = frame.proto;

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

        --local metadata = bytecode.instructions.metadata[info.opcode];
        table.insert(bytecode_lines, string.format("%s%i: %s", if i == frame.pc then ">" else " ", i, bytecode.instructions.display(insn, next_insn)));
    end

    local ok, err = pcall(function()
        tui.text_frame({
            position = vector.create(0, 0),
            size = vector.create(math.floor(width * 0.4), math.floor(height * 0.5)),
            title = "Bytecode",
            text = bytecode_lines,
        });

        for line, text in src do 
            src_lines[line] = string.format("%s%i: %s", if line == frame.line then ">" else " ", line, text);
        end
    
        tui.text_frame({
            position = vector.create(math.floor(width * 0.4) - 1, 0),
            size = vector.create(math.floor(width * 0.4) + 1, math.floor(height * 0.5)),
            title = "Source",
            text = src_lines,
        });

        local registers = {};

        for i, v in frame.registers do
            registers[i] = `R{i-1}: ({type(v)}) {tostring(v)}` 
        end

        tui.text_frame({
            position = vector.create(math.floor(width * 0.8) - 1, 0),
            size = vector.create(math.floor(width * 0.2) + 2, math.floor(height * 0.4)),
            title = "Registers",
            text = registers,
        });

        tui.text_frame({
            position = vector.create(0, math.floor(height * 0.5) - 1),
            size = vector.create(math.floor(width * 0.4), math.floor(height * 0.5) + 1),
            title = "REPL",
            text = repl_logs,
            wrap_text = true
        });
        
        tui.text_frame({
            position = vector.create(math.floor(width * 0.4) - 1, math.floor(height * 0.5) - 1),
            size = vector.create(math.floor(width * 0.4) + 1, math.floor(height * 0.5) + 1),
            title = "Output",
            text = luau_output_logs,
            wrap_text = true
        });

        local constants = {};

        for i, v in frame.constants do
            constants[i] = `K{i-1}: ({type(v)}) {tostring(v)}` 
        end

        tui.text_frame({
            position = vector.create(math.floor(width * 0.8) - 1, math.floor(height * 0.4) - 1),
            size = vector.create(math.floor(width * 0.2) + 2, math.floor(height * 0.4) + 1),
            title = "Constants",
            text = constants,
        });

        tui.text_frame({
            position = vector.create(math.floor(width * 0.8) - 1, math.floor(height * 0.8) - 1),
            size = vector.create(math.floor(width * 0.2) + 2, math.floor(height * 0.2) + 2),
            title = "Metadata",
            text = {
                `PC: {frame.pc}`,
                `Line: {frame.line}`,
                `Chunk Name: '{frame.debug_name}'`,
                `Function: P{frame.proto_id} '{frame.chunk.strings[proto.debug_name] or "<anonymous>"}'`,
            },
        });

        tui.render();

        repl();
        return nil;
    end);
    if not ok then
        write(err);
        error()
    end
end

while true do
    update();
end
