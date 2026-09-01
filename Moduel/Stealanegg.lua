for _, t in getgc(true) do 
    if typeof(t) ~= "table" then continue end
    if getrawmetatable(t) then continue end 
    local r = false 
    for _, v in t do 
        if typeof(v) == "table" and t == v then 
            r = true 
            break 
        end 
    end
    if not r then continue end 
    local b 
    for _, v in t do 
        if typeof(v) == "number" then 
            for i = 1, 3 do 
                if v == i then 
                    b = i 
                    break 
                end 
            end 
            if b then break end 
        end 
    end 
    if b and t[b] == nil then 
        setmetatable(t, {
            __newindex = function(s, k, v)
                rconsolewarn(string.format("Blocked %s %s", k, v))
            end
        }) 
    end 
end 

local I = filtergc("table", {Keys = {"Character", "MonitorPending"}}, true)
local F = filtergc("function", {Constants = {"Character integrity sampling was intercepted"}}, true)
local U = debug.getupvalues(F)
local L = {}

for _, t in U do 
    if typeof(t) ~= "table" then continue end 
    local r = false 
    for _, v in t do 
        if typeof(v) == "table" and t == v then 
            r = true 
            break 
        end 
    end 
    local b 
    for _, v in t do 
        if typeof(v) == "number" then 
            for i = 1, 3 do 
                if v == i then 
                    b = i 
                    break 
                end 
            end 
            if b then break end 
        end 
    end 
    L[#L + 1] = t[b] 
end 

local Interval = 4 
local Tick = .05 
local Seed = L[4] 
local T = L[5] 
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Networking = ReplicatedStorage:FindFirstChild("Packages")
if not Networking then 
    rconsolewarn("Packages not found")
    return
end

local Remote = Networking:FindFirstChild("RE")
if not Remote then
    rconsolewarn("RE not found")
    return
end

local ProbeSatchel = Remote:FindFirstChild("ProbeSatchel")
if not ProbeSatchel then
    rconsolewarn("ProbeSatchel not found")
    return
end

if not ProbeSatchel:IsA("RemoteEvent") and not ProbeSatchel:IsA("RemoteFunction") then
    rconsolewarn("ProbeSatchel is not a RemoteEvent or RemoteFunction")
    return
end

task.spawn(function()
    local Remaining = math.max(0, (Interval - (os.clock() - T)))
    task.wait(Remaining)
    while true do
        Seed = Seed + Interval / Tick
        if I and I.Character then
            ProbeSatchel:FireServer(I.Character, Seed)
        end
        task.wait(Interval)
    end
end)

for _, t in getreg() do 
    if typeof(t) == "thread" then 
        local S = debug.info(t, 1, "s") 
        if S and S:find("ContentCatalog") then 
            coroutine.close(t) 
        end 
    end 
end 

local Hook = function() end 
for _, f in getgc(false) do 
    if typeof(f) == "function" then 
        local S = debug.info(f, "s") 
        if S and S:find("ContentCatalog") then 
            hookfunction(f, Hook) 
        end 
    end 
end
