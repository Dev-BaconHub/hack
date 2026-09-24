local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local TaskWait = (task and task.wait) or wait
local TaskSpawn = (task and task.spawn) or spawn or function(Fn) Fn() end
local TaskDelay = (task and task.delay) or delay or function(_, Fn) Fn() end

local RootParent = (gethui and gethui())
if not RootParent then
	local OkCore, Core = pcall(function() return game:GetService("CoreGui") end)
	if OkCore and Core then RootParent = Core end
end
if not RootParent then
	local OkPlayer, PlayerGui = pcall(function() return game:GetService("Players").LocalPlayer:FindFirstChildOfClass("PlayerGui") end)
	if OkPlayer and PlayerGui then RootParent = PlayerGui end
end
if not RootParent then return end

local Old = RootParent:FindFirstChild("ScriptBrowser")
if Old then
	Old:Destroy()
end

local C = {
	Background = Color3.fromRGB(8, 22, 48),
	Panel = Color3.fromRGB(12, 35, 70),
	SidePanel = Color3.fromRGB(9, 27, 58),
	Border = Color3.fromRGB(45, 90, 160),
	Accent = Color3.fromRGB(65, 145, 230),
	Selected = Color3.fromRGB(40, 95, 175),
	SelectBar = Color3.fromRGB(65, 145, 230),
	TextPrimary = Color3.fromRGB(220, 235, 255),
	TextSecondary = Color3.fromRGB(110, 155, 210),
	ToggleOn = Color3.fromRGB(35, 120, 210),
	ToggleOff = Color3.fromRGB(20, 45, 90),
	Yes = Color3.fromRGB(120, 50, 45),
	YesHover = Color3.fromRGB(140, 62, 52),
	DropRow = Color3.fromRGB(30, 80, 160),
	Item = Color3.fromRGB(10, 28, 62),
	ItemHover = Color3.fromRGB(18, 48, 100),
	Hover = Color3.fromRGB(22, 58, 118),
	Action = Color3.fromRGB(24, 62, 120),
	ActionHover = Color3.fromRGB(55, 130, 210),
	ActionDown = Color3.fromRGB(35, 100, 180),
	LoadHover = Color3.fromRGB(55, 130, 210),
	UnloadHover = Color3.fromRGB(35, 100, 180),
	LeafDark = Color3.fromRGB(25, 60, 130),
	LeafLight = Color3.fromRGB(45, 110, 200),
	Knob = Color3.fromRGB(220, 235, 255),
	Gold = Color3.fromRGB(235, 195, 95),
	Purple = Color3.fromRGB(175, 115, 225),
	White = Color3.fromRGB(220, 235, 255),
	Blue = Color3.fromRGB(100, 185, 255),
	Coral = Color3.fromRGB(235, 130, 120),
	CoralLight = Color3.fromRGB(250, 175, 155),
	Weed = Color3.fromRGB(35, 120, 185),
	WeedLight = Color3.fromRGB(70, 170, 230),
}

local MonoBase = nil
pcall(function()
	MonoBase = Font.fromEnum(Enum.Font.RobotoMono)
end)
local Mono = MonoBase and Font.new(MonoBase.Family, Enum.FontWeight.Regular) or Enum.Font.Code
local MonoBold = MonoBase and Font.new(MonoBase.Family, Enum.FontWeight.Bold) or Enum.Font.Code

local function New(Class, Props)
	local Parent = Props.Parent
	Props.Parent = nil
	local Inst = Instance.new(Class)
	for Key, Value in pairs(Props) do
		if Key == "FontFace" and not MonoBase then
			pcall(function() Inst.Font = Value end)
		else
			local Ok = pcall(function() Inst[Key] = Value end)
			if not Ok and Key == "FontFace" then
				pcall(function() Inst.Font = Enum.Font.Code end)
			end
		end
	end
	if Parent then
		Inst.Parent = Parent
	end
	return Inst
end

local function Round(Inst, R)
	return New("UICorner", {CornerRadius = UDim.new(0, R or 4), Parent = Inst})
end

local function Stroke(Inst, T, Col, Tr)
	return New("UIStroke", {Thickness = T or 1.5, Color = Col or C.Border, Transparency = Tr or 0, Parent = Inst})
end

local function Pad(Inst, N)
	return New("UIPadding", {PaddingTop = UDim.new(0, N), PaddingBottom = UDim.new(0, N), PaddingLeft = UDim.new(0, N), PaddingRight = UDim.new(0, N), Parent = Inst})
end

local function Play(Inst, Props, Time, Style, Direction)
	if not Inst or not Inst.Parent then return end
	TweenService:Create(Inst, TweenInfo.new(Time or 0.2, Style or Enum.EasingStyle.Quad, Direction or Enum.EasingDirection.Out), Props):Play()
end

local function HoverColor(Button, Normal, Hover)
	Button.MouseEnter:Connect(function()
		Play(Button, {BackgroundColor3 = Hover})
	end)
	Button.MouseLeave:Connect(function()
		Play(Button, {BackgroundColor3 = Normal})
	end)
end

local function Appear(Inst, Index, TargetTr, TargetPos)
	Inst.BackgroundTransparency = 1
	Inst.Position = TargetPos + UDim2.fromOffset(0, 8)
	TaskDelay(Index * 0.04, function()
		if Inst.Parent then
			Play(Inst, {BackgroundTransparency = TargetTr, Position = TargetPos}, 0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		end
	end)
end

local function PressAnim(Button)
	local BtnScale = Button:FindFirstChildOfClass("UIScale") or New("UIScale", {Parent = Button})
	Button.InputBegan:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
			Play(BtnScale, {Scale = 0.94}, 0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		end
	end)
	Button.InputEnded:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
			Play(BtnScale, {Scale = 1.0}, 0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		end
	end)
	return BtnScale
end

local function Spaced(Text)
	local Out = Text:gsub(".", "%0 ")
	return Out:sub(1, -2)
end

local function FmtTime(Sec)
	return string.format("%02d:%02d", math.floor(Sec / 60), Sec % 60)
end

local function InElement(Point, Element)
	local AP = Element.AbsolutePosition
	local AS = Element.AbsoluteSize
	return Point.X >= AP.X and Point.X <= AP.X + AS.X and Point.Y >= AP.Y and Point.Y <= AP.Y + AS.Y
end

local function DrawMap(Parent, Map, Cell, Color)
	for _, P in ipairs(Map) do
		New("Frame", {Position = UDim2.fromOffset(P[1] * Cell, P[2] * Cell), Size = UDim2.fromOffset(Cell, Cell), BackgroundColor3 = Color, BorderSizePixel = 0, Parent = Parent})
	end
end

local GearMap = {
	{3, 0}, {4, 0}, {5, 0},
	{2, 1}, {3, 1}, {4, 1}, {5, 1}, {6, 1},
	{1, 2}, {2, 2}, {6, 2}, {7, 2},
	{1, 3}, {2, 3}, {6, 3}, {7, 3},
	{0, 4}, {1, 4}, {7, 4}, {8, 4},
	{1, 5}, {2, 5}, {6, 5}, {7, 5},
	{1, 6}, {2, 6}, {6, 6}, {7, 6},
	{2, 7}, {3, 7}, {4, 7}, {5, 7}, {6, 7},
	{3, 8}, {4, 8}, {5, 8},
}

local SearchMap = {
	{1, 0}, {2, 0}, {3, 0},
	{0, 1}, {4, 1},
	{0, 2}, {4, 2},
	{0, 3}, {4, 3},
	{1, 4}, {2, 4}, {3, 4},
	{4, 4}, {5, 5}, {6, 6},
}

local ArrowMap = {
	{4, 1},
	{0, 2}, {1, 2}, {2, 2}, {3, 2}, {4, 2}, {5, 2},
	{0, 3}, {1, 3}, {2, 3}, {3, 3}, {4, 3}, {5, 3}, {6, 3},
	{0, 4}, {1, 4}, {2, 4}, {3, 4}, {4, 4}, {5, 4},
	{4, 5},
}

local CheckMap = {
	{0, 4}, {1, 5}, {2, 6},
	{3, 5}, {4, 4}, {5, 3}, {6, 2}, {7, 1},
}

local ChevronMap = {
	{0, 0}, {1, 1}, {2, 2}, {4, 0}, {3, 1},
}

local LeafMap = {
	{1, 1, 6, 2},
	{9, 2, 4, 1}, {15, 2, 4, 2}, {21, 2, 4, 1}, {27, 2, 4, 2}, {33, 2, 4, 1},
	{2, 9, 4, 1}, {2, 15, 4, 2}, {2, 21, 4, 1}, {2, 27, 4, 2}, {2, 33, 4, 1},
	{8, 8, 4, 2}, {13, 13, 4, 1},
	{14, 6, 3, 1}, {6, 14, 3, 1},
	{20, 7, 3, 2}, {7, 20, 3, 2},
}

local function MakeLeaves(Parent, Area, Z)
	local S = Area / 40
	for _, Corner in ipairs({{true, true}, {false, true}, {true, false}, {false, false}}) do
		local Holder = New("Frame", {
			Size = UDim2.fromOffset(Area, Area),
			AnchorPoint = Vector2.new(Corner[1] and 0 or 1, Corner[2] and 0 or 1),
			Position = UDim2.new(Corner[1] and 0 or 1, 0, Corner[2] and 0 or 1, 0),
			BackgroundTransparency = 1,
			ZIndex = Z,
			Parent = Parent,
		})
		for _, P in ipairs(LeafMap) do
			local X = Corner[1] and P[1] or (40 - P[1] - P[3])
			local Y = Corner[2] and P[2] or (40 - P[2] - P[3])
			New("Frame", {
				Position = UDim2.fromOffset(math.floor(X * S + 0.5), math.floor(Y * S + 0.5)),
				Size = UDim2.fromOffset(math.max(2, math.floor(P[3] * S + 0.5)), math.max(2, math.floor(P[3] * S + 0.5))),
				BackgroundColor3 = P[4] == 2 and C.LeafLight or C.LeafDark,
				BorderSizePixel = 0,
				ZIndex = Z,
				Parent = Holder,
			})
		end
	end
end

local WeedTallMap = {
	{1, 13}, {2, 12}, {1, 11}, {2, 10}, {1, 9}, {2, 8}, {1, 7}, {2, 6}, {1, 5}, {2, 4}, {1, 3}, {2, 2}, {1, 1}, {2, 0},
	{5, 13}, {6, 12}, {5, 11}, {6, 10}, {5, 9}, {6, 8}, {5, 7}, {6, 6}, {5, 5}, {6, 4},
	{9, 13}, {10, 12}, {9, 11}, {10, 10}, {9, 9}, {10, 8}, {9, 7}, {10, 6}, {9, 5}, {10, 4}, {9, 3},
}

local WeedTallLightMap = {
	{2, 0}, {6, 4}, {9, 3}, {1, 7}, {5, 9}, {10, 6},
}

local WeedMap = {
	{2, 9}, {3, 8}, {2, 7}, {3, 6}, {2, 5}, {3, 4}, {2, 3}, {3, 2}, {2, 1},
	{6, 9}, {5, 8}, {6, 7}, {5, 6}, {6, 5}, {5, 4}, {6, 3},
	{9, 9}, {10, 8}, {9, 7}, {10, 6}, {9, 5},
}

local WeedLightMap = {
	{3, 0}, {6, 2}, {10, 5},
}

local function GetViewSize()
	local OkS, S = pcall(function() return Gui.AbsoluteSize end)
	if OkS and S and S.X > 100 and S.Y > 100 then return S.X, S.Y end
	local OkCam, Cam = pcall(function() return workspace.CurrentCamera end)
	if OkCam and Cam then
		local OkV, V = pcall(function() return Cam.ViewportSize end)
		if OkV and V and V.X > 100 and V.Y > 100 then return V.X, V.Y end
	end
	return 1280, 720
end

local function Comma(N)
	return tostring(N):gsub("(%d)(%d%d%d)$", "%1,%2")
end

local library = {}

local LibGui = nil

local function LibViewSize()
	if LibGui then
		local OkS, S = pcall(function() return LibGui.AbsoluteSize end)
		if OkS and S and S.X > 100 and S.Y > 100 then return S.X, S.Y end
	end
	local OkP, PV = pcall(function() return game:GetService("Players").LocalPlayer:FindFirstChildOfClass("PlayerGui").AbsoluteSize end)
	if OkP and PV and PV.X > 100 and PV.Y > 100 then return PV.X, PV.Y end
	local OkCam, Cam = pcall(function() return workspace.CurrentCamera end)
	if OkCam and Cam then
		local OkV, V = pcall(function() return Cam.ViewportSize end)
		if OkV and V and V.X > 100 and V.Y > 100 then return V.X, V.Y end
	end
	return 1280, 720
end

local function Atlantis(Inst)
	local S = New("UIStroke", {Thickness = 1, Parent = Inst})
	New("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(120, 200, 215)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(55, 110, 140)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 200, 215)),
		}),
		Rotation = 90,
		Parent = S,
	})
	return S
end

local WindowProto = {}
local TabProto = {}
local MinProto = {}

local function LibRowFrame(Tab, H)
	return New("Frame", {
		Size = UDim2.new(1, 0, 0, H or 28),
		BackgroundTransparency = 1,
		Parent = Tab.Page,
	})
end

local function LibTitle(Row, Text)
	local L = New("TextLabel", {
		Text = Text,
		FontFace = MonoBold,
		TextSize = 11,
		TextColor3 = C.TextPrimary,
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(4, 0),
		Size = UDim2.new(0.55, -8, 1, 0),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = Row,
	})
	return L
end

function TabProto:AddSection(Title)
	New("TextLabel", {
		Text = "— " .. Spaced(Title) .. " —",
		FontFace = MonoBold,
		TextSize = 9,
		TextColor3 = C.TextSecondary,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 16),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = self.Page,
	})
end

function TabProto:AddParagraph(Title, Desc)
	local Row = New("Frame", {
		Size = UDim2.new(1, 0, 0, 14),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Parent = self.Page,
	})
	New("UIListLayout", {Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder, Parent = Row})
	New("TextLabel", {
		Text = Title,
		FontFace = MonoBold,
		TextSize = 11,
		TextColor3 = C.TextPrimary,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 14),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = Row,
	})
	local D = New("TextLabel", {
		Text = Desc or "",
		FontFace = Mono,
		TextSize = 10,
		TextColor3 = C.TextSecondary,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 12),
		AutomaticSize = Enum.AutomaticSize.Y,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true,
		Parent = Row,
	})
	local DScale = New("UIScale", {Parent = D})
	local P = {}
	function P.SetDescription(_, NewText)
		if D.Text == NewText then return end
		D.Text = NewText
		DScale.Scale = 1
		Play(DScale, {Scale = 1.05}, 0.15)
		TaskDelay(0.15, function()
			if DScale.Parent then
				Play(DScale, {Scale = 1.0}, 0.15)
			end
		end)
		Play(D, {TextColor3 = Color3.fromRGB(65, 145, 230)}, 0.15)
		TaskDelay(0.15, function()
			if D.Parent then
				Play(D, {TextColor3 = C.TextSecondary}, 0.25)
			end
		end)
	end
	return P
end

function TabProto:AddToggle(Cfg)
	Cfg = Cfg or {}
	local Row = LibRowFrame(self)
	LibTitle(Row, Cfg.Title or "Toggle")
	local Root = New("TextButton", {
		Text = "",
		Size = UDim2.fromOffset(52, 22),
		Position = UDim2.new(1, -56, 0, 3),
		BackgroundColor3 = C.ToggleOff,
		AutoButtonColor = false,
		BorderSizePixel = 0,
		Parent = Row,
	})
	Round(Root, 11)
	Atlantis(Root)
	local Knob = New("Frame", {
		Size = UDim2.fromOffset(16, 16),
		Position = UDim2.fromOffset(3, 3),
		BackgroundColor3 = C.Knob,
		BorderSizePixel = 0,
		ZIndex = 1,
		Parent = Root,
	})
	Round(Knob, 8)
	local Option = {Value = false}
	local function Set(Value, Instant)
		Option.Value = Value and true or false
		local Pos = Option.Value and UDim2.fromOffset(33, 3) or UDim2.fromOffset(3, 3)
		local Col = Option.Value and C.ToggleOn or C.ToggleOff
		if Instant then
			Knob.Position = Pos
			Root.BackgroundColor3 = Col
		else
			Play(Knob, {Position = Pos}, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
			Play(Root, {BackgroundColor3 = Col}, 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		end
		if Cfg.Callback then
			pcall(Cfg.Callback, Option.Value)
		end
	end
	Root.Activated:Connect(function()
		local RipplePos = ((not Option.Value) and UDim2.fromOffset(33, 3) or UDim2.fromOffset(3, 3)) + UDim2.fromOffset(8, 8)
		Set(not Option.Value)
		local Ripple = New("Frame", {
			Size = UDim2.fromOffset(16, 16),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = RipplePos,
			BackgroundColor3 = C.Accent,
			BorderSizePixel = 0,
			Parent = Root,
		})
		New("UICorner", {CornerRadius = UDim.new(0, 8), Parent = Ripple})
		Play(Ripple, {Size = UDim2.fromOffset(22.4, 22.4), BackgroundTransparency = 1}, 0.3)
		TaskDelay(0.3, function()
			Ripple:Destroy()
		end)
	end)
	function Option.SetValue(_, Value)
		Set(Value)
	end
	function Option.GetValue()
		return Option.Value
	end
	Set(Cfg.Default, true)
	return Option
end

function TabProto:AddButton(Cfg)
	Cfg = Cfg or {}
	local Row = LibRowFrame(self, 30)
	local Btn = New("TextButton", {
		Text = Cfg.Title or "Button",
		FontFace = MonoBold,
		TextSize = 11,
		TextColor3 = C.White,
		Size = UDim2.new(1, -8, 1, -4),
		Position = UDim2.fromOffset(4, 2),
		BackgroundColor3 = C.Action,
		AutoButtonColor = false,
		BorderSizePixel = 0,
		Parent = Row,
	})
	Round(Btn, 3)
	Atlantis(Btn)
	HoverColor(Btn, C.Action, C.LoadHover)
	PressAnim(Btn)
	local Last = 0
	Btn.Activated:Connect(function()
		local Now = tick()
		if Now - Last < (Cfg.Cooldown or 0) then return end
		Last = Now
		if Cfg.Callback then
			pcall(Cfg.Callback)
		end
	end)
	return Btn
end

function TabProto:AddDropdown(Cfg)
	Cfg = Cfg or {}
	local Row = LibRowFrame(self, 30)
	LibTitle(Row, Cfg.Title or "Dropdown")
	local Box = New("TextButton", {
		Text = "",
		Size = UDim2.fromOffset(150, 24),
		Position = UDim2.new(1, -154, 0, 3),
		BackgroundColor3 = C.Item,
		AutoButtonColor = false,
		BorderSizePixel = 0,
		Parent = Row,
	})
	Round(Box, 3)
	Atlantis(Box)
	HoverColor(Box, C.Item, C.Hover)
	local Label = New("TextLabel", {
		Text = "",
		FontFace = MonoBold,
		TextSize = 10,
		TextColor3 = C.TextPrimary,
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(8, 0),
		Size = UDim2.new(1, -24, 1, 0),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = Box,
	})
	local Chev = New("Frame", {Size = UDim2.fromOffset(10, 6), Position = UDim2.new(1, -16, 0.5, -3), BackgroundTransparency = 1, Parent = Box})
	DrawMap(Chev, ChevronMap, 2, C.TextSecondary)
	local Options = Cfg.Options or {}
	local Holder = New("Frame", {
		Size = UDim2.fromOffset(150, 0),
		Position = UDim2.new(1, -154, 0, 29),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		ZIndex = 12,
		Parent = Row,
	})
	local Inner = New("Frame", {
		Size = UDim2.new(1, 0, 0, #Options * 24),
		BackgroundColor3 = C.Item,
		BorderSizePixel = 0,
		ZIndex = 12,
		Parent = Holder,
	})
	Round(Inner, 3)
	Stroke(Inner, 1)
	New("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Parent = Inner})
	local Open = false
	local function SetOpen(V)
		Open = V
		Row.ZIndex = V and 20 or 0
		if V then
			Play(Holder, {Size = UDim2.fromOffset(150, #Options * 24)}, 0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		else
			Play(Holder, {Size = UDim2.fromOffset(150, 0)}, 0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
		end
	end
	local Option = {Value = Cfg.Default}
	for I, Name in ipairs(Options) do
		local OBtn = New("TextButton", {
			Text = Name,
			FontFace = Mono,
			TextSize = 10,
			TextColor3 = C.TextPrimary,
			Size = UDim2.new(1, 0, 0, 24),
			BackgroundColor3 = C.Background,
			BackgroundTransparency = 1,
			AutoButtonColor = false,
			BorderSizePixel = 0,
			LayoutOrder = I,
			ZIndex = 13,
			Parent = Inner,
		})
		OBtn.MouseEnter:Connect(function()
			OBtn.BackgroundTransparency = 0
			OBtn.BackgroundColor3 = C.Hover
		end)
		OBtn.MouseLeave:Connect(function()
			OBtn.BackgroundTransparency = 1
		end)
		OBtn.Activated:Connect(function()
			Option.Value = Name
			Label.Text = Name
			SetOpen(false)
			if Cfg.Callback then
				pcall(Cfg.Callback, Name)
			end
		end)
	end
	Box.Activated:Connect(function()
		SetOpen(not Open)
	end)
	function Option.SetValue(_, Value)
		Option.Value = Value
		Label.Text = Value
		if Cfg.Callback then
			pcall(Cfg.Callback, Value)
		end
	end
	Label.Text = Cfg.Default or (Options[1] or "")
	if not Cfg.Default and Options[1] then
		Option.Value = Options[1]
	end
	return Option
end

function TabProto:AddMultiDropdown(Cfg)
	Cfg = Cfg or {}
	local Row = LibRowFrame(self, 30)
	LibTitle(Row, Cfg.Title or "MultiDropdown")
	local Box = New("TextButton", {
		Text = "",
		Size = UDim2.fromOffset(150, 24),
		Position = UDim2.new(1, -154, 0, 3),
		BackgroundColor3 = C.Item,
		AutoButtonColor = false,
		BorderSizePixel = 0,
		Parent = Row,
	})
	Round(Box, 3)
	Atlantis(Box)
	HoverColor(Box, C.Item, C.Hover)
	local Label = New("TextLabel", {
		Text = "",
		FontFace = MonoBold,
		TextSize = 10,
		TextColor3 = C.TextPrimary,
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(8, 0),
		Size = UDim2.new(1, -24, 1, 0),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = Box,
	})
	local Chev = New("Frame", {Size = UDim2.fromOffset(10, 6), Position = UDim2.new(1, -16, 0.5, -3), BackgroundTransparency = 1, Parent = Box})
	DrawMap(Chev, ChevronMap, 2, C.TextSecondary)
	local Options = Cfg.Options or {}
	local Holder = New("Frame", {
		Size = UDim2.fromOffset(150, 0),
		Position = UDim2.new(1, -154, 0, 29),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		ZIndex = 12,
		Parent = Row,
	})
	local Inner = New("Frame", {
		Size = UDim2.new(1, 0, 0, #Options * 24),
		BackgroundColor3 = C.Item,
		BorderSizePixel = 0,
		ZIndex = 12,
		Parent = Holder,
	})
	Round(Inner, 3)
	Stroke(Inner, 1)
	New("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Parent = Inner})
	local Selected = {}
	for _, D in ipairs(Cfg.Default or {}) do
		Selected[D] = true
	end
	local Ticks = {}
	local Option = {Value = {}}
	local function Refresh(Silent)
		local Names = {}
		for _, N in ipairs(Options) do
			if Selected[N] then
				Names[#Names + 1] = N
			end
		end
		Option.Value = Names
		Label.Text = #Names > 0 and table.concat(Names, ", ") or "None"
		if not Silent and Cfg.Callback then
			pcall(Cfg.Callback, Names)
		end
	end
	local Open = false
	local function SetOpen(V)
		Open = V
		Row.ZIndex = V and 20 or 0
		if V then
			Play(Holder, {Size = UDim2.fromOffset(150, #Options * 24)}, 0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		else
			Play(Holder, {Size = UDim2.fromOffset(150, 0)}, 0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
		end
	end
	for I, Name in ipairs(Options) do
		local OBtn = New("TextButton", {
			Text = "",
			Size = UDim2.new(1, 0, 0, 24),
			BackgroundColor3 = C.Background,
			BackgroundTransparency = 1,
			AutoButtonColor = false,
			BorderSizePixel = 0,
			LayoutOrder = I,
			ZIndex = 13,
			Parent = Inner,
		})
		local Tick = New("Frame", {
			Size = UDim2.fromOffset(8, 8),
			Position = UDim2.fromOffset(8, 8),
			BackgroundColor3 = C.SelectBar,
			Visible = Selected[Name] and true or false,
			BorderSizePixel = 0,
			ZIndex = 14,
			Parent = OBtn,
		})
		Round(Tick, 2)
		Ticks[Name] = Tick
		New("TextLabel", {
			Text = Name,
			FontFace = Mono,
			TextSize = 10,
			TextColor3 = C.TextPrimary,
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(22, 0),
			Size = UDim2.new(1, -26, 1, 0),
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Center,
			TextTruncate = Enum.TextTruncate.AtEnd,
			ZIndex = 14,
			Parent = OBtn,
		})
		OBtn.MouseEnter:Connect(function()
			OBtn.BackgroundTransparency = 0
			OBtn.BackgroundColor3 = C.Hover
		end)
		OBtn.MouseLeave:Connect(function()
			OBtn.BackgroundTransparency = 1
		end)
		OBtn.Activated:Connect(function()
			Selected[Name] = not Selected[Name] or nil
			Tick.Visible = Selected[Name] and true or false
			Refresh()
		end)
	end
	Box.Activated:Connect(function()
		SetOpen(not Open)
	end)
	function Option.SetValue(_, List)
		Selected = {}
		for _, N in ipairs(List or {}) do
			Selected[N] = true
		end
		for N, T in pairs(Ticks) do
			T.Visible = Selected[N] and true or false
		end
		Refresh()
	end
	function Option.GetValue()
		return Option.Value
	end
	Refresh(true)
	return Option
end

function TabProto:AddSlider(Cfg)
	Cfg = Cfg or {}
	local Min = Cfg.Min or 0
	local Max = Cfg.Max or 100
	local Row = LibRowFrame(self, 30)
	LibTitle(Row, Cfg.Title or "Slider")
	local Track = New("Frame", {
		Size = UDim2.fromOffset(190, 6),
		Position = UDim2.new(1, -234, 0, 12),
		BackgroundColor3 = C.ItemHover,
		BorderSizePixel = 0,
		Parent = Row,
	})
	Round(Track, 3)
	Atlantis(Track)
	local Fill = New("Frame", {
		Size = UDim2.new(0.5, 0, 1, 0),
		BackgroundColor3 = C.Accent,
		BorderSizePixel = 0,
		Parent = Track,
	})
	local Knob = New("Frame", {
		Size = UDim2.fromOffset(14, 14),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		BackgroundColor3 = C.Knob,
		BorderSizePixel = 0,
		ZIndex = 2,
		Parent = Track,
	})
	Round(Knob, 7)
	local Val = New("TextLabel", {
		Text = "",
		FontFace = MonoBold,
		TextSize = 10,
		TextColor3 = C.TextPrimary,
		BackgroundTransparency = 1,
		Position = UDim2.new(1, -36, 0, 0),
		Size = UDim2.fromOffset(36, 30),
		TextXAlignment = Enum.TextXAlignment.Right,
		TextYAlignment = Enum.TextYAlignment.Center,
		Parent = Row,
	})
	local Option = {Value = Cfg.Default or Min}
	local function Set(V, Silent)
		V = math.clamp(math.floor(V), Min, Max)
		Option.Value = V
		local Rel = (V - Min) / math.max(Max - Min, 1)
		Play(Fill, {Size = UDim2.new(Rel, 0, 1, 0)}, 0.08, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
		Knob.Position = UDim2.new(Rel, 0, 0.5, 0)
		Val.Text = tostring(V)
		if not Silent and Cfg.Callback then
			pcall(Cfg.Callback, V)
		end
	end
	local Slide = false
	local function FromX(X)
		local Rel = math.clamp((X - Track.AbsolutePosition.X) / math.max(Track.AbsoluteSize.X, 1), 0, 1)
		Set(Min + Rel * (Max - Min))
	end
	Track.InputBegan:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
			Slide = true
			Play(Knob, {BackgroundColor3 = C.Accent}, 0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
			FromX(Input.Position.X)
		end
	end)
	Knob.InputBegan:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
			Slide = true
			Play(Knob, {BackgroundColor3 = C.Accent}, 0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
			FromX(Input.Position.X)
		end
	end)
	UserInputService.InputChanged:Connect(function(Input)
		if Slide and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
			FromX(Input.Position.X)
		end
	end)
	UserInputService.InputEnded:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
			if Slide then
				Play(Knob, {BackgroundColor3 = C.Knob}, 0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
			end
			Slide = false
		end
	end)
	function Option.SetValue(_, V)
		Set(V)
	end
	Set(Option.Value, true)
	if Cfg.Callback then
		pcall(Cfg.Callback, Option.Value)
	end
	return Option
end

function TabProto:AddDiscordInvite(Cfg)
	Cfg = Cfg or {}
	local Card = New("Frame", {
		Size = UDim2.new(1, 0, 0, 80),
		BackgroundColor3 = C.Item,
		BorderSizePixel = 0,
		Parent = self.Page,
	})
	Round(Card, 4)
	local CardStroke = Stroke(Card, 1.5, C.Border, 0)
	local Grad = New("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(45, 110, 200)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(130, 195, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(45, 110, 200)),
		}),
		Parent = CardStroke,
	})
	local Banner = New("ImageLabel", {
		Image = Cfg.Banner or "",
		ScaleType = Enum.ScaleType.Crop,
		Size = UDim2.new(1, 0, 0.4, 0),
		ImageColor3 = Color3.fromRGB(90, 160, 235),
		ImageTransparency = 0.55,
		BackgroundTransparency = 1,
		ZIndex = 4,
		Parent = Card,
	})
	New("UIGradient", {
		Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0)}),
		Rotation = 270,
		Parent = Banner,
	})
	local Logo = New("ImageLabel", {
		Image = Cfg.Logo or "",
		Size = UDim2.fromOffset(32, 32),
		Position = UDim2.fromOffset(8, 16),
		BackgroundColor3 = C.Panel,
		BorderSizePixel = 0,
		ZIndex = 5,
		Parent = Card,
	})
	Round(Logo, 6)
	New("TextLabel", {
		Text = Cfg.Title or "Discord",
		FontFace = MonoBold,
		TextSize = 12,
		TextColor3 = C.TextPrimary,
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(48, 38),
		Size = UDim2.new(1, -170, 0, 14),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ZIndex = 5,
		Parent = Card,
	})
	local Info = {}
	if Cfg.Members then Info[#Info + 1] = Comma(Cfg.Members) .. " MEMBERS" end
	if Cfg.Online then Info[#Info + 1] = Comma(Cfg.Online) .. " ONLINE" end
	New("TextLabel", {
		Text = table.concat(Info, "   "),
		FontFace = Mono,
		TextSize = 10,
		TextColor3 = C.TextSecondary,
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(48, 54),
		Size = UDim2.new(1, -170, 0, 12),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ZIndex = 5,
		Parent = Card,
	})
	local Join = New("TextButton", {
		Text = "JOIN",
		FontFace = MonoBold,
		TextSize = 12,
		TextColor3 = C.White,
		Size = UDim2.fromOffset(70, 28),
		Position = UDim2.new(1, -80, 0.5, -14),
		BackgroundColor3 = C.Accent,
		AutoButtonColor = false,
		BorderSizePixel = 0,
		ZIndex = 5,
		Parent = Card,
	})
	Round(Join, 4)
	HoverColor(Join, C.Accent, C.LoadHover)
	Join.Activated:Connect(function()
		if Cfg.Invite then
			pcall(function()
				local Fn = setclipboard or toclipboard or set_clipboard or writeclipboard
				if Fn then Fn(Cfg.Invite) end
			end)
		end
		if self.Window.Notify then
			self.Window:Notify("Discord invite copied")
		end
	end)
	local ShA = {Color3.fromRGB(45, 110, 200), Color3.fromRGB(130, 195, 255), Color3.fromRGB(45, 110, 200)}
	local ShB = {Color3.fromRGB(130, 195, 255), Color3.fromRGB(45, 110, 200), Color3.fromRGB(130, 195, 255)}
	local ShV = New("NumberValue", {Value = 0, Parent = Card})
	ShV.Changed:Connect(function(V)
		Grad.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, ShA[1]:Lerp(ShB[1], V)),
			ColorSequenceKeypoint.new(0.5, ShA[2]:Lerp(ShB[2], V)),
			ColorSequenceKeypoint.new(1, ShA[3]:Lerp(ShB[3], V)),
		})
	end)
	if TaskWait then
		TaskSpawn(function()
			local Flip = false
			while Card.Parent do
				ShV.Value = Flip and 1 or 0
				Play(ShV, {Value = Flip and 0 or 1}, 3)
				Flip = not Flip
				TaskWait(3)
			end
		end)
	end
	if Cfg.Description then
		self:AddParagraph("", Cfg.Description)
	end
	return Card
end

function TabProto:AddLabel(Text)
	return New("TextLabel", {
		Text = Text,
		FontFace = Mono,
		TextSize = 10,
		TextColor3 = C.TextSecondary,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 16),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		Parent = self.Page,
	})
end

function TabProto:AddTextbox(Cfg)
	Cfg = Cfg or {}
	local Row = LibRowFrame(self, 30)
	LibTitle(Row, Cfg.Title or "Input")
	local Box = New("TextBox", {
		Size = UDim2.fromOffset(150, 24),
		Position = UDim2.new(1, -154, 0, 3),
		BackgroundColor3 = C.Item,
		BorderSizePixel = 0,
		Text = Cfg.Default or "",
		PlaceholderText = Cfg.Placeholder or "...",
		PlaceholderColor3 = Color3.fromRGB(70, 105, 160),
		FontFace = Mono,
		TextSize = 10,
		TextColor3 = C.TextPrimary,
		TextXAlignment = Enum.TextXAlignment.Left,
		ClearTextOnFocus = false,
		Parent = Row,
	})
	Round(Box, 3)
	Atlantis(Box)
	New("UIPadding", {PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6), Parent = Box})
	Box.FocusLost:Connect(function()
		if Cfg.Callback then
			pcall(Cfg.Callback, Box.Text)
		end
	end)
	local Option = {Value = Cfg.Default or ""}
	function Option.SetValue(_, Value)
		Box.Text = Value
		Option.Value = Value
		if Cfg.Callback then
			pcall(Cfg.Callback, Value)
		end
	end
	return Option
end

function TabProto:AddKeybind(Cfg)
	Cfg = Cfg or {}
	local Row = LibRowFrame(self)
	LibTitle(Row, Cfg.Title or "Keybind")
	local Key = Cfg.Default or "None"
	local Box = New("TextButton", {
		Text = "[" .. Key .. "]",
		FontFace = MonoBold,
		TextSize = 10,
		TextColor3 = C.TextPrimary,
		Size = UDim2.fromOffset(90, 22),
		Position = UDim2.new(1, -94, 0, 3),
		BackgroundColor3 = C.Item,
		AutoButtonColor = false,
		BorderSizePixel = 0,
		Parent = Row,
	})
	Round(Box, 3)
	Atlantis(Box)
	HoverColor(Box, C.Item, C.Hover)
	PressAnim(Box)
	local CapturingK = false
	Box.Activated:Connect(function()
		CapturingK = true
		Box.Text = "PRESS KEY..."
		TaskDelay(3, function()
			if CapturingK and Box.Parent then
				CapturingK = false
				Box.Text = "[" .. Key .. "]"
			end
		end)
	end)
	UserInputService.InputBegan:Connect(function(Input, Processed)
		if CapturingK and not Processed and Input.UserInputType == Enum.UserInputType.Keyboard then
			CapturingK = false
			Key = Input.KeyCode.Name
			Box.Text = "[" .. Key .. "]"
			if Cfg.Callback then
				pcall(Cfg.Callback, Key)
			end
		end
	end)
	if Cfg.KeyCode then
		UserInputService.InputBegan:Connect(function(Input, Processed)
			if not Processed and Input.KeyCode == Cfg.KeyCode then
				if Cfg.Callback then
					pcall(Cfg.Callback, Key)
				end
			end
		end)
	end
	local Option = {Value = Key}
	function Option.SetValue(_, Value)
		Key = Value
		Option.Value = Value
		Box.Text = "[" .. Value .. "]"
	end
	return Option
end

function TabProto:AddColorpicker(Cfg)
	Cfg = Cfg or {}
	local Row = LibRowFrame(self)
	LibTitle(Row, Cfg.Title or "Color")
	local Col = Cfg.Default or C.Accent
	local Swatch = New("TextButton", {
		Text = "",
		Size = UDim2.fromOffset(30, 20),
		Position = UDim2.new(1, -34, 0, 4),
		BackgroundColor3 = Col,
		AutoButtonColor = false,
		BorderSizePixel = 0,
		Parent = Row,
	})
	Round(Swatch, 3)
	Atlantis(Swatch)
	local Panel = New("Frame", {
		Size = UDim2.fromOffset(150, 12),
		Position = UDim2.new(1, -188, 0, 8),
		BackgroundColor3 = C.Item,
		BorderSizePixel = 0,
		Visible = false,
		ZIndex = 12,
		Parent = Row,
	})
	Round(Panel, 3)
	Stroke(Panel, 1)
	local HueFill = New("Frame", {
		Size = UDim2.new(1, -2, 1, -2),
		Position = UDim2.fromOffset(1, 1),
		BorderSizePixel = 0,
		Parent = Panel,
	})
	Round(HueFill, 2)
	local Grad = New("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
			ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255, 255, 0)),
			ColorSequenceKeypoint.new(0.4, Color3.fromRGB(0, 255, 0)),
			ColorSequenceKeypoint.new(0.6, Color3.fromRGB(0, 255, 255)),
			ColorSequenceKeypoint.new(0.8, Color3.fromRGB(0, 0, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 255)),
		}),
		Parent = HueFill,
	})
	local OpenC = false
	local function ApplyHue(X)
		local Rel = math.clamp((X - HueFill.AbsolutePosition.X) / math.max(HueFill.AbsoluteSize.X, 1), 0, 1)
		Col = Color3.fromHSV(Rel, 1, 1)
		Swatch.BackgroundColor3 = Col
		if Cfg.Callback then
			pcall(Cfg.Callback, Col)
		end
	end
	Swatch.Activated:Connect(function()
		OpenC = not OpenC
		Panel.Visible = OpenC
		Row.ZIndex = OpenC and 20 or 0
	end)
	HueFill.InputBegan:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
			ApplyHue(Input.Position.X)
		end
	end)
	UserInputService.InputChanged:Connect(function(Input)
		if Panel.Visible and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
			if InElement(Input.Position, Panel) then
				ApplyHue(Input.Position.X)
			end
		end
	end)
	UserInputService.InputBegan:Connect(function(Input)
		if OpenC and (Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch) then
			if not InElement(Input.Position, Panel) and not InElement(Input.Position, Swatch) then
				OpenC = false
				Panel.Visible = false
				Row.ZIndex = 0
			end
		end
	end)
	local Option = {Value = Col}
	function Option.SetValue(_, Value)
		Col = Value
		Option.Value = Value
		Swatch.BackgroundColor3 = Value
		if Cfg.Callback then
			pcall(Cfg.Callback, Value)
		end
	end
	return Option
end

function TabProto:AddPixel(Cfg)
	Cfg = Cfg or {}
	local Cell = Cfg.Cell or 3
	local Colors = Cfg.Colors or {C.Blue}
	local W = 0
	local H = 0
	for _, P in ipairs(Cfg.Map or {}) do
		local Sz = P[3] or 1
		W = math.max(W, P[1] + Sz)
		H = math.max(H, P[2] + Sz)
	end
	local Holder = New("Frame", {
		Size = UDim2.fromOffset(W * Cell, H * Cell),
		BackgroundTransparency = 1,
		Parent = self.Page,
	})
	for _, P in ipairs(Cfg.Map or {}) do
		local Sz = P[3] or 1
		New("Frame", {
			Position = UDim2.fromOffset(P[1] * Cell, P[2] * Cell),
			Size = UDim2.fromOffset(Sz * Cell, Sz * Cell),
			BackgroundColor3 = Colors[P[4] or 1] or Colors[1],
			BorderSizePixel = 0,
			Parent = Holder,
		})
	end
	return Holder
end

function WindowProto:MakeTab(Cfg)
	Cfg = Cfg or {}
	local Tab = {Title = Cfg.Title or "Tab", Window = self}
	setmetatable(Tab, {__index = TabProto})
	local Index = #self.Tabs + 1
	local Button = New("TextButton", {
		Text = "",
		Size = UDim2.new(1, 0, 0, 40),
		BackgroundColor3 = C.Item,
		AutoButtonColor = false,
		BorderSizePixel = 0,
		LayoutOrder = Index,
		Parent = self.TabList,
	})
	Round(Button, 4)
	local BtnStroke = Stroke(Button, 1, C.SelectBar, 1)
	New("TextLabel", {
		Text = Tab.Title,
		FontFace = MonoBold,
		TextSize = 11,
		TextColor3 = C.TextPrimary,
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(12, 0),
		Size = UDim2.new(1, -24, 1, 0),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = Button,
	})
	local Bar = New("Frame", {
		Size = UDim2.fromOffset(3, 40),
		BackgroundColor3 = C.SelectBar,
		BorderSizePixel = 0,
		Visible = false,
		ZIndex = 2,
		Parent = Button,
	})
	local BtnScale = PressAnim(Button)
	Button.MouseEnter:Connect(function()
		if self.ActiveTab ~= Tab then
			Button.BackgroundColor3 = C.ItemHover
		end
	end)
	Button.MouseLeave:Connect(function()
		if self.ActiveTab ~= Tab then
			Button.BackgroundColor3 = C.Item
		end
	end)
	local Page = New("ScrollingFrame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 2,
		ScrollBarImageColor3 = C.Border,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		TouchScrollEnabled = true,
		Visible = false,
		Parent = self.PageHolder,
	})
	New("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder, Parent = Page})
	Pad(Page, 6)
	Tab.Button = Button
	Tab.Bar = Bar
	Tab.Stroke = BtnStroke
	Tab.Scale = BtnScale
	Tab.Page = Page
	Button.Activated:Connect(function()
		self:SelectTab(Tab)
	end)
	self.Tabs[Index] = Tab
	if not self.ActiveTab then
		self:SelectTab(Tab)
	end
	return Tab
end

function WindowProto:SelectTab(Tab)
	self.ActiveTab = Tab
	for _, T in ipairs(self.Tabs) do
		local IsSel = T == Tab
		if IsSel then
			Play(T.Button, {BackgroundColor3 = C.Selected}, 0.2)
			T.Bar.Visible = true
			T.Bar.Size = UDim2.fromOffset(3, 0)
			Play(T.Bar, {Size = UDim2.fromOffset(3, 40)}, 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
			T.Stroke.Transparency = 0
			Play(T.Scale, {Scale = 1.08}, 0.125, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
			TaskDelay(0.125, function()
				if T.Scale.Parent then
					Play(T.Scale, {Scale = 1.0}, 0.125, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
				end
			end)
		else
			T.Button.BackgroundColor3 = C.Item
			T.Bar.Visible = false
			T.Stroke.Transparency = 1
		end
		T.Page.Visible = IsSel
	end
end

function WindowProto:Notify(Msg)
	library.Notify(nil, Msg)
end

function WindowProto:NewMinimizer(Cfg)
	Cfg = Cfg or {}
	local Min = {Window = self}
	setmetatable(Min, {__index = MinProto})
	local W = self
	if Cfg.KeyCode then
		UserInputService.InputBegan:Connect(function(Input, Processed)
			if not Processed and Input.KeyCode == Cfg.KeyCode then
				W.Minimized = not W.Minimized
				W:ApplyMinimize()
			end
		end)
	end
	return Min
end

function MinProto:CreateMobileMinimizer(Cfg)
	Cfg = Cfg or {}
	local W = self.Window
	local Btn = New("TextButton", {
		Text = "",
		Size = UDim2.fromOffset(44, 44),
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 12, 1, -12),
		BackgroundColor3 = Cfg.BackgroundColor3 or Color3.fromRGB(10, 30, 70),
		BackgroundTransparency = 0.15,
		AutoButtonColor = false,
		BorderSizePixel = 0,
		ZIndex = 10,
		Parent = LibGui,
	})
	New("UICorner", {CornerRadius = UDim.new(0, 8), Parent = Btn})
	local BStroke = New("UIStroke", {Thickness = 1.5, Color = Color3.fromRGB(65, 145, 230), Transparency = 0.3, Parent = Btn})
	local BScale = New("UIScale", {Parent = Btn})
	local Icon = New("ImageLabel", {
		Image = Cfg.Image or "",
		Size = UDim2.fromOffset(26, 26),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundTransparency = 1,
		ZIndex = 10,
		Parent = Btn,
	})
	Btn.MouseEnter:Connect(function()
		Play(BScale, {Scale = 1.1}, 0.15)
		Play(BStroke, {Transparency = 0}, 0.15)
	end)
	Btn.MouseLeave:Connect(function()
		Play(BScale, {Scale = 1.0}, 0.2)
		Play(BStroke, {Transparency = 0.3}, 0.2)
	end)
	Btn.Activated:Connect(function()
		Play(BScale, {Scale = 0.88}, 0.1)
		TaskDelay(0.1, function()
			Play(BScale, {Scale = 1.0}, 0.2)
		end)
		W.Minimized = not W.Minimized
		W:ApplyMinimize()
		Play(Icon, {Rotation = W.Minimized and 180 or 0}, 0.3)
	end)
	return Btn
end

function WindowProto:ApplyMinimize()
	local TargetSize = self.Minimized and UDim2.fromOffset(780, 36) or UDim2.fromOffset(780, 500)
	local TargetY = self.Minimized and (self.Root.Position.Y.Offset - 232) or (self.Root.Position.Y.Offset + 232)
	Play(self.Root, {Size = TargetSize, Position = UDim2.new(self.Root.Position.X.Scale, self.Root.Position.X.Offset, self.Root.Position.Y.Scale, TargetY)})
end

function WindowProto:Toggle()
	self.Root.Visible = not self.Root.Visible
	return self.Root.Visible
end

function WindowProto:SetScale(S)
	self.ManualScale = math.clamp(S or 1, 0.3, 1)
	if self.ScaleObj then
		self.ScaleObj.Scale = self.ManualScale
	end
	return self.ManualScale
end

function WindowProto:SetColors(Cfg)
	Cfg = Cfg or {}
	for K, V in pairs(Cfg) do
		if C[K] ~= nil then
			C[K] = V
		end
	end
	self.Root.BackgroundColor3 = C.Background
	if self.TopBar then self.TopBar.BackgroundColor3 = C.Panel end
	if self.LeftPanel then self.LeftPanel.BackgroundColor3 = C.SidePanel end
	if self.RightPanel then self.RightPanel.BackgroundColor3 = C.Background end
	for _, T in ipairs(self.Tabs) do
		T.Button.BackgroundColor3 = (T == self.ActiveTab) and C.Selected or C.Item
	end
end

function WindowProto:Destroy()
	self.Root:Destroy()
end

function library.MakeWindow(_, Options)
	Options = Options or {}
	if not LibGui then
		LibGui = New("ScreenGui", {Name = "ScriptBrowserLib", IgnoreGuiInset = true, ResetOnSpawn = false, DisplayOrder = 1000, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, Parent = RootParent})
	end
	local Win = New("Frame", {
		Size = UDim2.fromOffset(780, 500),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = C.Background,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Parent = LibGui,
	})
	Round(Win, 4)
	Stroke(Win, 1.5)
	local WScale = New("UIScale", {Parent = Win})
	Win.Size = UDim2.fromOffset(0, 0)
	Win.BackgroundTransparency = 1
	WScale.Scale = 0.7
	TaskSpawn(function()
		TaskWait()
		Play(Win, {Size = UDim2.fromOffset(780, 500), BackgroundTransparency = 0}, 0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		Play(WScale, {Scale = 1.0}, 0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	end)
	local TopBar = New("Frame", {
		Size = UDim2.new(1, 0, 0, 36),
		BackgroundColor3 = C.Panel,
		BorderSizePixel = 0,
		Parent = Win,
	})
	Round(TopBar, 4)
	local Gear = New("Frame", {Size = UDim2.fromOffset(18, 18), Position = UDim2.fromOffset(10, 9), BackgroundTransparency = 1, Parent = TopBar})
	DrawMap(Gear, GearMap, 2, C.White)
	New("TextLabel", {
		Text = string.upper(Options.Title or "SCRIPT BROWSER"),
		FontFace = MonoBold,
		TextSize = 13,
		TextColor3 = C.TextPrimary,
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(36, 0),
		Size = UDim2.new(0.5, -40, 1, 0),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		Parent = TopBar,
	})
	if Options.SubTitle then
		New("TextLabel", {
			Text = Options.SubTitle,
			FontFace = Mono,
			TextSize = 10,
			TextColor3 = C.TextSecondary,
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(36, 0),
			Size = UDim2.new(1, -120, 1, 0),
			TextXAlignment = Enum.TextXAlignment.Right,
			TextYAlignment = Enum.TextYAlignment.Center,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Parent = TopBar,
		})
	end
	New("Frame", {Position = UDim2.fromOffset(0, 36), Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = C.Border, BorderSizePixel = 0, ZIndex = 2, Parent = Win})
	New("Frame", {Position = UDim2.fromOffset(220, 37), Size = UDim2.new(0, 1, 1, -37), BackgroundColor3 = C.Border, BorderSizePixel = 0, ZIndex = 2, Parent = Win})
	local LeftPanel = New("Frame", {
		Size = UDim2.new(0, 220, 1, -36),
		Position = UDim2.fromOffset(0, 36),
		BackgroundColor3 = C.SidePanel,
		BorderSizePixel = 0,
		Parent = Win,
	})
	local TabList = New("ScrollingFrame", {
		Position = UDim2.fromOffset(8, 8),
		Size = UDim2.new(1, -16, 1, -16),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 2,
		ScrollBarImageColor3 = C.Border,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		TouchScrollEnabled = true,
		Parent = LeftPanel,
	})
	New("UIListLayout", {Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder, Parent = TabList})
	Pad(TabList, 4)
	local RightPanel = New("Frame", {
		Position = UDim2.fromOffset(221, 37),
		Size = UDim2.new(1, -221, 1, -37),
		BackgroundColor3 = C.Background,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Parent = Win,
	})
	local PageHolder = New("Frame", {
		Size = UDim2.new(1, -28, 1, -80),
		Position = UDim2.fromOffset(14, 14),
		BackgroundTransparency = 1,
		Parent = RightPanel,
	})
	local Ocean = New("Frame", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Parent = RightPanel})
	local Weed = New("Frame", {Size = UDim2.fromOffset(24, 20), Position = UDim2.new(0, 6, 1, -20), BackgroundTransparency = 1, Parent = Ocean})
	DrawMap(Weed, WeedMap, 2, C.Weed)
	DrawMap(Weed, WeedLightMap, 2, C.WeedLight)
	local Weed2 = New("Frame", {Size = UDim2.fromOffset(22, 28), Position = UDim2.new(1, -30, 1, -28), BackgroundTransparency = 1, Parent = Ocean})
	DrawMap(Weed2, WeedTallMap, 2, C.Weed)
	DrawMap(Weed2, WeedTallLightMap, 2, C.WeedLight)
	if TaskWait then
		TaskSpawn(function()
			while Ocean.Parent do
				TaskWait(1 + math.random())
				local Sz = 3 + math.random() * 4
				local X = 0.05 + math.random() * 0.9
				local B = New("Frame", {
					Size = UDim2.fromOffset(Sz, Sz),
					Position = UDim2.new(X, 0, 1, 4),
					BackgroundColor3 = math.random() < 0.5 and C.Blue or C.WeedLight,
					BackgroundTransparency = 0.55,
					BorderSizePixel = 0,
					Parent = Ocean,
				})
				New("UICorner", {CornerRadius = UDim.new(1, 0), Parent = B})
				local T = 3.5 + math.random() * 2.5
				local Drift = math.random() * 24 - 12
				Play(B, {Position = UDim2.new(X, Drift, 1, -(Ocean.AbsoluteSize.Y + 10)), BackgroundTransparency = 0.95}, T, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
				TaskDelay(T, function()
					B:Destroy()
				end)
			end
		end)
	end
	MakeLeaves(Win, 40, 3)
	local CloseBtn = New("TextButton", {
		Text = "×",
		FontFace = MonoBold,
		TextSize = 14,
		TextColor3 = C.TextPrimary,
		Size = UDim2.fromOffset(20, 20),
		Position = UDim2.new(1, -30, 0, 8),
		BackgroundColor3 = C.Item,
		AutoButtonColor = false,
		BorderSizePixel = 0,
		Parent = TopBar,
	})
	Round(CloseBtn, 3)
	Stroke(CloseBtn, 1, C.Border, 0.35)
	HoverColor(CloseBtn, C.Item, C.Yes)
	PressAnim(CloseBtn)
	local Overlay = New("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0.4,
		Visible = false,
		ZIndex = 50,
		Active = true,
		BorderSizePixel = 0,
		Parent = Win,
	})
	local Dialog = New("Frame", {
		Size = UDim2.fromOffset(280, 170),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		BackgroundColor3 = C.Panel,
		BorderSizePixel = 0,
		ZIndex = 51,
		Parent = Overlay,
	})
	Round(Dialog, 4)
	Stroke(Dialog, 1.5)
	MakeLeaves(Dialog, 28, 53)
	local DialogScale = New("UIScale", {Parent = Dialog})
	New("TextLabel", {
		Text = "CLOSE UI?",
		FontFace = MonoBold,
		TextSize = 16,
		TextColor3 = C.TextPrimary,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 16),
		Size = UDim2.new(1, 0, 0, 20),
		TextXAlignment = Enum.TextXAlignment.Center,
		ZIndex = 54,
		Parent = Dialog,
	})
	New("TextLabel", {
		Text = "Are you sure? The window\nwill be destroyed.",
		FontFace = Mono,
		TextSize = 12,
		TextColor3 = C.TextSecondary,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 20, 0, 56),
		Size = UDim2.new(1, -40, 0, 36),
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextWrapped = true,
		ZIndex = 54,
		Parent = Dialog,
	})
	local YesBtn = New("TextButton", {
		Text = "YES",
		FontFace = MonoBold,
		TextSize = 13,
		TextColor3 = C.White,
		Size = UDim2.fromOffset(110, 34),
		Position = UDim2.fromOffset(20, 116),
		BackgroundColor3 = C.Yes,
		AutoButtonColor = false,
		BorderSizePixel = 0,
		ZIndex = 54,
		Parent = Dialog,
	})
	Round(YesBtn, 4)
	Stroke(YesBtn, 1.5)
	HoverColor(YesBtn, C.Yes, C.YesHover)
	local NoBtn = New("TextButton", {
		Text = "NO",
		FontFace = MonoBold,
		TextSize = 13,
		TextColor3 = C.White,
		Size = UDim2.fromOffset(110, 34),
		Position = UDim2.fromOffset(150, 116),
		BackgroundColor3 = C.Selected,
		AutoButtonColor = false,
		BorderSizePixel = 0,
		ZIndex = 54,
		Parent = Dialog,
	})
	Round(NoBtn, 4)
	Stroke(NoBtn, 1.5)
	HoverColor(NoBtn, C.Selected, C.ActionHover)
	CloseBtn.Activated:Connect(function()
		Overlay.Visible = true
		Overlay.BackgroundTransparency = 1
		DialogScale.Scale = 0.85
		Play(Overlay, {BackgroundTransparency = 0.4})
		Play(DialogScale, {Scale = 1})
	end)
	NoBtn.Activated:Connect(function()
		Play(Overlay, {BackgroundTransparency = 1})
		TaskDelay(0.2, function()
			Overlay.Visible = false
		end)
	end)
	YesBtn.Activated:Connect(function()
		Win:Destroy()
	end)
	local Window = {
		Root = Win,
		ScaleObj = WScale,
		TopBar = TopBar,
		LeftPanel = LeftPanel,
		RightPanel = RightPanel,
		TabList = TabList,
		PageHolder = PageHolder,
		Tabs = {},
		ActiveTab = nil,
		Minimized = false,
		Options = Options,
	}
	setmetatable(Window, {__index = WindowProto})
	local DraggingW = false
	local DragStartW, DragOriginW
	TopBar.InputBegan:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
			DraggingW = true
			DragStartW = Input.Position
			DragOriginW = Win.Position
		end
	end)
	UserInputService.InputChanged:Connect(function(Input)
		if DraggingW and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
			local Delta = Input.Position - DragStartW
			local S = WScale.Scale
			local VX, VY = LibViewSize()
			local MX = math.clamp(DragOriginW.X.Offset + Delta.X / S, 100 - VX / 2, VX / 2 - 100)
			local MY = math.clamp(DragOriginW.Y.Offset + Delta.Y / S, 60 - VY / 2, VY / 2 - 60)
			Win.Position = UDim2.new(0.5, MX, 0.5, MY)
		end
	end)
	UserInputService.InputEnded:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
			DraggingW = false
		end
	end)
	local function UpdateScaleW()
		if Window.ManualScale then
			WScale.Scale = Window.ManualScale
		else
			local VX, VY = LibViewSize()
			WScale.Scale = math.clamp(math.min(VX * 0.88 / 780, VY * 0.75 / 500), 0.3, 0.65)
		end
		if not DraggingW and not Window.Minimized then
			Win.Position = UDim2.new(0.5, 0, 0.5, 0)
		end
	end
	UpdateScaleW()
	if LibGui then
		pcall(function()
			LibGui:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateScaleW)
		end)
	end
	workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
		local Cam2 = workspace.CurrentCamera
		if Cam2 then
			pcall(function()
				Cam2:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateScaleW)
			end)
		end
		UpdateScaleW()
	end)
	if TaskWait then
		TaskSpawn(function()
			for _ = 1, 30 do
				UpdateScaleW()
				TaskWait(0.1)
			end
		end)
	end
	local Cam = workspace.CurrentCamera
	if Cam then
		Cam:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateScaleW)
	end
	library.ActiveWindow = Window
	return Window
end

local Toasts = {}

local function ToastReflow()
	for I, T in ipairs(Toasts) do
		Play(T, {Position = UDim2.new(1, -10, 0, 44 + (I - 1) * 36)}, 0.2)
	end
end

function library.Notify(_, Msg)
	if not LibGui then
		LibGui = New("ScreenGui", {Name = "ScriptBrowserLib", IgnoreGuiInset = true, ResetOnSpawn = false, DisplayOrder = 1000, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, Parent = RootParent})
	end
	local Frame = New("Frame", {
		Size = UDim2.fromOffset(240, 30),
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 250, 0, 44 + #Toasts * 36),
		BackgroundColor3 = C.Panel,
		BorderSizePixel = 0,
		ZIndex = 60,
		Parent = LibGui,
	})
	Round(Frame, 4)
	Stroke(Frame, 1.5, C.Accent, 0.2)
	local Dot = New("Frame", {
		Size = UDim2.fromOffset(6, 6),
		Position = UDim2.fromOffset(8, 12),
		BackgroundColor3 = C.SelectBar,
		BorderSizePixel = 0,
		Parent = Frame,
	})
	Round(Dot, 3)
	New("TextLabel", {
		Text = Msg,
		FontFace = MonoBold,
		TextSize = 11,
		TextColor3 = C.TextPrimary,
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(20, 0),
		Size = UDim2.new(1, -26, 1, 0),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = Frame,
	})
	Toasts[#Toasts + 1] = Frame
	Play(Frame, {Position = UDim2.new(1, -10, 0, 44 + (#Toasts - 1) * 36)}, 0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	TaskDelay(2.5, function()
		for I, T in ipairs(Toasts) do
			if T == Frame then
				table.remove(Toasts, I)
				break
			end
		end
		ToastReflow()
		Play(Frame, {Position = UDim2.new(1, 250, 0, Frame.Position.Y.Offset)}, 0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
		TaskDelay(0.25, function()
			Frame:Destroy()
		end)
	end)
end

return library
