local vector_size: number?;

local ok, val: number = pcall(function()
    return (vector.one :: any).w;
end);

if ok and val == 1 then
    vector_size = 4;
else
    vector_size = 3;
end

return { vector_size = vector_size};
