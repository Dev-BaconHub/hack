local Players     = game:GetService("Players")
local CoreGui     = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local env         = (getgenv and getgenv()) or _G

-- ================= Custom Fluent (self-contained, no loadstring) =================
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")

local THEME = {
    Window  = Color3.fromRGB(24, 24, 28),
    Bar     = Color3.fromRGB(32, 32, 38),
    Element = Color3.fromRGB(40, 40, 48),
    Hover   = Color3.fromRGB(54, 54, 64),
    Accent  = Color3.fromRGB(255, 170, 60),
    Text    = Color3.fromRGB(240, 240, 240),
    SubText = Color3.fromRGB(160, 160, 170),
}

local function make(class, props)
    local o = Instance.new(class)
    local parent = props.Parent
    props.Parent = nil
    for k, v in pairs(props) do o[k] = v end
    o.Parent = parent
    return o
end

local function corner(o, r)
    make("UICorner", { CornerRadius = UDim.new(0, r), Parent = o })
end

local function padding(o, t, b, l, r)
    make("UIPadding", {
        PaddingTop = UDim.new(0, t), PaddingBottom = UDim.new(0, b),
        PaddingLeft = UDim.new(0, l), PaddingRight = UDim.new(0, r), Parent = o,
    })
end

local function label(parent, text, size, color, font)
    return make("TextLabel", {
        BackgroundTransparency = 1, Text = text or "", TextSize = size, TextColor3 = color,
        Font = font or Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top, TextWrapped = true,
        Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = parent,
    })
end

local Fluent = { Connections = {} }

local function connect(signal, fn)
    local c = signal:Connect(fn)
    table.insert(Fluent.Connections, c)
    return c
end

do
    local gui = make("ScreenGui", { Name = "BaconPetsUI", ResetOnSpawn = false, DisplayOrder = 998, ZIndexBehavior = Enum.ZIndexBehavior.Sibling })
    local parented = pcall(function() gui.Parent = (gethui and gethui()) or CoreGui end)
    if not parented or not gui.Parent then
        gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
    Fluent.Gui = gui

    Fluent.Notifs = make("Frame", {
        BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, -12, 1, -12), Size = UDim2.fromOffset(240, 300), Parent = gui,
    })
    make("UIListLayout", { Padding = UDim.new(0, 6), VerticalAlignment = Enum.VerticalAlignment.Bottom, Parent = Fluent.Notifs })
end

function Fluent:Destroy()
    for _, c in ipairs(self.Connections) do pcall(function() c:Disconnect() end) end
    self.Connections = {}
    if self.Gui then self.Gui:Destroy() end
end

function Fluent:Notify(cfg)
    local f = make("Frame", {
        BackgroundColor3 = THEME.Element, Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y, Parent = self.Notifs,
    })
    corner(f, 8)
    padding(f, 8, 8, 10, 10)
    make("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder, Parent = f })
    label(f, cfg.Title, 14, THEME.Text, Enum.Font.GothamBold)
    label(f, cfg.Content, 12, THEME.SubText)
    task.delay(cfg.Duration or 4, function() pcall(function() f:Destroy() end) end)
end

local function makeTab(Window, cfg, index)
    local Tab = { Index = index }

    Tab.Button = make("TextButton", {
        BackgroundColor3 = THEME.Element, AutoButtonColor = false, Text = cfg.Title or "Tab",
        TextColor3 = THEME.SubText, TextSize = 13, Font = Enum.Font.GothamMedium,
        Size = UDim2.new(1, 0, 0, 30), Parent = Window.TabList,
    })
    corner(Tab.Button, 6)

    Tab.Page = make("ScrollingFrame", {
        BackgroundTransparency = 1, BorderSizePixel = 0, Visible = false,
        Size = UDim2.new(1, 0, 1, 0), CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 3, ScrollBarImageColor3 = THEME.Accent, Parent = Window.Pages,
    })
    padding(Tab.Page, 8, 8, 8, 10)
    make("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder, Parent = Tab.Page })

    connect(Tab.Button.MouseButton1Click, function() Window:SelectTab(index) end)

    function Tab:AddParagraph(c)
        local f = make("Frame", {
            BackgroundColor3 = THEME.Element, Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y, Parent = self.Page,
        })
        corner(f, 8)
        padding(f, 8, 8, 10, 10)
        make("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder, Parent = f })
        local t = label(f, c.Title, 14, THEME.Text, Enum.Font.GothamBold)
        local d = label(f, c.Content, 12, THEME.SubText)
        local P = {}
        function P:SetTitle(x) t.Text = tostring(x) end
        function P:SetDesc(x) d.Text = tostring(x) end
        function P:Destroy() f:Destroy() end
        return P
    end

    function Tab:AddButton(c)
        local f = make("TextButton", {
            BackgroundColor3 = THEME.Element, AutoButtonColor = false, Text = "",
            Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = self.Page,
        })
        corner(f, 8)
        padding(f, 8, 8, 10, 10)
        make("UISizeConstraint", { MinSize = Vector2.new(0, 46), Parent = f })

        local ICON = 36
        local offset = 0
        if c.Icon and c.Icon ~= "" then
            offset = ICON + 10
            local img = make("ImageLabel", {
                Name = "Icon", BackgroundColor3 = THEME.Window, Image = c.Icon,
                Size = UDim2.fromOffset(ICON, ICON), Parent = f,
            })
            corner(img, 6)
        end

        local holder = make("Frame", {
            BackgroundTransparency = 1, Position = UDim2.new(0, offset, 0, 0),
            Size = UDim2.new(1, -offset, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = f,
        })
        make("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder, Parent = holder })
        local t = label(holder, c.Title, 14, THEME.Text, Enum.Font.GothamBold)
        local d
        if c.Description and c.Description ~= "" then d = label(holder, c.Description, 11, THEME.SubText) end

        connect(f.MouseEnter, function() TweenService:Create(f, TweenInfo.new(0.12), { BackgroundColor3 = THEME.Hover }):Play() end)
        connect(f.MouseLeave, function() TweenService:Create(f, TweenInfo.new(0.12), { BackgroundColor3 = THEME.Element }):Play() end)
        connect(f.MouseButton1Click, function()
            if c.Callback then task.spawn(c.Callback) end
        end)

        local B = {}
        function B:SetTitle(x) t.Text = tostring(x) end
        function B:SetDesc(x) if d then d.Text = tostring(x) end end
        function B:Destroy() f:Destroy() end
        return B
    end

    return Tab
end

function Fluent:CreateWindow(cfg)
    local Window = { Tabs = {} }
    local tabWidth = cfg.TabWidth or 80

    local main = make("Frame", {
        Name = "Main", BackgroundColor3 = THEME.Window, Size = cfg.Size or UDim2.fromOffset(440, 300),
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
        ClipsDescendants = true, Parent = self.Gui,
    })
    corner(main, 10)

    local bar = make("Frame", { BackgroundColor3 = THEME.Bar, Size = UDim2.new(1, 0, 0, 36), Parent = main })
    padding(bar, 0, 0, 12, 12)
    make("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8),
        VerticalAlignment = Enum.VerticalAlignment.Center, Parent = bar,
    })
    for _, info in ipairs({
        { cfg.Title or "", 14, THEME.Text, Enum.Font.GothamBold },
        { cfg.SubTitle or "", 11, THEME.SubText, Enum.Font.Gotham },
    }) do
        local l = make("TextLabel", {
            BackgroundTransparency = 1, Text = info[1], TextSize = info[2], TextColor3 = info[3], Font = info[4],
            Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X, Parent = bar,
        })
    end

    Window.TabList = make("Frame", {
        BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 36), Size = UDim2.new(0, tabWidth, 1, -36), Parent = main,
    })
    padding(Window.TabList, 6, 6, 6, 6)
    make("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder, Parent = Window.TabList })

    Window.Pages = make("Frame", {
        BackgroundTransparency = 1, Position = UDim2.new(0, tabWidth, 0, 36), Size = UDim2.new(1, -tabWidth, 1, -36), Parent = main,
    })

    -- drag
    local dragging, dragStart, startPos
    connect(bar.InputBegan, function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging, dragStart, startPos = true, i.Position, main.Position
            local c; c = i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then dragging = false; c:Disconnect() end
            end)
        end
    end)
    connect(UserInputService.InputChanged, function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)

    function Window:Minimize() main.Visible = not main.Visible end

    if cfg.MinimizeKey then
        connect(UserInputService.InputBegan, function(i, gp)
            if not gp and i.KeyCode == cfg.MinimizeKey then Window:Minimize() end
        end)
    end

    function Window:AddTab(c)
        local tab = makeTab(self, c, #self.Tabs + 1)
        table.insert(self.Tabs, tab)
        return tab
    end

    function Window:SelectTab(n)
        for i, t in ipairs(self.Tabs) do
            local on = (i == n)
            t.Page.Visible = on
            t.Button.TextColor3 = on and THEME.Accent or THEME.SubText
            t.Button.BackgroundColor3 = on and THEME.Hover or THEME.Element
        end
    end

    return Window
end
-- ================= End custom Fluent =================

return Fluent
