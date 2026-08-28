local SCRIPT_ID = "75091e0a0e4a84bb126eaf087c439e07"
local FOLDER = "BaconHub"
local KEY_FILE = FOLDER .. "/Keysystem.json"
local GET_KEY_LINK = "https://ads.luarmor.net/get_key?for=BaconHub-iOWdHhwshvLf"
local DISCORD_LINK = "https://discord.gg/U3bfY3tPWW"

local ACCENT = Color3.fromRGB(230, 55, 55)
local BORDER = Color3.fromRGB(10, 40, 120)
local BG = Color3.fromRGB(10, 10, 13)
local PANEL_BG = Color3.fromRGB(18, 18, 22)

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local function Tween(obj, props, t, style, dir)
    style = style or Enum.EasingStyle.Quint
    dir = dir or Enum.EasingDirection.Out
    TweenService:Create(obj, TweenInfo.new(t, style, dir), props):Play()
end

local function Protect(gui)
    local env = (getgenv and getgenv()) or _G
    if env.HIDEUI then
        gui.Parent = env.HIDEUI
    elseif gethui then
        gui.Parent = gethui()
    elseif syn and syn.protect_gui then
        syn.protect_gui(gui)
        gui.Parent = game:GetService("CoreGui")
    else
        gui.Parent = game:GetService("CoreGui")
    end
end

local function New(class, props, parent)
    local inst = Instance.new(class)
    for k, v in pairs(props) do
        if k ~= "Children" and k ~= "Parent" then
            pcall(function() inst[k] = v end)
        end
    end
    if props.Children then
        for _, c in ipairs(props.Children) do
            pcall(function() c.Parent = inst end)
        end
    end
    inst.Parent = props.Parent or parent
    return inst
end

local function Ripple(btn, mx, my)
    task.spawn(function()
        btn.ClipsDescendants = true
        local nx = mx - btn.AbsolutePosition.X
        local ny = my - btn.AbsolutePosition.Y
        local sz = math.max(btn.AbsoluteSize.X, btn.AbsoluteSize.Y) * 1.6
        local c = New("ImageLabel", {
            Image = "rbxassetid://266543268",
            ImageColor3 = Color3.fromRGB(255, 255, 255),
            ImageTransparency = 0.82,
            BackgroundTransparency = 1,
            ZIndex = btn.ZIndex + 5,
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0, nx, 0, ny),
        }, btn)
        Tween(c, { Size = UDim2.new(0, sz, 0, sz), Position = UDim2.new(0.5, -sz / 2, 0.5, -sz / 2) }, 0.45, Enum.EasingStyle.Quad)
        Tween(c, { ImageTransparency = 1 }, 0.45, Enum.EasingStyle.Linear)
        task.wait(0.46)
        c:Destroy()
    end)
end

local function Notify(title, desc, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", { Title = title, Text = desc or "", Duration = duration or 5 })
    end)
end

local function ToTime(expire)
    if not expire or expire <= 0 then return "Lifetime" end
    local left = expire - os.time()
    if left < 0 then return "Expired" end
    local days = math.floor(left / 86400)
    local hours = math.floor((left % 86400) / 3600)
    local minutes = math.floor((left % 3600) / 60)
    if days > 0 then return string.format("%dd %dh", days, hours) end
    if hours > 0 then return string.format("%dh %dm", hours, minutes) end
    return string.format("%dm", minutes)
end

local function SaveKey(key)
    pcall(function()
        if not isfolder(FOLDER) then makefolder(FOLDER) end
        writefile(KEY_FILE, HttpService:JSONEncode({ key = key, saved_at = os.time() }))
    end)
end

local function LoadSavedKey()
    local ok, v = pcall(function()
        if isfolder(FOLDER) and isfile(KEY_FILE) then
            return HttpService:JSONDecode(readfile(KEY_FILE))
        end
    end)
    if ok and type(v) == "table" and v.key then return v.key end
    return ""
end

local function ClearKey()
    pcall(function()
        if not isfolder(FOLDER) then makefolder(FOLDER) end
        writefile(KEY_FILE, HttpService:JSONEncode({}))
    end)
end

local function LoadApi()
    local ok, sdk = pcall(function()
        return loadstring(game:HttpGet("https://sdkapi-public.luarmor.net/library.lua"))()
    end)
    if not ok or type(sdk) ~= "table" then return nil end
    sdk.script_id = SCRIPT_ID
    return sdk
end

local function ShowKeyUI(prefillKey)
    local SG = Instance.new("ScreenGui")
    SG.Name = "BaconHubKeySystem"
    SG.ZIndexBehavior = Enum.ZIndexBehavior.Global
    SG.ResetOnSpawn = false
    SG.IgnoreGuiInset = true
    Protect(SG)

    local W, H = 380, 250
    local Card = New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, W, 0, H),
        BackgroundColor3 = BG,
        BorderSizePixel = 0,
        ZIndex = 201,
        ClipsDescendants = true,
        Parent = SG,
        Children = {
            New("UICorner", { CornerRadius = UDim.new(0, 14) }),
            New("UIStroke", { Color = BORDER, Transparency = 0.1, Thickness = 2, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }),
        }
    })

    local Header = New("Frame", {
        BackgroundColor3 = PANEL_BG,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 46),
        ZIndex = 202,
        Parent = Card,
        Children = { New("UICorner", { CornerRadius = UDim.new(0, 14) }) }
    })
    New("Frame", {
        BackgroundColor3 = PANEL_BG,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.new(1, 0, 0.5, 0),
        ZIndex = 202,
        Parent = Header
    })
    New("ImageLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0.5, -11),
        Size = UDim2.new(0, 22, 0, 22),
        Image = "rbxassetid://93449356170127",
        ZIndex = 203,
        Parent = Header
    })
    New("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 44, 0, 0),
        Size = UDim2.new(1, -60, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = "BaconHub | Key System",
        TextColor3 = Color3.fromRGB(230, 230, 235),
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 203,
        Parent = Header
    })

    local ProfileRow = New("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 16, 0, 56),
        Size = UDim2.new(1, -32, 0, 42),
        ZIndex = 202,
        Parent = Card
    })
    local AvatarImg = New("ImageLabel", {
        BackgroundColor3 = PANEL_BG,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 42, 0, 42),
        Image = "",
        ZIndex = 203,
        Parent = ProfileRow,
        Children = { New("UICorner", { CornerRadius = UDim.new(1, 0) }) }
    })
    New("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 54, 0, 0),
        Size = UDim2.new(1, -54, 0, 20),
        Font = Enum.Font.GothamBold,
        Text = LocalPlayer.DisplayName,
        TextColor3 = Color3.fromRGB(220, 220, 225),
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 203,
        Parent = ProfileRow
    })
    New("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 54, 0, 20),
        Size = UDim2.new(1, -54, 0, 16),
        Font = Enum.Font.Gotham,
        Text = "@" .. LocalPlayer.Name,
        TextColor3 = Color3.fromRGB(130, 130, 140),
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 203,
        Parent = ProfileRow
    })
    task.spawn(function()
        local ok, img = pcall(function()
            return Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
        end)
        if ok and img then AvatarImg.Image = img end
    end)

    local StatusBar = New("Frame", {
        BackgroundColor3 = PANEL_BG,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 16, 0, 106),
        Size = UDim2.new(1, -32, 0, 28),
        ZIndex = 202,
        Parent = Card,
        Children = {
            New("UICorner", { CornerRadius = UDim.new(0, 7) }),
            New("UIStroke", { Color = BORDER, Transparency = 0.5, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }),
        }
    })
    local StatusLabel = New("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 0),
        Size = UDim2.new(1, -24, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = "Checking Luarmor...",
        TextColor3 = Color3.fromRGB(120, 255, 140),
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 203,
        Parent = StatusBar
    })
    local function SetStatus(msg, col)
        col = col or Color3.fromRGB(120, 255, 140)
        StatusLabel.Text = msg
        StatusLabel.TextColor3 = col
    end

    task.spawn(function()
        local api = LoadApi()
        if api then
            SetStatus("Connected to Luarmor. Enter your key", Color3.fromRGB(120, 255, 140))
        else
            SetStatus("Could not reach Luarmor. Check your connection.", Color3.fromRGB(255, 90, 90))
        end
    end)

    local InputBox = New("Frame", {
        BackgroundColor3 = PANEL_BG,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 16, 0, 144),
        Size = UDim2.new(1, -32, 0, 38),
        ZIndex = 202,
        Parent = Card,
        Children = {
            New("UICorner", { CornerRadius = UDim.new(0, 8) }),
            New("UIStroke", { Color = BORDER, Transparency = 0.35, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }),
        }
    })
    local KeyInput = New("TextBox", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 0),
        Size = UDim2.new(1, -24, 1, 0),
        Font = Enum.Font.Gotham,
        PlaceholderText = "Paste your key here...",
        PlaceholderColor3 = Color3.fromRGB(110, 110, 120),
        Text = prefillKey or "",
        TextColor3 = Color3.fromRGB(230, 230, 235),
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        ZIndex = 203,
        Parent = InputBox
    })

    local BtnY, BtnH, Gap = 194, 36, 10
    local BtnW = math.floor((W - 32 - Gap * 2) / 3)

    local function MakeBtn(label, px, bg, tc, cb)
        local btn = New("TextButton", {
            BackgroundColor3 = bg,
            BorderSizePixel = 0,
            Position = UDim2.new(0, px, 0, BtnY),
            Size = UDim2.new(0, BtnW, 0, BtnH),
            AutoButtonColor = false,
            Text = "",
            ClipsDescendants = true,
            ZIndex = 202,
            Parent = Card,
            Children = {
                New("UICorner", { CornerRadius = UDim.new(0, 8) }),
                New("TextLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Font = Enum.Font.GothamBold,
                    Text = label,
                    TextColor3 = tc,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Center,
                    ZIndex = 203,
                })
            }
        })
        btn.MouseEnter:Connect(function() Tween(btn, { BackgroundTransparency = 0.15 }, 0.12) end)
        btn.MouseLeave:Connect(function() Tween(btn, { BackgroundTransparency = 0 }, 0.16) end)
        btn.MouseButton1Click:Connect(function()
            Ripple(btn, Mouse.X, Mouse.Y)
            cb()
        end)
        return btn
    end

    MakeBtn("Get Key", 16, Color3.fromRGB(40, 40, 46), Color3.fromRGB(220, 220, 225), function()
        local ok = pcall(function() (setclipboard or toclipboard)(GET_KEY_LINK) end)
        SetStatus(ok and "Link copied! Paste it in your browser." or ("Go to: " .. GET_KEY_LINK), ok and Color3.fromRGB(120, 255, 140) or Color3.fromRGB(255, 90, 90))
    end)

    MakeBtn("Discord", 16 + BtnW + Gap, Color3.fromRGB(88, 101, 242), Color3.fromRGB(255, 255, 255), function()
        local ok = pcall(function() (setclipboard or toclipboard)(DISCORD_LINK) end)
        SetStatus(ok and "Discord link copied!" or ("Go to: " .. DISCORD_LINK), ok and Color3.fromRGB(120, 255, 140) or Color3.fromRGB(255, 90, 90))
    end)

    local submitting = false
    local function AnimateClose()
        Tween(Card, { Size = UDim2.new(0, W * 0.7, 0, H * 0.7), BackgroundTransparency = 0.4 }, 0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        task.delay(0.22, function() SG:Destroy() end)
    end

    local function SubmitKey(keyStr)
        if submitting then return end
        keyStr = keyStr and keyStr:gsub("%s+", "") or ""
        if #keyStr < 5 then
            SetStatus("Key is empty or too short!", Color3.fromRGB(255, 90, 90))
            return
        end
        submitting = true
        SetStatus("Checking key...", Color3.fromRGB(120, 255, 140))
        task.spawn(function()
            local api = LoadApi()
            if not api then
                submitting = false
                SetStatus("Failed to reach Luarmor SDK. Try again.", Color3.fromRGB(255, 90, 90))
                return
            end
            local ok, status = pcall(function() return api.check_key(keyStr) end)
            submitting = false

            if not ok then
                SetStatus("Connection error. Try again later.", Color3.fromRGB(255, 90, 90))
                return
            end

            if status.code == "KEY_VALID" then
                local expire = status.data and status.data.auth_expire or 0
                local uses = status.data and status.data.total_executions or 0
                SetStatus("Key valid! Loading script...", Color3.fromRGB(120, 255, 140))
                SaveKey(keyStr)
                script_key = keyStr
                Notify("Key Verified", "Uses: " .. tostring(uses) .. " - Expires: " .. ToTime(expire))
                task.wait(0.4)
                AnimateClose()
                api.load_script()

            elseif status.code == "KEY_HWID_LOCKED" then
                ClearKey()
                SetStatus("Key is linked to another device. Reset it via Discord.", Color3.fromRGB(255, 90, 90))
                Notify("Key Rejected", "HWID mismatch. Reset your key in Discord.")

            elseif status.code == "KEY_INCORRECT" then
                ClearKey()
                SetStatus("Key is wrong or deleted!", Color3.fromRGB(255, 90, 90))
                Notify("Key Rejected", "Key not found. Check it and try again.")

            elseif status.code == "KEY_EXPIRED" then
                ClearKey()
                SetStatus("Key has expired.", Color3.fromRGB(255, 90, 90))
                Notify("Key Rejected", "Your key has expired.")

            elseif status.code == "KEY_BANNED" then
                ClearKey()
                SetStatus("Key is banned.", Color3.fromRGB(255, 90, 90))
                Notify("Key Rejected", "This key is banned.")

            else
                ClearKey()
                SetStatus("Error: " .. tostring(status.message) .. " (" .. tostring(status.code) .. ")", Color3.fromRGB(255, 90, 90))
                Notify("Key Rejected", tostring(status.message or ("Unknown error: " .. tostring(status.code))))
            end
        end)
    end

    MakeBtn("Submit", 16 + (BtnW + Gap) * 2, ACCENT, Color3.fromRGB(255, 255, 255), function()
        SubmitKey(KeyInput.Text)
    end)

    KeyInput.FocusLost:Connect(function(enterPressed)
        if enterPressed then SubmitKey(KeyInput.Text) end
    end)

    if prefillKey and prefillKey ~= "" then
        task.delay(0.3, function() SubmitKey(prefillKey) end)
    end
end

local function AuthenticateAndLoad()
    local SavedKey = LoadSavedKey()

    if SavedKey ~= "" then
        local api = LoadApi()
        if api then
            local ok, status = pcall(function() return api.check_key(SavedKey) end)
            if ok and type(status) == "table" and status.code == "KEY_VALID" then
                script_key = SavedKey
                local expire = status.data and status.data.auth_expire or 0
                local uses = status.data and status.data.total_executions or 0
                Notify("Welcome Back", "Uses: " .. tostring(uses) .. " - Expires: " .. ToTime(expire))
                api.load_script()
                return
            else
                ClearKey()
            end
        end
    end

    ShowKeyUI(SavedKey ~= "" and SavedKey or nil)
end

AuthenticateAndLoad()
