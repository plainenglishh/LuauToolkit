```luau $
local fs = require("@lune/fs");
local readme = fs.readFile("../README.md");
return readme;
```
