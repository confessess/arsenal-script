--// Arsenal Minimalist UI Framework
--// Lightweight, modular, drag-to-expand
--// Paste into any Roblox executor

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--// Color Palette
local Colors = {
    Background = Color3.fromRGB(18, 18, 22),
    Surface = Color3.fromRGB(28, 28, 34),
    SurfaceHover = Color3.fromRGB(38, 38, 46),
    Accent = Color3.fromRGB(0, 170, 255),
    AccentDark = Color3.fromRGB(0, 130, 200),
    Text = Color3.fromRGB(240, 240, 245),
    TextDim = Color3.fromRGB(150, 150, 160),
    ToggleOn = Color3.fromRGB(0, 200, 100),
    ToggleOff = Color3.fromRGB(60, 60, 70)
}

--// Main GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ArsenalKit"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 520, 0, 340)
Main.Position = UDim2.new(0.5, -260, 0.5, -170)
Main.BackgroundColor3 = Colors.Background
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Parent = ScreenGui

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)

--// Drop Shadow
local Shadow = Instance.new("ImageLabel")
Shadow.Name = "Shadow"
Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
Shadow.Position = UDim2.new(0.5, 0, 0.5, 4)
Shadow.Size = UDim2.new(1, 40, 1, 40)
Shadow.BackgroundTransparency = 1
Shadow.Image = "rbxassetid://5554236805"
Shadow.ImageColor3 = Color3.new(0, 0, 0)
Shadow.ImageTransparency = 0.6
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(23, 23, 277, 277)
Shadow.ZIndex = -1
Shadow.Parent = Main

--// Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 36)
TitleBar.BackgroundColor3 = Colors.Surface
TitleBar.BorderSizePixel = 0
TitleBar.Parent = Main

Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 8)

local TitleText = Instance.new("TextLabel")
TitleText.Text = "ARSENAL  v1.0"
TitleText.Size = UDim2.new(1, -20, 1, 0)
TitleText.Position = UDim2.new(0, 14, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.TextColor3 = Colors.Text
TitleText.Font = Enum.Font.GothamBold
TitleText.TextSize = 14
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

--// Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -34, 0, 4)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Colors.Text
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 18
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = TitleBar

Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

--// Tab Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 130, 1, -36)
Sidebar.Position = UDim2.new(0, 0, 0, 36)
Sidebar.BackgroundColor3 = Colors.Surface
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Main

Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 0)

local TabList = Instance.new("UIListLayout")
TabList.Padding = UDim.new(0, 4)
TabList.SortOrder = Enum.SortOrder.LayoutOrder
TabList.Parent = Sidebar

local TabPadding = Instance.new("UIPadding")
TabPadding.PaddingTop = UDim.new(0, 8)
TabPadding.PaddingLeft = UDim.new(0, 8)
TabPadding.PaddingRight = UDim.new(0, 8)
TabPadding.Parent = Sidebar

--// Content Area
local Content = Instance.new("Frame")
Content.Name = "Content"
Content.Size = UDim2.new(1, -130, 1, -36)
Content.Position = UDim2.new(0, 130, 0, 36)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.Parent = Main

--// Utility: Tween
local function Tween(obj, props, duration)
    TweenService:Create(obj, TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

--// Utility: Create Tab
local Tabs = {}
local ActiveTab = nil

local function CreateTab(name, icon)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Name = name
    TabBtn.Size = UDim2.new(1, 0, 0, 32)
    TabBtn.BackgroundColor3 = Colors.Surface
    TabBtn.Text = "  " .. (icon or "›") .. "  " .. name
    TabBtn.TextColor3 = Colors.TextDim
    TabBtn.Font = Enum.Font.GothamSemibold
    TabBtn.TextSize = 13
    TabBtn.TextXAlignment = Enum.TextXAlignment.Left
    TabBtn.BorderSizePixel = 0
    TabBtn.AutoButtonColor = false
    TabBtn.Parent = Sidebar

    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)

    local TabPage = Instance.new("ScrollingFrame")
    TabPage.Name = name .. "Page"
    TabPage.Size = UDim2.new(1, -16, 1, -16)
    TabPage.Position = UDim2.new(0, 8, 0, 8)
    TabPage.BackgroundTransparency = 1
    TabPage.BorderSizePixel = 0
    TabPage.ScrollBarThickness = 3
    TabPage.ScrollBarImageColor3 = Colors.Accent
    TabPage.Visible = false
    TabPage.Parent = Content

    local List = Instance.new("UIListLayout")
    List.Padding = UDim.new(0, 8)
    List.SortOrder = Enum.SortOrder.LayoutOrder
    List.Parent = TabPage

    local Pad = Instance.new("UIPadding")
    Pad.PaddingTop = UDim.new(0, 4)
    Pad.PaddingBottom = UDim.new(0, 4)
    Pad.Parent = TabPage

    TabBtn.MouseEnter:Connect(function()
        if ActiveTab ~= TabPage then
            Tween(TabBtn, {BackgroundColor3 = Colors.SurfaceHover}, 0.15)
        end
    end)

    TabBtn.MouseLeave:Connect(function()
        if ActiveTab ~= TabPage then
            Tween(TabBtn, {BackgroundColor3 = Colors.Surface}, 0.15)
        end
    end)

    TabBtn.MouseButton1Click:Connect(function()
        if ActiveTab then
            ActiveTab.Visible = false
            for _, btn in pairs(Sidebar:GetChildren()) do
                if btn:IsA("TextButton") then
                    Tween(btn, {BackgroundColor3 = Colors.Surface, TextColor3 = Colors.TextDim}, 0.15)
                end
            end
        end
        ActiveTab = TabPage
        TabPage.Visible = true
        Tween(TabBtn, {BackgroundColor3 = Colors.Accent, TextColor3 = Colors.Text}, 0.15)
    end)

    Tabs[name] = TabPage
    return TabPage
end

--// Utility: Create Toggle
local function CreateToggle(parent, label, default, callback)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 0, 36)
    Container.BackgroundColor3 = Colors.Surface
    Container.BorderSizePixel = 0
    Container.Parent = parent

    Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 6)

    local Label = Instance.new("TextLabel")
    Label.Text = label
    Label.Size = UDim2.new(1, -70, 1, 0)
    Label.Position = UDim2.new(0, 12, 0, 0)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Colors.Text
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Container

    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 44, 0, 22)
    ToggleBtn.Position = UDim2.new(1, -56, 0.5, -11)
    ToggleBtn.BackgroundColor3 = default and Colors.ToggleOn or Colors.ToggleOff
    ToggleBtn.Text = ""
    ToggleBtn.BorderSizePixel = 0
    ToggleBtn.AutoButtonColor = false
    ToggleBtn.Parent = Container

    Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)

    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 18, 0, 18)
    Knob.Position = default and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
    Knob.BackgroundColor3 = Colors.Text
    Knob.BorderSizePixel = 0
    Knob.Parent = ToggleBtn

    Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

    local State = default

    ToggleBtn.MouseButton1Click:Connect(function()
        State = not State
        Tween(ToggleBtn, {BackgroundColor3 = State and Colors.ToggleOn or Colors.ToggleOff}, 0.2)
        Tween(Knob, {Position = State and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)}, 0.2)
        if callback then callback(State) end
    end)

    return Container
end

--// Utility: Create Slider
local function CreateSlider(parent, label, min, max, default, callback)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 0, 52)
    Container.BackgroundColor3 = Colors.Surface
    Container.BorderSizePixel = 0
    Container.Parent = parent

    Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 6)

    local Label = Instance.new("TextLabel")
    Label.Text = label
    Label.Size = UDim2.new(1, -70, 0, 20)
    Label.Position = UDim2.new(0, 12, 0, 6)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Colors.Text
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Container

    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Text = tostring(default)
    ValueLabel.Size = UDim2.new(0, 50, 0, 20)
    ValueLabel.Position = UDim2.new(1, -62, 0, 6)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.TextColor3 = Colors.Accent
    ValueLabel.Font = Enum.Font.GothamBold
    ValueLabel.TextSize = 13
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.Parent = Container

    local Track = Instance.new("Frame")
    Track.Size = UDim2.new(1, -24, 0, 4)
    Track.Position = UDim2.new(0, 12, 0, 34)
    Track.BackgroundColor3 = Colors.ToggleOff
    Track.BorderSizePixel = 0
    Track.Parent = Container

    Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)

    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = Colors.Accent
    Fill.BorderSizePixel = 0
    Fill.Parent = Track

    Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 12, 0, 12)
    Knob.Position = UDim2.new((default - min) / (max - min), -6, 0.5, -6)
    Knob.BackgroundColor3 = Colors.Text
    Knob.BorderSizePixel = 0
    Knob.Parent = Track

    Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

    local Dragging = false

    local function Update(input)
        local pos = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
        local val = math.floor(min + (pos * (max - min)))
        ValueLabel.Text = tostring(val)
        Fill.Size = UDim2.new(pos, 0, 1, 0)
        Knob.Position = UDim2.new(pos, -6, 0.5, -6)
        if callback then callback(val) end
    end

    Knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
        end
    end)

    Track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            Update(input)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            Update(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = false
        end
    end)

    return Container
end

--// Utility: Create Button
local function CreateButton(parent, label, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 0, 34)
    Btn.BackgroundColor3 = Colors.Accent
    Btn.Text = label
    Btn.TextColor3 = Colors.Text
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 13
    Btn.BorderSizePixel = 0
    Btn.AutoButtonColor = false
    Btn.Parent = parent

    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)

    Btn.MouseEnter:Connect(function()
        Tween(Btn, {BackgroundColor3 = Colors.AccentDark}, 0.15)
    end)

    Btn.MouseLeave:Connect(function()
        Tween(Btn, {BackgroundColor3 = Colors.Accent}, 0.15)
    end)

    Btn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)

    return Btn
end

--// Utility: Create Section Label
local function CreateSection(parent, text)
    local Label = Instance.new("TextLabel")
    Label.Text = text:upper()
    Label.Size = UDim2.new(1, 0, 0, 18)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Colors.Accent
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 11
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = parent
    return Label
end

--// DRAGGING
local Dragging = false
local DragStart, StartPos

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        Dragging = true
        DragStart = input.Position
        StartPos = Main.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - DragStart
        Main.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + delta.X, StartPos.Y.Scale, StartPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        Dragging = false
    end
end)

--// ==========================
--// BUILD YOUR FEATURES BELOW
--// ==========================

local CombatTab = CreateTab("Combat", "⚔")
local VisualsTab = CreateTab("Visuals", "👁")
local MiscTab = CreateTab("Misc", "⚙")

--// Combat Section
CreateSection(CombatTab, "Aimbot")
CreateToggle(CombatTab, "Silent Aim", false, function(v)
    -- _G.SilentAim = v
    print("Silent Aim:", v)
end)

CreateToggle(CombatTab, "Auto-Aim", false, function(v)
    -- _G.AutoAim = v
    print("Auto-Aim:", v)
end)

CreateSlider(CombatTab, "FOV", 10, 500, 120, function(v)
    -- _G.AimFOV = v
    print("FOV:", v)
end)

CreateSlider(CombatTab, "Smoothing", 0, 100, 15, function(v)
    -- _G.AimSmooth = v / 100
    print("Smooth:", v)
end)

CreateSection(CombatTab, "Weapon")
CreateToggle(CombatTab, "No Recoil", false, function(v)
    -- _G.NoRecoil = v
    print("No Recoil:", v)
end)

CreateToggle(CombatTab, "No Spread", false, function(v)
    -- _G.NoSpread = v
    print("No Spread:", v)
end)

CreateToggle(CombatTab, "Rapid Fire", false, function(v)
    -- _G.RapidFire = v
    print("Rapid Fire:", v)
end)

CreateToggle(CombatTab, "Instant Reload", false, function(v)
    -- _G.InstantReload = v
    print("Instant Reload:", v)
end)

--// Visuals Section
CreateSection(VisualsTab, "ESP")
CreateToggle(VisualsTab, "Box ESP", false, function(v)
    -- _G.BoxESP = v
    print("Box ESP:", v)
end)

CreateToggle(VisualsTab, "Skeleton", false, function(v)
    -- _G.SkeletonESP = v
    print("Skeleton:", v)
end)

CreateToggle(VisualsTab, "Name ESP", false, function(v)
    -- _G.NameESP = v
    print("Name ESP:", v)
end)

CreateToggle(VisualsTab, "Health Bar", false, function(v)
    -- _G.HealthESP = v
    print("Health Bar:", v)
end)

CreateToggle(VisualsTab, "Tracers", false, function(v)
    -- _G.Tracers = v
    print("Tracers:", v)
end)

CreateSection(VisualsTab, "World")
CreateToggle(VisualsTab, "Fullbright", false, function(v)
    -- _G.Fullbright = v
    print("Fullbright:", v)
end)

CreateToggle(VisualsTab, "No Fog", false, function(v)
    -- _G.NoFog = v
    print("No Fog:", v)
end)

CreateSlider(VisualsTab, "FOV Changer", 30, 150, 90, function(v)
    -- workspace.CurrentCamera.FieldOfView = v
    print("Camera FOV:", v)
end)

--// Misc Section
CreateSection(MiscTab, "Movement")
CreateToggle(MiscTab, "Speed Hack", false, function(v)
    -- _G.SpeedHack = v
    print("Speed:", v)
end)

CreateSlider(MiscTab, "Speed Multiplier", 1, 5, 2, function(v)
    -- _G.SpeedMult = v
    print("Speed Mult:", v)
end)

CreateToggle(MiscTab, "Bunny Hop", false, function(v)
    -- _G.BunnyHop = v
    print("BHop:", v)
end)

CreateToggle(MiscTab, "Infinite Jump", false, function(v)
    -- _G.InfJump = v
    print("Inf Jump:", v)
end)

CreateSection(MiscTab, "Fun")
CreateButton(MiscTab, "Kill All", function()
    -- your kill logic here
    print("Kill All triggered")
end)

CreateButton(MiscTab, "Teleport to Random", function()
    -- teleport logic
    print("Teleport triggered")
end)

CreateToggle(MiscTab, "Anti-AFK", false, function(v)
    -- _G.AntiAFK = v
    print("Anti-AFK:", v)
end)

--// Activate first tab
for _, btn in pairs(Sidebar:GetChildren()) do
    if btn:IsA("TextButton") then
        btn.TextColor3 = Colors.TextDim
        btn.BackgroundColor3 = Colors.Surface
    end
end

ActiveTab = CombatTab
CombatTab.Visible = true
for _, btn in pairs(Sidebar:GetChildren()) do
    if btn.Name == "Combat" then
        btn.BackgroundColor3 = Colors.Accent
        btn.TextColor3 = Colors.Text
    end
end

--// Keybind to toggle UI (RightShift)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.RightShift then
        Main.Visible = not Main.Visible
    end
end)

print("[ArsenalKit] UI Loaded | Press RightShift to toggle")