local TweenService = game:GetService("TweenService");
local Players = game:GetService("Players");
local Debris = game:GetService("Debris");

local CoreGui = (gethui and gethui()) or game:GetService("CoreGui");

if CoreGui:FindFirstChild("rz-warning") then
	CoreGui["rz-warning"]:Destroy()
end

local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "rz-warning"
ScreenGui.IgnoreGuiInset = true
Debris:AddItem(ScreenGui, 25)

local Background = Instance.new("Frame", ScreenGui)
Background.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Background.Size = UDim2.fromScale(1, 1)
	
local Gradient = Instance.new("UIGradient", Background)
Gradient.Rotation = 90
Gradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0.00, Color3.fromRGB(0, 0, 0));
	ColorSequenceKeypoint.new(1.00, Color3.fromRGB(25, 25, 25));
})

local Center = Instance.new("Frame", Background)
Center.Size = UDim2.fromScale(0.25, 0.09);
Center.AnchorPoint = Vector2.new(0.5, 1)
Center.Position = UDim2.new(0.5, 0, 0.95, 0)
Center.BackgroundColor3 = Color3.fromRGB(15, 15, 15)

local Corner = Instance.new("UICorner", Center)
Corner.CornerRadius = UDim.new(0, 8)

local ServerLink = "https://discord.gg/U3bfY3tPWW"
local WarnMessage = "VN vô discord để lấy script hop | EN Go to Discord to get the hop script."

local Warn = Instance.new("TextLabel", Background)
Warn.Text = WarnMessage
Warn.Size = UDim2.new(0.6, 0, 0.2, 0)
Warn.AnchorPoint = Vector2.new(0.5, 0.5)
Warn.Position = UDim2.fromScale(0.5, 0.5)
Warn.Font = Enum.Font.FredokaOne
Warn.TextColor3 = Color3.fromRGB(230, 230, 230)
Warn.TextScaled = true
Warn.BackgroundTransparency = 1

local CopyLink = Instance.new("TextButton", Center)
CopyLink.Text = ServerLink
CopyLink.Size = UDim2.new(0.8, 0, 0.6, 0)
CopyLink.AnchorPoint = Vector2.new(0.5, 0.5)
CopyLink.Position = UDim2.fromScale(0.5, 0.5)
CopyLink.Font = Enum.Font.FredokaOne
CopyLink.TextColor3 = Color3.fromRGB(180, 180, 180)
CopyLink.TextScaled = true
CopyLink.TextTransparency = 0.2
CopyLink.BackgroundTransparency = 1

CopyLink.Activated:Connect(function()
	if CopyLink.Text ~= "Copied!" then
		setclipboard(ServerLink)
		CopyLink.Text = "Copied!"
		task.wait(2)
		CopyLink.Text = ServerLink
	end
end)

local CloseButton = Instance.new("TextButton", Background)
CloseButton.Size = UDim2.fromScale(0.1, 0.055)
CloseButton.Position = UDim2.fromScale(0.29, 0.99)
CloseButton.AnchorPoint = Vector2.new(1, 1)
CloseButton.Text = "Close"
CloseButton.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
CloseButton.TextColor3 = Color3.fromRGB(235, 20, 20)
CloseButton.Font = Enum.Font.FredokaOne
CloseButton.TextScaled = true
CloseButton.TextTransparency = 0.6

local Corner = Instance.new("UICorner", CloseButton)
Corner.CornerRadius = UDim.new(0, 8)

CloseButton.Activated:Connect(function()
	ScreenGui:Destroy()
end)refillKey or "",
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
