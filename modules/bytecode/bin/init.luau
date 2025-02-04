local process = require("@lune/process");
local stdio = require("@lune/stdio");

local args = table.clone(process.args);
local command = args[1];

local commands = {
    info = require("./commands/info"),
};

if not command then
    stdio.ewrite("specify command");
    process.exit(1);
end

local command_fn = commands[command];
if not command_fn then
    stdio.ewrite(`unknown command '{command}'`);
    process.exit(1);
end

table.remove(args, 1);

command_fn(unpack(args));
