-- [[ AKATSUKI UI ONLY [v5.7.2] - REFINED UNIFIED EDITION — FIXED BUILD ]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local ContentProvider = game:GetService("ContentProvider")

local player = Players.LocalPlayer

-- ==================== ESTADO DOS TOGGLES DA UI ====================
local Configs = {
	ESP         = false,
	Aimbot      = false,
	Speed       = false,
	Reach       = false,
	AntiFling   = false,
	TpToGun     = false,
	SafeSpot    = false,
	AutoCollect = false,
	ChatRoles   = false
}

-- ==================== DYNAMIC UI COMPONENT & STATE MACHINE ====================
local UIState = "CLOSED"

local UI_TEXT = {
	SearchPlaceholder = "Search...",
	ConfirmCloseTitle = "Do you want to close the script?",
	ConfirmBtn        = "Yes",
	CancelBtn         = "No",
	Intro             = '<font color="#FFFFFF">Scripts by | </font><font color="#8B0000">AKATSUKI</font>',
	Tabs              = { Player = "Player", Combat = "Combat", Visuals = "Visuals", Teleports = "Teleports", Settings = "Settings" },
	Options           = {
		Aimbot      = { Title = "Aimbot Murderer",  Desc = "Automatic aimbot that stays in the murderer's head non-stop." },
		Reach       = { Title = "Knife Reach",       Desc = "Significantly increases your knife attack reach (18 studs)." },
		ESP         = { Title = "Player ESP",        Desc = "Highlights players through walls (Sheriff Blue / Hero Yellow)." },
		Speed       = { Title = "WalkSpeed",         Desc = "Slightly increases player walkspeed up to 23 smoothly." },
		AntiFling   = { Title = "Anti-Fling",        Desc = "Disables collisions to prevent other players from flinging you." },
		TpToGun     = { Title = "TP to Gun",         Desc = "Teleports to dropped gun (Automatically disabled for the Murderer)." },
		SafeSpot    = { Title = "Safe Spot",         Desc = "Teleports you to an invisible sky platform to remain completely safe." },
		AutoCollect = { Title = "Auto Collect",      Desc = "Smoothly collects coins continuously without clunky visual stops." },
		ChatRoles   = { Title = "Reveal Roles",      Desc = "Sends a message in chat revealing active roles." }
	}
}

local activeTab     = "Player"
local tabButtons    = {}
local isExpanded    = false
local originalTrans = {}
local isConfirmOpen = false

-- ==================== SCREENGUI ====================
local screenGui           = Instance.new("ScreenGui")
screenGui.Name            = "DeltaAkatUniversalUI"
screenGui.ResetOnSpawn    = false
screenGui.IgnoreGuiInset  = true
screenGui.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling

local uiParent = player:FindFirstChild("PlayerGui")
if gethui then
	uiParent = gethui()
else
	pcall(function() uiParent = game:GetService("CoreGui") end)
end

if uiParent:FindFirstChild("DeltaAkatUniversalUI") then
	pcall(function() uiParent.DeltaAkatUniversalUI:Destroy() end)
end

for _, bf in ipairs(Lighting:GetChildren()) do
	if bf:IsA("BlurEffect") and (bf.Name == "ConfirmBlur" or bf.Name == "IntroBlur") then
		pcall(function() bf:Destroy() end)
	end
end

screenGui.Parent = uiParent

local SharedClickSound     = Instance.new("Sound", screenGui)
SharedClickSound.Name      = "SharedClickSound"
SharedClickSound.SoundId   = "rbxassetid://6895079853"
SharedClickSound.Volume    = 0.6
SharedClickSound.Looped    = false

local function PlayUI_Click()
	pcall(function()
		SharedClickSound.TimePosition = 0
		SharedClickSound:Play()
	end)
end

local function RegistrarTransparencias(objeto)
	if originalTrans[objeto] then return end
	if objeto:IsA("Frame") or objeto:IsA("ScrollingFrame") or objeto:IsA("CanvasGroup") then
		originalTrans[objeto] = { BackgroundTransparency = objeto.BackgroundTransparency }
	elseif objeto:IsA("TextLabel") or objeto:IsA("TextButton") or objeto:IsA("TextBox") then
		originalTrans[objeto] = { TextTransparency = objeto.TextTransparency, BackgroundTransparency = objeto.BackgroundTransparency, TextStrokeTransparency = objeto.TextStrokeTransparency or 1 }
	elseif objeto:IsA("ImageLabel") or objeto:IsA("ImageButton") then
		originalTrans[objeto] = { ImageTransparency = objeto.ImageTransparency, BackgroundTransparency = objeto.BackgroundTransparency }
	elseif objeto:IsA("UIStroke") then
		originalTrans[objeto] = { Transparency = objeto.Transparency }
	end
end

local function AplicarFadeSincronizado(raiz, fadeOut, duracao)
	if not raiz or not raiz.Parent then return end
	local info = TweenInfo.new(duracao, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
	local function tratarObjeto(obj)
		if not obj or not obj.Parent then return end
		RegistrarTransparencias(obj)
		local orig = originalTrans[obj]
		if not orig then return end
		if orig.BackgroundTransparency ~= nil then
			local t = fadeOut and 1 or orig.BackgroundTransparency
			if obj.BackgroundTransparency ~= t then
				if duracao == 0 then obj.BackgroundTransparency = t
				else TweenService:Create(obj, info, {BackgroundTransparency = t}):Play() end
			end
		end
		if orig.TextTransparency ~= nil then
			local t = fadeOut and 1 or orig.TextTransparency
			if obj.TextTransparency ~= t then
				if duracao == 0 then obj.TextTransparency = t
				else TweenService:Create(obj, info, {TextTransparency = t}):Play() end
			end
		end
		if orig.ImageTransparency ~= nil then
			local t = fadeOut and 1 or orig.ImageTransparency
			if obj.ImageTransparency ~= t then
				if duracao == 0 then obj.ImageTransparency = t
				else TweenService:Create(obj, info, {ImageTransparency = t}):Play() end
			end
		end
		if orig.Transparency ~= nil then
			local t = fadeOut and 1 or orig.Transparency
			if obj.Transparency ~= t then
				if duracao == 0 then obj.Transparency = t
				else TweenService:Create(obj, info, {Transparency = t}):Play() end
			end
		end
	end
	tratarObjeto(raiz)
	for _, desc in ipairs(raiz:GetDescendants()) do tratarObjeto(desc) end
end

-- ==================== BOTÃO FLUTUANTE ====================
local FloatBtn = Instance.new("ImageButton", screenGui)
FloatBtn.Name                = "FloatBtn"
FloatBtn.AnchorPoint         = Vector2.new(0.5, 0.5)
FloatBtn.Size                = UDim2.new(0, 44, 0, 44)
FloatBtn.Position            = UDim2.new(0.12, 0, 0.4, 0)
FloatBtn.Image               = "rbxthumb://type=Asset&id=139044062702391&w=150&h=150"
FloatBtn.BackgroundColor3    = Color3.fromRGB(15, 0, 0)
FloatBtn.Visible             = false
FloatBtn.ZIndex              = 100
FloatBtn.ClipsDescendants    = false
FloatBtn.AutoButtonColor     = false
if not FloatBtn:FindFirstChildOfClass("UICorner") then
	Instance.new("UICorner", FloatBtn).CornerRadius = UDim.new(0, 8)
end

local FloatOpenSound         = Instance.new("Sound", FloatBtn)
FloatOpenSound.Name          = "FloatOpenSound"
FloatOpenSound.SoundId       = "rbxassetid://6310837681"
FloatOpenSound.Volume        = 0.2
FloatOpenSound.Looped        = false

task.spawn(function()
	pcall(function()
		ContentProvider:PreloadAsync({FloatOpenSound, SharedClickSound})
	end)
end)

-- ==================== DRAG DO FLOATING BUTTON ====================
local dragToggleF  = false
local dragInputF   = nil
local dragStartF   = nil
local startPosF    = nil
local isDraggingF  = false

FloatBtn.InputBegan:Connect(function(input)
	if (input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch)
		and not dragToggleF then
		dragToggleF  = true
		dragInputF   = input
		isDraggingF  = false
		dragStartF   = input.Position
		startPosF    = FloatBtn.Position
	end
end)

local SetUIState 

-- ==================== DRAG DA JANELA PRINCIPAL ====================
local mainWrapper         = Instance.new("Frame", screenGui)
mainWrapper.Name          = "MainWrapper"
mainWrapper.AnchorPoint   = Vector2.new(0.5, 0.5)
mainWrapper.Size          = UDim2.new(0, 640, 0, 360)
mainWrapper.Position      = UDim2.new(0.5, 0, 0.5, 0)
mainWrapper.BackgroundTransparency = 1
mainWrapper.Visible       = false
mainWrapper.ClipsDescendants = false
mainWrapper.ZIndex        = 1

local mainFrame           = Instance.new("Frame", mainWrapper)
mainFrame.Name            = "MainFrame"
mainFrame.Size            = UDim2.new(1, 0, 1, 0)
mainFrame.BackgroundTransparency = 1
mainFrame.ZIndex          = 2
mainFrame.ClipsDescendants = false

local dragUIToggle = false
local dragUIInput  = nil
local dragUIStart  = nil
local startUIPos   = nil

mainFrame.InputBegan:Connect(function(input)
	if (input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch)
		and not dragUIToggle then
		dragUIToggle = true
		dragUIInput  = input
		dragUIStart  = input.Position
		startUIPos   = mainWrapper.Position
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragUIToggle and input == dragUIInput then
		local delta   = input.Position - dragUIStart
		local vp      = workspace.CurrentCamera.ViewportSize
		local hw      = mainWrapper.Size.X.Offset / 2
		local hh      = mainWrapper.Size.Y.Offset / 2
		local newX    = startUIPos.X.Offset + delta.X
		local newY    = startUIPos.Y.Offset + delta.Y
		local absX    = vp.X * startUIPos.X.Scale + newX
		local absY    = vp.Y * startUIPos.Y.Scale + newY
		absX          = math.clamp(absX, hw, vp.X - hw)
		absY          = math.clamp(absY, hh, vp.Y - hh)
		mainWrapper.Position = UDim2.new(0, absX, 0, absY)
	end

	if dragToggleF and input == dragInputF then
		local delta   = input.Position - dragStartF
		if delta.Magnitude > 5 then isDraggingF = true end

		local vp      = workspace.CurrentCamera.ViewportSize
		local half    = 22
		local baseAbsX = vp.X * startPosF.X.Scale + startPosF.X.Offset
		local baseAbsY = vp.Y * startPosF.Y.Scale + startPosF.Y.Offset
		local newAbsX  = math.clamp(baseAbsX + delta.X, half, vp.X - half)
		local newAbsY  = math.clamp(baseAbsY + delta.Y, half, vp.Y - half)
		FloatBtn.Position = UDim2.new(0, newAbsX, 0, newAbsY)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input == dragInputF then
		if dragToggleF and not isDraggingF then
			if UIState == "MINIMIZED" or UIState == "CLOSED" then
				pcall(function()
					FloatOpenSound.TimePosition = 0
					FloatOpenSound:Play()
				end)
				SetUIState("OPEN")
			elseif UIState == "OPEN" then
				SetUIState("MINIMIZED")
			end
		end
		dragToggleF = false
		dragInputF  = nil
	end

	if input == dragUIInput then
		dragUIToggle = false
		dragUIInput  = nil
	end
end)

-- ==================== ESTRUTURA UNIFICADA DA JANELA ====================
local Shadow               = Instance.new("ImageLabel", mainFrame)
Shadow.Name                = "WindowShadow"
Shadow.AnchorPoint         = Vector2.new(0, 0)
Shadow.Position            = UDim2.new(0, -12, 0, -12)
Shadow.Size                = UDim2.new(1, 24, 1, 24)
Shadow.BackgroundTransparency = 1
Shadow.Image               = "rbxassetid://5554831957"
Shadow.ImageColor3         = Color3.fromRGB(0, 0, 0)
Shadow.ImageTransparency   = 0.45
Shadow.ScaleType           = Enum.ScaleType.Slice
Shadow.SliceCenter         = Rect.new(36, 36, 114, 114)
Shadow.ZIndex              = 3

local MainBackground       = Instance.new("Frame", mainFrame)
MainBackground.Name        = "MainBackground"
MainBackground.Size        = UDim2.new(1, 0, 1, 0)
MainBackground.BackgroundColor3 = Color3.fromRGB(15, 0, 3)
MainBackground.BorderSizePixel = 0
MainBackground.ClipsDescendants = true
MainBackground.ZIndex      = 4
Instance.new("UICorner", MainBackground).CornerRadius = UDim.new(0, 10)

local MainStroke           = Instance.new("UIStroke", MainBackground)
MainStroke.Name            = "MainStroke"
MainStroke.Thickness       = 2
MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
MainStroke.Color           = Color3.fromRGB(255, 255, 255)

local MainStrokeGrad       = Instance.new("UIGradient", MainStroke)
MainStrokeGrad.Rotation    = 45
MainStrokeGrad.Color       = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(50,  0,  5)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 20, 30))
})

local RedGradientOverlay   = Instance.new("Frame", MainBackground)
RedGradientOverlay.Name    = "RedGradientOverlay"
RedGradientOverlay.Size    = UDim2.new(1, 0, 1, 0)
RedGradientOverlay.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
RedGradientOverlay.BackgroundTransparency = 0
RedGradientOverlay.BorderSizePixel = 0
RedGradientOverlay.ZIndex  = 4
Instance.new("UICorner", RedGradientOverlay).CornerRadius = UDim.new(0, 10)

local SingleRedGrad        = Instance.new("UIGradient", RedGradientOverlay)
SingleRedGrad.Rotation     = 90
SingleRedGrad.Color        = ColorSequence.new({
	ColorSequenceKeypoint.new(0,   Color3.fromRGB(40, 0, 5)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(120, 15, 22)),
	ColorSequenceKeypoint.new(1,   Color3.fromRGB(40, 0, 5))
})

local LeftPanel            = Instance.new("Frame", MainBackground)
LeftPanel.Name             = "LeftPanel"
LeftPanel.Size             = UDim2.new(0, 220, 1, 0)
LeftPanel.Position         = UDim2.new(0, 0, 0, 0)
LeftPanel.BackgroundTransparency = 1
LeftPanel.ZIndex           = 5

local RightPanel           = Instance.new("Frame", MainBackground)
RightPanel.Name            = "RightPanel"
RightPanel.Size            = UDim2.new(1, -220, 1, 0)
RightPanel.Position        = UDim2.new(0, 220, 0, 0)
RightPanel.BackgroundTransparency = 1
RightPanel.ZIndex          = 5

-- ==================== HEADER DA BARRA LATERAL ====================
local HeaderLeft           = Instance.new("Frame", LeftPanel)
HeaderLeft.Size            = UDim2.new(1, 0, 0, 36)
HeaderLeft.Position        = UDim2.new(0, 0, 0, 0)
HeaderLeft.BackgroundTransparency = 1
HeaderLeft.ZIndex          = 20

local HeaderImage          = Instance.new("ImageLabel", HeaderLeft)
HeaderImage.Size           = UDim2.new(0, 24, 0, 24)
HeaderImage.Position       = UDim2.new(0, 10, 0.5, -12)
HeaderImage.BackgroundTransparency = 1
HeaderImage.Image          = "rbxthumb://type=Asset&id=134217291845443&w=150&h=150"
HeaderImage.ZIndex         = 21

local title                = Instance.new("TextLabel", HeaderLeft)
title.Size                 = UDim2.new(1, -44, 0, 16)
title.Position             = UDim2.new(0, 40, 0, 4)
title.BackgroundTransparency = 1
title.Text                 = "AKATSUKI SCRIPTS HUB"
title.TextColor3           = Color3.fromRGB(245, 245, 245)
title.TextSize             = 13
title.Font                 = Enum.Font.GothamBold
title.TextXAlignment       = Enum.TextXAlignment.Left
title.ZIndex               = 21

local subtitle             = Instance.new("TextLabel", HeaderLeft)
subtitle.Size              = UDim2.new(1, -44, 0, 12)
subtitle.Position          = UDim2.new(0, 40, 0, 20)
subtitle.BackgroundTransparency = 1
subtitle.Text              = "MM2 SCRIPT | by zeni"
subtitle.TextColor3        = Color3.fromRGB(180, 180, 180)
subtitle.TextTransparency  = 0.2
subtitle.TextSize          = 9.5
subtitle.Font              = Enum.Font.Gotham
subtitle.TextXAlignment    = Enum.TextXAlignment.Left
subtitle.ZIndex            = 21

-- ==================== BARRA DE PESQUISA ====================
local SearchContainer      = Instance.new("Frame", LeftPanel)
SearchContainer.Name       = "SearchContainer"
SearchContainer.Size       = UDim2.new(1, -16, 0, 36)
SearchContainer.Position   = UDim2.new(0, 8, 0, 44)
SearchContainer.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
SearchContainer.BackgroundTransparency = 0.85
SearchContainer.ZIndex     = 20
Instance.new("UICorner", SearchContainer).CornerRadius = UDim.new(0, 8)

local searchStroke         = Instance.new("UIStroke", SearchContainer)
searchStroke.Color         = Color3.fromRGB(60, 20, 20)
searchStroke.Transparency  = 0.75
searchStroke.Thickness     = 1

local SearchIconFrame      = Instance.new("Frame", SearchContainer)
SearchIconFrame.Size       = UDim2.new(0, 14, 0, 14)
SearchIconFrame.Position   = UDim2.new(0, 14, 0.5, -7)
SearchIconFrame.BackgroundTransparency = 1
SearchIconFrame.ZIndex     = 21

local scCircle             = Instance.new("Frame", SearchIconFrame)
scCircle.Size              = UDim2.new(0, 8, 0, 8)
scCircle.BackgroundTransparency = 1
Instance.new("UICorner", scCircle).CornerRadius = UDim.new(1, 0)
local scCStroke            = Instance.new("UIStroke", scCircle)
scCStroke.Color            = Color3.fromRGB(140, 140, 140)
scCStroke.Thickness        = 1.2

local scHandle             = Instance.new("Frame", SearchIconFrame)
scHandle.Size              = UDim2.new(0, 1.2, 0, 5)
scHandle.Position          = UDim2.new(0, 9, 0, 8)
scHandle.Rotation          = -45
scHandle.BackgroundColor3  = Color3.fromRGB(140, 140, 140)
scHandle.BorderSizePixel   = 0

local searchTextBox        = Instance.new("TextBox", SearchContainer)
searchTextBox.Size         = UDim2.new(1, -38, 1, 0)
searchTextBox.Position     = UDim2.new(0, 38, 0, 0)
searchTextBox.BackgroundTransparency = 1
searchTextBox.PlaceholderText  = UI_TEXT.SearchPlaceholder
searchTextBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
searchTextBox.Text         = ""
searchTextBox.TextColor3   = Color3.fromRGB(230, 230, 230)
searchTextBox.Font         = Enum.Font.GothamMedium
searchTextBox.TextSize     = 13
searchTextBox.TextXAlignment = Enum.TextXAlignment.Left
searchTextBox.ZIndex       = 22
searchTextBox.Active       = true
searchTextBox.ClearTextOnFocus = false

-- ==================== TABS CONTAINER ====================
local TabsContainer        = Instance.new("ScrollingFrame", LeftPanel)
TabsContainer.Name         = "TabsContainer"
TabsContainer.Size         = UDim2.new(1, -8, 1, -152)
TabsContainer.Position     = UDim2.new(0, 4, 0, 87)
TabsContainer.BackgroundTransparency = 1
TabsContainer.BorderSizePixel = 0
TabsContainer.ZIndex       = 10
TabsContainer.CanvasSize   = UDim2.new(0, 0, 0, 0)
TabsContainer.ScrollBarThickness = 3
TabsContainer.ScrollBarImageColor3 = Color3.fromRGB(200, 50, 50)
TabsContainer.ScrollBarImageTransparency = 0.2
TabsContainer.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar

local TabsLayout           = Instance.new("UIListLayout", TabsContainer)
TabsLayout.SortOrder       = Enum.SortOrder.LayoutOrder
TabsLayout.Padding         = UDim.new(0, 2)
TabsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function UpdateTabsCanvas()
	local contentH = TabsLayout.AbsoluteContentSize.Y + 8
	local minH     = TabsContainer.AbsoluteSize.Y + 12
	TabsContainer.CanvasSize = UDim2.new(0, 0, 0, math.max(contentH, minH))
end

TabsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateTabsCanvas)
TabsContainer:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateTabsCanvas)

-- ==================== ACTIVEBAR REUTILIZÁVEL (CORRIGIDA) ====================
local ActiveBarContainer   = Instance.new("Frame", LeftPanel)
ActiveBarContainer.Name    = "ActiveBarContainer"
ActiveBarContainer.Size    = UDim2.new(1, -8, 1, -152)
ActiveBarContainer.Position = UDim2.new(0, 4, 0, 87)
ActiveBarContainer.BackgroundTransparency = 1
ActiveBarContainer.ClipsDescendants = true
ActiveBarContainer.ZIndex  = 8

local sharedActiveBar      = Instance.new("Frame", ActiveBarContainer)
sharedActiveBar.Name       = "SharedActiveBar"
sharedActiveBar.AnchorPoint = Vector2.new(0, 0.5)
sharedActiveBar.Size       = UDim2.new(0, 3, 0, 22)
sharedActiveBar.Position   = UDim2.new(0, 7, 0, 0)
sharedActiveBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
sharedActiveBar.BorderSizePixel = 0
sharedActiveBar.Visible    = false
sharedActiveBar.ZIndex     = 8
sharedActiveBar.ClipsDescendants = false
Instance.new("UICorner", sharedActiveBar).CornerRadius = UDim.new(1, 0)

local sharedBarGrad        = Instance.new("UIGradient", sharedActiveBar)
sharedBarGrad.Rotation     = 90
sharedBarGrad.Color        = ColorSequence.new({
	ColorSequenceKeypoint.new(0.0, Color3.fromRGB(120, 0, 10)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 30, 40)),
	ColorSequenceKeypoint.new(1.0, Color3.fromRGB(120, 0, 10))
})

-- ==================== USER PROFILE BADGE ====================
local UserProfileFrame     = Instance.new("Frame", LeftPanel)
UserProfileFrame.Size      = UDim2.new(1, -16, 0, 55)
UserProfileFrame.Position  = UDim2.new(0, 8, 1, -63)
UserProfileFrame.BackgroundColor3 = Color3.fromRGB(20, 12, 12)
UserProfileFrame.BackgroundTransparency = 0.35
UserProfileFrame.BorderSizePixel = 0
UserProfileFrame.ZIndex    = 20
Instance.new("UICorner", UserProfileFrame).CornerRadius = UDim.new(0, 8)

local userStroke           = Instance.new("UIStroke", UserProfileFrame)
userStroke.Thickness       = 0.9
userStroke.Color           = Color3.fromRGB(255, 255, 255)
local uGrad                = Instance.new("UIGradient", userStroke)
uGrad.Color                = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 10, 15)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 0, 0))
})

local AvatarImage          = Instance.new("ImageLabel", UserProfileFrame)
AvatarImage.Size           = UDim2.new(0, 34, 0, 34)
AvatarImage.Position       = UDim2.new(0, 10, 0.5, -17)
AvatarImage.BackgroundTransparency = 1
AvatarImage.Image          = "rbxthumb://type=AvatarHeadShot&id=" .. player.UserId .. "&w=150&h=150"
AvatarImage.ZIndex         = 21
Instance.new("UICorner", AvatarImage).CornerRadius = UDim.new(1, 0)

local AvatarStroke         = Instance.new("UIStroke", AvatarImage)
AvatarStroke.Thickness     = 0.9
AvatarStroke.Color         = Color3.fromRGB(255, 255, 255)
local avGrad               = Instance.new("UIGradient", AvatarStroke)
avGrad.Color               = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 10, 15)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 0, 0))
})

local StatusIndicator      = Instance.new("Frame", AvatarImage)
StatusIndicator.Size       = UDim2.new(0, 9, 0, 9)
StatusIndicator.Position   = UDim2.new(1, -7, 1, -7)
StatusIndicator.BackgroundColor3 = Color3.fromRGB(40, 220, 80)
StatusIndicator.BorderSizePixel = 0
StatusIndicator.ZIndex     = 22
Instance.new("UICorner", StatusIndicator).CornerRadius = UDim.new(1, 0)
local statusStroke         = Instance.new("UIStroke", StatusIndicator)
statusStroke.Color         = Color3.fromRGB(15, 5, 5)
statusStroke.Thickness     = 1.5

local DisplayNameLabel     = Instance.new("TextLabel", UserProfileFrame)
DisplayNameLabel.Size      = UDim2.new(1, -82, 0, 16)
DisplayNameLabel.Position  = UDim2.new(0, 54, 0.5, -16)
DisplayNameLabel.BackgroundTransparency = 1
DisplayNameLabel.Text      = player.DisplayName
DisplayNameLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
DisplayNameLabel.Font      = Enum.Font.GothamBold
DisplayNameLabel.TextSize  = 13.5
DisplayNameLabel.TextXAlignment = Enum.TextXAlignment.Left
DisplayNameLabel.TextTruncate = Enum.TextTruncate.AtEnd
DisplayNameLabel.ZIndex    = 21

local UsernameLabel        = Instance.new("TextLabel", UserProfileFrame)
UsernameLabel.Size         = UDim2.new(1, -82, 0, 14)
UsernameLabel.Position     = UDim2.new(0, 54, 0.5, 2)
UsernameLabel.BackgroundTransparency = 1
UsernameLabel.Text         = "@" .. player.Name
UsernameLabel.TextColor3   = Color3.fromRGB(110, 110, 110)
UsernameLabel.Font         = Enum.Font.Gotham
UsernameLabel.TextSize     = 11.5
UsernameLabel.TextXAlignment = Enum.TextXAlignment.Left
UsernameLabel.TextTruncate = Enum.TextTruncate.AtEnd
UsernameLabel.ZIndex       = 21

local PrivacyBtn           = Instance.new("ImageButton", UserProfileFrame)
PrivacyBtn.Size            = UDim2.new(0, 20, 0, 20)
PrivacyBtn.Position        = UDim2.new(1, -26, 0.5, -10)
PrivacyBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
PrivacyBtn.BackgroundTransparency = 0.2
PrivacyBtn.BorderSizePixel = 0
PrivacyBtn.ZIndex          = 22
PrivacyBtn.AutoButtonColor = false
Instance.new("UICorner", PrivacyBtn).CornerRadius = UDim.new(0, 5)
local privStroke           = Instance.new("UIStroke", PrivacyBtn)
privStroke.Color           = Color3.fromRGB(60, 20, 20)
privStroke.Thickness       = 1
privStroke.Transparency    = 0.5

local PrivacyIcon          = Instance.new("ImageLabel", PrivacyBtn)
PrivacyIcon.Size           = UDim2.new(1, -6, 1, -6)
PrivacyIcon.Position       = UDim2.new(0, 3, 0, 3)
PrivacyIcon.BackgroundTransparency = 1
PrivacyIcon.Image          = "rbxthumb://type=Asset&id=103096515071530&w=150&h=150"
PrivacyIcon.ImageColor3    = Color3.fromRGB(255, 255, 255)
PrivacyIcon.ZIndex         = 23

local isPrivate = false

PrivacyBtn.MouseButton1Click:Connect(function()
	PlayUI_Click()
	local flashTween = TweenService:Create(PrivacyBtn, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true), {BackgroundTransparency = 0})
	flashTween:Play()

	isPrivate = not isPrivate
	if isPrivate then
		PrivacyIcon.Image = "rbxthumb://type=Asset&id=85795266774996&w=150&h=150"
		DisplayNameLabel.Text = string.rep("*", math.clamp(#player.DisplayName, 3, 8))
		UsernameLabel.Text    = "@" .. string.rep("*", math.clamp(#player.Name, 3, 8))
	else
		PrivacyIcon.Image = "rbxthumb://type=Asset&id=103096515071530&w=150&h=150"
		DisplayNameLabel.Text = player.DisplayName
		UsernameLabel.Text    = "@" .. player.Name
	end
end)

-- ==================== RIGHT PANEL HEADER & BADGE ====================
local topButtons           = Instance.new("Frame", RightPanel)
topButtons.Size            = UDim2.new(1, -12, 0, 36)
topButtons.Position        = UDim2.new(0, 0, 0, 0)
topButtons.BackgroundTransparency = 1
topButtons.ZIndex          = 20

local ControlsFrame        = Instance.new("Frame", topButtons)
ControlsFrame.Size         = UDim2.new(0, 130, 1, 0)
ControlsFrame.Position     = UDim2.new(1, -130, 0, 0)
ControlsFrame.BackgroundTransparency = 1
ControlsFrame.ZIndex       = 25

local UIListTop            = Instance.new("UIListLayout", ControlsFrame)
UIListTop.FillDirection    = Enum.FillDirection.Horizontal
UIListTop.HorizontalAlignment = Enum.HorizontalAlignment.Right
UIListTop.VerticalAlignment = Enum.VerticalAlignment.Center
UIListTop.Padding          = UDim.new(0, 2)
UIListTop.SortOrder        = Enum.SortOrder.LayoutOrder

local TOP_BTN_COLOR        = Color3.fromRGB(150, 150, 150)

local function CriarBotaoTopo(nome, idAsset, ordem)
	local btn              = Instance.new("ImageButton", ControlsFrame)
	btn.Name               = nome
	btn.LayoutOrder        = ordem
	btn.Size               = UDim2.new(0, 28, 0, 28)
	btn.BackgroundTransparency = 1
	btn.ZIndex             = 25
	btn.AutoButtonColor    = false

	local icon             = Instance.new("ImageLabel", btn)
	icon.Name              = "Icon"
	icon.AnchorPoint       = Vector2.new(0.5, 0.5)
	icon.Position          = UDim2.new(0.5, 0, 0.5, 0)
	icon.Size              = UDim2.new(0, 14, 0, 14)
	icon.BackgroundTransparency = 1
	icon.Image             = idAsset
	icon.ImageColor3       = TOP_BTN_COLOR
	icon.ZIndex            = 26

	return btn, icon
end

local MinimizeBtn, MinimizeIcon = CriarBotaoTopo("MinimizeBtn", "rbxthumb://type=Asset&id=97090905107587&w=150&h=150", 1)
local ExpandBtn,   ExpandIcon   = CriarBotaoTopo("ExpandBtn",   "rbxthumb://type=Asset&id=78749046909931&w=150&h=150", 2)
local CloseBtn,    CloseIcon    = CriarBotaoTopo("CloseBtn",    "rbxthumb://type=Asset&id=70710316269357&w=150&h=150", 3)

local BadgeFrame           = Instance.new("Frame", RightPanel)
BadgeFrame.Name            = "BadgeFrame"
BadgeFrame.Size            = UDim2.new(0, 44, 0, 18)
BadgeFrame.Position        = UDim2.new(0, 12, 0, 9)
BadgeFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
BadgeFrame.BorderSizePixel = 0
BadgeFrame.ZIndex          = 15
Instance.new("UICorner", BadgeFrame).CornerRadius = UDim.new(0, 8)

local badgeStroke          = Instance.new("UIStroke", BadgeFrame)
badgeStroke.Thickness      = 0.9
badgeStroke.Color          = Color3.fromRGB(255, 255, 255)

local badgeGrad            = Instance.new("UIGradient", BadgeFrame)
badgeGrad.Rotation         = 45
badgeGrad.Color            = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(230, 20, 25)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 0, 0))
})

local badgeStrokeGrad      = Instance.new("UIGradient", badgeStroke)
badgeStrokeGrad.Rotation   = 45
badgeStrokeGrad.Color      = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(230, 20, 25)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 0, 0))
})

local BadgeText            = Instance.new("TextLabel", BadgeFrame)
BadgeText.Size             = UDim2.new(1, 0, 1, 0)
BadgeText.BackgroundTransparency = 1
BadgeText.Text             = "V5.7"
BadgeText.TextColor3       = Color3.fromRGB(255, 255, 255)
BadgeText.Font             = Enum.Font.GothamBold
BadgeText.TextSize         = 8.5
BadgeText.ZIndex           = 16

-- ==================== TOGGLES CONTAINER ====================
local togglesContainer     = Instance.new("ScrollingFrame", RightPanel)
togglesContainer.Name      = "TogglesContainer"
togglesContainer.Size      = UDim2.new(1, -12, 1, -48)
togglesContainer.Position  = UDim2.new(0, 6, 0, 42)
togglesContainer.BackgroundColor3 = Color3.fromRGB(30, 12, 14)
togglesContainer.BackgroundTransparency = 0.7
togglesContainer.BorderSizePixel = 0
togglesContainer.ClipsDescendants = true
togglesContainer.ZIndex    = 10
togglesContainer.ScrollBarThickness = 3
togglesContainer.ScrollBarImageColor3 = Color3.fromRGB(220, 30, 40)
togglesContainer.ScrollBarImageTransparency = 0
togglesContainer.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar
togglesContainer.AutomaticCanvasSize = Enum.AutomaticSize.None
Instance.new("UICorner", togglesContainer).CornerRadius = UDim.new(0, 8)

local containerLayout      = Instance.new("UIListLayout", togglesContainer)
containerLayout.SortOrder  = Enum.SortOrder.LayoutOrder
containerLayout.Padding    = UDim.new(0, 6)
containerLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local uiPadding            = Instance.new("UIPadding", togglesContainer)
uiPadding.PaddingTop       = UDim.new(0, 8)
uiPadding.PaddingBottom    = UDim.new(0, 8)
uiPadding.PaddingLeft      = UDim.new(0, 4)
uiPadding.PaddingRight     = UDim.new(0, 6)

local function UpdateCanvasSize()
	local contentHeight = containerLayout.AbsoluteContentSize.Y + 24
	local minHeight     = togglesContainer.AbsoluteSize.Y + 1
	togglesContainer.CanvasSize = UDim2.new(0, 0, 0, math.max(contentHeight, minHeight))
end

containerLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateCanvasSize)
togglesContainer:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateCanvasSize)

-- ==================== CONFIRM FRAME & INTENSE BLUR ====================
local confirmBlur          = Instance.new("BlurEffect", Lighting)
confirmBlur.Name           = "ConfirmBlur"
confirmBlur.Size           = 0

local confirmOverlay       = Instance.new("Frame", screenGui)
confirmOverlay.Name        = "ConfirmOverlay"
confirmOverlay.Size        = UDim2.new(1, 0, 1, 0)
confirmOverlay.Position    = UDim2.new(0, 0, 0, 0)
confirmOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
confirmOverlay.BackgroundTransparency = 0.55
confirmOverlay.Visible     = false
confirmOverlay.ZIndex      = 990
confirmOverlay.ClipsDescendants = true

local confirmCard          = Instance.new("Frame", confirmOverlay)
confirmCard.Name           = "ConfirmCard"
confirmCard.Size           = UDim2.new(0, 300, 0, 130)
confirmCard.AnchorPoint    = Vector2.new(0.5, 0.5)
confirmCard.Position       = UDim2.new(0.5, 0, 0.5, 0)
confirmCard.BackgroundColor3 = Color3.fromRGB(18, 8, 8)
confirmCard.BackgroundTransparency = 0
confirmCard.BorderSizePixel = 0
confirmCard.ZIndex         = 995
Instance.new("UICorner", confirmCard).CornerRadius = UDim.new(0, 14)

local confirmStroke        = Instance.new("UIStroke", confirmCard)
confirmStroke.Thickness    = 1.5
confirmStroke.Color        = Color3.fromRGB(255, 255, 255)

local confStrokeGrad       = Instance.new("UIGradient", confirmStroke)
confStrokeGrad.Color       = ColorSequence.new({
	ColorSequenceKeypoint.new(0.0, Color3.fromRGB(120, 0, 10)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 30, 40)),
	ColorSequenceKeypoint.new(1.0, Color3.fromRGB(120, 0, 10))
})

local confirmCardGrad      = Instance.new("UIGradient", confirmCard)
confirmCardGrad.Rotation   = 135
confirmCardGrad.Color      = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(28, 10, 10)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(12,  4,  4))
})

local confirmLabel         = Instance.new("TextLabel", confirmCard)
confirmLabel.Size          = UDim2.new(1, -24, 0, 22)
confirmLabel.Position      = UDim2.new(0, 12, 0, 18)
confirmLabel.BackgroundTransparency = 1
confirmLabel.TextColor3    = Color3.fromRGB(235, 235, 235)
confirmLabel.Font          = Enum.Font.GothamBold
confirmLabel.TextSize      = 13
confirmLabel.TextXAlignment = Enum.TextXAlignment.Center
confirmLabel.Text          = UI_TEXT.ConfirmCloseTitle
confirmLabel.ZIndex        = 1000

local confirmSep           = Instance.new("Frame", confirmCard)
confirmSep.Size            = UDim2.new(1, -40, 0, 1)
confirmSep.Position        = UDim2.new(0, 20, 0, 48)
confirmSep.BackgroundColor3 = Color3.fromRGB(120, 20, 20)
confirmSep.BackgroundTransparency = 0.6
confirmSep.BorderSizePixel = 0
confirmSep.ZIndex          = 999
Instance.new("UICorner", confirmSep).CornerRadius = UDim.new(1, 0)

local btnYes               = Instance.new("TextButton", confirmCard)
btnYes.Size                = UDim2.new(0, 118, 0, 32)
btnYes.Position            = UDim2.new(0.5, -124, 0, 62)
btnYes.BackgroundColor3    = Color3.fromRGB(139, 0, 0)
btnYes.TextColor3          = Color3.fromRGB(255, 255, 255)
btnYes.Font                = Enum.Font.GothamMedium
btnYes.TextSize            = 14
btnYes.Text                = UI_TEXT.ConfirmBtn
btnYes.ZIndex              = 1000
btnYes.BorderSizePixel     = 0
Instance.new("UICorner", btnYes).CornerRadius = UDim.new(0, 14)
local btnYesGrad           = Instance.new("UIGradient", btnYes)
btnYesGrad.Rotation        = 90
btnYesGrad.Color           = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(180, 20, 20)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(100,  0,  0))
})

local btnNo                = Instance.new("TextButton", confirmCard)
btnNo.Size                 = UDim2.new(0, 118, 0, 32)
btnNo.Position             = UDim2.new(0.5, 6, 0, 62)
btnNo.BackgroundColor3     = Color3.fromRGB(30, 30, 30)
btnNo.TextColor3           = Color3.fromRGB(170, 170, 170)
btnNo.Font                 = Enum.Font.GothamMedium
btnNo.TextSize             = 14
btnNo.Text                 = UI_TEXT.CancelBtn
btnNo.ZIndex               = 1000
btnNo.BorderSizePixel      = 0
Instance.new("UICorner", btnNo).CornerRadius = UDim.new(0, 14)
local btnNoStroke          = Instance.new("UIStroke", btnNo)
btnNoStroke.Color          = Color3.fromRGB(60, 60, 60)
btnNoStroke.Thickness      = 1
btnNoStroke.Transparency   = 0.3

btnYes.MouseEnter:Connect(function() TweenService:Create(btnYes, TweenInfo.new(0.12, Enum.EasingStyle.Quad), {BackgroundColor3 = Color3.fromRGB(180, 20, 20)}):Play() end)
btnYes.MouseLeave:Connect(function() TweenService:Create(btnYes, TweenInfo.new(0.12, Enum.EasingStyle.Quad), {BackgroundColor3 = Color3.fromRGB(139,  0,  0)}):Play() end)
btnNo.MouseEnter:Connect(function()  TweenService:Create(btnNo,  TweenInfo.new(0.12, Enum.EasingStyle.Quad), {BackgroundColor3 = Color3.fromRGB(45, 45, 45)}):Play() end)
btnNo.MouseLeave:Connect(function()  TweenService:Create(btnNo,  TweenInfo.new(0.12, Enum.EasingStyle.Quad), {BackgroundColor3 = Color3.fromRGB(30, 30, 30)}):Play() end)

AplicarFadeSincronizado(confirmCard, true, 0)

-- ==================== RENDERSTEP UNIFICADO ====================
RunService.RenderStepped:Connect(function()
	local t = os.clock()
	SingleRedGrad.Rotation    = (t * 12)  % 360
	confStrokeGrad.Rotation   = (t * 15)  % 360
	uGrad.Rotation            = (t * 60)  % 360
	avGrad.Rotation           = (t * 60)  % 360
	badgeGrad.Rotation        = (t * 10)  % 360
	badgeStrokeGrad.Rotation  = (t * 10)  % 360
end)

-- ==================== SISTEMA DE NOTIFICAÇÃO (STACK / FILA) ====================
local ActiveNotifications = {}
local NOTIF_DURATION      = 10

local function UpdateNotifications()
	local currentY = -24
	for _, notif in ipairs(ActiveNotifications) do
		if notif and notif.Parent then
			local h = notif.Size.Y.Offset
			if h == 0 then h = 96 end
			TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
				Position = UDim2.new(1, -20, 1, currentY)
			}):Play()
			currentY = currentY - (h + 12)
		end
	end
end

-- ==================== NOTIFICAÇÃO GENÉRICA ====================
local function CriarNotificacao(titulo, descricao, iconeId)
	local notifHolder              = Instance.new("Frame", screenGui)
	notifHolder.Name               = "NotifHolder"
	notifHolder.AnchorPoint        = Vector2.new(1, 1)
	notifHolder.Size               = UDim2.new(0, 330, 0, 96)
	notifHolder.Position           = UDim2.new(1, 340, 1, -24)
	notifHolder.BackgroundTransparency = 1
	notifHolder.ZIndex             = 200
	notifHolder.ClipsDescendants   = false

	local notifCard                = Instance.new("Frame", notifHolder)
	notifCard.Name                 = "NotifCard"
	notifCard.Size                 = UDim2.new(1, 0, 1, 0)
	notifCard.BackgroundColor3     = Color3.fromRGB(16, 16, 18)
	notifCard.BackgroundTransparency = 0.25
	notifCard.BorderSizePixel      = 0
	notifCard.ZIndex               = 201
	notifCard.ClipsDescendants     = false
	Instance.new("UICorner", notifCard).CornerRadius = UDim.new(0, 16)

	local notifShadow              = Instance.new("ImageLabel", notifCard)
	notifShadow.Name               = "Shadow"
	notifShadow.AnchorPoint        = Vector2.new(0.5, 0.5)
	notifShadow.Position           = UDim2.new(0.5, 0, 0.5, 4)
	notifShadow.Size               = UDim2.new(1, 24, 1, 24)
	notifShadow.BackgroundTransparency = 1
	notifShadow.Image              = "rbxassetid://5554831957"
	notifShadow.ImageColor3        = Color3.fromRGB(0, 0, 0)
	notifShadow.ImageTransparency  = 0.35
	notifShadow.ScaleType          = Enum.ScaleType.Slice
	notifShadow.SliceCenter        = Rect.new(36, 36, 114, 114)
	notifShadow.ZIndex             = 200

	local accentBar                = Instance.new("Frame", notifCard)
	accentBar.Size                 = UDim2.new(0, 4, 0, 52)
	accentBar.Position             = UDim2.new(0, 14, 0.5, -26)
	accentBar.BackgroundColor3     = Color3.fromRGB(180, 20, 20)
	accentBar.BorderSizePixel      = 0
	accentBar.ZIndex               = 202
	Instance.new("UICorner", accentBar).CornerRadius = UDim.new(1, 0)
	local accentGrad               = Instance.new("UIGradient", accentBar)
	accentGrad.Rotation            = 90
	accentGrad.Color               = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(230, 30, 30)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 10, 10))
	})

	local notifTitle               = Instance.new("TextLabel", notifCard)
	notifTitle.Size                = UDim2.new(1, -76, 0, 18)
	notifTitle.Position            = UDim2.new(0, 26, 0.5, -19)
	notifTitle.BackgroundTransparency = 1
	notifTitle.Text                = titulo or "AKATSUKI"
	notifTitle.TextColor3          = Color3.fromRGB(240, 240, 240)
	notifTitle.Font                = Enum.Font.GothamBold
	notifTitle.TextSize            = 16
	notifTitle.TextXAlignment      = Enum.TextXAlignment.Left
	notifTitle.ZIndex              = 203

	local notifDesc                = Instance.new("TextLabel", notifCard)
	notifDesc.Size                 = UDim2.new(1, -76, 0, 18)
	notifDesc.Position             = UDim2.new(0, 26, 0.5, 1)
	notifDesc.BackgroundTransparency = 1
	notifDesc.Text                 = descricao or ""
	notifDesc.TextColor3           = Color3.fromRGB(150, 150, 155)
	notifDesc.Font                 = Enum.Font.Gotham
	notifDesc.TextSize             = 12
	notifDesc.TextXAlignment       = Enum.TextXAlignment.Left
	notifDesc.TextYAlignment       = Enum.TextYAlignment.Top
	notifDesc.TextWrapped          = true
	notifDesc.ZIndex               = 203

	local notifCloseBtn            = Instance.new("TextButton", notifCard)
	notifCloseBtn.Size             = UDim2.new(0, 24, 0, 24)
	notifCloseBtn.Position         = UDim2.new(1, -32, 0, 10)
	notifCloseBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 38)
	notifCloseBtn.BackgroundTransparency = 0.2
	notifCloseBtn.Text             = ""
	notifCloseBtn.ZIndex           = 205
	notifCloseBtn.BorderSizePixel  = 0
	Instance.new("UICorner", notifCloseBtn).CornerRadius = UDim.new(0, 6)
	local xStroke                  = Instance.new("UIStroke", notifCloseBtn)
	xStroke.Color                  = Color3.fromRGB(80, 80, 85)
	xStroke.Thickness              = 1
	xStroke.Transparency           = 0.5

	local xL1                      = Instance.new("Frame", notifCloseBtn)
	xL1.AnchorPoint                = Vector2.new(0.5, 0.5)
	xL1.Position                   = UDim2.new(0.5, 0, 0.5, 0)
	xL1.Size                       = UDim2.new(0, 10, 0, 1.5)
	xL1.Rotation                   = 45
	xL1.BackgroundColor3           = Color3.fromRGB(160, 160, 165)
	xL1.BorderSizePixel            = 0
	xL1.ZIndex                     = 206
	Instance.new("UICorner", xL1).CornerRadius = UDim.new(1, 0)
	local xL2                      = Instance.new("Frame", notifCloseBtn)
	xL2.AnchorPoint                = Vector2.new(0.5, 0.5)
	xL2.Position                   = UDim2.new(0.5, 0, 0.5, 0)
	xL2.Size                       = UDim2.new(0, 10, 0, 1.5)
	xL2.Rotation                   = -45
	xL2.BackgroundColor3           = Color3.fromRGB(160, 160, 165)
	xL2.BorderSizePixel            = 0
	xL2.ZIndex                     = 206
	Instance.new("UICorner", xL2).CornerRadius = UDim.new(1, 0)

	notifCloseBtn.MouseEnter:Connect(function()
		TweenService:Create(notifCloseBtn, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(160, 20, 20)}):Play()
		TweenService:Create(xL1, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
		TweenService:Create(xL2, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
	end)
	notifCloseBtn.MouseLeave:Connect(function()
		TweenService:Create(notifCloseBtn, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(35, 35, 38)}):Play()
		TweenService:Create(xL1, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(160, 160, 165)}):Play()
		TweenService:Create(xL2, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(160, 160, 165)}):Play()
	end)

	local progressBg               = Instance.new("Frame", notifCard)
	progressBg.Size                = UDim2.new(1, -28, 0, 3)
	progressBg.Position            = UDim2.new(0, 14, 1, -10)
	progressBg.BackgroundColor3    = Color3.fromRGB(30, 30, 35)
	progressBg.BorderSizePixel     = 0
	progressBg.ZIndex              = 202
	progressBg.ClipsDescendants    = true
	Instance.new("UICorner", progressBg).CornerRadius = UDim.new(1, 0)

	local progressBar              = Instance.new("Frame", progressBg)
	progressBar.Size               = UDim2.new(1, 0, 1, 0)
	progressBar.Position           = UDim2.new(0, 0, 0, 0)
	progressBar.BackgroundColor3   = Color3.fromRGB(255, 255, 255)
	progressBar.BorderSizePixel    = 0
	progressBar.ZIndex             = 203
	Instance.new("UICorner", progressBar).CornerRadius = UDim.new(1, 0)
	local progressGrad             = Instance.new("UIGradient", progressBar)
	progressGrad.Color             = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(230, 20, 25)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 0, 0))
	})

	table.insert(ActiveNotifications, 1, notifHolder)
	UpdateNotifications()

	TweenService:Create(notifHolder, TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
		Position = UDim2.new(1, -20, 1, -24)
	}):Play()

	local dismissed = false
	local function DismissNotif()
		if dismissed then return end
		dismissed = true
		for i, v in ipairs(ActiveNotifications) do
			if v == notifHolder then table.remove(ActiveNotifications, i) break end
		end
		UpdateNotifications()
		local slideOut = TweenInfo.new(0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.In)
		TweenService:Create(notifHolder, slideOut, {
			Position = UDim2.new(1, 360, notifHolder.Position.Y.Scale, notifHolder.Position.Y.Offset)
		}):Play()
		TweenService:Create(notifCard, slideOut, {BackgroundTransparency = 1}):Play()
		task.delay(0.28, function()
			if notifHolder and notifHolder.Parent then notifHolder:Destroy() end
		end)
	end

	notifCloseBtn.MouseButton1Click:Connect(function() DismissNotif() end)
	local barTween = TweenService:Create(progressBar, TweenInfo.new(NOTIF_DURATION, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {Size = UDim2.new(0, 0, 1, 0)})
	task.delay(0.1, function() barTween:Play() end)
	task.delay(NOTIF_DURATION + 0.1, function() DismissNotif() end)
end

-- ==================== NOTIFICAÇÃO DE LINK COPIADO ====================
local function CriarNotificacaoLinkCopiado(texto, iconeId)
	local notifHolder              = Instance.new("Frame", screenGui)
	notifHolder.Name               = "NotifHolderLink"
	notifHolder.AnchorPoint        = Vector2.new(1, 1)
	notifHolder.Size               = UDim2.new(0, 330, 0, 64)
	notifHolder.Position           = UDim2.new(1, 360, 1, -24)
	notifHolder.BackgroundTransparency = 1
	notifHolder.ZIndex             = 200
	notifHolder.ClipsDescendants   = false

	local notifCard                = Instance.new("Frame", notifHolder)
	notifCard.Name                 = "NotifCard"
	notifCard.Size                 = UDim2.new(1, 0, 1, 0)
	notifCard.BackgroundColor3     = Color3.fromRGB(16, 16, 18)
	notifCard.BackgroundTransparency = 0.25
	notifCard.BorderSizePixel      = 0
	notifCard.ZIndex               = 201
	notifCard.ClipsDescendants     = false
	Instance.new("UICorner", notifCard).CornerRadius = UDim.new(0, 16)

	local notifShadow              = Instance.new("ImageLabel", notifCard)
	notifShadow.Name               = "Shadow"
	notifShadow.AnchorPoint        = Vector2.new(0.5, 0.5)
	notifShadow.Position           = UDim2.new(0.5, 0, 0.5, 4)
	notifShadow.Size               = UDim2.new(1, 24, 1, 24)
	notifShadow.BackgroundTransparency = 1
	notifShadow.Image              = "rbxassetid://5554831957"
	notifShadow.ImageColor3        = Color3.fromRGB(0, 0, 0)
	notifShadow.ImageTransparency  = 0.35
	notifShadow.ScaleType          = Enum.ScaleType.Slice
	notifShadow.SliceCenter        = Rect.new(36, 36, 114, 114)
	notifShadow.ZIndex             = 200

	local accentBar                = Instance.new("Frame", notifCard)
	accentBar.Size                 = UDim2.new(0, 4, 0, 36)
	accentBar.Position             = UDim2.new(0, 14, 0.5, -18)
	accentBar.BackgroundColor3     = Color3.fromRGB(180, 20, 20)
	accentBar.BorderSizePixel      = 0
	accentBar.ZIndex               = 202
	Instance.new("UICorner", accentBar).CornerRadius = UDim.new(1, 0)
	local accentGrad               = Instance.new("UIGradient", accentBar)
	accentGrad.Rotation            = 90
	accentGrad.Color               = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(230, 30, 30)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 10, 10))
	})

	local contentContainer         = Instance.new("Frame", notifCard)
	contentContainer.Size          = UDim2.new(1, -64, 1, -12)
	contentContainer.Position      = UDim2.new(0, 26, 0, 6)
	contentContainer.BackgroundTransparency = 1
	local cLayout                  = Instance.new("UIListLayout", contentContainer)
	cLayout.FillDirection          = Enum.FillDirection.Horizontal
	cLayout.SortOrder              = Enum.SortOrder.LayoutOrder
	cLayout.VerticalAlignment      = Enum.VerticalAlignment.Center
	cLayout.HorizontalAlignment    = Enum.HorizontalAlignment.Center
	cLayout.Padding                = UDim.new(0, 8)

	local notifText                = Instance.new("TextLabel", contentContainer)
	notifText.LayoutOrder          = 1
	notifText.AutomaticSize        = Enum.AutomaticSize.X
	notifText.Size                 = UDim2.new(0, 0, 0, 24)
	notifText.BackgroundTransparency = 1
	notifText.Text                 = texto or "LINK COPIED SUCCESSFULLY"
	notifText.TextColor3           = Color3.fromRGB(240, 240, 240)
	notifText.Font                 = Enum.Font.GothamBold
	notifText.TextSize             = 15
	notifText.TextXAlignment       = Enum.TextXAlignment.Left
	notifText.ZIndex               = 203

	if iconeId then
		local verifyIcon           = Instance.new("ImageLabel", contentContainer)
		verifyIcon.LayoutOrder     = 2
		verifyIcon.Size            = UDim2.new(0, 20, 0, 20)
		verifyIcon.BackgroundTransparency = 1
		verifyIcon.Image           = iconeId
		verifyIcon.ImageColor3     = Color3.fromRGB(40, 220, 80)
		verifyIcon.ZIndex          = 203
	end

	local notifCloseBtn            = Instance.new("TextButton", notifCard)
	notifCloseBtn.Size             = UDim2.new(0, 24, 0, 24)
	notifCloseBtn.Position         = UDim2.new(1, -32, 0.5, -12)
	notifCloseBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 38)
	notifCloseBtn.BackgroundTransparency = 0.2
	notifCloseBtn.Text             = ""
	notifCloseBtn.ZIndex           = 205
	notifCloseBtn.BorderSizePixel  = 0
	Instance.new("UICorner", notifCloseBtn).CornerRadius = UDim.new(0, 6)
	local xStroke                  = Instance.new("UIStroke", notifCloseBtn)
	xStroke.Color                  = Color3.fromRGB(80, 80, 85)
	xStroke.Thickness              = 1
	xStroke.Transparency           = 0.5

	local xL1                      = Instance.new("Frame", notifCloseBtn)
	xL1.AnchorPoint                = Vector2.new(0.5, 0.5)
	xL1.Position                   = UDim2.new(0.5, 0, 0.5, 0)
	xL1.Size                       = UDim2.new(0, 10, 0, 1.5)
	xL1.Rotation                   = 45
	xL1.BackgroundColor3           = Color3.fromRGB(160, 160, 165)
	xL1.BorderSizePixel            = 0
	xL1.ZIndex                     = 206
	Instance.new("UICorner", xL1).CornerRadius = UDim.new(1, 0)
	local xL2                      = Instance.new("Frame", notifCloseBtn)
	xL2.AnchorPoint                = Vector2.new(0.5, 0.5)
	xL2.Position                   = UDim2.new(0.5, 0, 0.5, 0)
	xL2.Size                       = UDim2.new(0, 10, 0, 1.5)
	xL2.Rotation                   = -45
	xL2.BackgroundColor3           = Color3.fromRGB(160, 160, 165)
	xL2.BorderSizePixel            = 0
	xL2.ZIndex                     = 206
	Instance.new("UICorner", xL2).CornerRadius = UDim.new(1, 0)

	notifCloseBtn.MouseEnter:Connect(function()
		TweenService:Create(notifCloseBtn, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(160, 20, 20)}):Play()
		TweenService:Create(xL1, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
		TweenService:Create(xL2, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
	end)
	notifCloseBtn.MouseLeave:Connect(function()
		TweenService:Create(notifCloseBtn, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(35, 35, 38)}):Play()
		TweenService:Create(xL1, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(160, 160, 165)}):Play()
		TweenService:Create(xL2, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(160, 160, 165)}):Play()
	end)

	local progressBg               = Instance.new("Frame", notifCard)
	progressBg.Size                = UDim2.new(1, -28, 0, 3)
	progressBg.Position            = UDim2.new(0, 14, 1, -10)
	progressBg.BackgroundColor3    = Color3.fromRGB(30, 30, 35)
	progressBg.BorderSizePixel     = 0
	progressBg.ZIndex              = 202
	progressBg.ClipsDescendants    = true
	Instance.new("UICorner", progressBg).CornerRadius = UDim.new(1, 0)

	local progressBar              = Instance.new("Frame", progressBg)
	progressBar.Size               = UDim2.new(1, 0, 1, 0)
	progressBar.Position           = UDim2.new(0, 0, 0, 0)
	progressBar.BackgroundColor3   = Color3.fromRGB(255, 255, 255)
	progressBar.BorderSizePixel    = 0
	progressBar.ZIndex             = 203
	Instance.new("UICorner", progressBar).CornerRadius = UDim.new(1, 0)
	local progressGrad             = Instance.new("UIGradient", progressBar)
	progressGrad.Color             = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(230, 20, 25)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 0, 0))
	})

	table.insert(ActiveNotifications, 1, notifHolder)
	UpdateNotifications()

	local linkDur = 5
	local dismissed = false
	local function DismissNotif()
		if dismissed then return end
		dismissed = true
		for i, v in ipairs(ActiveNotifications) do
			if v == notifHolder then table.remove(ActiveNotifications, i) break end
		end
		UpdateNotifications()
		local slideOut = TweenInfo.new(0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.In)
		TweenService:Create(notifHolder, slideOut, {
			Position = UDim2.new(1, 360, notifHolder.Position.Y.Scale, notifHolder.Position.Y.Offset)
		}):Play()
		TweenService:Create(notifCard, slideOut, {BackgroundTransparency = 1}):Play()
		task.delay(0.28, function()
			if notifHolder and notifHolder.Parent then notifHolder:Destroy() end
		end)
	end

	notifCloseBtn.MouseButton1Click:Connect(function() DismissNotif() end)
	local barTween = TweenService:Create(progressBar, TweenInfo.new(linkDur, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {Size = UDim2.new(0, 0, 1, 0)})
	task.delay(0.1, function() barTween:Play() end)
	task.delay(linkDur + 0.1, function() DismissNotif() end)
end

-- ==================== CRIAÇÃO DINÂMICA DOS TOGGLES E LABELS ====================
local function ClearRightPanel()
	for _, child in ipairs(togglesContainer:GetChildren()) do
		if not child:IsA("UIListLayout") and not child:IsA("UIPadding") then
			child:Destroy()
		end
	end
end

local function CriarSecaoLink(labelPrincipal, link, iconeLink)
	local frame                = Instance.new("Frame", togglesContainer)
	frame.Name                 = labelPrincipal .. "_Link"
	frame.Size                 = UDim2.new(1, -6, 0, 48)
	frame.BackgroundColor3     = Color3.fromRGB(45, 10, 15)
	frame.BackgroundTransparency = 0.5
	frame.BorderSizePixel      = 0
	frame.ZIndex               = 11
	Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

	local frameStroke          = Instance.new("UIStroke", frame)
	frameStroke.Color          = Color3.fromRGB(100, 20, 25)
	frameStroke.Thickness      = 1
	frameStroke.Transparency   = 0.3

	local labelText            = Instance.new("TextLabel", frame)
	labelText.Size             = UDim2.new(1, -70, 0, 18)
	labelText.Position         = UDim2.new(0, 16, 0.5, -17)
	labelText.BackgroundTransparency = 1
	labelText.Text             = labelPrincipal
	labelText.TextColor3       = Color3.fromRGB(250, 250, 250)
	labelText.Font             = Enum.Font.GothamBold
	labelText.TextSize         = 13.5
	labelText.TextXAlignment   = Enum.TextXAlignment.Left
	labelText.ZIndex           = 12

	local subText              = Instance.new("TextLabel", frame)
	subText.Size               = UDim2.new(1, -70, 0, 16)
	subText.Position           = UDim2.new(0, 16, 0.5, 1)
	subText.BackgroundTransparency = 1
	subText.Text               = "Click to copy link"
	subText.TextColor3         = Color3.fromRGB(150, 150, 150)
	subText.Font               = Enum.Font.Gotham
	subText.TextSize           = 11.5
	subText.TextXAlignment     = Enum.TextXAlignment.Left
	subText.ZIndex             = 12

	local btn                  = Instance.new("ImageButton", frame)
	btn.Size                   = UDim2.new(0, 28, 0, 28)
	btn.Position               = UDim2.new(1, -36, 0.5, -14)
	btn.BackgroundColor3       = Color3.fromRGB(20, 10, 10)
	btn.BackgroundTransparency = 0
	btn.BorderSizePixel        = 0
	btn.AutoButtonColor        = false
	btn.ZIndex                 = 13
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

	local btnStroke            = Instance.new("UIStroke", btn)
	btnStroke.Color            = Color3.fromRGB(120, 20, 25)
	btnStroke.Thickness        = 1

	local icone                = Instance.new("ImageLabel", btn)
	icone.Size                 = UDim2.new(0, 16, 0, 16)
	icone.AnchorPoint          = Vector2.new(0.5, 0.5)
	icone.Position             = UDim2.new(0.5, 0, 0.5, 0)
	icone.BackgroundTransparency = 1
	icone.Image                = iconeLink or "rbxthumb://type=Asset&id=132712398495147&w=150&h=150"
	icone.ImageColor3          = Color3.fromRGB(200, 200, 200)
	icone.ZIndex               = 14

	btn.MouseButton1Click:Connect(function()
		PlayUI_Click()
		if setclipboard then
			setclipboard(link)
			CriarNotificacaoLinkCopiado("COPIED TO CLIPBOARD!", "rbxthumb://type=Asset&id=132712398495147&w=150&h=150")
		else
			CriarNotificacao("Error", "Your executor does not support clipboard copying.", "rbxthumb://type=Asset&id=70710316269357&w=150&h=150")
		end
		local pressTween = TweenService:Create(btn, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true), {BackgroundColor3 = Color3.fromRGB(80, 10, 15)})
		pressTween:Play()
	end)
end

local function CriarInfoLabel(labelPrincipal, valor)
	local frame                = Instance.new("Frame", togglesContainer)
	frame.Name                 = labelPrincipal .. "_Info"
	frame.Size                 = UDim2.new(1, -6, 0, 48)
	frame.BackgroundColor3     = Color3.fromRGB(20, 8, 12)
	frame.BackgroundTransparency = 0.5
	frame.BorderSizePixel      = 0
	frame.ZIndex               = 11
	Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

	local frameStroke          = Instance.new("UIStroke", frame)
	frameStroke.Color          = Color3.fromRGB(60, 15, 20)
	frameStroke.Thickness      = 1
	frameStroke.Transparency   = 0.3

	local labelText            = Instance.new("TextLabel", frame)
	labelText.Size             = UDim2.new(0.5, -24, 1, 0)
	labelText.Position         = UDim2.new(0, 16, 0, 0)
	labelText.BackgroundTransparency = 1
	labelText.Text             = labelPrincipal
	labelText.TextColor3       = Color3.fromRGB(190, 190, 190)
	labelText.Font             = Enum.Font.GothamMedium
	labelText.TextSize         = 13.5
	labelText.TextXAlignment   = Enum.TextXAlignment.Left
	labelText.ZIndex           = 12

	local valorText            = Instance.new("TextLabel", frame)
	valorText.Size             = UDim2.new(0.5, -24, 1, 0)
	valorText.Position         = UDim2.new(0.5, 8, 0, 0)
	valorText.BackgroundTransparency = 1
	valorText.Text             = tostring(valor)
	valorText.TextColor3       = Color3.fromRGB(240, 240, 240)
	valorText.Font             = Enum.Font.GothamBold
	valorText.TextSize         = 13.5
	valorText.TextXAlignment   = Enum.TextXAlignment.Right
	valorText.ZIndex           = 12
end

local function CriarToggleUI(optKey, optData)
	local optFrame             = Instance.new("Frame", togglesContainer)
	optFrame.Name              = optKey .. "_ToggleFrame"
	optFrame.Size              = UDim2.new(1, -6, 0, 52)
	optFrame.BackgroundColor3  = Color3.fromRGB(45, 10, 15)
	optFrame.BackgroundTransparency = 0.5
	optFrame.BorderSizePixel   = 0
	optFrame.ZIndex            = 11
	Instance.new("UICorner", optFrame).CornerRadius = UDim.new(0, 8)

	local optStroke            = Instance.new("UIStroke", optFrame)
	optStroke.Color            = Color3.fromRGB(100, 20, 25)
	optStroke.Thickness        = 1
	optStroke.Transparency     = 0.3

	local optTitle             = Instance.new("TextLabel", optFrame)
	optTitle.Size              = UDim2.new(1, -70, 0, 18)
	optTitle.Position          = UDim2.new(0, 16, 0.5, -17)
	optTitle.BackgroundTransparency = 1
	optTitle.Text              = optData.Title
	optTitle.TextColor3        = Color3.fromRGB(250, 250, 250)
	optTitle.Font              = Enum.Font.GothamBold
	optTitle.TextSize          = 13.5
	optTitle.TextXAlignment    = Enum.TextXAlignment.Left
	optTitle.ZIndex            = 12

	local optDesc              = Instance.new("TextLabel", optFrame)
	optDesc.Size               = UDim2.new(1, -70, 0, 16)
	optDesc.Position           = UDim2.new(0, 16, 0.5, 1)
	optDesc.BackgroundTransparency = 1
	optDesc.Text               = optData.Desc
	optDesc.TextColor3         = Color3.fromRGB(150, 150, 150)
	optDesc.Font               = Enum.Font.Gotham
	optDesc.TextSize           = 11.5
	optDesc.TextXAlignment     = Enum.TextXAlignment.Left
	optDesc.TextTruncate       = Enum.TextTruncate.AtEnd
	optDesc.ZIndex             = 12

	local toggleBtn            = Instance.new("TextButton", optFrame)
	toggleBtn.Size             = UDim2.new(0, 38, 0, 22)
	toggleBtn.Position         = UDim2.new(1, -50, 0.5, -11)
	toggleBtn.BackgroundColor3 = Configs[optKey] and Color3.fromRGB(220, 30, 40) or Color3.fromRGB(20, 10, 10)
	toggleBtn.Text             = ""
	toggleBtn.ZIndex           = 13
	toggleBtn.AutoButtonColor  = false
	Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1, 0)
	local tStroke              = Instance.new("UIStroke", toggleBtn)
	tStroke.Color              = Color3.fromRGB(120, 20, 25)
	tStroke.Thickness          = 1

	local toggleCircle         = Instance.new("Frame", toggleBtn)
	toggleCircle.Size          = UDim2.new(0, 16, 0, 16)
	toggleCircle.Position      = Configs[optKey] and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
	toggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	toggleCircle.BorderSizePixel = 0
	toggleCircle.ZIndex        = 14
	Instance.new("UICorner", toggleCircle).CornerRadius = UDim.new(1, 0)

	local db = false
	toggleBtn.MouseButton1Click:Connect(function()
		if db then return end
		db = true
		PlayUI_Click()
		Configs[optKey] = not Configs[optKey]
		local state = Configs[optKey]

		local bgGoal  = state and Color3.fromRGB(220, 30, 40) or Color3.fromRGB(20, 10, 10)
		local posGoal = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
		local tInfo   = TweenInfo.new(0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)

		TweenService:Create(toggleBtn, tInfo, {BackgroundColor3 = bgGoal}):Play()
		TweenService:Create(toggleCircle, tInfo, {Position = posGoal}):Play()

		if state then
			CriarNotificacao(optData.Title .. " Enabled", "You enabled " .. optData.Title .. " successfully.")
		else
			CriarNotificacao(optData.Title .. " Disabled", "You disabled " .. optData.Title .. " successfully.")
		end
		task.delay(0.2, function() db = false end)
	end)
end

local function LoadTabContent(tabName, filter)
	ClearRightPanel()
	local toRender = {}
	if tabName == "Player" then
		table.insert(toRender, "Speed")
		table.insert(toRender, "SafeSpot")
		table.insert(toRender, "AntiFling")
		table.insert(toRender, "AutoCollect")
	elseif tabName == "Combat" then
		table.insert(toRender, "Aimbot")
		table.insert(toRender, "Reach")
	elseif tabName == "Visuals" then
		table.insert(toRender, "ESP")
		table.insert(toRender, "ChatRoles")
	elseif tabName == "Teleports" then
		table.insert(toRender, "TpToGun")
	end

	local renderedCount = 0
	for _, optKey in ipairs(toRender) do
		local optData = UI_TEXT.Options[optKey]
		if optData then
			if not filter or filter == "" or string.find(string.lower(optData.Title), string.lower(filter)) then
				CriarToggleUI(optKey, optData)
				renderedCount = renderedCount + 1
			end
		end
	end

	if tabName == "Settings" then
		CriarSecaoLink("Join Discord Server", "https://discord.gg/R9c2G75z9d", "rbxthumb://type=Asset&id=103096515071530&w=150&h=150")
		CriarInfoLabel("Script Version", "v5.7.2")
		CriarInfoLabel("Developer", "zeni")
	end
end

-- ==================== CRIAR TABS LATERAL (COM ACTIVEBAR REUTILIZÁVEL CORRIGIDA) ====================
local function CriarTabButton(tabKey, tabLabel, ordem)
	local tBtn                 = Instance.new("TextButton", TabsContainer)
	tBtn.Name                  = "Tab_" .. tabKey
	tBtn.LayoutOrder           = ordem
	tBtn.Size                  = UDim2.new(1, -24, 0, 36)
	tBtn.BackgroundColor3      = Color3.fromRGB(30, 5, 10)
	tBtn.BackgroundTransparency = 1
	tBtn.Text                  = tabLabel
	tBtn.TextColor3            = Color3.fromRGB(150, 150, 150)
	tBtn.Font                  = Enum.Font.GothamMedium
	tBtn.TextSize              = 14
	tBtn.ZIndex                = 11
	tBtn.BorderSizePixel       = 0
	Instance.new("UICorner", tBtn).CornerRadius = UDim.new(0, 8)

	tabButtons[tabKey] = tBtn

	tBtn.MouseButton1Click:Connect(function()
		PlayUI_Click()
		if activeTab == tabKey then return end
		activeTab = tabKey
		searchTextBox.Text = ""

		for k, btn in pairs(tabButtons) do
			if k == activeTab then
				TweenService:Create(btn, TweenInfo.new(0.2), {
					BackgroundTransparency = 0,
					TextColor3 = Color3.fromRGB(240, 240, 240)
				}):Play()

				sharedActiveBar.Visible = true
				-- Usamos a posição absoluta relativa ao AbsoluteSize/Position do container
				-- Para simplificar, pegaremos o AbsolutePosition Y do botão e subtraímos o AbsolutePosition Y do ActiveBarContainer
				local relY = tBtn.AbsolutePosition.Y - ActiveBarContainer.AbsolutePosition.Y
				
				TweenService:Create(sharedActiveBar, TweenInfo.new(0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
					Position = UDim2.new(0, 7, 0, relY + (tBtn.AbsoluteSize.Y / 2))
				}):Play()

			else
				TweenService:Create(btn, TweenInfo.new(0.2), {
					BackgroundTransparency = 1,
					TextColor3 = Color3.fromRGB(150, 150, 150)
				}):Play()
			end
		end

		local fadeOut = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local fadeIn  = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

		local t1 = TweenService:Create(togglesContainer, fadeOut, {BackgroundTransparency = 1})
		t1:Play()
		t1.Completed:Wait()

		LoadTabContent(activeTab)
		AplicarFadeSincronizado(togglesContainer, false, 0)
		togglesContainer.CanvasPosition = Vector2.new(0, 0)
		TweenService:Create(togglesContainer, fadeIn, {BackgroundTransparency = 0.7}):Play()
	end)
end

CriarTabButton("Player",    UI_TEXT.Tabs.Player,    1)
CriarTabButton("Combat",    UI_TEXT.Tabs.Combat,    2)
CriarTabButton("Visuals",   UI_TEXT.Tabs.Visuals,   3)
CriarTabButton("Teleports", UI_TEXT.Tabs.Teleports, 4)
CriarTabButton("Settings",  UI_TEXT.Tabs.Settings,  5)

task.spawn(function()
	task.wait(0.1)
	local initBtn = tabButtons["Player"]
	if initBtn then
		initBtn.BackgroundTransparency = 0
		initBtn.TextColor3 = Color3.fromRGB(240, 240, 240)
		sharedActiveBar.Visible = true
		local relY = initBtn.AbsolutePosition.Y - ActiveBarContainer.AbsolutePosition.Y
		sharedActiveBar.Position = UDim2.new(0, 7, 0, relY + (initBtn.AbsoluteSize.Y / 2))
	end
end)

searchTextBox:GetPropertyChangedSignal("Text"):Connect(function()
	LoadTabContent(activeTab, searchTextBox.Text)
end)

-- ==================== STATE MACHINE LOGIC ====================
function SetUIState(newState)
	if UIState == newState then return end
	UIState = newState

	local tInfoCubic = TweenInfo.new(0.4, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)

	if UIState == "OPEN" then
		FloatBtn.Visible = false
		mainWrapper.Visible = true
		AplicarFadeSincronizado(mainFrame, false, 0.4)

		mainWrapper.Size = UDim2.new(0, 600, 0, 320)
		TweenService:Create(mainWrapper, tInfoCubic, {Size = UDim2.new(0, 640, 0, 360)}):Play()

		if isExpanded then
			TweenService:Create(LeftPanel,  tInfoCubic, {Size = UDim2.new(0, 220, 1, 0), Position = UDim2.new(0, 0, 0, 0)}):Play()
			TweenService:Create(RightPanel, tInfoCubic, {Size = UDim2.new(1, -220, 1, 0), Position = UDim2.new(0, 220, 0, 0)}):Play()
		else
			TweenService:Create(LeftPanel,  tInfoCubic, {Size = UDim2.new(0, 220, 1, 0), Position = UDim2.new(0, 0, 0, 0)}):Play()
			TweenService:Create(RightPanel, tInfoCubic, {Size = UDim2.new(1, -220, 1, 0), Position = UDim2.new(0, 220, 0, 0)}):Play()
		end

	elseif UIState == "MINIMIZED" then
		AplicarFadeSincronizado(mainFrame, true, 0.3)
		TweenService:Create(mainWrapper, TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), {Size = UDim2.new(0, 580, 0, 300)}):Play()

		task.delay(0.3, function()
			if UIState == "MINIMIZED" then
				mainWrapper.Visible = false
				FloatBtn.Visible = true
				FloatBtn.Size = UDim2.new(0, 0, 0, 0)
				FloatBtn.Rotation = 180
				TweenService:Create(FloatBtn, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
					Size = UDim2.new(0, 44, 0, 44),
					Rotation = 0
				}):Play()
			end
		end)

	elseif UIState == "CONFIRM_CLOSE" then
		isConfirmOpen = true
		confirmOverlay.Visible = true
		TweenService:Create(confirmBlur, TweenInfo.new(0.3), {Size = 24}):Play()
		TweenService:Create(confirmOverlay, TweenInfo.new(0.3), {BackgroundTransparency = 0.55}):Play()
		AplicarFadeSincronizado(confirmCard, false, 0.3)
		confirmCard.Size = UDim2.new(0, 260, 0, 100)
		TweenService:Create(confirmCard, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 300, 0, 130)}):Play()

	elseif UIState == "CLOSED" then
		AplicarFadeSincronizado(mainFrame, true, 0.3)
		TweenService:Create(mainWrapper, TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), {Size = UDim2.new(0, 580, 0, 300)}):Play()
		task.delay(0.3, function() if UIState == "CLOSED" then mainWrapper.Visible = false end end)
	end
end

MinimizeBtn.MouseButton1Click:Connect(function()
	PlayUI_Click()
	SetUIState("MINIMIZED")
end)

ExpandBtn.MouseButton1Click:Connect(function()
	PlayUI_Click()
	isExpanded = not isExpanded
	local tInfo = TweenInfo.new(0.4, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
	if isExpanded then
		TweenService:Create(LeftPanel,  tInfo, {Size = UDim2.new(0, 0, 1, 0), Position = UDim2.new(0, -220, 0, 0)}):Play()
		TweenService:Create(RightPanel, tInfo, {Size = UDim2.new(1, 0, 1, 0), Position = UDim2.new(0, 0, 0, 0)}):Play()
		ExpandIcon.Image = "rbxthumb://type=Asset&id=78749046909931&w=150&h=150"
	else
		TweenService:Create(LeftPanel,  tInfo, {Size = UDim2.new(0, 220, 1, 0), Position = UDim2.new(0, 0, 0, 0)}):Play()
		TweenService:Create(RightPanel, tInfo, {Size = UDim2.new(1, -220, 1, 0), Position = UDim2.new(0, 220, 0, 0)}):Play()
		ExpandIcon.Image = "rbxthumb://type=Asset&id=78749046909931&w=150&h=150"
	end
end)

CloseBtn.MouseButton1Click:Connect(function()
	PlayUI_Click()
	SetUIState("CONFIRM_CLOSE")
end)

local function FecharConfirmacao()
	if not isConfirmOpen then return end
	PlayUI_Click()
	isConfirmOpen = false
	TweenService:Create(confirmBlur, TweenInfo.new(0.3), {Size = 0}):Play()
	TweenService:Create(confirmOverlay, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
	AplicarFadeSincronizado(confirmCard, true, 0.3)
	TweenService:Create(confirmCard, TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), {Size = UDim2.new(0, 260, 0, 100)}):Play()
	task.delay(0.3, function()
		if not isConfirmOpen then confirmOverlay.Visible = false end
	end)
end

btnNo.MouseButton1Click:Connect(function()
	FecharConfirmacao()
	SetUIState("OPEN")
end)

btnYes.MouseButton1Click:Connect(function()
	PlayUI_Click()
	SetUIState("CLOSED")
	TweenService:Create(confirmBlur, TweenInfo.new(0.3), {Size = 0}):Play()
	TweenService:Create(confirmOverlay, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
	AplicarFadeSincronizado(confirmCard, true, 0.3)
	task.delay(0.35, function()
		screenGui:Destroy()
	end)
end)

-- ==================== ANIMAÇÃO DE INTRODUÇÃO ====================
local introBlur = Instance.new("BlurEffect", Lighting)
introBlur.Name  = "IntroBlur"
introBlur.Size  = 24

local IntroOverlay = Instance.new("Frame", screenGui)
IntroOverlay.Name  = "IntroOverlay"
IntroOverlay.Size  = UDim2.new(1, 0, 1, 0)
IntroOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
IntroOverlay.BackgroundTransparency = 0
IntroOverlay.ZIndex = 1000

local IntroLogo = Instance.new("ImageLabel", IntroOverlay)
IntroLogo.Size = UDim2.new(0, 120, 0, 120)
IntroLogo.AnchorPoint = Vector2.new(0.5, 0.5)
IntroLogo.Position = UDim2.new(0.5, 0, 0.45, 0)
IntroLogo.BackgroundTransparency = 1
IntroLogo.Image = "rbxthumb://type=Asset&id=139044062702391&w=150&h=150"
IntroLogo.ImageTransparency = 1
IntroLogo.ZIndex = 1001
local startScale = 0.6
IntroLogo.Size = UDim2.new(0, 120 * startScale, 0, 120 * startScale)

local IntroText = Instance.new("TextLabel", IntroOverlay)
IntroText.Size = UDim2.new(0, 300, 0, 30)
IntroText.AnchorPoint = Vector2.new(0.5, 0.5)
IntroText.Position = UDim2.new(0.5, 0, 0.55, 0)
IntroText.BackgroundTransparency = 1
IntroText.RichText = true
IntroText.Text = UI_TEXT.Intro
IntroText.Font = Enum.Font.GothamMedium
IntroText.TextSize = 18
IntroText.TextTransparency = 1
IntroText.ZIndex = 1001

task.spawn(function()
	LoadTabContent(activeTab)
	task.wait(0.5)
	TweenService:Create(IntroLogo, TweenInfo.new(0.8, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
		ImageTransparency = 0,
		Size = UDim2.new(0, 120, 0, 120)
	}):Play()
	task.wait(0.4)
	TweenService:Create(IntroText, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		TextTransparency = 0,
		Position = UDim2.new(0.5, 0, 0.57, 0)
	}):Play()
	task.wait(1.5)
	TweenService:Create(IntroLogo, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		ImageTransparency = 1,
		Size = UDim2.new(0, 120 * 1.1, 0, 120 * 1.1)
	}):Play()
	TweenService:Create(IntroText, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		TextTransparency = 1,
		Position = UDim2.new(0.5, 0, 0.59, 0)
	}):Play()
	task.wait(0.5)
	TweenService:Create(IntroOverlay, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
	TweenService:Create(introBlur, TweenInfo.new(0.5), {Size = 0}):Play()
	task.wait(0.5)
	IntroOverlay:Destroy()
	introBlur:Destroy()

	SetUIState("OPEN")
	CriarNotificacao("Welcome to AKATSUKI", "UI Loaded successfully. Enjoy!")
end)

-- ==================== EXECUÇÃO DA LÓGICA EXTERNA ====================

-- 1. Expõe a tabela de configurações globalmente para que o script do link raw possa lê-la:
getgenv().AkatConfigs = Configs

-- 2. Carrega e executa o seu script externo por um link raw:
-- Formato de link raw corrigido (Geralmente não se usa 'refs/heads/' para links raw)
local rawLink = "https://raw.githubusercontent.com/estratosfera88-afk/MM2-SCRIPT-/main/main.lua"

local fetchSuccess, fetchResult = pcall(function()
	return game:HttpGet(rawLink)
end)

if fetchSuccess and fetchResult then
	local scriptFunction, compilerError = loadstring(fetchResult)
	
	if scriptFunction then
		local execSuccess, execResult = pcall(scriptFunction)
		if not execSuccess then
			warn("[AKATSUKI ERROR] Erro durante a execução do código raw:", execResult)
		end
	else
		warn("[AKATSUKI ERROR] Erro de sintaxe no código baixado (loadstring falhou):", compilerError)
	end
else
	warn("[AKATSUKI ERROR] Falha ao tentar baixar o script (game:HttpGet falhou). Verifique a URL. Motivo:", fetchResult)
end
