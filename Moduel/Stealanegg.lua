for _, obj in getgc(true) do
    if typeof(obj) ~= "table" or getrawmetatable(obj) then continue end
    local mainrun = false
    for _, v in obj do
        if v == obj then mainrun = true break end
    end
    if not mainrun then continue end
    for _, v in obj do
        if typeof(v) == "number" and v >= 1 and v <= 3 and obj[v] == nil then
            setmetatable(obj, {__newindex = function() end})
            break
        end
    end
end
