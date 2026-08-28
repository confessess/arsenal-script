--// ArsenalKit Modular Loader v4.0
--// Glassmorphism UI, No Clipping, Mouse + Keyboard Keybinds

local BASE_URL = "https://raw.githubusercontent.com/confessess/arsenal-script/main"

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--// Color Palette - Glassmorphism Blue
local Colors = {
    Background = Color3.fromRGB(12, 20, 35),
    BackgroundTrans = 0.15,
    Surface = Color3.fromRGB(20, 35, 60),
    SurfaceTrans = 0.25,
    SurfaceHover = Color3.fromRGB(30, 55, 90),
    Accent = Color3.fromRGB(0, 180, 255),
    AccentGlow = Color3.fromRGB(0, 140, 220),
    Text = Color3.fromRGB(230, 245, 255),
    TextDim = Color3.fromRGB(140, 170, 200),
    ToggleOn = Color3.fromRGB(0, 220, 120),
    ToggleOff = Color3.fromRGB(40, 55, 80),
    Error = Color3.fromRGB(255, 70, 70),
    Keybind = Color3.fromRGB(0, 160, 240),
    GlassBorder = Color3.fromRGB(60, 120, 200)
}

--// Module Registry
local ArsenalKit = {
    Modules = {},
    Features = {},
    Tabs = {},
    Colors = Colors,
    Keybinds = {},
    Tween = function(obj, props, dur)
        TweenService:Create(obj, TweenInfo.new(dur or 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
    end
}
_G.ArsenalKit = ArsenalKit

--// Instance ID
local InstanceID = tick()
ArsenalKit.InstanceID = InstanceID

if _G.ArsenalKitInstanceID then
    for _, gui in ipairs(PlayerGui:GetChildren()) do
        if gui.Name == "ArsenalKit" then
            gui:Destroy()
        end
    end
end
_G.ArsenalKitInstanceID = InstanceID

--// Fetch Module
local function FetchModule(name)
    local url = BASE_URL .. "/modules/" .. name .. ".lua"
    local success, result = pcall(function()
        return game:HttpGet(url, true)
    end)
    if success and result and #result > 50 then
        return result
    end
    warn("[ArsenalKit] Failed to fetch: " .. name)
    return nil
end

local function LoadModule(name)
    local src = FetchModule(name)
    if not src then return false end
    local success, err = pcall(function()
        loadstring(src)()
    end)
    if success then
        print("[ArsenalKit] Loaded: " .. name)
        return true
    end
    warn("[ArsenalKit] Error loading " .. name .. ": " .. tostring(err))
    return false
end

--// ==========================
--// GLASSMORPHISM UI
--// ==========================

for _, gui in ipairs(PlayerGui:GetChildren()) do
    if gui.Name == "ArsenalKit" then gui:Destroy() end
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ArsenalKit"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999999
ScreenGui.Parent = PlayerGui

--// Main Frame
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 580, 0, 400)
Main.Position = UDim2.new(0.5, -290, 0.5, -200)
Main.BackgroundColor3 = Colors.Background
Main.BackgroundTransparency = Colors.BackgroundTrans
Main.BorderSizePixel = 0
Main.ClipsDescendants = false
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner", Main)
MainCorner.CornerRadius = UDim.new(0, 12)

--// Glass Border
local Border = Instance.new("UIStroke")
Border.Color = Colors.GlassBorder
Border.Thickness = 1.5
Border.Transparency = 0.4
Border.Parent = Main

--// Shadow
local Shadow = Instance.new("ImageLabel")
Shadow.Name = "Shadow"
Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
Shadow.Position = UDim2.new(0.5, 0, 0.5, 6)
Shadow.Size = UDim2.new(1, 50, 1, 50)
Shadow.BackgroundTransparency = 1
Shadow.Image = "rbxassetid://5554236805"
Shadow.ImageColor3 = Color3.new(0, 0, 0)
Shadow.ImageTransparency = 0.5
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(23, 23, 277, 277)
Shadow.ZIndex = -1
Shadow.Parent = Main

--// Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 42)
TitleBar.BackgroundColor3 = Colors.Surface
TitleBar.BackgroundTransparency = Colors.SurfaceTrans
TitleBar.BorderSizePixel = 0
TitleBar.Parent = Main

local TitleCorner = Instance.new("UICorner", TitleBar)
TitleCorner.CornerRadius = UDim.new(0, 12)

--// Title Accent Line
local AccentLine = Instance.new("Frame")
AccentLine.Size = UDim2.new(1, 0, 0, 2)
AccentLine.Position = UDim2.new(0, 0, 1, -2)
AccentLine.BackgroundColor3 = Colors.Accent
AccentLine.BorderSizePixel = 0
AccentLine.Parent = TitleBar

local AccentLineGlow = Instance.new("UIGradient", AccentLine)
AccentLineGlow.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Colors.Accent),
    ColorSequenceKeypoint.new(0.5, Colors.AccentGlow),
    ColorSequenceKeypoint.new(1, Colors.Accent)
})

--// Title Text
local TitleText = Instance.new("TextLabel")
TitleText.Text = "ARSENAL KIT"
TitleText.Size = UDim2.new(0, 200, 1, 0)
TitleText.Position = UDim2.new(0, 18, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.TextColor3 = Colors.Text
TitleText.Font = Enum.Font.SourceSans
TitleText.TextSize = 16
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

--// Version badge
local VersionBadge = Instance.new("TextLabel")
VersionBadge.Text = "v4.0"
VersionBadge.Size = UDim2.new(0, 40, 0, 18)
VersionBadge.Position = UDim2.new(0, 135, 0, 12)
VersionBadge.BackgroundColor3 = Colors.Accent
VersionBadge.BackgroundTransparency = 0.7
VersionBadge.TextColor3 = Colors.Text
VersionBadge.Font = Enum.Font.SourceSans
VersionBadge.TextSize = 11
VersionBadge.Parent = TitleBar

Instance.new("UICorner", VersionBadge).CornerRadius = UDim.new(0, 4)

--// Status
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = "Status"
StatusLabel.Size = UDim2.new(0, 140, 0, 42)
StatusLabel.Position = UDim2.new(1, -180, 0, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Loading..."
StatusLabel.TextColor3 = Colors.Accent
StatusLabel.Font = Enum.Font.SourceSans
StatusLabel.TextSize = 12
StatusLabel.TextXAlignment = Enum.TextXAlignment.Right
StatusLabel.Parent = TitleBar

--// Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -38, 0, 6)
CloseBtn.BackgroundColor3 = Colors.Error
CloseBtn.BackgroundTransparency = 0.3
CloseBtn.Text = "x"
CloseBtn.TextColor3 = Colors.Text
CloseBtn.Font = Enum.Font.SourceSans
CloseBtn.TextSize = 18
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = TitleBar

local CloseCorner = Instance.new("UICorner", CloseBtn)
CloseCorner.CornerRadius = UDim.new(0, 8)

CloseBtn.MouseEnter:Connect(function()
    ArsenalKit.Tween(CloseBtn, {BackgroundTransparency = 0}, 0.15)
end)
CloseBtn.MouseLeave:Connect(function()
    ArsenalKit.Tween(CloseBtn, {BackgroundTransparency = 0.3}, 0.15)
end)
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
    _G.ArsenalKit = nil
end)

--// Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 140, 1, -42)
Sidebar.Position = UDim2.new(0, 0, 0, 42)
Sidebar.BackgroundColor3 = Colors.Surface
Sidebar.BackgroundTransparency = Colors.SurfaceTrans
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Main

Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 0)

--// Sidebar accent
local SideAccent = Instance.new("Frame")
SideAccent.Size = UDim2.new(0, 2, 1, 0)
SideAccent.Position = UDim2.new(1, -2, 0, 0)
SideAccent.BackgroundColor3 = Colors.Accent
SideAccent.BackgroundTransparency = 0.5
SideAccent.BorderSizePixel = 0
SideAccent.Parent = Sidebar

local TabList = Instance.new("UIListLayout")
TabList.Padding = UDim.new(0, 6)
TabList.SortOrder = Enum.SortOrder.LayoutOrder
TabList.Parent = Sidebar

local TabPadding = Instance.new("UIPadding")
TabPadding.PaddingTop = UDim.new(0, 12)
TabPadding.PaddingLeft = UDim.new(0, 10)
TabPadding.PaddingRight = UDim.new(0, 10)
TabPadding.Parent = Sidebar

--// Content Area
local Content = Instance.new("Frame")
Content.Name = "Content"
Content.Size = UDim2.new(1, -140, 1, -42)
Content.Position = UDim2.new(0, 140, 0, 42)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.ClipsDescendants = false
Content.Parent = Main

local ActiveTab = nil
local ActiveTabBtn = nil

--// Create Tab
function ArsenalKit:CreateTab(name, icon)
    if ArsenalKit.Tabs[name] then
        return ArsenalKit.Tabs[name]
    end

    local TabBtn = Instance.new("TextButton")
    TabBtn.Name = name
    TabBtn.Size = UDim2.new(1, 0, 0, 36)
    TabBtn.BackgroundColor3 = Colors.Surface
    TabBtn.BackgroundTransparency = 0.5
    TabBtn.Text = "  [" .. (icon or ">") .. "]  " .. name
    TabBtn.TextColor3 = Colors.TextDim
    TabBtn.Font = Enum.Font.SourceSans
    TabBtn.TextSize = 14
    TabBtn.TextXAlignment = Enum.TextXAlignment.Left
    TabBtn.BorderSizePixel = 0
    TabBtn.AutoButtonColor = false
    TabBtn.Parent = Sidebar

    local BtnCorner = Instance.new("UICorner", TabBtn)
    BtnCorner.CornerRadius = UDim.new(0, 8)

    --// Active indicator (left side)
    local Indicator = Instance.new("Frame")
    Indicator.Name = "Indicator"
    Indicator.Size = UDim2.new(0, 3, 0.6, 0)
    Indicator.Position = UDim2.new(0, -1, 0.2, 0)
    Indicator.BackgroundColor3 = Colors.Accent
    Indicator.BorderSizePixel = 0
    Indicator.Visible = false
    Indicator.Parent = TabBtn

    Instance.new("UICorner", Indicator).CornerRadius = UDim.new(0, 2)

    local TabPage = Instance.new("ScrollingFrame")
    TabPage.Name = name .. "Page"
    TabPage.Size = UDim2.new(1, -20, 1, -20)
    TabPage.Position = UDim2.new(0, 10, 0, 10)
    TabPage.BackgroundTransparency = 1
    TabPage.BorderSizePixel = 0
    TabPage.ScrollBarThickness = 4
    TabPage.ScrollBarImageColor3 = Colors.Accent
    TabPage.ScrollBarImageTransparency = 0.3
    TabPage.Visible = false
    TabPage.Parent = Content

    local List = Instance.new("UIListLayout")
    List.Padding = UDim.new(0, 8)
    List.SortOrder = Enum.SortOrder.LayoutOrder
    List.Parent = TabPage

    local Pad = Instance.new("UIPadding")
    Pad.PaddingTop = UDim.new(0, 4)
    Pad.PaddingBottom = UDim.new(0, 8)
    Pad.Parent = TabPage

    TabBtn.MouseEnter:Connect(function()
        if ActiveTab ~= TabPage then
            ArsenalKit.Tween(TabBtn, {BackgroundColor3 = Colors.SurfaceHover, BackgroundTransparency = 0.3}, 0.15)
        end
    end)

    TabBtn.MouseLeave:Connect(function()
        if ActiveTab ~= TabPage then
            ArsenalKit.Tween(TabBtn, {BackgroundColor3 = Colors.Surface, BackgroundTransparency = 0.5}, 0.15)
        end
    end)

    TabBtn.MouseButton1Click:Connect(function()
        if ActiveTab then
            ActiveTab.Visible = false
            if ActiveTabBtn then
                ArsenalKit.Tween(ActiveTabBtn, {BackgroundColor3 = Colors.Surface, BackgroundTransparency = 0.5, TextColor3 = Colors.TextDim}, 0.15)
                local ind = ActiveTabBtn:FindFirstChild("Indicator")
                if ind then ind.Visible = false end
            end
        end
        ActiveTab = TabPage
        ActiveTabBtn = TabBtn
        TabPage.Visible = true
        ArsenalKit.Tween(TabBtn, {BackgroundColor3 = Colors.Accent, BackgroundTransparency = 0.15, TextColor3 = Colors.Text}, 0.15)
        Indicator.Visible = true
    end)

    ArsenalKit.Tabs[name] = TabPage
    return TabPage
end

--// Create Section
function ArsenalKit:CreateSection(parent, text)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 0, 24)
    Container.BackgroundTransparency = 1
    Container.Parent = parent

    local Label = Instance.new("TextLabel")
    Label.Text = text:upper()
    Label.Size = UDim2.new(1, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Colors.Accent
    Label.Font = Enum.Font.SourceSans
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Container

    --// Underline
    local Line = Instance.new("Frame")
    Line.Size = UDim2.new(0.3, 0, 0, 1)
    Line.Position = UDim2.new(0, 0, 1, -4)
    Line.BackgroundColor3 = Colors.Accent
    Line.BackgroundTransparency = 0.5
    Line.BorderSizePixel = 0
    Line.Parent = Container

    return Container
end

--// Create Toggle
function ArsenalKit:CreateToggle(parent, label, default, callback)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 0, 38)
    Container.BackgroundColor3 = Colors.Surface
    Container.BackgroundTransparency = 0.4
    Container.BorderSizePixel = 0
    Container.Parent = parent

    Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 8)

    local LabelObj = Instance.new("TextLabel")
    LabelObj.Text = label
    LabelObj.Size = UDim2.new(1, -70, 1, 0)
    LabelObj.Position = UDim2.new(0, 14, 0, 0)
    LabelObj.BackgroundTransparency = 1
    LabelObj.TextColor3 = Colors.Text
    LabelObj.Font = Enum.Font.SourceSans
    LabelObj.TextSize = 14
    LabelObj.TextXAlignment = Enum.TextXAlignment.Left
    LabelObj.Parent = Container

    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 46, 0, 24)
    ToggleBtn.Position = UDim2.new(1, -58, 0.5, -12)
    ToggleBtn.BackgroundColor3 = default and Colors.ToggleOn or Colors.ToggleOff
    ToggleBtn.BackgroundTransparency = 0.2
    ToggleBtn.Text = ""
    ToggleBtn.BorderSizePixel = 0
    ToggleBtn.AutoButtonColor = false
    ToggleBtn.Parent = Container

    Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)

    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 20, 0, 20)
    Knob.Position = default and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
    Knob.BackgroundColor3 = Colors.Text
    Knob.BorderSizePixel = 0
    Knob.Parent = ToggleBtn

    Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

    local State = default

    ToggleBtn.MouseButton1Click:Connect(function()
        State = not State
        ArsenalKit.Tween(ToggleBtn, {BackgroundColor3 = State and Colors.ToggleOn or Colors.ToggleOff}, 0.2)
        ArsenalKit.Tween(Knob, {Position = State and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)}, 0.2)
        if callback then callback(State) end
    end)

    return Container, function() return State end
end

--// Create Slider
function ArsenalKit:CreateSlider(parent, label, min, max, default, callback)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 0, 54)
    Container.BackgroundColor3 = Colors.Surface
    Container.BackgroundTransparency = 0.4
    Container.BorderSizePixel = 0
    Container.Parent = parent

    Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 8)

    local LabelObj = Instance.new("TextLabel")
    LabelObj.Text = label
    LabelObj.Size = UDim2.new(1, -70, 0, 22)
    LabelObj.Position = UDim2.new(0, 14, 0, 6)
    LabelObj.BackgroundTransparency = 1
    LabelObj.TextColor3 = Colors.Text
    LabelObj.Font = Enum.Font.SourceSans
    LabelObj.TextSize = 14
    LabelObj.TextXAlignment = Enum.TextXAlignment.Left
    LabelObj.Parent = Container

    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Text = tostring(default)
    ValueLabel.Size = UDim2.new(0, 50, 0, 22)
    ValueLabel.Position = UDim2.new(1, -64, 0, 6)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.TextColor3 = Colors.Accent
    ValueLabel.Font = Enum.Font.SourceSans
    ValueLabel.TextSize = 14
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.Parent = Container

    local Track = Instance.new("Frame")
    Track.Size = UDim2.new(1, -28, 0, 5)
    Track.Position = UDim2.new(0, 14, 0, 36)
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
    Knob.Size = UDim2.new(0, 14, 0, 14)
    Knob.Position = UDim2.new((default - min) / (max - min), -7, 0.5, -7)
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
        Knob.Position = UDim2.new(pos, -7, 0.5, -7)
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

--// Create Button
function ArsenalKit:CreateButton(parent, label, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 0, 36)
    Btn.BackgroundColor3 = Colors.Accent
    Btn.BackgroundTransparency = 0.2
    Btn.Text = label
    Btn.TextColor3 = Colors.Text
    Btn.Font = Enum.Font.SourceSans
    Btn.TextSize = 14
    Btn.BorderSizePixel = 0
    Btn.AutoButtonColor = false
    Btn.Parent = parent

    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)

    Btn.MouseEnter:Connect(function()
        ArsenalKit.Tween(Btn, {BackgroundTransparency = 0}, 0.15)
    end)

    Btn.MouseLeave:Connect(function()
        ArsenalKit.Tween(Btn, {BackgroundTransparency = 0.2}, 0.15)
    end)

    Btn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)

    return Btn
end

--// Create Dropdown (NO CLIPPING - overlay parented to ScreenGui)
function ArsenalKit:CreateDropdown(parent, label, options, default, callback)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 0, 38)
    Container.BackgroundColor3 = Colors.Surface
    Container.BackgroundTransparency = 0.4
    Container.BorderSizePixel = 0
    Container.Parent = parent

    Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 8)

    local LabelObj = Instance.new("TextLabel")
    LabelObj.Text = label
    LabelObj.Size = UDim2.new(1, -120, 1, 0)
    LabelObj.Position = UDim2.new(0, 14, 0, 0)
    LabelObj.BackgroundTransparency = 1
    LabelObj.TextColor3 = Colors.Text
    LabelObj.Font = Enum.Font.SourceSans
    LabelObj.TextSize = 14
    LabelObj.TextXAlignment = Enum.TextXAlignment.Left
    LabelObj.Parent = Container

    local Selected = Instance.new("TextButton")
    Selected.Size = UDim2.new(0, 110, 0, 28)
    Selected.Position = UDim2.new(1, -122, 0.5, -14)
    Selected.BackgroundColor3 = Colors.Background
    Selected.BackgroundTransparency = 0.3
    Selected.Text = default or options[1] or "Select"
    Selected.TextColor3 = Colors.Text
    Selected.Font = Enum.Font.SourceSans
    Selected.TextSize = 13
    Selected.BorderSizePixel = 0
    Selected.AutoButtonColor = false
    Selected.Parent = Container

    Instance.new("UICorner", Selected).CornerRadius = UDim.new(0, 6)

    --// Dropdown overlay (parented to ScreenGui to avoid clipping)
    local OptionsFrame = Instance.new("Frame")
    OptionsFrame.Name = "DropdownOptions_" .. label
    OptionsFrame.Size = UDim2.new(0, 110, 0, 0)
    OptionsFrame.BackgroundColor3 = Colors.Surface
    OptionsFrame.BackgroundTransparency = 0.1
    OptionsFrame.BorderSizePixel = 0
    OptionsFrame.Visible = false
    OptionsFrame.ZIndex = 1000
    OptionsFrame.Parent = ScreenGui

    local OFCorner = Instance.new("UICorner", OptionsFrame)
    OFCorner.CornerRadius = UDim.new(0, 8)

    local OFBorder = Instance.new("UIStroke", OptionsFrame)
    OFBorder.Color = Colors.GlassBorder
    OFBorder.Thickness = 1
    OFBorder.Transparency = 0.3

    local OptionsList = Instance.new("UIListLayout")
    OptionsList.Padding = UDim.new(0, 2)
    OptionsList.SortOrder = Enum.SortOrder.LayoutOrder
    OptionsList.Parent = OptionsFrame

    local Opened = false

    local function CloseDropdown()
        Opened = false
        ArsenalKit.Tween(OptionsFrame, {Size = UDim2.new(0, 110, 0, 0)}, 0.15)
        task.delay(0.15, function()
            if not Opened then
                OptionsFrame.Visible = false
                for _, child in ipairs(OptionsFrame:GetChildren()) do
                    if child:IsA("TextButton") then child:Destroy() end
                end
            end
        end)
    end

    local function OpenDropdown()
        if Opened then
            CloseDropdown()
            return
        end
        Opened = true

        -- Clear old
        for _, child in ipairs(OptionsFrame:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end

        -- Position
        local absPos = Selected.AbsolutePosition
        local absSize = Selected.AbsoluteSize
        OptionsFrame.Position = UDim2.new(0, absPos.X, 0, absPos.Y + absSize.Y + 2)
        OptionsFrame.Size = UDim2.new(0, absSize.X, 0, 0)
        OptionsFrame.Visible = true

        ArsenalKit.Tween(OptionsFrame, {Size = UDim2.new(0, absSize.X, 0, #options * 30)}, 0.2)

        for i, opt in ipairs(options) do
            local OptBtn = Instance.new("TextButton")
            OptBtn.Size = UDim2.new(1, 0, 0, 28)
            OptBtn.BackgroundColor3 = Colors.Background
            OptBtn.BackgroundTransparency = 0.3
            OptBtn.Text = opt
            OptBtn.TextColor3 = Colors.TextDim
            OptBtn.Font = Enum.Font.SourceSans
            OptBtn.TextSize = 13
            OptBtn.BorderSizePixel = 0
            OptBtn.AutoButtonColor = false
            OptBtn.ZIndex = 1001
            OptBtn.Parent = OptionsFrame

            Instance.new("UICorner", OptBtn).CornerRadius = UDim.new(0, 4)

            OptBtn.MouseEnter:Connect(function()
                ArsenalKit.Tween(OptBtn, {BackgroundColor3 = Colors.SurfaceHover, TextColor3 = Colors.Text}, 0.1)
            end)

            OptBtn.MouseLeave:Connect(function()
                ArsenalKit.Tween(OptBtn, {BackgroundColor3 = Colors.Background, TextColor3 = Colors.TextDim}, 0.1)
            end)

            OptBtn.MouseButton1Click:Connect(function()
                Selected.Text = opt
                CloseDropdown()
                if callback then callback(opt) end
            end)
        end
    end

    Selected.MouseButton1Click:Connect(OpenDropdown)

    -- Close when clicking elsewhere
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
        if not Opened then return end
        local mousePos = input.Position
        local ofPos = OptionsFrame.AbsolutePosition
        local ofSize = OptionsFrame.AbsoluteSize
        local selPos = Selected.AbsolutePosition
        local selSize = Selected.AbsoluteSize
        local inOptions = mousePos.X >= ofPos.X and mousePos.X <= ofPos.X + ofSize.X and mousePos.Y >= ofPos.Y and mousePos.Y <= ofPos.Y + ofSize.Y
        local inSelected = mousePos.X >= selPos.X and mousePos.X <= selPos.X + selSize.X and mousePos.Y >= selPos.Y and mousePos.Y <= selPos.Y + selSize.Y
        if not inOptions and not inSelected then
            CloseDropdown()
        end
    end)

    return Container
end

--// Create Keybind (Keyboard + Mouse)
function ArsenalKit:CreateKeybind(parent, label, defaultKey, callback)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 0, 38)
    Container.BackgroundColor3 = Colors.Surface
    Container.BackgroundTransparency = 0.4
    Container.BorderSizePixel = 0
    Container.Parent = parent

    Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 8)

    local LabelObj = Instance.new("TextLabel")
    LabelObj.Text = label
    LabelObj.Size = UDim2.new(1, -90, 1, 0)
    LabelObj.Position = UDim2.new(0, 14, 0, 0)
    LabelObj.BackgroundTransparency = 1
    LabelObj.TextColor3 = Colors.Text
    LabelObj.Font = Enum.Font.SourceSans
    LabelObj.TextSize = 14
    LabelObj.TextXAlignment = Enum.TextXAlignment.Left
    LabelObj.Parent = Container

    local KeyBtn = Instance.new("TextButton")
    KeyBtn.Size = UDim2.new(0, 70, 0, 28)
    KeyBtn.Position = UDim2.new(1, -84, 0.5, -14)
    KeyBtn.BackgroundColor3 = Colors.Keybind
    KeyBtn.BackgroundTransparency = 0.3
    KeyBtn.TextColor3 = Colors.Text
    KeyBtn.Font = Enum.Font.SourceSans
    KeyBtn.TextSize = 13
    KeyBtn.BorderSizePixel = 0
    KeyBtn.AutoButtonColor = false
    KeyBtn.Parent = Container

    Instance.new("UICorner", KeyBtn).CornerRadius = UDim.new(0, 6)

    local CurrentKey = nil
    local CurrentMouse = nil
    local Listening = false

    local function GetBindName()
        if CurrentKey and CurrentKey ~= Enum.KeyCode.Unknown then
            return CurrentKey.Name
        elseif CurrentMouse then
            if CurrentMouse == Enum.UserInputType.MouseButton1 then return "LMB" end
            if CurrentMouse == Enum.UserInputType.MouseButton2 then return "RMB" end
            if CurrentMouse == Enum.UserInputType.MouseButton3 then return "MMB" end
            if CurrentMouse == Enum.UserInputType.MouseButton4 then return "MB4" end
            if CurrentMouse == Enum.UserInputType.MouseButton5 then return "MB5" end
            return CurrentMouse.Name
        end
        return "NONE"
    end

    local function MatchesBind(input)
        if CurrentKey and input.KeyCode == CurrentKey then return true end
        if CurrentMouse and input.UserInputType == CurrentMouse then return true end
        return false
    end

    if typeof(defaultKey) == "EnumItem" then
        if defaultKey.EnumType == Enum.KeyCode then
            CurrentKey = defaultKey
        elseif defaultKey.EnumType == Enum.UserInputType then
            CurrentMouse = defaultKey
        end
    end
    KeyBtn.Text = GetBindName()

    KeyBtn.MouseButton1Click:Connect(function()
        if Listening then
            Listening = false
            KeyBtn.Text = GetBindName()
            KeyBtn.BackgroundColor3 = Colors.Keybind
            KeyBtn.BackgroundTransparency = 0.3
            return
        end
        Listening = true
        KeyBtn.Text = "..."
        KeyBtn.BackgroundColor3 = Colors.Accent
        KeyBtn.BackgroundTransparency = 0.1
    end)

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if Listening then
            if input.KeyCode ~= Enum.KeyCode.Unknown then
                CurrentKey = input.KeyCode
                CurrentMouse = nil
            elseif input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.MouseButton2
                or input.UserInputType == Enum.UserInputType.MouseButton3
                or input.UserInputType == Enum.UserInputType.MouseButton4
                or input.UserInputType == Enum.UserInputType.MouseButton5 then
                CurrentMouse = input.UserInputType
                CurrentKey = nil
            else
                return
            end
            KeyBtn.Text = GetBindName()
            KeyBtn.BackgroundColor3 = Colors.Keybind
            KeyBtn.BackgroundTransparency = 0.3
            Listening = false
            if callback then callback(CurrentKey or CurrentMouse) end
            return
        end
        if MatchesBind(input) then
            if callback then callback(CurrentKey or CurrentMouse, true) end
        end
    end)

    return Container, function() return CurrentKey or CurrentMouse end
end

--// Dragging
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

--// Toggle UI
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.RightShift then
        Main.Visible = not Main.Visible
    end
end)

--// ==========================
--// MODULE LOADING
--// ==========================

local ModuleList = {"aimbot", "esp", "weapon", "world", "movement", "misc"}
local LoadResults = {}

for _, modName in ipairs(ModuleList) do
    task.spawn(function()
        LoadResults[modName] = LoadModule(modName)
    end)
end

task.delay(2.5, function()
    local successCount = 0
    for _, v in pairs(LoadResults) do if v then successCount = successCount + 1 end end
    StatusLabel.Text = successCount .. "/" .. #ModuleList .. " loaded"
    StatusLabel.TextColor3 = successCount == #ModuleList and Colors.ToggleOn or Colors.Error

    local firstTab = nil
    for _, page in pairs(Content:GetChildren()) do
        if page:IsA("ScrollingFrame") then firstTab = page break end
    end
    if firstTab then
        for _, btn in pairs(Sidebar:GetChildren()) do
            if btn:IsA("TextButton") then
                btn.TextColor3 = Colors.TextDim
                btn.BackgroundColor3 = Colors.Surface
                btn.BackgroundTransparency = 0.5
                local ind = btn:FindFirstChild("Indicator")
                if ind then ind.Visible = false end
            end
        end
        ActiveTab = firstTab
        firstTab.Visible = true
        for _, btn in pairs(Sidebar:GetChildren()) do
            if btn:IsA("TextButton") and btn.Name .. "Page" == firstTab.Name then
                ActiveTabBtn = btn
                ArsenalKit.Tween(btn, {BackgroundColor3 = Colors.Accent, BackgroundTransparency = 0.15, TextColor3 = Colors.Text}, 0.15)
                local ind = btn:FindFirstChild("Indicator")
                if ind then ind.Visible = true end
            end
        end
    end
end)

print("[ArsenalKit] v4.0 loaded. Press RightShift to toggle UI.")