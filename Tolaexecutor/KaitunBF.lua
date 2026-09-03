local webhookURL = "https://api.bacon-hub.xyz/webhook/kaitunbf"

local function getHWID()
    local ok, hwid = pcall(function()
        return game:GetService("RbxAnalyticsService"):GetClientId()
    end)
    return ok and hwid or "Unknown"
end

local function getExecutor()
    local ok, name, ver = pcall(identifyexecutor)
    if ok and name then
        return ver and (name .. " " .. tostring(ver)) or name
    end
    return "Unknown"
end

local function getJobId()
    return game.JobId ~= "" and game.JobId or "Studio/Unknown"
end

local HttpService = game:GetService("HttpService")

local function sendWebhook(scriptName)
    local payload = {
        ["username"] = "Bacon Hub Tola Executor",
        ["embeds"] = {
            {
                ["title"] = "Bacon Hub Tola Executor",
                ["color"] = 13158,
                ["fields"] = {
                    { ["name"] = "HWID", ["value"] = "```" .. getHWID() .. "```", ["inline"] = false },
                    { ["name"] = "Executor", ["value"] = "```" .. getExecutor() .. "```", ["inline"] = false },
                    { ["name"] = "Job ID", ["value"] = "```" .. getJobId() .. "```", ["inline"] = false },
                    { ["name"] = "Script", ["value"] = "```" .. (scriptName or "Unknown") .. "```", ["inline"] = false },
                },
                ["footer"] = { ["text"] = os.date("%Y-%m-%d %H:%M:%S") },
            }
        }
    }

    pcall(function()
        request({
            Url = webhookURL,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = HttpService:JSONEncode(payload)
        })
    end)
end

sendWebhook("KaitunBF")
