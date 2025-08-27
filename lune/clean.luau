local fs = require("@lune/fs");

if fs.isDir("./dist") then
    fs.removeDir("./dist/");
end
