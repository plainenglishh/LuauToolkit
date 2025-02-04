local fs = require("@lune/fs");
local stdio = require("@lune/stdio");
local process = require("@lune/process");
local bytecode = require("../../lib");

local RST = stdio.color("reset");
local BOLD = stdio.style("bold");

return function(file_path: string)
    if not file_path then
        stdio.ewrite("specify file");
        process.exit(1);
    end

    if not fs.isFile(file_path) then
        stdio.ewrite(`no file '{file_path}'`);
        process.exit(1);
    end

    local bc=  fs.readFile(file_path);
    local chunk = bytecode.decode(bc);

    print(`luau_version:  {chunk.luau_version}`);
    print(`types_version: {chunk.types_version}`);
    print(`\nstrings ({#chunk.strings}):`);
    for i, str in chunk.strings do
        print(`    S{i}: "{stdio.format(str)}",`);
    end

    print(`\nprotos: ({#chunk.protos}):`);
    for fake_i, proto in chunk.protos do
        local i = fake_i - 1;
        
        local main_tag = if chunk.main_proto == i then " (main)" else "";
        local name_tag = if proto.debug_name ~= 0 then ` "{chunk.strings[proto.debug_name]}"` else " <anonymous>";
        print(`    P{i}{name_tag}{main_tag}:`);
        print(`    |   debug_name:     {if proto.debug_name ~= 0 then `"{chunk.strings[proto.debug_name]}"` else "none"}`);
        print(`    |   num_params:     {proto.num_params}`);
        print(`    |   num_upvalues:   {proto.num_upvalues}`);
        print(`    |   is_vararg:      {proto.is_vararg}`);
        print(`    |   max_stack_size: {proto.max_stack_size}`);

        local flags;
        for i, flag in proto.flags do
            if not flags then
                flags = "";
            end
            if i ~= 1 then
                flags ..= ", "
            end
            flags ..= `{flag}`;
        end

        print(`    |   flags:          {flags or "none"}`);
        print(`    |   line_defined:   {proto.line_defined}`);
        print(`    |   has_line_info:  {proto.line_info ~= nil}`);
        print(`    |   has_debug_info: {proto.debug_info ~= nil}`);

        local child_protos;
        for i, flag in proto.protos do
            if not child_protos then
                child_protos = "";
            end
            if i ~= 1 then
                child_protos ..= ", "
            end
            child_protos ..= `{flag}`;
        end
        print(`    |   child_protos:   {child_protos or "none"}`);
    end
end
