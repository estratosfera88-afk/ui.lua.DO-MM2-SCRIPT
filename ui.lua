-- [[
--     AKAT SCRIPT - UNIVERSAL DYNAMIC UI COMPONENT [v3.5]
--     Hospede este script no GitHub/Pastebin e pegue o link "Raw"
-- ]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local mouse = player:GetMouse()

-- Recupera as configurações globais criadas pelo Script de Lógica
local Configs = _G.Configs or {}

-- ==================== SISTEMA DE CARGA DINÂMICA (FALLBACK MM2) ====================
local DefaultLocales = {
    PT = {
        SearchPlaceholder = "Pesquisar...",
        ConfirmCloseTitle = "Deseja fechar o script?",
        ConfirmBtn = "Confirmar",
        CancelBtn = "Cancelar",
        Tabs = { Combat = "Combate", Visuals = "Visuais", Movement = "Movimento", Teleports = "Teleportes", Misc = "Diversos" },
        Options = {
            AutoShoot = { Title = "Atirar no Murder", Desc = "Ativa o botão flutuante de disparo direto e silencioso no Assassino." },
            Reach = { Title = "Alcance da Faca", Desc = "Aumenta consideravelmente o alcance de ataque com a sua faca (18 studs)." },
            ESP = { Title = "ESP Jogadores", Desc = "Destaca jogadores pelas paredes (Xerife Azul / Herói Amarelo)." },
            Speed = { Title = "Velocidade", Desc = "Aumenta a velocidade de caminhada do seu personagem para 23 de forma estável." },
            AntiFling = { Title = "Anti-Arremesso", Desc = "Bloqueia colisões que tentem te empurrar ou arremessar." },
            TpToGun = { Title = "Teleportar p/ Arma", Desc = "Inocentes se teleportam para a arma dropada (Ignorado se você for Murder)." },
            SafeSpot = { Title = "Lugar Seguro", Desc = "Cria uma plataforma invisível no céu para ficar totalmente seguro." },
            AutoCollect = { Title = "Coletar Moedas", Desc = "Coleta moedas continuamente em alta velocidade sem pausas lentas." },
            ChatRoles = { Title = "Revelar Funções", Desc = "Envia no chat quem é o Assassino e o Xerife." }
        },
        Intro = '<font color="#FFFFFF">Scripts por | </font><font color="#8B0000">Comunidade AKAT</font>'
    },
    EN = {
        SearchPlaceholder = "Search...",
        ConfirmCloseTitle = "Do you want to close the script?",
        ConfirmBtn = "Confirm",
        CancelBtn = "Cancel",
        Tabs = { Combat = "Combat", Visuals = "Visuals", Movement = "Movement", Teleports = "Teleports", Misc = "Misc" },
        Options = {
            AutoShoot = { Title = "Shoot Murderer", Desc = "Enables a floating shoot button that perfectly hits the Murderer." },
            Reach = { Title = "Knife Reach", Desc = "Significantly increases your knife attack reach (18 studs)." },
            ESP = { Title = "Player ESP", Desc = "Highlights players through walls (Sheriff Blue / Hero Yellow)." },
            Speed = { Title = "WalkSpeed", Desc = "Slightly increases player walkspeed up to 23 smoothly." },
            AntiFling = { Title = "Anti-Fling", Desc = "Disables collisions to prevent other players from flinging you." },
            TpToGun = { Title = "TP to Gun", Desc = "Teleports to dropped gun (Automatically disabled for the Murderer)." },
            SafeSpot = { Title = "Safe Spot", Desc = "Teleports you to an invisible sky platform to remain completely safe." },
            AutoCollect = { Title = "Auto Collect", Desc = "Smoothly collects coins continuously without clunky visual stops." },
            ChatRoles = { Title = "Reveal Roles", Desc = "Sends a message in chat revealing active roles." }
        },
        Intro = '<font color="#FFFFFF">Scripts by | </font><font color="#8B0000">AKAT Community</font>'
    }
}

-- Se o backend enviou dados, usa eles. Se não, usa o MM2 padrão.
local Locales = (_G.UIData and _G.UIData.Locales) or DefaultLocales
local MenuTitleText = (_G.UIData and _G.UIData.Title) or "AKAT SCRIPTS"
local MenuSubtitleText = (_G.UIData and _G.UIData.Subtitle) or "MM2 SCRIPT [BETA v3.2]"

local currentLanguage = "EN"
local activeTab = ""
local tabButtons = {}
local menuAberto = true
local isMinimized = false
local originalTrans = {}
local confirmBlur = nil
local isConfirmOpen = false
local wasMinimizedBeforeConfirm = false

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DeltaAkatUniversalUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true

local uiParent = player:FindFirstChild("PlayerGui")
if gethui then uiParent = gethui()
else
    local ok, cg = pcall(function() return game:GetService("CoreGui") end)
    if ok and cg then uiParent = cg end
end

if uiParent:FindFirstChild("DeltaAkatUniversalUI") then
    pcall(function() uiParent.DeltaAkatUniversalUI:Destroy() end)
end
screenGui.Parent = uiParent

local function ConfigurarArrastarAkat(inst)
    local drag = false
    local startPos, dragStart, dragInput
    inst.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            drag = true
            dragStart = input.Position
            startPos = inst.Position
            dragInput = input
            local connection
            connection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    drag = false
                    connection:Disconnect()
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if drag and input == dragInput and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            inst.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- [BOTÃO FLUTUANTE DO MENU]
local FloatBtn = Instance.new("ImageButton", screenGui)
FloatBtn.Name = "FloatBtn"
FloatBtn.AnchorPoint = Vector2.new(0.5, 0.5)
FloatBtn.Size = UDim2.new(0, 44, 0, 44)
FloatBtn.Position = UDim2.new(0.12, 0, 0.4, 0)
FloatBtn.Image = "rbxthumb://type=Asset&id=99997714241420&w=150&h=150"
FloatBtn.ImageColor3 = Color3.fromRGB(255, 255, 255)
FloatBtn.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
FloatBtn.Visible = false
FloatBtn.ZIndex = 30

local floatCorner = Instance.new("UICorner", FloatBtn)
floatCorner.CornerRadius = UDim.new(0, 8)

local FloatStroke = Instance.new("UIStroke", FloatBtn)
FloatStroke.Thickness = 1
FloatStroke.Color = Color3.fromRGB(139, 0, 0)

local StrokeGradient = Instance.new("UIGradient", FloatStroke)
StrokeGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromHex("#8B0000")),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(15, 15, 15)),
    ColorSequenceKeypoint.new(1, Color3.fromHex("#8B0000"))
})

task.spawn(function()
    local rot = 0
    while task.wait() do
        if not StrokeGradient.Parent then break end
        rot = (rot + 3) % 360
        StrokeGradient.Rotation = rot
    end
end)

-- [BOTÃO FLUTUANTE DO AUTO SHOOT MOBILE]
local AutoShootMobileBtn = Instance.new("Frame", screenGui)
AutoShootMobileBtn.Name = "AutoShootMobileBtn"
AutoShootMobileBtn.AnchorPoint = Vector2.new(0.5, 0.5)
AutoShootMobileBtn.Size = UDim2.new(0, 140, 0, 42)
AutoShootMobileBtn.Position = UDim2.new(0.78, 0, 0.55, 0)
AutoShootMobileBtn.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
AutoShootMobileBtn.BackgroundTransparency = 0.25
AutoShootMobileBtn.Visible = false
AutoShootMobileBtn.ZIndex = 40

local asBtnCorner = Instance.new("UICorner", AutoShootMobileBtn)
asBtnCorner.CornerRadius = UDim.new(0, 8)

local asBtnStroke = Instance.new("UIStroke", AutoShootMobileBtn)
asBtnStroke.Thickness = 1.5
asBtnStroke.Color = Color3.fromRGB(139, 0, 0)

local asStrokeGradient = Instance.new("UIGradient", asBtnStroke)
asStrokeGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromHex("#8B0000")),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(15, 15, 15)),
    ColorSequenceKeypoint.new(1, Color3.fromHex("#8B0000"))
})

task.spawn(function()
    local rot = 0
    while task.wait() do
        if not asStrokeGradient.Parent then break end
        rot = (rot + 3) % 360
        asStrokeGradient.Rotation = rot
    end
end)

local asBtnText = Instance.new("TextButton", AutoShootMobileBtn)
asBtnText.Size = UDim2.new(1, 0, 1, 0)
asBtnText.BackgroundTransparency = 1
asBtnText.Text = "Auto Action"
asBtnText.TextColor3 = Color3.fromRGB(255, 255, 255)
asBtnText.Font = Enum.Font.GothamBold
asBtnText.TextSize = 12
asBtnText.ZIndex = 41

ConfigurarArrastarAkat(AutoShootMobileBtn)

asBtnText.MouseButton1Click:Connect(function()
    local info = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(AutoShootMobileBtn, info, {Size = UDim2.new(0, 130, 0, 38)}):Play()
    task.delay(0.1, function()
        TweenService:Create(AutoShootMobileBtn, info, {Size = UDim2.new(0, 140, 0, 42)}):Play()
    end)

    if _G.AkatCallbacks and _G.AkatCallbacks.FireShoot then
        _G.AkatCallbacks.FireShoot()
    elseif _G.AkatCallbacks and _G.AkatCallbacks.CustomAction then
        _G.AkatCallbacks.CustomAction()
    end
end)

-- [ESTRUTURA GERAL DO MENU]
local mainWrapper = Instance.new("Frame")
mainWrapper.Name = "MainWrapper"
mainWrapper.AnchorPoint = Vector2.new(0.5, 0)
mainWrapper.Size = UDim2.new(0, 520, 0, 300)
mainWrapper.Position = UDim2.new(0.5, 0, 0.5, -150)
mainWrapper.BackgroundTransparency = 1
mainWrapper.Visible = false
mainWrapper.Parent = screenGui

local shadow3D = Instance.new("ImageLabel")
shadow3D.Name = "Shadow3D"
shadow3D.AnchorPoint = Vector2.new(0.5, 0.5)
shadow3D.Position = UDim2.new(0.5, 0, 0.5, 4)
shadow3D.Size = UDim2.new(1, 40, 1, 40)
shadow3D.BackgroundTransparency = 1
shadow3D.Image = "rbxassetid://6014261993"
shadow3D.ImageColor3 = Color3.fromRGB(0, 0, 0)
shadow3D.ImageTransparency = 0.5
shadow3D.ScaleType = Enum.ScaleType.Slice
shadow3D.SliceCenter = Rect.new(49, 49, 450, 450)
shadow3D.ZIndex = 1
shadow3D.Parent = mainWrapper

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(1, 0, 1, 0)
mainFrame.BackgroundColor3 = Color3.fromHex("#0A0A0A")
mainFrame.BackgroundTransparency = 0.22
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.ZIndex = 5
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 9)
local frameStroke = Instance.new("UIStroke", mainFrame)
frameStroke.Color = Color3.fromHex("#161616")
frameStroke.Thickness = 1
mainFrame.Parent = mainWrapper

local topBar = Instance.new("Frame", mainFrame)
topBar.Name = "TopBar"
topBar.Size = UDim2.new(1, 0, 0, 52)
topBar.BackgroundTransparency = 1
topBar.ZIndex = 6

local title = Instance.new("TextLabel", topBar)
title.Name = "Title"
title.Size = UDim2.new(0, 200, 0, 22)
title.Position = UDim2.new(0, 16, 0, 10)
title.BackgroundTransparency = 1
title.Text = MenuTitleText
title.TextColor3 = Color3.fromHex("#8B0000")
title.TextSize = 16
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.ZIndex = 6

local subtitle = Instance.new("TextLabel", topBar)
subtitle.Name = "Subtitle"
subtitle.Size = UDim2.new(0, 200, 0, 14)
subtitle.Position = UDim2.new(0, 16, 0, 28)
subtitle.BackgroundTransparency = 1
subtitle.Text = MenuSubtitleText
subtitle.TextColor3 = Color3.fromHex("#8B0000")
subtitle.TextSize = 10
subtitle.Font = Enum.Font.Gotham
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.ZIndex = 6

local searchBarFrame = Instance.new("Frame", topBar)
searchBarFrame.Name = "SearchBarFrame"
searchBarFrame.AnchorPoint = Vector2.new(1, 0.5)
searchBarFrame.Position = UDim2.new(1, -154, 0.5, 0)
searchBarFrame.Size = UDim2.new(0, 0, 0, 26)
searchBarFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
searchBarFrame.ClipsDescendants = true
searchBarFrame.ZIndex = 7
Instance.new("UICorner", searchBarFrame).CornerRadius = UDim.new(0, 13)
local searchStroke = Instance.new("UIStroke", searchBarFrame)
searchStroke.Color = Color3.fromHex("#1F1F1F")
searchStroke.Thickness = 1

local searchTextBox = Instance.new("TextBox", searchBarFrame)
searchTextBox.Name = "SearchTextBox"
searchTextBox.Size = UDim2.new(1, -20, 1, 0)
searchTextBox.Position = UDim2.new(0, 12, 0, 0)
searchTextBox.BackgroundTransparency = 1
searchTextBox.PlaceholderText = "Search..."
searchTextBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
searchTextBox.Text = ""
searchTextBox.TextColor3 = Color3.fromRGB(230, 230, 230)
searchTextBox.Font = Enum.Font.Gotham
searchTextBox.TextSize = 11
searchTextBox.TextXAlignment = Enum.TextXAlignment.Left
searchTextBox.ZIndex = 8

local topButtons = Instance.new("Frame", topBar)
topButtons.Size = UDim2.new(0, 128, 0, 26)
topButtons.Position = UDim2.new(1, -144, 0.5, -13)
topButtons.BackgroundTransparency = 1
topButtons.ZIndex = 6

local UIListTop = Instance.new("UIListLayout", topButtons)
UIListTop.FillDirection = Enum.FillDirection.Horizontal
UIListTop.HorizontalAlignment = Enum.HorizontalAlignment.Right
UIListTop.VerticalAlignment = Enum.VerticalAlignment.Center
UIListTop.Padding = UDim.new(0, 8)
UIListTop.SortOrder = Enum.SortOrder.LayoutOrder

local LanguageBtn = Instance.new("TextButton", topButtons)
LanguageBtn.Name = "LanguageBtn"
LanguageBtn.LayoutOrder = 0
LanguageBtn.Size = UDim2.new(0, 26, 0, 26)
LanguageBtn.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
LanguageBtn.Text = currentLanguage
LanguageBtn.TextColor3 = Color3.fromRGB(160, 160, 160)
LanguageBtn.Font = Enum.Font.GothamBold
LanguageBtn.TextSize = 10
LanguageBtn.ZIndex = 7
Instance.new("UICorner", LanguageBtn).CornerRadius = UDim.new(0, 5)

local SearchBtn = Instance.new("TextButton", topButtons)
SearchBtn.Name = "SearchBtn"
SearchBtn.LayoutOrder = 1
SearchBtn.Size = UDim2.new(0, 26, 0, 26)
SearchBtn.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
SearchBtn.Text = ""
SearchBtn.ZIndex = 7
Instance.new("UICorner", SearchBtn).CornerRadius = UDim.new(0, 5)

local SearchIcon = Instance.new("Frame", SearchBtn)
SearchIcon.Name = "Icon"
SearchIcon.Size = UDim2.new(0, 14, 0, 14)
SearchIcon.AnchorPoint = Vector2.new(0.5, 0.5)
SearchIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
SearchIcon.BackgroundTransparency = 1
SearchIcon.ZIndex = 8

local SearchCircle = Instance.new("Frame", SearchIcon)
SearchCircle.Name = "Circle"
SearchCircle.Size = UDim2.new(0, 8, 0, 8)
SearchCircle.Position = UDim2.new(0, 1, 0, 1)
SearchCircle.BackgroundTransparency = 1
SearchCircle.ZIndex = 8
Instance.new("UICorner", SearchCircle).CornerRadius = UDim.new(1, 0)
local circleStroke = Instance.new("UIStroke", SearchCircle)
circleStroke.Color = Color3.fromHex("#A0A0A0")
circleStroke.Thickness = 1

local SearchHandle = Instance.new("Frame", SearchIcon)
SearchHandle.Name = "Handle"
SearchHandle.Size = UDim2.new(0, 1, 0, 5)
SearchHandle.Position = UDim2.new(0, 9, 0, 8)
SearchHandle.Rotation = -45
SearchHandle.BackgroundColor3 = Color3.fromHex("#A0A0A0")
SearchHandle.BorderSizePixel = 0
SearchHandle.ZIndex = 8

local MinimizeBtn = Instance.new("TextButton", topButtons)
MinimizeBtn.Name = "MinimizeBtn"
MinimizeBtn.LayoutOrder = 2
MinimizeBtn.Size = UDim2.new(0, 26, 0, 26)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
MinimizeBtn.Text = ""
MinimizeBtn.ZIndex = 7
Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(0, 5)

local MinimizeLine = Instance.new("Frame", MinimizeBtn)
MinimizeLine.Name = "Line"
MinimizeLine.AnchorPoint = Vector2.new(0.5, 0.5)
MinimizeLine.Position = UDim2.new(0.5, 0, 0.5, 0)
MinimizeLine.Size = UDim2.new(0, 10, 0, 1)
MinimizeLine.BackgroundColor3 = Color3.fromHex("#A0A0A0")
MinimizeLine.BorderSizePixel = 0
MinimizeLine.ZIndex = 8

local CloseBtn = Instance.new("TextButton", topButtons)
CloseBtn.Name = "CloseBtn"
CloseBtn.LayoutOrder = 3
CloseBtn.Size = UDim2.new(0, 26, 0, 26)
CloseBtn.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
CloseBtn.Text = ""
CloseBtn.ZIndex = 7
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 5)

local CloseLine1 = Instance.new("Frame", CloseBtn)
CloseLine1.Name = "Line1"
CloseLine1.AnchorPoint = Vector2.new(0.5, 0.5)
CloseLine1.Position = UDim2.new(0.5, 0, 0.5, 0)
CloseLine1.Size = UDim2.new(0, 10, 0, 1)
CloseLine1.Rotation = 45
CloseLine1.BackgroundColor3 = Color3.fromHex("#A0A0A0")
CloseLine1.BorderSizePixel = 0
CloseLine1.ZIndex = 8

local CloseLine2 = Instance.new("Frame", CloseBtn)
CloseLine2.Name = "Line2"
CloseLine2.AnchorPoint = Vector2.new(0.5, 0.5)
CloseLine2.Position = UDim2.new(0.5, 0, 0.5, 0)
CloseLine2.Size = UDim2.new(0, 10, 0, 1)
CloseLine2.Rotation = -45
CloseLine2.BackgroundColor3 = Color3.fromHex("#A0A0A0")
CloseLine2.BorderSizePixel = 0
CloseLine2.ZIndex = 8

local div = Instance.new("Frame", mainFrame)
div.Size = UDim2.new(1, 0, 0, 1)
div.Position = UDim2.new(0, 0, 0, 52)
div.BackgroundColor3 = Color3.fromHex("#121212")
div.BorderSizePixel = 0
div.ZIndex = 6

-- [SIDEBAR]
local SidebarFrame = Instance.new("Frame", mainFrame)
SidebarFrame.Name = "SidebarFrame"
SidebarFrame.Size = UDim2.new(0, 140, 1, -53)
SidebarFrame.Position = UDim2.new(0, 0, 0, 53)
SidebarFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
SidebarFrame.BackgroundTransparency = 0.35
SidebarFrame.BorderSizePixel = 0
SidebarFrame.ZIndex = 6
Instance.new("UICorner", SidebarFrame).CornerRadius = UDim.new(0, 9)

local SidebarSeparator = Instance.new("Frame", SidebarFrame)
SidebarSeparator.Size = UDim2.new(0, 1, 1, 0)
SidebarSeparator.Position = UDim2.new(1, 0, 0, 0)
SidebarSeparator.BackgroundColor3 = Color3.fromHex("#121212")
SidebarSeparator.BorderSizePixel = 0
SidebarSeparator.ZIndex = 6

local ProfileDiv = Instance.new("Frame", SidebarFrame)
ProfileDiv.Size = UDim2.new(1, 0, 0, 1)
ProfileDiv.Position = UDim2.new(0, 0, 1, -66)
ProfileDiv.BackgroundColor3 = Color3.fromHex("#121212")
ProfileDiv.BorderSizePixel = 0
ProfileDiv.ZIndex = 6

local TabsContainer = Instance.new("ScrollingFrame", SidebarFrame)
TabsContainer.Name = "TabsContainer"
TabsContainer.Size = UDim2.new(1, 0, 1, -75)
TabsContainer.Position = UDim2.new(0, 0, 0, 5)
TabsContainer.BackgroundTransparency = 1
TabsContainer.BorderSizePixel = 0
TabsContainer.ScrollBarThickness = 0
TabsContainer.ZIndex = 7
TabsContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
TabsContainer.ElasticBehavior = Enum.ElasticBehavior.Never
pcall(function() TabsContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y end)

local TabsLayout = Instance.new("UIListLayout", TabsContainer)
TabsLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabsLayout.Padding = UDim.new(0, 0)
TabsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local UserProfileFrame = Instance.new("Frame", SidebarFrame)
UserProfileFrame.Name = "UserProfileFrame"
UserProfileFrame.Size = UDim2.new(1, -16, 0, 50)
UserProfileFrame.Position = UDim2.new(0, 8, 1, -58)
UserProfileFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
UserProfileFrame.BackgroundTransparency = 0.2
UserProfileFrame.BorderSizePixel = 0
UserProfileFrame.ZIndex = 7
Instance.new("UICorner", UserProfileFrame).CornerRadius = UDim.new(0, 6)
local ProfileBorder = Instance.new("UIStroke", UserProfileFrame)
ProfileBorder.Color = Color3.fromRGB(24, 24, 24)
ProfileBorder.Thickness = 1

local AvatarImage = Instance.new("ImageLabel", UserProfileFrame)
AvatarImage.Name = "AvatarImage"
AvatarImage.Size = UDim2.new(0, 32, 0, 32)
AvatarImage.Position = UDim2.new(0, 10, 0.5, -16)
AvatarImage.BackgroundTransparency = 1
AvatarImage.Image = "rbxthumb://type=AvatarHeadShot&id=" .. player.UserId .. "&w=150&h=150"
AvatarImage.ZIndex = 8
Instance.new("UICorner", AvatarImage).CornerRadius = UDim.new(1, 0)

local DisplayNameLabel = Instance.new("TextLabel", UserProfileFrame)
DisplayNameLabel.Name = "DisplayNameLabel"
DisplayNameLabel.Size = UDim2.new(1, -54, 0, 14)
DisplayNameLabel.Position = UDim2.new(0, 48, 0.5, -14)
DisplayNameLabel.BackgroundTransparency = 1
DisplayNameLabel.Text = player.DisplayName
DisplayNameLabel.TextColor3 = Color3.fromRGB(235, 235, 235)
DisplayNameLabel.Font = Enum.Font.GothamBold
DisplayNameLabel.TextSize = 11
DisplayNameLabel.TextXAlignment = Enum.TextXAlignment.Left
DisplayNameLabel.TextTruncate = Enum.TextTruncate.AtEnd
DisplayNameLabel.ZIndex = 8

local UsernameLabel = Instance.new("TextLabel", UserProfileFrame)
UsernameLabel.Name = "UsernameLabel"
UsernameLabel.Size = UDim2.new(1, -54, 0, 12)
UsernameLabel.Position = UDim2.new(0, 48, 0.5, 0)
UsernameLabel.BackgroundTransparency = 1
UsernameLabel.Text = "@" .. player.Name
UsernameLabel.TextColor3 = Color3.fromRGB(130, 130, 130)
UsernameLabel.Font = Enum.Font.Gotham
UsernameLabel.TextSize = 9
UsernameLabel.TextXAlignment = Enum.TextXAlignment.Left
UsernameLabel.TextTruncate = Enum.TextTruncate.AtEnd
UsernameLabel.ZIndex = 8

local togglesContainer = Instance.new("ScrollingFrame", mainFrame)
togglesContainer.Name = "TogglesContainer"
togglesContainer.Size = UDim2.new(1, -156, 1, -66)
togglesContainer.Position = UDim2.new(0, 148, 0, 58)
togglesContainer.BackgroundTransparency = 1
togglesContainer.BorderSizePixel = 0
togglesContainer.ScrollBarThickness = 0
togglesContainer.ZIndex = 6
togglesContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
togglesContainer.ElasticBehavior = Enum.ElasticBehavior.Never
pcall(function() togglesContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y end)

local containerLayout = Instance.new("UIListLayout", togglesContainer)
containerLayout.SortOrder = Enum.SortOrder.LayoutOrder
containerLayout.Padding = UDim.new(0, 6)
containerLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local uiPadding = Instance.new("UIPadding", togglesContainer)
uiPadding.PaddingBottom = UDim.new(0, 8)

local confirmFrame = Instance.new("Frame", mainFrame)
confirmFrame.Name = "ConfirmFrame"
confirmFrame.Size = UDim2.new(1, 0, 1, 0)
confirmFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
confirmFrame.BackgroundTransparency = 0.4
confirmFrame.Visible = false
confirmFrame.ZIndex = 50
Instance.new("UICorner", confirmFrame).CornerRadius = UDim.new(0, 9)

local confirmLabel = Instance.new("TextLabel", confirmFrame)
confirmLabel.Size = UDim2.new(1, 0, 0, 30)
confirmLabel.Position = UDim2.new(0, 0, 0.35, -10)
confirmLabel.BackgroundTransparency = 1
confirmLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
confirmLabel.Font = Enum.Font.GothamBold
confirmLabel.TextSize = 14
confirmLabel.ZIndex = 51

local btnYes = Instance.new("TextButton", confirmFrame)
btnYes.Size = UDim2.new(0, 110, 0, 34)
btnYes.Position = UDim2.new(0.5, -115, 0.55, 0)
btnYes.BackgroundColor3 = Color3.fromHex("#8B0000")
btnYes.TextColor3 = Color3.fromRGB(255, 255, 255)
btnYes.Font = Enum.Font.GothamMedium
btnYes.TextSize = 12
btnYes.ZIndex = 51
Instance.new("UICorner", btnYes).CornerRadius = UDim.new(0, 6)

local btnNo = Instance.new("TextButton", confirmFrame)
btnNo.Size = UDim2.new(0, 110, 0, 34)
btnNo.Position = UDim2.new(0.5, 5, 0.55, 0)
btnNo.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
btnNo.TextColor3 = Color3.fromRGB(180, 180, 180)
btnNo.Font = Enum.Font.GothamMedium
btnNo.TextSize = 12
btnNo.ZIndex = 51
Instance.new("UICorner", btnNo).CornerRadius = UDim.new(0, 6)

-- [FUNÇÕES DA UI]
local function RegistrarTransparencias(objeto)
    if originalTrans[objeto] then return end
    if objeto:IsA("Frame") or objeto:IsA("ScrollingFrame") then
        originalTrans[objeto] = { BackgroundTransparency = objeto.BackgroundTransparency }
    elseif objeto:IsA("TextLabel") or objeto:IsA("TextButton") or objeto:IsA("TextBox") then
        originalTrans[objeto] = {
            TextTransparency = objeto.TextTransparency,
            BackgroundTransparency = objeto.BackgroundTransparency,
            TextStrokeTransparency = objeto.TextStrokeTransparency or 1
        }
    elseif objeto:IsA("ImageLabel") or objeto:IsA("ImageButton") then
        originalTrans[objeto] = {
            ImageTransparency = objeto.ImageTransparency,
            BackgroundTransparency = objeto.BackgroundTransparency
        }
    elseif objeto:IsA("UIStroke") then
        originalTrans[objeto] = { Transparency = objeto.Transparency }
    end
end

local function AplicarFadeSincronizado(raiz, fadeOut, duracao)
    local info = TweenInfo.new(duracao, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    local function tratarObjeto(obj)
        RegistrarTransparencias(obj)
        local orig = originalTrans[obj]
        if not orig then return end
        if orig.BackgroundTransparency then
            local t = fadeOut and 1 or orig.BackgroundTransparency
            if duracao == 0 then obj.BackgroundTransparency = t else TweenService:Create(obj, info, {BackgroundTransparency = t}):Play() end
        end
        if orig.TextTransparency then
            local t = fadeOut and 1 or orig.TextTransparency
            if duracao == 0 then obj.TextTransparency = t else TweenService:Create(obj, info, {TextTransparency = t}):Play() end
        end
        if orig.TextStrokeTransparency then
            local t = fadeOut and 1 or orig.TextStrokeTransparency
            if duracao == 0 then obj.TextStrokeTransparency = t else TweenService:Create(obj, info, {TextStrokeTransparency = t}):Play() end
        end
        if orig.ImageTransparency then
            local t = fadeOut and 1 or (obj.Name == "Shadow3D" and 0.5 or orig.ImageTransparency)
            if duracao == 0 then obj.ImageTransparency = t else TweenService:Create(obj, info, {ImageTransparency = t}):Play() end
        end
        if orig.Transparency then
            local t = fadeOut and 1 or orig.Transparency
            if duracao == 0 then obj.Transparency = t else TweenService:Create(obj, info, {Transparency = t}):Play() end
        end
    end
    tratarObjeto(raiz)
    for _, desc in ipairs(raiz:GetDescendants()) do tratarObjeto(desc) end
end

local function AplicarFadeIdiomaModerno(fadeOut, duracao)
    local info = TweenInfo.new(duracao, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    
    if fadeOut then
        TweenService:Create(LanguageBtn, TweenInfo.new(duracao, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0, 18, 0, 18)}):Play()
    else
        TweenService:Create(LanguageBtn, TweenInfo.new(duracao, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 26, 0, 26)}):Play()
    end

    for _, btn in pairs(tabButtons) do
        local label = btn:FindFirstChild("Label")
        if label then
            RegistrarTransparencias(label)
            local orig = originalTrans[label]
            local t = fadeOut and 1 or (orig and orig.TextTransparency or 0)
            TweenService:Create(label, info, {TextTransparency = t}):Play()
        end
    end
    for _, child in ipairs(togglesContainer:GetDescendants()) do
        if child:IsA("TextLabel") then
            RegistrarTransparencias(child)
            local orig = originalTrans[child]
            local t = fadeOut and 1 or (orig and orig.TextTransparency or 0)
            TweenService:Create(child, info, {TextTransparency = t}):Play()
        end
    end
    RegistrarTransparencias(searchTextBox)
    TweenService:Create(searchTextBox, info, {TextTransparency = fadeOut and 1 or 0}):Play()
end

local function CriarIconeProcedural(parent, tabName)
    local iconContainer = Instance.new("Frame", parent)
    iconContainer.Name = "Icon"
    iconContainer.Size = UDim2.new(0, 16, 0, 16)
    iconContainer.Position = UDim2.new(0, 12, 0.5, -8)
    iconContainer.BackgroundTransparency = 1
    iconContainer.ZIndex = 9
    local imageLabel = Instance.new("ImageLabel", iconContainer)
    imageLabel.Name = "AccentImage"
    imageLabel.Size = UDim2.new(1, 0, 1, 0)
    imageLabel.BackgroundTransparency = 1
    imageLabel.ZIndex = 10
    imageLabel.ImageColor3 = Color3.fromRGB(180, 180, 180)
    
    if tabName == "Movement" or tabName == "Movimento" then
        imageLabel.Image = "rbxthumb://type=Asset&id=116118153718196&w=150&h=150"
    elseif tabName == "Teleports" or tabName == "Teleportes" then
        imageLabel.Image = "rbxthumb://type=Asset&id=131357413318360&w=150&h=150"
    elseif tabName == "Misc" or tabName == "Diversos" or tabName == "Varios" then
        imageLabel.Image = "rbxthumb://type=Asset&id=96954032676031&w=150&h=150"
    elseif tabName == "Visuals" or tabName == "Visuales" or tabName == "Visuais" then
        imageLabel.Image = "rbxthumb://type=Asset&id=134099134229815&w=150&h=150"
    elseif tabName == "Combat" or tabName == "Combate" then
        imageLabel.Image = "rbxthumb://type=Asset&id=131607049070859&w=150&h=150"
    else
        imageLabel.Image = "rbxthumb://type=Asset&id=96954032676031&w=150&h=150" -- Icone Fallback Padrão
    end
end

local function RecolorirIcone(iconContainer, targetColor, animSpeed)
    if not iconContainer then return end
    for _, child in ipairs(iconContainer:GetDescendants()) do
        if child.Name == "AccentStroke" and child:IsA("UIStroke") then
            TweenService:Create(child, animSpeed, {Color = targetColor}):Play()
        elseif child.Name == "AccentFill" and child:IsA("Frame") then
            TweenService:Create(child, animSpeed, {BackgroundColor3 = targetColor}):Play()
        elseif child.Name == "AccentImage" and child:IsA("ImageLabel") then
            TweenService:Create(child, animSpeed, {ImageColor3 = targetColor}):Play()
        end
    end
end

local function AtualizarIdioma()
    local langData = Locales[currentLanguage]
    if not langData then return end
    searchTextBox.PlaceholderText = langData.SearchPlaceholder or "Search..."
    for tabName, btn in pairs(tabButtons) do
        local label = btn:FindFirstChild("Label")
        if label then label.Text = (langData.Tabs and langData.Tabs[tabName]) or tabName end
    end
    for _, child in ipairs(togglesContainer:GetChildren()) do
        if child:IsA("Frame") and child.Name ~= "UIListLayout" and child.Name ~= "UIPadding" then
            local configKey = child:GetAttribute("ConfigKey")
            if configKey and langData.Options and langData.Options[configKey] then
                local titleLabel = child:FindFirstChild("Title")
                local descLabel  = child:FindFirstChild("Description")
                if titleLabel then titleLabel.Text = langData.Options[configKey].Title end
                if descLabel  then descLabel.Text  = langData.Options[configKey].Desc  end
            end
        end
    end
    confirmLabel.Text = langData.ConfirmCloseTitle or "Close?"
    btnYes.Text = langData.ConfirmBtn or "Yes"
    btnNo.Text  = langData.CancelBtn or "No"
end

local function filterToggles(currentActiveTab, query)
    local searchQuery = (query or ""):lower()
    local itemIndex = 0
    for _, child in ipairs(togglesContainer:GetChildren()) do
        if child:IsA("Frame") and child.Name ~= "UIListLayout" and child.Name ~= "UIPadding" then
            local itemTab = child:GetAttribute("Tab") or "Combat"
            local shouldBeVisible = false
            if searchQuery ~= "" then
                local titleLabel = child:FindFirstChild("Title")
                shouldBeVisible = titleLabel and titleLabel.Text:lower():find(searchQuery) ~= nil
            else
                shouldBeVisible = (itemTab == currentActiveTab)
            end
            child.Visible = shouldBeVisible
            if shouldBeVisible then
                itemIndex = itemIndex + 1
                child.Size = UDim2.new(1, -8, 0, 0)
                child.BackgroundTransparency = 1
                local t = child:FindFirstChild("Title")
                local d = child:FindFirstChild("Description")
                if t then t.TextTransparency = 1 end
                if d then d.TextTransparency = 1 end
                task.delay((itemIndex - 1) * 0.03, function()
                    TweenService:Create(child, TweenInfo.new(0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
                        Size = UDim2.new(1, -8, 0, 56),
                        BackgroundTransparency = 0
                    }):Play()
                    if t then TweenService:Create(t, TweenInfo.new(0.2), {TextTransparency = 0}):Play() end
                    if d then TweenService:Create(d, TweenInfo.new(0.2), {TextTransparency = 0}):Play() end
                end)
            end
        end
    end
end

local function selectTab(tabName)
    activeTab = tabName
    local animSpeed = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    for name, btn in pairs(tabButtons) do
        local label = btn:FindFirstChild("Label")
        local iconContainer = btn:FindFirstChild("Icon")
        local activeBar = btn:FindFirstChild("ActiveBar")
        if name == tabName then
            TweenService:Create(btn, animSpeed, {BackgroundColor3 = Color3.fromRGB(24, 15, 15), BackgroundTransparency = 0.4}):Play()
            if label then TweenService:Create(label, animSpeed, {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play() end
            if activeBar then activeBar.Visible = true end
            RecolorirIcone(iconContainer, Color3.fromRGB(255, 255, 255), animSpeed)
        else
            TweenService:Create(btn, animSpeed, {BackgroundColor3 = Color3.fromRGB(12, 12, 12), BackgroundTransparency = 1}):Play()
            if label then TweenService:Create(label, animSpeed, {TextColor3 = Color3.fromRGB(180, 180, 180)}):Play() end
            if activeBar then activeBar.Visible = false end
            RecolorirIcone(iconContainer, Color3.fromRGB(180, 180, 180), animSpeed)
        end
    end
    togglesContainer.CanvasPosition = Vector2.new(0, 0)
    searchTextBox.Text = ""
    filterToggles(tabName, "")
end

local function createTabBtn(tabName)
    local tabBtn = Instance.new("TextButton", TabsContainer)
    tabBtn.Name = tabName .. "TabBtn"
    tabBtn.Size = UDim2.new(1, 0, 0, 36)
    tabBtn.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    tabBtn.BackgroundTransparency = 1
    tabBtn.Text = ""
    tabBtn.ZIndex = 8
    tabBtn.AutoButtonColor = false

    local activeBar = Instance.new("Frame", tabBtn)
    activeBar.Name = "ActiveBar"
    activeBar.Size = UDim2.new(0, 3, 1, 0)
    activeBar.Position = UDim2.new(0, 0, 0, 0)
    activeBar.BackgroundColor3 = Color3.fromHex("#8B0000")
    activeBar.BorderSizePixel = 0
    activeBar.Visible = false
    activeBar.ZIndex = 9

    CriarIconeProcedural(tabBtn, tabName)
    local tabLabel = Instance.new("TextLabel", tabBtn)
    tabLabel.Name = "Label"
    tabLabel.Size = UDim2.new(1, -44, 1, 0)
    tabLabel.Position = UDim2.new(0, 36, 0, 0)
    tabLabel.BackgroundTransparency = 1
    tabLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    tabLabel.Font = Enum.Font.GothamMedium
    tabLabel.TextSize = 11
    tabLabel.TextXAlignment = Enum.TextXAlignment.Left
    tabLabel.ZIndex = 9

    tabBtn.MouseButton1Down:Connect(function()
        TweenService:Create(tabLabel, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {TextSize = 10}):Play()
    end)
    tabBtn.MouseButton1Up:Connect(function()
        TweenService:Create(tabLabel, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {TextSize = 11}):Play()
    end)
    tabBtn.MouseLeave:Connect(function()
        TweenService:Create(tabLabel, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {TextSize = 11}):Play()
        if activeTab ~= tabName then
            TweenService:Create(tabBtn, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {BackgroundColor3 = Color3.fromRGB(12, 12, 12), BackgroundTransparency = 1}):Play()
            TweenService:Create(tabLabel, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {TextColor3 = Color3.fromRGB(180, 180, 180)}):Play()
            RecolorirIcone(tabBtn:FindFirstChild("Icon"), Color3.fromRGB(180, 180, 180), TweenInfo.new(0.15, Enum.EasingStyle.Quad))
        end
    end)
    tabBtn.MouseEnter:Connect(function()
        if activeTab ~= tabName then
            TweenService:Create(tabBtn, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {BackgroundColor3 = Color3.fromRGB(22, 22, 22), BackgroundTransparency = 0.7}):Play()
            TweenService:Create(tabLabel, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {TextColor3 = Color3.fromRGB(220, 220, 220)}):Play()
            RecolorirIcone(tabBtn:FindFirstChild("Icon"), Color3.fromRGB(220, 220, 220), TweenInfo.new(0.15, Enum.EasingStyle.Quad))
        end
    end)
    tabBtn.MouseButton1Click:Connect(function() selectTab(tabName) end)
    tabButtons[tabName] = tabBtn
end

local function createToggle(parent, configKey, tabCategory)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Name = configKey
    toggleFrame.Size = UDim2.new(1, -8, 0, 56)
    toggleFrame.BackgroundColor3 = Color3.fromHex("#0F0F0F")
    toggleFrame.BackgroundTransparency = 0.15
    toggleFrame.ZIndex = 6
    toggleFrame:SetAttribute("Tab", tabCategory)
    toggleFrame:SetAttribute("ConfigKey", configKey)
    toggleFrame.Parent = parent
    Instance.new("UICorner", toggleFrame).CornerRadius = UDim.new(0, 6)
    local stroke = Instance.new("UIStroke", toggleFrame)
    stroke.Color = Color3.fromHex("#141414")
    stroke.Thickness = 1
    local titleLabel = Instance.new("TextLabel", toggleFrame)
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(0.65, 0, 0, 16)
    titleLabel.Position = UDim2.new(0, 12, 0, 6)
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextColor3 = Color3.fromHex("#CCCCCC")
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 11
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.ZIndex = 6
    local descLabel = Instance.new("TextLabel", toggleFrame)
    descLabel.Name = "Description"
    descLabel.Size = UDim2.new(0.65, 0, 0, 28)
    descLabel.Position = UDim2.new(0, 12, 0, 22)
    descLabel.BackgroundTransparency = 1
    descLabel.TextColor3 = Color3.fromRGB(130, 130, 130)
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextSize = 9
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.TextYAlignment = Enum.TextYAlignment.Top
    descLabel.TextWrapped = true
    descLabel.ZIndex = 6
    local switchTrack = Instance.new("Frame", toggleFrame)
    switchTrack.Size = UDim2.new(0, 40, 0, 20)
    switchTrack.Position = UDim2.new(1, -52, 0.5, -10)
    switchTrack.BackgroundColor3 = Configs[configKey] and Color3.fromHex("#8B0000") or Color3.fromRGB(30, 30, 30)
    switchTrack.ZIndex = 6
    Instance.new("UICorner", switchTrack).CornerRadius = UDim.new(1, 0)
    local trackStroke = Instance.new("UIStroke", switchTrack)
    trackStroke.Color = Color3.fromRGB(45, 45, 45)
    trackStroke.Thickness = 1
    local switchCircle = Instance.new("Frame", switchTrack)
    switchCircle.Size = UDim2.new(0, 14, 0, 14)
    switchCircle.Position = Configs[configKey] and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
    switchCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    switchCircle.ZIndex = 7
    Instance.new("UICorner", switchCircle).CornerRadius = UDim.new(1, 0)
    local triggerBtn = Instance.new("TextButton", toggleFrame)
    triggerBtn.Size = UDim2.new(1, 0, 1, 0)
    triggerBtn.BackgroundTransparency = 1
    triggerBtn.Text = ""
    triggerBtn.ZIndex = 8
    
    triggerBtn.MouseButton1Click:Connect(function()
        Configs[configKey] = not Configs[configKey]
        local targetPos   = Configs[configKey] and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
        local targetColor = Configs[configKey] and Color3.fromHex("#8B0000") or Color3.fromRGB(30, 30, 30)
        local anim = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        TweenService:Create(switchCircle, anim, {Position = targetPos}):Play()
        TweenService:Create(switchTrack, anim, {BackgroundColor3 = targetColor}):Play()
        
        -- EXECUTA A FUNÇÃO DE LÓGICA PELO BRIDGE GLOBAL
        if _G.AkatCallbacks and _G.AkatCallbacks[configKey] then
            task.spawn(_G.AkatCallbacks[configKey], Configs[configKey])
        end

        -- Atualização interna da interface
        if configKey == "AutoShoot" or configKey == "ActiveSlow" then
            AutoShootMobileBtn.Visible = Configs[configKey]
        end
    end)
end

local function AlternarConfirmacao(exibir)
    isConfirmOpen = exibir
    local tempoAnim = 0.15
    if exibir then
        if not confirmBlur then
            confirmBlur = Instance.new("BlurEffect")
            confirmBlur.Name = "AkatConfirmBlur"
            confirmBlur.Size = 0
            confirmBlur.Parent = Lighting
        end
        confirmFrame.Visible = true
        AplicarFadeSincronizado(confirmFrame, true, 0)
        AplicarFadeSincronizado(confirmFrame, false, tempoAnim)
        TweenService:Create(confirmBlur, TweenInfo.new(tempoAnim, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = 14}):Play()
    else
        AplicarFadeSincronizado(confirmFrame, true, tempoAnim)
        if confirmBlur then TweenService:Create(confirmBlur, TweenInfo.new(tempoAnim, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = 0}):Play() end
        if wasMinimizedBeforeConfirm then
            AplicarFadeSincronizado(SidebarFrame, true, 0.15)
            AplicarFadeSincronizado(togglesContainer, true, 0.15)
            isMinimized = true
            TweenService:Create(mainWrapper, TweenInfo.new(0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {Size = UDim2.new(0, 520, 0, 52)}):Play()
            task.delay(0.15, function()
                if isMinimized then
                    togglesContainer.Visible = false
                    SidebarFrame.Visible = false
                    div.Visible = false
                end
            end)
        end
        task.delay(tempoAnim, function()
            if not isConfirmOpen then
                confirmFrame.Visible = false
                if confirmBlur then confirmBlur:Destroy(); confirmBlur = nil end
            end
        end)
    end
end

local function executarMinimizacao()
    if isConfirmOpen then return end
    isMinimized = not isMinimized
    local windowAnim = TweenInfo.new(0.16, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    if isMinimized then
        AplicarFadeSincronizado(SidebarFrame, true, 0.1)
        AplicarFadeSincronizado(togglesContainer, true, 0.1)
        TweenService:Create(mainWrapper, windowAnim, {Size = UDim2.new(0, 520, 0, 52)}):Play()
        task.delay(0.1, function()
            if isMinimized then
                togglesContainer.Visible = false
                SidebarFrame.Visible = false
                div.Visible = false
            end
        end)
    else
        div.Visible = true
        SidebarFrame.Visible = true
        togglesContainer.Visible = true
        AplicarFadeSincronizado(SidebarFrame, true, 0)
        AplicarFadeSincronizado(togglesContainer, true, 0)
        TweenService:Create(mainWrapper, windowAnim, {Size = UDim2.new(0, 520, 0, 300)}):Play()
        AplicarFadeSincronizado(SidebarFrame, false, 0.16)
        AplicarFadeSincronizado(togglesContainer, false, 0.16)
        filterToggles(activeTab, searchTextBox.Text)
    end
end

local function alternarVisibilidadeMenu()
    menuAberto = not menuAberto
    local tempoAnim = 0.12
    local windowAnim = TweenInfo.new(tempoAnim, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    if menuAberto then
        mainWrapper.Visible = true
        togglesContainer.Visible = false
        SidebarFrame.Visible = false
        div.Visible = false
        mainWrapper.Size = UDim2.new(0, 480, 0, isMinimized and 40 or 270)
        AplicarFadeSincronizado(mainWrapper, true, 0)
        AplicarFadeSincronizado(mainWrapper, false, tempoAnim)
        local pop = TweenService:Create(mainWrapper, windowAnim, {Size = UDim2.new(0, 520, 0, isMinimized and 52 or 300)})
        pop:Play()
        pop.Completed:Connect(function()
            if menuAberto and not isMinimized and not isConfirmOpen then
                SidebarFrame.Visible = true
                togglesContainer.Visible = true
                div.Visible = true
                AplicarFadeSincronizado(SidebarFrame, true, 0)
                AplicarFadeSincronizado(SidebarFrame, false, 0.1)
                filterToggles(activeTab, searchTextBox.Text)
            end
        end)
    else
        togglesContainer.Visible = false
        SidebarFrame.Visible = false
        div.Visible = false
        AplicarFadeSincronizado(mainWrapper, true, tempoAnim)
        local hide = TweenService:Create(mainWrapper, windowAnim, {Size = UDim2.new(0, 480, 0, isMinimized and 40 or 270)})
        hide:Play()
        hide.Completed:Connect(function()
            if not menuAberto then mainWrapper.Visible = false end
        end)
    end
end

local function ExecutarIntroAkat()
    local Blur = Instance.new("BlurEffect")
    Blur.Size = 0
    Blur.Parent = Lighting

    local IntroFrame = Instance.new("Frame", screenGui)
    IntroFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    IntroFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    IntroFrame.Size = UDim2.new(1, 0, 1, 0)
    IntroFrame.BackgroundColor3 = Color3.fromHex("#0A0A0A")
    IntroFrame.BackgroundTransparency = 1
    IntroFrame.ZIndex = 500

    local IntroText = Instance.new("TextLabel", IntroFrame)
    IntroText.AnchorPoint = Vector2.new(0.5, 0.5)
    IntroText.Size = UDim2.new(0, 600, 0, 80)
    IntroText.Position = UDim2.new(0.5, 0, 0.5, 10)
    IntroText.BackgroundTransparency = 1
    IntroText.Font = Enum.Font.GothamBold
    IntroText.TextSize = 26
    IntroText.RichText = true
    IntroText.Text = Locales[currentLanguage].Intro or "AKAT HUB"
    IntroText.TextTransparency = 1
    IntroText.ZIndex = 501

    local IntroLine = Instance.new("Frame", IntroFrame)
    IntroLine.AnchorPoint = Vector2.new(0.5, 0.5)
    IntroLine.Position = UDim2.new(0.5, 0, 0.5, 30)
    IntroLine.Size = UDim2.new(0, 0, 0, 2)
    IntroLine.BackgroundColor3 = Color3.fromHex("#8B0000")
    IntroLine.BorderSizePixel = 0
    IntroLine.BackgroundTransparency = 1
    IntroLine.ZIndex = 502

    TweenService:Create(IntroFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0.2}):Play()
    TweenService:Create(IntroText, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0, Position = UDim2.new(0.5, 0, 0.5, -6)}):Play()
    TweenService:Create(IntroLine, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0, Size = UDim2.new(0, 260, 0, 2), Position = UDim2.new(0.5, 0, 0.5, 17)}):Play()
    TweenService:Create(Blur, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = 14}):Play()
    task.wait(0.5)

    local correndoBrilho = true
    task.spawn(function()
        local i1 = TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
        while correndoBrilho do
            local t1 = TweenService:Create(IntroText, i1, {TextTransparency = 0.4})
            local t2 = TweenService:Create(IntroLine, i1, {BackgroundTransparency = 0.4})
            t1:Play(); t2:Play(); t1.Completed:Wait()
            if not correndoBrilho then break end
            local t3 = TweenService:Create(IntroText, i1, {TextTransparency = 0})
            local t4 = TweenService:Create(IntroLine, i1, {BackgroundTransparency = 0})
            t3:Play(); t4:Play(); t3.Completed:Wait()
        end
    end)

    task.wait(1.5)
    correndoBrilho = false

    TweenService:Create(IntroText, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {TextTransparency = 1, Position = UDim2.new(0.5, 0, 0.5, -16)}):Play()
    TweenService:Create(IntroLine, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = 1, Size = UDim2.new(0, 0, 0, 2)}):Play()
    TweenService:Create(IntroFrame, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
    TweenService:Create(Blur, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = 0}):Play()
    task.wait(0.35)

    IntroFrame:Destroy()
    Blur:Destroy()

    RegistrarTransparencias(mainFrame)
    for _, item in ipairs(mainFrame:GetDescendants()) do RegistrarTransparencias(item) end

    mainWrapper.Visible = true
    FloatBtn.Visible = true

    AplicarFadeSincronizado(mainWrapper, true, 0)
    mainWrapper.Size = UDim2.new(0, 505, 0, 288)

    local fastOpen = TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    AplicarFadeSincronizado(mainWrapper, false, 0.12)
    local openTween = TweenService:Create(mainWrapper, fastOpen, {Size = UDim2.new(0, 520, 0, 300)})
    openTween:Play()
    openTween.Completed:Connect(function() selectTab(activeTab) end)
end

local function AplicarEfeitoFisicoBotao(btn, hoverColor)
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {BackgroundColor3 = Color3.fromRGB(36, 36, 36)}):Play()
        if btn.Name == "MinimizeBtn" then
            TweenService:Create(btn.Line, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {BackgroundColor3 = hoverColor}):Play()
        elseif btn.Name == "SearchBtn" then
            TweenService:Create(circleStroke, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {Color = hoverColor}):Play()
            TweenService:Create(SearchHandle, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {BackgroundColor3 = hoverColor}):Play()
        elseif btn.Name == "CloseBtn" then
            TweenService:Create(btn.Line1, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {BackgroundColor3 = hoverColor}):Play()
            TweenService:Create(btn.Line2, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {BackgroundColor3 = hoverColor}):Play()
        elseif btn.Name == "LanguageBtn" then
            TweenService:Create(btn, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {TextColor3 = hoverColor}):Play()
        end
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {BackgroundColor3 = Color3.fromRGB(24, 24, 24)}):Play()
        if btn.Name == "MinimizeBtn" then
            TweenService:Create(btn.Line, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {BackgroundColor3 = Color3.fromHex("#A0A0A0")}):Play()
        elseif btn.Name == "SearchBtn" then
            TweenService:Create(circleStroke, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {Color = Color3.fromHex("#A0A0A0")}):Play()
            TweenService:Create(SearchHandle, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {BackgroundColor3 = Color3.fromHex("#A0A0A0")}):Play()
        elseif btn.Name == "CloseBtn" then
            TweenService:Create(btn.Line1, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {BackgroundColor3 = Color3.fromHex("#A0A0A0")}):Play()
            TweenService:Create(btn.Line2, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {BackgroundColor3 = Color3.fromHex("#A0A0A0")}):Play()
        elseif btn.Name == "LanguageBtn" then
            TweenService:Create(btn, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {TextColor3 = Color3.fromRGB(160, 160, 160)}):Play()
        end
    end)
end

AplicarEfeitoFisicoBotao(LanguageBtn, Color3.fromRGB(255, 255, 255))
AplicarEfeitoFisicoBotao(SearchBtn, Color3.fromRGB(255, 255, 255))
AplicarEfeitoFisicoBotao(MinimizeBtn, Color3.fromRGB(255, 255, 255))
AplicarEfeitoFisicoBotao(CloseBtn, Color3.fromRGB(255, 60, 60))


-- ==================== CONSTRUTOR DINÂMICO DE ELEMENTOS ====================
local tabsCriadas = {}

if _G.UIData and _G.UIData.Toggles then
    -- Geração Dinâmica Baseada no Novo Script
    for _, item in ipairs(_G.UIData.Toggles) do
        if not tabsCriadas[item.Tab] then
            createTabBtn(item.Tab)
            tabsCriadas[item.Tab] = true
            if activeTab == "" then activeTab = item.Tab end
        end
        createToggle(togglesContainer, item.Key, item.Tab)
    end
else
    -- Fallback de Segurança (Mantém o MM2 ativo por padrão se executado puro)
    activeTab = "Combat"
    createTabBtn("Combat")
    createTabBtn("Visuals")
    createTabBtn("Movement")
    createTabBtn("Teleports")
    createTabBtn("Misc")

    createToggle(togglesContainer, "AutoShoot",   "Combat")
    createToggle(togglesContainer, "Reach",       "Combat")
    createToggle(togglesContainer, "ESP",         "Visuals")
    createToggle(togglesContainer, "Speed",       "Movement")
    createToggle(togglesContainer, "AntiFling",   "Movement")
    createToggle(togglesContainer, "TpToGun",     "Teleports")
    createToggle(togglesContainer, "SafeSpot",    "Teleports")
    createToggle(togglesContainer, "AutoCollect", "Misc")
    createToggle(togglesContainer, "ChatRoles",   "Misc")
end


local searchOpen = false
SearchBtn.MouseButton1Click:Connect(function()
    searchOpen = not searchOpen
    local info = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    if searchOpen then
        TweenService:Create(searchBarFrame, info, {Size = UDim2.new(0, 160, 0, 26)}):Play()
        searchTextBox:CaptureFocus()
    else
        searchTextBox.Text = ""
        TweenService:Create(searchBarFrame, info, {Size = UDim2.new(0, 0, 0, 26)}):Play()
        searchTextBox:ReleaseFocus()
        filterToggles(activeTab, "")
    end
end)

searchTextBox:GetPropertyChangedSignal("Text"):Connect(function()
    filterToggles(activeTab, searchTextBox.Text)
end)

local languageTransitioning = false
LanguageBtn.MouseButton1Click:Connect(function()
    if languageTransitioning then return end
    languageTransitioning = true
    
    AplicarFadeIdiomaModerno(true, 0.14)
    task.wait(0.14)
    
    if currentLanguage == "EN" then currentLanguage = "PT"
    elseif currentLanguage == "PT" then currentLanguage = "ES"
    else currentLanguage = "EN" end
    LanguageBtn.Text = currentLanguage
    
    AtualizarIdioma()
    AplicarFadeIdiomaModerno(false, 0.18)
    task.wait(0.18)
    languageTransitioning = false
end)

CloseBtn.MouseButton1Click:Connect(function()
    wasMinimizedBeforeConfirm = isMinimized
    if isMinimized then
        isMinimized = false
        div.Visible = true
        SidebarFrame.Visible = true
        togglesContainer.Visible = true
        AplicarFadeSincronizado(SidebarFrame, false, 0.15)
        AplicarFadeSincronizado(togglesContainer, false, 0.15)
        TweenService:Create(mainWrapper, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, 520, 0, 300)}):Play()
        AlternarConfirmacao(true)
    else
        AlternarConfirmacao(true)
    end
end)

btnNo.MouseButton1Click:Connect(function() AlternarConfirmacao(false) end)

btnYes.MouseButton1Click:Connect(function()
    local syncTime = 0.18
    if confirmBlur then TweenService:Create(confirmBlur, TweenInfo.new(syncTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = 0}):Play() end
    AplicarFadeSincronizado(mainWrapper, true, syncTime)
    TweenService:Create(FloatBtn, TweenInfo.new(syncTime, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {ImageTransparency = 1}):Play()
    task.wait(syncTime)
    
    -- Dispara a rotina absoluta de desligamento no Script de Lógica
    if _G.AkatCallbacks and _G.AkatCallbacks.ShutdownAll then
        _G.AkatCallbacks.ShutdownAll()
    end
    
    pcall(function() if confirmBlur then confirmBlur:Destroy() end end)
    screenGui:Destroy()
end)

local function AnimarCliqueFloatBtn()
    local originalSize = UDim2.new(0, 44, 0, 44)
    local targetSize   = UDim2.new(0, 36, 0, 36)
    local shrink = TweenService:Create(FloatBtn, TweenInfo.new(0.12, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Size = targetSize})
    local expand = TweenService:Create(FloatBtn, TweenInfo.new(0.12, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Size = originalSize})
    shrink:Play()
    local c; c = shrink.Completed:Connect(function() expand:Play(); c:Disconnect() end)
end

MinimizeBtn.MouseButton1Click:Connect(executarMinimizacao)

FloatBtn.MouseButton1Click:Connect(function()
    AnimarCliqueFloatBtn()
    alternarVisibilidadeMenu()
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and (input.KeyCode == Enum.KeyCode.Insert or input.KeyCode == Enum.KeyCode.RightShift) then
        alternarVisibilidadeMenu()
    end
end)

ConfigurarArrastarAkat(mainWrapper)
ConfigurarArrastarAkat(FloatBtn)

task.spawn(function()
    task.wait(0.1)
    RegistrarTransparencias(confirmFrame)
    for _, d in ipairs(confirmFrame:GetDescendants()) do RegistrarTransparencias(d) end
end)

task.spawn(ExecutarIntroAkat)
