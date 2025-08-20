--!native

--[[
    Note: if statements are probably faster when upvalues/constructing functions
    are factored in. maybe passing arguments would be faster?
]]

local iterations = 10000;
local attempts = 10;

local lowest_time = math.huge;
local highest_time = 0;

local times: {[string]: {number}} = {
    ["if"] = table.create(100, 0),
    branch = table.create(100, 0),
};

print("running tests...")

for op = 1, 100 do
    local delta_avg = 0;

    for _ = 1, attempts do
        local start = os.clock();

        for i = 1, iterations do
            if op == 1 then
            elseif op == 2 then
            elseif op == 3 then
            elseif op == 4 then
            elseif op == 5 then
            elseif op == 6 then
            elseif op == 7 then
            elseif op == 8 then
            elseif op == 9 then
            elseif op == 10 then
            elseif op == 11 then
            elseif op == 12 then
            elseif op == 13 then
            elseif op == 14 then
            elseif op == 15 then
            elseif op == 16 then
            elseif op == 17 then
            elseif op == 18 then
            elseif op == 19 then
            elseif op == 20 then
            elseif op == 21 then
            elseif op == 22 then
            elseif op == 23 then
            elseif op == 24 then
            elseif op == 25 then
            elseif op == 26 then
            elseif op == 27 then
            elseif op == 28 then
            elseif op == 29 then
            elseif op == 30 then
            elseif op == 31 then
            elseif op == 32 then
            elseif op == 33 then
            elseif op == 34 then
            elseif op == 35 then
            elseif op == 36 then
            elseif op == 37 then
            elseif op == 38 then
            elseif op == 39 then
            elseif op == 40 then
            elseif op == 41 then
            elseif op == 42 then
            elseif op == 43 then
            elseif op == 44 then
            elseif op == 45 then
            elseif op == 46 then
            elseif op == 47 then
            elseif op == 48 then
            elseif op == 49 then
            elseif op == 50 then
            elseif op == 51 then
            elseif op == 52 then
            elseif op == 53 then
            elseif op == 54 then
            elseif op == 55 then
            elseif op == 56 then
            elseif op == 57 then
            elseif op == 58 then
            elseif op == 59 then
            elseif op == 60 then
            elseif op == 61 then
            elseif op == 62 then
            elseif op == 63 then
            elseif op == 64 then
            elseif op == 65 then
            elseif op == 66 then
            elseif op == 67 then
            elseif op == 68 then
            elseif op == 69 then
            elseif op == 70 then
            elseif op == 71 then
            elseif op == 72 then
            elseif op == 73 then
            elseif op == 74 then
            elseif op == 75 then
            elseif op == 76 then
            elseif op == 77 then
            elseif op == 78 then
            elseif op == 79 then
            elseif op == 80 then
            elseif op == 81 then
            elseif op == 82 then
            elseif op == 83 then
            elseif op == 84 then
            elseif op == 85 then
            elseif op == 86 then
            elseif op == 87 then
            elseif op == 88 then
            elseif op == 89 then
            elseif op == 90 then
            elseif op == 91 then
            elseif op == 92 then
            elseif op == 93 then
            elseif op == 94 then
            elseif op == 95 then
            elseif op == 96 then
            elseif op == 97 then
            elseif op == 98 then
            elseif op == 99 then
            elseif op == 100 then
            end
        end

        local stop = os.clock();
        delta_avg += stop - start;
    end

    delta_avg /= attempts;
    if delta_avg < lowest_time then
        lowest_time = delta_avg;
    end

    if delta_avg > highest_time then
        highest_time = delta_avg;
    end

    times["if"][op] = delta_avg;
end

type OpcodeImpl = (registers: {any}, constants: {any}, strings: {string}) -> number?;

local registers, constants, strings = {}, {}, {};
local op_branch: {OpcodeImpl} = table.create(100, function(registers: {any}, constants: {any}, strings: {string}): number?
    return 0;
end);

for op = 1, 100 do
    local delta_avg = 0;

    for _ = 1, attempts do
        local start = os.clock();

        for i = 1, iterations do
            local branch = op_branch[op] or error(`encountered unimplemented opcode {op}`);
            local jump_by = branch(registers, constants, strings);
        end

        local stop = os.clock();
        delta_avg += stop - start;
    end

    delta_avg /= attempts;
    if delta_avg < lowest_time then
        lowest_time = delta_avg;
    end

    if delta_avg > highest_time then
        highest_time = delta_avg;
    end

    times.branch[op] = delta_avg;
end

--// display

local gradient =  {
    vector.create(105 / 255, 179 / 255, 76 / 255),
    vector.create(172 / 255, 179 / 255, 52 / 255),
    vector.create(250 / 255, 183 / 255, 51 / 255),
    vector.create(255 / 255, 142 / 255, 21 / 255),
    vector.create(255 / 255, 78 / 255, 17 / 255),
    vector.create(255 / 255, 13 / 255, 13 / 255),
};

local function colour_lerp(point_a: vector, point_b: vector, a: number): vector
    return vector.create(
        point_a.x + (point_b.x - point_a.x) * a,
        point_a.y + (point_b.y - point_a.y) * a,
        point_a.z + (point_b.z - point_a.z) * a
    );
end

local function linear_gradient(stops: {vector}, a: number): vector
    local stop_len = 1 / (#stops - 1);
    local ratio = a / stop_len;
    local stopIndex = math.floor(ratio) + 1;

    if stopIndex >= #stops then
        return stops[#stops];
    end

    return colour_lerp(stops[stopIndex], stops[stopIndex + 1], ratio % 1);
end

local function format_time(delta: number)
    local alpha = math.map(delta, lowest_time, highest_time, 0, 1);
    local colour = linear_gradient(gradient, alpha);


    local start_ansi = `\x1b[38;2;{math.round(colour.x * 255)};{math.round(colour.y * 255)};{math.round(colour.z * 255)}m`;
    local end_ansi = "\x1b[0m";

    return string.format("%s%dµs%s", start_ansi, math.round((delta * 1000 * 1000) * 1000) / 1000, end_ansi);
end

for op = 1, 100 do
    local args = {};

    for name, ops in times do
        table.insert(args, `{name}={format_time(ops[op])}`)
    end
    
    print(string.format("%3i = %s, %s", op, unpack(args)));
end

print(`\nlowest={format_time(lowest_time)}, highest={format_time(highest_time)}`);
