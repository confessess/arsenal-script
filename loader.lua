--// ARSENALKIT v2.1 — Modular Loader
--// Loader + UI Framework — loads modules from GitHub raw URLs

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer

-- Clean up old
for _, gui in pairs(Player:WaitForChild("PlayerGui"):GetChildren()) do
    if gui.Name == "ArsenalKit" then gui:Destroy() end
end

--========================================================
-- API
--========================================================

getgenv().ArsenalKit = {
    Tabs = {},
    ActiveTab = nil,
    Keybinds = {},
    UI = {},
    Features = {},
    Connections = {},
    Theme = {
        Background = Color3.fromRGB(4, 8, 16),
        Glass = Color3.fromRGB(8, 15, 28),
        GlassLight = Color3.fromRGB(12, 22, 39),
        GlassHover = Color3.fromRGB(15, 29, 50),
        Blue = Color3.fromRGB(0, 145, 255),
        Cyan = Color3.fromRGB(74, 205, 255),
        White = Color3.fromRGB(238, 246, 255),
        Muted = Color3.fromRGB(130, 153, 181),
        Dim = Color3.fromRGB(74, 94, 120),
        Green = Color3.fromRGB(72, 230, 155),
        Red = Color3.fromRGB(255, 78, 98),
    }
}

-- CRITICAL: Mirror to _G so loadstring modules can access it
_G.ArsenalKit = getgenv().ArsenalKit

local ArsenalKit = getgenv().ArsenalKit
local Theme = ArsenalKit.Theme

--========================================================
-- HELPERS
--========================================================

local function Tween(Object, Duration, Properties, Style)
    return TweenService:Create(Object, TweenInfo.new(Duration, Style or Enum.EasingStyle.Quint, Enum.EasingDirection.Out), Properties)
end

local function Corner(Object, Radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, Radius)
    c.Parent = Object
    return c
end

local function Stroke(Object, Transparency, Thickness)
    local s = Instance.new("UIStroke")
    s.Color = Theme.Blue
    s.Transparency = Transparency or 0.5
    s.Thickness = Thickness or 2
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = Object
    return s
end

local function Text(Object, Value, Size, Color, Bold)
    Object.BackgroundTransparency = 1
    Object.Text = Value
    Object.TextSize = Size
    Object.TextColor3 = Color or Theme.White
    Object.Font = Bold and Enum.Font.GothamBold or Enum.Font.Gotham
    Object.TextTruncate = Enum.TextTruncate.AtEnd
    return Object
end

local function AddConnection(conn)
    table.insert(ArsenalKit.Connections, conn)
    return conn
end

--========================================================
-- SCREEN GUI
--========================================================

local Gui = Instance.new("ScreenGui")
Gui.Name = "ArsenalKit"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true
Gui.DisplayOrder = 50
Gui.Parent = Player:WaitForChild("PlayerGui")
ArsenalKit.UI.ScreenGui = Gui

-- Backdrop
local Backdrop = Instance.new("Frame")
Backdrop.Size = UDim2.fromScale(1, 1)
Backdrop.BackgroundColor3 = Theme.Background
Backdrop.BackgroundTransparency = .18
Backdrop.BorderSizePixel = 0
Backdrop.Parent = Gui
ArsenalKit.UI.Backdrop = Backdrop

-- Outer Glow
local OuterGlow = Instance.new("Frame")
OuterGlow.Size = UDim2.fromOffset(1000, 620)
OuterGlow.Position = UDim2.new(.5, -500, .5, -310)
OuterGlow.BackgroundColor3 = Theme.Blue
OuterGlow.BackgroundTransparency = .94
OuterGlow.BorderSizePixel = 0
OuterGlow.Parent = Gui
Corner(OuterGlow, 28)
ArsenalKit.UI.OuterGlow = OuterGlow

local InnerGlow = Instance.new("Frame")
InnerGlow.Size = UDim2.fromOffset(980, 600)
InnerGlow.Position = UDim2.new(.5, -490, .5, -300)
InnerGlow.BackgroundColor3 = Theme.Cyan
InnerGlow.BackgroundTransparency = .97
InnerGlow.BorderSizePixel = 0
InnerGlow.Parent = Gui
Corner(InnerGlow, 25)
ArsenalKit.UI.InnerGlow = InnerGlow

-- Main Window
local Main = Instance.new("Frame")
Main.Size = UDim2.fromOffset(940, 560)
Main.Position = UDim2.new(.5, -470, .5, -280)
Main.BackgroundColor3 = Theme.Glass
Main.BackgroundTransparency = .04
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Parent = Gui
Corner(Main, 20)
Stroke(Main, .28, 2)
ArsenalKit.UI.Main = Main

local MainGradient = Instance.new("UIGradient")
MainGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(11, 25, 44)),
    ColorSequenceKeypoint.new(.5, Color3.fromRGB(6, 12, 24)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(9, 18, 33))
})
MainGradient.Rotation = 125
MainGradient.Parent = Main

-- Particle VFX
local VFX = Instance.new("Frame")
VFX.Size = UDim2.fromScale(1, 1)
VFX.BackgroundTransparency = 1
VFX.ClipsDescendants = true
VFX.ZIndex = 2
VFX.Parent = Main

for i = 1, 20 do
    local Particle = Instance.new("Frame")
    local ps = math.random(1, 3)
    Particle.Size = UDim2.fromOffset(ps, ps)
    Particle.Position = UDim2.fromScale(math.random(5, 95)/100, math.random(5, 95)/100)
    Particle.BackgroundColor3 = Theme.Cyan
    Particle.BackgroundTransparency = math.random(45, 80)/100
    Particle.BorderSizePixel = 0
    Particle.ZIndex = 2
    Particle.Parent = VFX
    Corner(Particle, 10)
    task.spawn(function()
        while Particle.Parent do
            local Target = UDim2.fromScale(math.random(5, 95)/100, math.random(5, 95)/100)
            local anim = Tween(Particle, math.random(3,7), {Position = Target, BackgroundTransparency = math.random(35,85)/100}, Enum.EasingStyle.Sine)
            anim:Play()
            anim.Completed:Wait()
        end
    end)
end

--========================================================
-- HEADER
--========================================================

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, -36, 0, 65)
Header.Position = UDim2.fromOffset(18, 15)
Header.BackgroundTransparency = 1
Header.ZIndex = 5
Header.Parent = Main
ArsenalKit.UI.Header = Header

-- Logo
local LogoGlow = Instance.new("Frame")
LogoGlow.Size = UDim2.fromOffset(58, 58)
LogoGlow.Position = UDim2.fromOffset(-6, 2)
LogoGlow.BackgroundColor3 = Theme.Blue
LogoGlow.BackgroundTransparency = .9
LogoGlow.BorderSizePixel = 0
LogoGlow.ZIndex = 4
LogoGlow.Parent = Header
Corner(LogoGlow, 18)

local LogoContainer = Instance.new("Frame")
LogoContainer.Size = UDim2.fromOffset(46, 46)
LogoContainer.Position = UDim2.fromOffset(2, 8)
LogoContainer.BackgroundColor3 = Theme.Blue
LogoContainer.BackgroundTransparency = .82
LogoContainer.BorderSizePixel = 0
LogoContainer.ZIndex = 5
LogoContainer.Parent = Header
Corner(LogoContainer, 14)
Stroke(LogoContainer, .45, 2)

local Logo = Instance.new("TextLabel")
Logo.Size = UDim2.fromScale(1, 1)
Text(Logo, "A", 23, Theme.Cyan, true)
Logo.TextXAlignment = Enum.TextXAlignment.Center
Logo.TextYAlignment = Enum.TextYAlignment.Center
Logo.ZIndex = 6
Logo.Parent = LogoContainer

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.fromOffset(200, 27)
Title.Position = UDim2.fromOffset(62, 7)
Text(Title, "ArsenalKit", 21, Theme.White, true)
Title.ZIndex = 6
Title.Parent = Header

local Subtitle = Instance.new("TextLabel")
Subtitle.Size = UDim2.fromOffset(250, 17)
Subtitle.Position = UDim2.fromOffset(63, 34)
Text(Subtitle, "ARSENAL  /  PREMIUM TOOLKIT", 8, Theme.Muted, true)
Subtitle.ZIndex = 6
Subtitle.Parent = Header

-- Status
local Status = Instance.new("Frame")
Status.Size = UDim2.fromOffset(128, 32)
Status.Position = UDim2.new(1, -170, 0, 15)
Status.BackgroundColor3 = Theme.GlassLight
Status.BackgroundTransparency = .05
Status.BorderSizePixel = 0
Status.ZIndex = 6
Status.Parent = Header
Corner(Status, 10)
Stroke(Status, .72, 2)

local StatusDot = Instance.new("Frame")
StatusDot.Size = UDim2.fromOffset(7, 7)
StatusDot.Position = UDim2.fromOffset(12, 12)
StatusDot.BackgroundColor3 = Theme.Green
StatusDot.BorderSizePixel = 0
StatusDot.ZIndex = 7
StatusDot.Parent = Status
Corner(StatusDot, 10)

local StatusText = Instance.new("TextLabel")
StatusText.Size = UDim2.fromOffset(90, 32)
StatusText.Position = UDim2.fromOffset(26, 0)
Text(StatusText, "ONLINE", 8, Theme.Green, true)
StatusText.TextYAlignment = Enum.TextYAlignment.Center
StatusText.ZIndex = 7
StatusText.Parent = Status

--========================================================
-- BODY (defined BEFORE minimize/close buttons reference it)
--========================================================

local Body = Instance.new("Frame")
Body.Size = UDim2.new(1, -36, 1, -100)
Body.Position = UDim2.fromOffset(18, 85)
Body.BackgroundTransparency = 1
Body.ZIndex = 5
Body.Parent = Main

-- Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.fromOffset(160, 455)
Sidebar.BackgroundColor3 = Theme.GlassLight
Sidebar.BackgroundTransparency = .2
Sidebar.BorderSizePixel = 0
Sidebar.ZIndex = 5
Sidebar.Parent = Body
Corner(Sidebar, 16)
Stroke(Sidebar, .72, 2)

local SidebarTitle = Instance.new("TextLabel")
SidebarTitle.Size = UDim2.new(1, -28, 0, 18)
SidebarTitle.Position = UDim2.fromOffset(14, 14)
Text(SidebarTitle, "ARSENAL", 8, Theme.Muted, true)
SidebarTitle.ZIndex = 6
SidebarTitle.Parent = Sidebar

local Navigation = Instance.new("Frame")
Navigation.Size = UDim2.new(1, -18, 0, 330)
Navigation.Position = UDim2.fromOffset(9, 42)
Navigation.BackgroundTransparency = 1
Navigation.ZIndex = 6
Navigation.Parent = Sidebar

local NavLayout = Instance.new("UIListLayout")
NavLayout.Padding = UDim.new(0, 5)
NavLayout.Parent = Navigation

-- Content
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -175, 1, 0)
Content.Position = UDim2.fromOffset(175, 0)
Content.BackgroundTransparency = 1
Content.ClipsDescendants = true
Content.ZIndex = 5
Content.Parent = Body
ArsenalKit.UI.Content = Content

--========================================================
-- MINIMIZE / CLOSE BUTTONS (Body is now defined above)
--========================================================

local Minimized = false
local Minimize = Instance.new("TextButton")
Minimize.Size = UDim2.fromOffset(32, 32)
Minimize.Position = UDim2.new(1, -70, 0, 15)
Minimize.BackgroundColor3 = Theme.GlassLight
Minimize.BackgroundTransparency = .05
Minimize.BorderSizePixel = 0
Minimize.Text = "−"
Minimize.TextSize = 20
Minimize.TextColor3 = Theme.Muted
Minimize.Font = Enum.Font.GothamBold
Minimize.AutoButtonColor = false
Minimize.ZIndex = 7
Minimize.Parent = Header
Corner(Minimize, 10)
Stroke(Minimize, .72, 2)

Minimize.MouseEnter:Connect(function()
    Tween(Minimize, .15, {BackgroundColor3 = Theme.Blue, TextColor3 = Color3.new(1,1,1)}):Play()
end)
Minimize.MouseLeave:Connect(function()
    Tween(Minimize, .15, {BackgroundColor3 = Theme.GlassLight, TextColor3 = Theme.Muted}):Play()
end)

-- Store restore position
local RestoreSize = UDim2.fromOffset(940, 560)
local RestorePosition = Main.Position

Minimize.MouseButton1Click:Connect(function()
    Minimized = not Minimized
    if Minimized then
        RestorePosition = Main.Position
        RestoreSize = Main.Size
        Tween(Main, .3, {Size = UDim2.fromOffset(940, 65), Position = UDim2.new(Main.Position.X.Scale, Main.Position.X.Offset, Main.Position.Y.Scale, Main.Position.Y.Offset)}):Play()
        Tween(OuterGlow, .3, {BackgroundTransparency = 1}):Play()
        Tween(InnerGlow, .3, {BackgroundTransparency = 1}):Play()
        Body.Visible = false
        Minimize.Text = "+"
    else
        Tween(Main, .3, {Size = RestoreSize, Position = RestorePosition}):Play()
        Tween(OuterGlow, .3, {BackgroundTransparency = .94}):Play()
        Tween(InnerGlow, .3, {BackgroundTransparency = .97}):Play()
        task.delay(.15, function()
            Body.Visible = true
        end)
        Minimize.Text = "−"
    end
end)

-- Close
local Close = Instance.new("TextButton")
Close.Size = UDim2.fromOffset(32, 32)
Close.Position = UDim2.new(1, -32, 0, 15)
Close.BackgroundColor3 = Theme.GlassLight
Close.BackgroundTransparency = .05
Close.BorderSizePixel = 0
Close.Text = "×"
Close.TextSize = 18
Close.TextColor3 = Theme.Muted
Close.Font = Enum.Font.GothamBold
Close.AutoButtonColor = false
Close.ZIndex = 7
Close.Parent = Header
Corner(Close, 10)
Stroke(Close, .72, 2)

Close.MouseEnter:Connect(function()
    Tween(Close, .15, {BackgroundColor3 = Theme.Red, TextColor3 = Color3.new(1,1,1)}):Play()
end)
Close.MouseLeave:Connect(function()
    Tween(Close, .15, {BackgroundColor3 = Theme.GlassLight, TextColor3 = Theme.Muted}):Play()
end)

Close.MouseButton1Click:Connect(function()
    Tween(Main, .3, {Size = UDim2.fromOffset(820, 490), BackgroundTransparency = 1}):Play()
    Tween(OuterGlow, .3, {BackgroundTransparency = 1}):Play()
    Tween(InnerGlow, .3, {BackgroundTransparency = 1}):Play()
    task.wait(.3)
    for _, conn in pairs(ArsenalKit.Connections) do
        if typeof(conn) == "RBXScriptConnection" then conn:Disconnect() end
    end
    Gui:Destroy()
    getgenv().ArsenalKit = nil
    _G.ArsenalKit = nil
end)

--========================================================
-- PAGE SYSTEM
--========================================================

local Pages = {}
local Buttons = {}
local CurrentPage = nil
local CurrentButton = nil
local Switching = false

local function CreatePage(Name)
    local Page = Instance.new("Frame")
    Page.Name = Name .. "Page"
    Page.Size = UDim2.fromScale(1, 1)
    Page.Position = UDim2.fromOffset(0, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.ZIndex = 5
    Page.Parent = Content

    local ScrollFrame = Instance.new("ScrollingFrame")
    ScrollFrame.Size = UDim2.new(1, -10, 1, -10)
    ScrollFrame.Position = UDim2.fromOffset(0, 0)
    ScrollFrame.BackgroundTransparency = 1
    ScrollFrame.BorderSizePixel = 0
    ScrollFrame.ScrollBarThickness = 3
    ScrollFrame.ScrollBarImageColor3 = Theme.Cyan
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    ScrollFrame.ZIndex = 5
    ScrollFrame.Parent = Page

    local Layout = Instance.new("UIListLayout")
    Layout.Padding = UDim.new(0, 10)
    Layout.Parent = ScrollFrame

    local Padding = Instance.new("UIPadding")
    Padding.PaddingLeft = UDim.new(0, 0)
    Padding.PaddingRight = UDim.new(0, 8)
    Padding.PaddingTop = UDim.new(0, 0)
    Padding.PaddingBottom = UDim.new(0, 15)
    Padding.Parent = ScrollFrame

    Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 20)
    end)

    Page.ScrollFrame = ScrollFrame
    Pages[Name] = Page
    return Page, ScrollFrame
end

--========================================================
-- NAV BUTTON
--========================================================

local function NavButton(IconText, Name)
    local Button = Instance.new("TextButton")
    Button.Name = Name .. "Button"
    Button.Size = UDim2.new(1, 0, 0, 40)
    Button.BackgroundColor3 = Theme.Blue
    Button.BackgroundTransparency = 1
    Button.BorderSizePixel = 0
    Button.Text = ""
    Button.AutoButtonColor = false
    Button.ZIndex = 6
    Button.Parent = Navigation
    Corner(Button, 10)
    Buttons[Name] = Button

    local ActiveGlow = Instance.new("Frame")
    ActiveGlow.Name = "ActiveGlow"
    ActiveGlow.Size = UDim2.new(1, 0, 1, 0)
    ActiveGlow.BackgroundColor3 = Theme.Blue
    ActiveGlow.BackgroundTransparency = 1
    ActiveGlow.BorderSizePixel = 0
    ActiveGlow.ZIndex = 6
    ActiveGlow.Parent = Button
    Corner(ActiveGlow, 10)

    local Icon = Instance.new("TextLabel")
    Icon.Name = "Icon"
    Icon.Size = UDim2.fromOffset(30, 40)
    Icon.Position = UDim2.fromOffset(5, 0)
    Text(Icon, IconText, 14, Theme.Muted, true)
    Icon.TextXAlignment = Enum.TextXAlignment.Center
    Icon.TextYAlignment = Enum.TextYAlignment.Center
    Icon.ZIndex = 8
    Icon.Parent = Button

    local Label = Instance.new("TextLabel")
    Label.Name = "Label"
    Label.Size = UDim2.new(1, -43, 1, 0)
    Label.Position = UDim2.fromOffset(41, 0)
    Text(Label, Name, 10, Theme.Muted, true)
    Label.TextYAlignment = Enum.TextYAlignment.Center
    Label.ZIndex = 8
    Label.Parent = Button

    local Indicator = Instance.new("Frame")
    Indicator.Name = "Indicator"
    Indicator.Size = UDim2.fromOffset(3, 18)
    Indicator.Position = UDim2.new(0, 2, .5, -9)
    Indicator.BackgroundColor3 = Theme.Cyan
    Indicator.BackgroundTransparency = 1
    Indicator.BorderSizePixel = 0
    Indicator.ZIndex = 9
    Indicator.Parent = Button
    Corner(Indicator, 5)

    Button.MouseEnter:Connect(function()
        if Button ~= CurrentButton then
            Tween(Button, .15, {BackgroundTransparency = .88}):Play()
            Tween(Icon, .15, {TextColor3 = Theme.Cyan}):Play()
        end
    end)
    Button.MouseLeave:Connect(function()
        if Button ~= CurrentButton then
            Tween(Button, .15, {BackgroundTransparency = 1}):Play()
            Tween(Icon, .15, {TextColor3 = Theme.Muted}):Play()
        end
    end)

    Button.MouseButton1Click:Connect(function()
        if CurrentPage == Name or Switching then return end
        Switching = true

        local targetTab = nil
        for _, t in pairs(ArsenalKit.Tabs) do
            if t.Name == Name then targetTab = t; break end
        end
        if not targetTab then Switching = false; return end

        ArsenalKit:SwitchTab(targetTab)
        task.delay(.3, function() Switching = false end)
    end)

    return Button
end

--========================================================
-- UI CONTROL CONSTRUCTORS
--========================================================

function ArsenalKit:CreateTab(name, iconText)
    local btn = NavButton(iconText or "●", name)
    local page, scroll = CreatePage(name)

    local tab = {
        Name = name,
        Button = btn,
        Page = page,
        Content = scroll,
    }
    table.insert(ArsenalKit.Tabs, tab)

    if #ArsenalKit.Tabs == 1 then
        task.delay(0.15, function()
            ArsenalKit:SwitchTab(tab)
        end)
    end

    return scroll
end

function ArsenalKit:SwitchTab(targetTab)
    -- Deactivate all tabs
    for _, t in pairs(ArsenalKit.Tabs) do
        t.Page.Visible = false
        t.Page.Position = UDim2.fromOffset(0, 0)

        Tween(t.Button, 0.2, {BackgroundTransparency = 1}):Play()
        local glow = t.Button:FindFirstChild("ActiveGlow")
        if glow then Tween(glow, 0.2, {BackgroundTransparency = 1}):Play() end
        local icon = t.Button:FindFirstChild("Icon")
        if icon then Tween(icon, 0.2, {TextColor3 = Theme.Muted}):Play() end
        local label = t.Button:FindFirstChild("Label")
        if label then Tween(label, 0.2, {TextColor3 = Theme.Muted}):Play() end
        local indicator = t.Button:FindFirstChild("Indicator")
        if indicator then Tween(indicator, 0.2, {BackgroundTransparency = 1, Size = UDim2.fromOffset(3, 18)}):Play() end
    end

    -- Activate target
    ArsenalKit.ActiveTab = targetTab
    CurrentPage = targetTab.Name
    CurrentButton = targetTab.Button

    targetTab.Page.Visible = true
    targetTab.Page.Position = UDim2.fromOffset(14, 0)
    Tween(targetTab.Page, 0.3, {Position = UDim2.fromOffset(0, 0)}, Enum.EasingStyle.Quint):Play()

    Tween(targetTab.Button, 0.22, {BackgroundTransparency = 0.64}):Play()
    local glow = targetTab.Button:FindFirstChild("ActiveGlow")
    if glow then Tween(glow, 0.25, {BackgroundTransparency = 0.9}):Play() end
    local icon = targetTab.Button:FindFirstChild("Icon")
    if icon then Tween(icon, 0.22, {TextColor3 = Theme.Cyan}):Play() end
    local label = targetTab.Button:FindFirstChild("Label")
    if label then Tween(label, 0.22, {TextColor3 = Theme.White}):Play() end
    local indicator = targetTab.Button:FindFirstChild("Indicator")
    if indicator then Tween(indicator, 0.25, {BackgroundTransparency = 0, Size = UDim2.fromOffset(3, 25)}, Enum.EasingStyle.Back):Play() end
end

function ArsenalKit:CreateSection(parent, titleText, descriptionText)
    local Section = Instance.new("Frame")
    Section.Size = UDim2.new(1, 0, 0, 0)
    Section.BackgroundColor3 = Theme.GlassLight
    Section.BackgroundTransparency = .1
    Section.BorderSizePixel = 0
    Section.ZIndex = 5
    Section.Parent = parent
    Corner(Section, 16)
    Stroke(Section, .72, 2)

    local SectionTitle = Instance.new("TextLabel")
    SectionTitle.Size = UDim2.new(1, -30, 0, 20)
    SectionTitle.Position = UDim2.fromOffset(15, 13)
    Text(SectionTitle, titleText, 9, Theme.White, true)
    SectionTitle.ZIndex = 7
    SectionTitle.Parent = Section

    local SectionDescription = Instance.new("TextLabel")
    SectionDescription.Size = UDim2.new(1, -30, 0, 18)
    SectionDescription.Position = UDim2.fromOffset(15, 35)
    Text(SectionDescription, descriptionText or "", 8, Theme.Muted, false)
    SectionDescription.ZIndex = 7
    SectionDescription.Parent = Section

    local ControlContainer = Instance.new("Frame")
    ControlContainer.Size = UDim2.new(1, -20, 0, 0)
    ControlContainer.Position = UDim2.fromOffset(10, 58)
    ControlContainer.BackgroundTransparency = 1
    ControlContainer.BorderSizePixel = 0
    ControlContainer.ZIndex = 6
    ControlContainer.Parent = Section

    local ControlLayout = Instance.new("UIListLayout")
    ControlLayout.Padding = UDim.new(0, 6)
    ControlLayout.Parent = ControlContainer

    ControlLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        ControlContainer.Size = UDim2.new(1, -20, 0, ControlLayout.AbsoluteContentSize.Y)
        Section.Size = UDim2.new(1, 0, 0, 58 + ControlLayout.AbsoluteContentSize.Y + 12)
    end)

    return ControlContainer
end

function ArsenalKit:CreateToggle(parent, text, default, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, 0, 0, 38)
    ToggleFrame.BackgroundColor3 = Theme.Glass
    ToggleFrame.BackgroundTransparency = .3
    ToggleFrame.BorderSizePixel = 0
    ToggleFrame.ZIndex = 6
    ToggleFrame.Parent = parent
    Corner(ToggleFrame, 10)
    Stroke(ToggleFrame, .82, 1)

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.55, 0, 1, 0)
    Label.Position = UDim2.fromOffset(14, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Theme.White
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 11
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.ZIndex = 7
    Label.Parent = ToggleFrame

    local Button = Instance.new("TextButton")
    Button.Size = UDim2.fromOffset(48, 24)
    Button.Position = UDim2.new(1, -62, 0.5, -12)
    Button.BackgroundColor3 = default and Theme.Green or Theme.Red
    Button.BackgroundTransparency = .3
    Button.Text = ""
    Button.BorderSizePixel = 0
    Button.AutoButtonColor = false
    Button.ZIndex = 7
    Button.Parent = ToggleFrame
    Corner(Button, 12)

    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.fromOffset(20, 20)
    Knob.Position = default and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
    Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Knob.BorderSizePixel = 0
    Knob.ZIndex = 8
    Knob.Parent = Button
    Corner(Knob, 10)

    local State = default
    local function Update()
        State = not State
        local tc = State and Theme.Green or Theme.Red
        local tp = State and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
        Tween(Button, 0.2, {BackgroundColor3 = tc}):Play()
        Tween(Knob, 0.2, {Position = tp}):Play()
        if callback then callback(State) end
    end
    Button.MouseButton1Click:Connect(Update)

    return {Frame = ToggleFrame, GetState = function() return State end, SetState = function(ns) if State ~= ns then Update() end end}
end

function ArsenalKit:CreateSlider(parent, text, min, max, default, callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(1, 0, 0, 52)
    SliderFrame.BackgroundColor3 = Theme.Glass
    SliderFrame.BackgroundTransparency = .3
    SliderFrame.BorderSizePixel = 0
    SliderFrame.ZIndex = 6
    SliderFrame.Parent = parent
    Corner(SliderFrame, 10)
    Stroke(SliderFrame, .82, 1)

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.5, 0, 0, 20)
    Label.Position = UDim2.fromOffset(14, 6)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Theme.White
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 11
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.ZIndex = 7
    Label.Parent = SliderFrame

    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0.3, 0, 0, 20)
    ValueLabel.Position = UDim2.new(0.6, 0, 0, 6)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(default)
    ValueLabel.TextColor3 = Theme.Cyan
    ValueLabel.Font = Enum.Font.GothamBold
    ValueLabel.TextSize = 11
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.ZIndex = 7
    ValueLabel.Parent = SliderFrame

    local Track = Instance.new("Frame")
    Track.Size = UDim2.new(1, -28, 0, 4)
    Track.Position = UDim2.fromOffset(14, 34)
    Track.BackgroundColor3 = Theme.GlassLight
    Track.BorderSizePixel = 0
    Track.ZIndex = 7
    Track.Parent = SliderFrame
    Corner(Track, 2)

    local Fill = Instance.new("Frame")
    local Ratio = (default - min) / (max - min)
    Fill.Size = UDim2.new(Ratio, 0, 1, 0)
    Fill.BackgroundColor3 = Theme.Blue
    Fill.BorderSizePixel = 0
    Fill.ZIndex = 8
    Fill.Parent = Track
    Corner(Fill, 2)

    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.fromOffset(14, 14)
    Knob.Position = UDim2.new(Ratio, -7, 0.5, -7)
    Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Knob.BorderSizePixel = 0
    Knob.ZIndex = 9
    Knob.Parent = Track
    Corner(Knob, 7)

    local Dragging = false
    local function SetValue(Input)
        local Pos = math.clamp((Input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
        local Val = math.floor(min + (max - min) * Pos)
        Fill.Size = UDim2.new(Pos, 0, 1, 0)
        Knob.Position = UDim2.new(Pos, -7, 0.5, -7)
        ValueLabel.Text = tostring(Val)
        if callback then callback(Val) end
    end

    Knob.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = true end
    end)
    Track.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then SetValue(Input); Dragging = true end
    end)
    AddConnection(UserInputService.InputChanged:Connect(function(Input)
        if Dragging and Input.UserInputType == Enum.UserInputType.MouseMovement then SetValue(Input) end
    end))
    AddConnection(UserInputService.InputEnded:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end
    end))

    return SliderFrame
end

function ArsenalKit:CreateDropdown(parent, text, options, default, callback)
    local DropdownFrame = Instance.new("Frame")
    DropdownFrame.Size = UDim2.new(1, 0, 0, 38)
    DropdownFrame.BackgroundColor3 = Theme.Glass
    DropdownFrame.BackgroundTransparency = .3
    DropdownFrame.BorderSizePixel = 0
    DropdownFrame.ZIndex = 6
    DropdownFrame.Parent = parent
    DropdownFrame.ClipsDescendants = false
    Corner(DropdownFrame, 10)
    Stroke(DropdownFrame, .82, 1)

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.45, 0, 1, 0)
    Label.Position = UDim2.fromOffset(14, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Theme.White
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 11
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.ZIndex = 7
    Label.Parent = DropdownFrame

    local Button = Instance.new("TextButton")
    Button.Size = UDim2.fromOffset(130, 26)
    Button.Position = UDim2.new(1, -146, 0.5, -13)
    Button.BackgroundColor3 = Theme.GlassLight
    Button.BackgroundTransparency = .2
    Button.Text = default or options[1]
    Button.TextColor3 = Theme.White
    Button.Font = Enum.Font.Gotham
    Button.TextSize = 10
    Button.BorderSizePixel = 0
    Button.AutoButtonColor = false
    Button.ZIndex = 7
    Button.Parent = DropdownFrame
    Corner(Button, 6)
    Stroke(Button, .6, 1)

    local Arrow = Instance.new("TextLabel")
    Arrow.Size = UDim2.fromOffset(20, 26)
    Arrow.Position = UDim2.new(1, -20, 0, 0)
    Arrow.BackgroundTransparency = 1
    Arrow.Text = "v"
    Arrow.TextColor3 = Theme.Muted
    Arrow.Font = Enum.Font.Gotham
    Arrow.TextSize = 10
    Arrow.ZIndex = 7
    Arrow.Parent = Button

    local OptionsFrame = Instance.new("Frame")
    OptionsFrame.Size = UDim2.fromOffset(130, math.min(#options * 26, 140))
    OptionsFrame.BackgroundColor3 = Theme.GlassLight
    OptionsFrame.BackgroundTransparency = .02
    OptionsFrame.BorderSizePixel = 0
    OptionsFrame.Visible = false
    OptionsFrame.ZIndex = 100
    OptionsFrame.Parent = Gui
    Corner(OptionsFrame, 8)
    Stroke(OptionsFrame, .4, 1.5)

    local Scroll = Instance.new("ScrollingFrame")
    Scroll.Size = UDim2.new(1, 0, 1, 0)
    Scroll.BackgroundTransparency = 1
    Scroll.BorderSizePixel = 0
    Scroll.ScrollBarThickness = 2
    Scroll.ScrollBarImageColor3 = Theme.Cyan
    Scroll.CanvasSize = UDim2.new(0, 0, 0, #options * 26)
    Scroll.ZIndex = 100
    Scroll.Parent = OptionsFrame

    for i, Opt in ipairs(options) do
        local OptBtn = Instance.new("TextButton")
        OptBtn.Size = UDim2.new(1, 0, 0, 26)
        OptBtn.Position = UDim2.fromOffset(0, (i - 1) * 26)
        OptBtn.BackgroundColor3 = Theme.GlassLight
        OptBtn.BackgroundTransparency = 1
        OptBtn.Text = Opt
        OptBtn.TextColor3 = Theme.White
        OptBtn.Font = Enum.Font.Gotham
        OptBtn.TextSize = 10
        OptBtn.BorderSizePixel = 0
        OptBtn.AutoButtonColor = false
        OptBtn.ZIndex = 100
        OptBtn.Parent = Scroll
        OptBtn.MouseEnter:Connect(function() Tween(OptBtn, 0.15, {BackgroundTransparency = .4}):Play() end)
        OptBtn.MouseLeave:Connect(function() Tween(OptBtn, 0.15, {BackgroundTransparency = 1}):Play() end)
        OptBtn.MouseButton1Click:Connect(function()
            Button.Text = Opt
            OptionsFrame.Visible = false
            if callback then callback(Opt) end
        end)
    end

    Button.MouseButton1Click:Connect(function()
        OptionsFrame.Visible = not OptionsFrame.Visible
        local AbsPos = Button.AbsolutePosition
        OptionsFrame.Position = UDim2.fromOffset(AbsPos.X, AbsPos.Y + 30)
    end)

    AddConnection(UserInputService.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 and OptionsFrame.Visible then
            local MousePos = UserInputService:GetMouseLocation()
            local DropPos = DropdownFrame.AbsolutePosition
            local DropSize = DropdownFrame.AbsoluteSize
            local OptPos = OptionsFrame.AbsolutePosition
            local OptSize = OptionsFrame.AbsoluteSize
            local InDropdown = MousePos.X >= DropPos.X and MousePos.X <= DropPos.X + DropSize.X and MousePos.Y >= DropPos.Y and MousePos.Y <= DropPos.Y + DropSize.Y
            local InOptions = MousePos.X >= OptPos.X and MousePos.X <= OptPos.X + OptSize.X and MousePos.Y >= OptPos.Y and MousePos.Y <= OptPos.Y + OptSize.Y
            if not InDropdown and not InOptions then OptionsFrame.Visible = false end
        end
    end))

    return DropdownFrame
end

function ArsenalKit:CreateKeybind(parent, text, defaultKey, callback)
    local KeybindFrame = Instance.new("Frame")
    KeybindFrame.Size = UDim2.new(1, 0, 0, 38)
    KeybindFrame.BackgroundColor3 = Theme.Glass
    KeybindFrame.BackgroundTransparency = .3
    KeybindFrame.BorderSizePixel = 0
    KeybindFrame.ZIndex = 6
    KeybindFrame.Parent = parent
    Corner(KeybindFrame, 10)
    Stroke(KeybindFrame, .82, 1)

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.55, 0, 1, 0)
    Label.Position = UDim2.fromOffset(14, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Theme.White
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 11
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.ZIndex = 7
    Label.Parent = KeybindFrame

    local KeyText = defaultKey and defaultKey.Name or "None"
    if typeof(KeyText) == "EnumItem" then KeyText = KeyText.Name end

    local Button = Instance.new("TextButton")
    Button.Size = UDim2.fromOffset(90, 26)
    Button.Position = UDim2.new(1, -106, 0.5, -13)
    Button.BackgroundColor3 = Theme.GlassLight
    Button.BackgroundTransparency = .2
    Button.Text = KeyText
    Button.TextColor3 = Theme.Cyan
    Button.Font = Enum.Font.GothamBold
    Button.TextSize = 10
    Button.BorderSizePixel = 0
    Button.AutoButtonColor = false
    Button.ZIndex = 7
    Button.Parent = KeybindFrame
    Corner(Button, 6)
    Stroke(Button, .6, 1)

    local CurrentKey = defaultKey
    local BindData = {Key = CurrentKey, Callback = callback}
    table.insert(ArsenalKit.Keybinds, BindData)

    local Binding = false
    Button.MouseButton1Click:Connect(function()
        if Binding then return end
        Binding = true
        Button.Text = "..."
        local Connection
        Connection = UserInputService.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.Keyboard then
                CurrentKey = Input.KeyCode
                Button.Text = Input.KeyCode.Name
            elseif Input.UserInputType == Enum.UserInputType.MouseButton1 then
                CurrentKey = Input.UserInputType; Button.Text = "LMB"
            elseif Input.UserInputType == Enum.UserInputType.MouseButton2 then
                CurrentKey = Input.UserInputType; Button.Text = "RMB"
            elseif Input.UserInputType == Enum.UserInputType.MouseButton3 then
                CurrentKey = Input.UserInputType; Button.Text = "MMB"
            end
            BindData.Key = CurrentKey
            Binding = false
            if Connection then Connection:Disconnect() end
        end)
    end)

    return KeybindFrame
end

function ArsenalKit:CreateButton(parent, text, callback)
    local ButtonFrame = Instance.new("Frame")
    ButtonFrame.Size = UDim2.new(1, 0, 0, 38)
    ButtonFrame.BackgroundTransparency = 1
    ButtonFrame.BorderSizePixel = 0
    ButtonFrame.Parent = parent

    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -12, 0, 32)
    Btn.Position = UDim2.fromOffset(6, 3)
    Btn.BackgroundColor3 = Theme.Blue
    Btn.BackgroundTransparency = .25
    Btn.Text = text
    Btn.TextColor3 = Theme.White
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 11
    Btn.BorderSizePixel = 0
    Btn.AutoButtonColor = false
    Btn.ZIndex = 7
    Btn.Parent = ButtonFrame
    Corner(Btn, 8)
    Stroke(Btn, .4, 1.5)

    Btn.MouseEnter:Connect(function() Tween(Btn, 0.2, {BackgroundTransparency = .1}):Play() end)
    Btn.MouseLeave:Connect(function() Tween(Btn, 0.2, {BackgroundTransparency = .25}):Play() end)
    Btn.MouseButton1Click:Connect(function() if callback then callback() end end)

    return ButtonFrame
end

-- Global keybind handler
AddConnection(UserInputService.InputBegan:Connect(function(Input, GameProcessed)
    if GameProcessed then return end
    for _, Bind in pairs(ArsenalKit.Keybinds) do
        local Match = false
        if typeof(Bind.Key) == "EnumItem" then
            if Bind.Key.EnumType == Enum.KeyCode and Input.KeyCode == Bind.Key then
                Match = true
            elseif Bind.Key.EnumType == Enum.UserInputType and Input.UserInputType == Bind.Key then
                Match = true
            end
        end
        if Match and Bind.Callback then Bind.Callback() end
    end
end))

--========================================================
-- PLAYER CARD
--========================================================

local PlayerCard = Instance.new("Frame")
PlayerCard.Size = UDim2.new(1, -18, 0, 67)
PlayerCard.Position = UDim2.new(0, 9, 1, -76)
PlayerCard.BackgroundColor3 = Theme.Glass
PlayerCard.BackgroundTransparency = .05
PlayerCard.BorderSizePixel = 0
PlayerCard.ZIndex = 6
PlayerCard.Parent = Sidebar
Corner(PlayerCard, 11)
Stroke(PlayerCard, .82, 2)

local Avatar = Instance.new("ImageLabel")
Avatar.Size = UDim2.fromOffset(36, 36)
Avatar.Position = UDim2.fromOffset(10, 15)
Avatar.BackgroundTransparency = 1
Avatar.ZIndex = 7
Avatar.Parent = PlayerCard
Corner(Avatar, 10)
Avatar.Image = Players:GetUserThumbnailAsync(Player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)

local Username = Instance.new("TextLabel")
Username.Size = UDim2.new(1, -56, 0, 18)
Username.Position = UDim2.fromOffset(54, 11)
Text(Username, Player.DisplayName, 9, Theme.White, true)
Username.ZIndex = 7
Username.Parent = PlayerCard

local Preview = Instance.new("TextLabel")
Preview.Size = UDim2.new(1, -56, 0, 15)
Preview.Position = UDim2.fromOffset(54, 31)
Text(Preview, "ARSENALKIT USER", 7, Theme.Cyan, true)
Preview.ZIndex = 7
Preview.Parent = PlayerCard

--========================================================
-- FOOTER
--========================================================

local Footer = Instance.new("Frame")
Footer.Size = UDim2.new(1, 0, 0, 25)
Footer.Position = UDim2.new(0, 0, 1, -25)
Footer.BackgroundTransparency = 1
Footer.ZIndex = 7
Footer.Parent = Content

local FooterLeft = Instance.new("TextLabel")
FooterLeft.Size = UDim2.fromOffset(180, 25)
FooterLeft.Position = UDim2.fromOffset(0, 0)
Text(FooterLeft, "●  ARSENALKIT ONLINE", 7, Theme.Cyan, true)
FooterLeft.TextYAlignment = Enum.TextYAlignment.Center
FooterLeft.ZIndex = 8
FooterLeft.Parent = Footer

local FooterRight = Instance.new("TextLabel")
FooterRight.Size = UDim2.fromOffset(220, 25)
FooterRight.Position = UDim2.new(1, -220, 0, 0)
Text(FooterRight, "ARSENALKIT  •  v2.1.0", 7, Theme.Muted, true)
FooterRight.TextXAlignment = Enum.TextXAlignment.Right
FooterRight.TextYAlignment = Enum.TextYAlignment.Center
FooterRight.ZIndex = 8
FooterRight.Parent = Footer

--========================================================
-- DRAGGING
--========================================================

local Dragging = false
local DragStart
local StartPosition

Header.InputBegan:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
        Dragging = true
        DragStart = Input.Position
        StartPosition = Main.Position
        Input.Changed:Connect(function()
            if Input.UserInputState == Enum.UserInputState.End then Dragging = false end
        end)
    end
end)

AddConnection(UserInputService.InputChanged:Connect(function(Input)
    if Dragging and Input.UserInputType == Enum.UserInputType.MouseMovement then
        local Delta = Input.Position - DragStart
        Main.Position = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + Delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y)
        OuterGlow.Position = UDim2.new(Main.Position.X.Scale, Main.Position.X.Offset - 30, Main.Position.Y.Scale, Main.Position.Y.Offset - 30)
        InnerGlow.Position = UDim2.new(Main.Position.X.Scale, Main.Position.X.Offset - 20, Main.Position.Y.Scale, Main.Position.Y.Offset - 20)
    end
end))

--========================================================
-- LOGO PULSE
--========================================================

task.spawn(function()
    while LogoGlow.Parent do
        Tween(LogoGlow, 1.5, {BackgroundTransparency = .76}, Enum.EasingStyle.Sine):Play()
        task.wait(1.5)
        Tween(LogoGlow, 1.5, {BackgroundTransparency = .9}, Enum.EasingStyle.Sine):Play()
        task.wait(1.5)
    end
end)

--========================================================
-- OPEN ANIMATION
--========================================================

local FinalSize = Main.Size
local FinalPosition = Main.Position
Main.Size = UDim2.fromOffset(790, 470)
Main.Position = UDim2.new(.5, -395, .5, -235)
Main.BackgroundTransparency = 1
OuterGlow.BackgroundTransparency = 1
InnerGlow.BackgroundTransparency = 1

Tween(Main, .55, {Size = FinalSize, Position = FinalPosition, BackgroundTransparency = .04}):Play()
Tween(OuterGlow, .55, {BackgroundTransparency = .94}):Play()
Tween(InnerGlow, .55, {BackgroundTransparency = .97}):Play()

--========================================================
-- RIGHTSHIFT TOGGLE
--========================================================

local UIVisible = true
AddConnection(UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.RightShift then
        UIVisible = not UIVisible
        Main.Visible = UIVisible
        OuterGlow.Visible = UIVisible
        InnerGlow.Visible = UIVisible
        Backdrop.Visible = UIVisible
    end
end))

--========================================================
-- MODULE LOADING
--========================================================

-- CHANGE THIS TO YOUR GITHUB RAW URL BASE
local BaseURL = "https://raw.githubusercontent.com/confessess/arsenal-script/main/modules/"

local ModuleList = {
    "world",
    "esp",
    "movement",
    "aimbot",  -- FIXED: was "combat", file is "aimbot.lua"
    "weapon",
    "misc"
}

local LoadedCount = 0

for _, moduleName in ipairs(ModuleList) do
    local success, err = pcall(function()
        local url = BaseURL .. moduleName .. ".lua?t=" .. tostring(tick())
        local source = game:HttpGet(url, true)
        if source and #source > 50 then
            local func = loadstring(source)
            if func then
                func()
                LoadedCount = LoadedCount + 1
                print("[ArsenalKit] Loaded module: " .. moduleName)
            else
                warn("[ArsenalKit] Failed to compile: " .. moduleName)
            end
        else
            warn("[ArsenalKit] Empty source: " .. moduleName)
        end
    end)
    if not success then
        warn("[ArsenalKit] Error loading " .. moduleName .. ": " .. tostring(err))
    end
end

print("[ArsenalKit] Loader initialized — " .. LoadedCount .. "/" .. #ModuleList .. " modules loaded")