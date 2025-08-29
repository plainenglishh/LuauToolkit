local commands = {};

commands.alert = require("@self/alert");
commands.require = function()
    error("require is forbidden.");
end

commands.fs = require("@lune/fs");
commands.net = require("@lune/net");
commands.process = require("@lune/process");
commands.regex = require("@lune/regex");
commands.serde = require("@lune/serde");

return commands;
