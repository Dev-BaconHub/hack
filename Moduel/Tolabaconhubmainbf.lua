local WEBHOOK_URL = "https://api.bacon-hub.xyz/webhook/mainbfbaconhub"
local SCRIPT_NAME = "Bacon Hub Main BF"

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer

local function getExecutorName()
    local ok, name = pcall(function()
        return identifyexecutor()
    end)
    if ok and name then return name end
    return "Unknown"
end

local function getHWID()
    local ok, id = pcall(function()
        return gethwid()
    end)
    if ok and id then return id end
    return "Unknown"
end

local payload = {
    embeds = {
        {
            title = "Bacon Hub Tola Executor",
            color = 337650,
            fields = {
                { name = "HWID", value = "```" .. tostring(getHWID()) .. "```", inline = false },
                { name = "Executor", value = "```" .. tostring(getExecutorName()) .. "```", inline = false },
                { name = "Job ID", value = "```" .. tostring(game.JobId) .. "```", inline = false },
                { name = "Script", value = "```" .. SCRIPT_NAME .. "```", inline = false },
            },
            footer = { text = "Bacon Hub" },
            timestamp = DateTime.now():ToIsoDate(),
        },
    },
}

local encoded = HttpService:JSONEncode(payload)
local request = (syn and syn.request) or (http and http.request) or (fluxus and fluxus.request) or http_request or request

if request then
    request({
        Url = WEBHOOK_URL,
        Method = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body = encoded,
    })
end
