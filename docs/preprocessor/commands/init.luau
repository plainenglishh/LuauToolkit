local commands: {[string]: (args: string) -> string} = {};

commands.alert = require("@self/alert");

return commands;
