--// ArsenalKit Loader v5 - Clean & Simple
local BASE_URL = "https://raw.githubusercontent.com/confessess/arsenal-script/main"

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--// Colors
local Colors = {
    BG = Color3.fromRGB(20, 25, 35),
    Surface = Color3.fromRGB(30, 38, 52),
    SurfaceHover = Color3.fromRGB(40, 52, 72),
    Accent = Color3.fromRGB(0, 170, 255),
    AccentDark = Color3.fromRGB(0, 130, 200),
    Text = Color3.fromRGB(240, 245, 255),
    TextDim = Color3.fromRGB(150, 165, 190),
    ToggleOn = Color3.fromRGB(0, 210, 100),
    ToggleOff = Color3.fromRGB(55, 65, 85),
    Error = Color3.fromRGB(220, 60, 60)
}

--// Registry
local ArsenalKit = {
    Tabs = {},
    Colors = Colors,
    Tween = function(obj, props, dur)
        TweenService:Create(obj, TweenInfo.new(dur or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
    end
}
_G.ArsenalKit = ArsenalKit

--// Cleanup old
for _, gui in ipairs(PlayerGui:GetChildren()) do
    if gui.Name == "ArsenalKit" then gui:Destroy() end
end

--// Fetch
local function FetchModule(name)
    local url = BASE_URL .. "/modules/" .. name .. ".lua"
    local ok, result = pcall(function() return game:HttpGet(url, true) end)
    if ok and result and #result > 50 then return result end
    warn("[ArsenalKit] Failed: " .. name)
    return nil
end

local function LoadModule(name)
    local src = FetchModule(name)
    if not src then return false end
    local ok, err = pcall(function() loadstring(src)() end)
    if ok then print("[ArsenalKit] Loaded: " .. name) return true end
    warn("[ArsenalKit] Error " .. name .. ": " .. tostring(err))
    return false
end

--// ==========================
--// UI
--// ==========================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ArsenalKit"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999999
ScreenGui.Parent = PlayerGui

-- Main container
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 520, 0, 340)
Main.Position = UDim2.new(0.5, -260, 0.5, -170)
Main.BackgroundColor3 = Colors.BG
Main.BorderSizePixel = 0
Main.Parent = ScreenGui

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)

-- Shadow
local Shadow = Instance.new("ImageLabel")
Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
Shadow.Position = UDim2.new(0.5, 0, 0.5, 4)
Shadow.Size = UDim2.new(1, 40, 1, 40)
Shadow.BackgroundTransparency = 1
Shadow.Image = "rbxassetid://5554236805"
Shadow.ImageColor3 = Color3.new(0, 0, 0)
Shadow.ImageTransparency = 0.6
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(23, 23, 277, 277)
Shadow.ZIndex = 0
Shadow.Parent = Main

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 36)
TitleBar.BackgroundColor3 = Colors.Surface
TitleBar.BorderSizePixel = 0
TitleBar.ZIndex = 2
TitleBar.Parent = Main

Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 8)

local TitleText = Instance.new("TextLabel")
TitleText.Text = "ARSENAL KIT  v5"
TitleText.Size = UDim2.new(1, -80, 1, 0)
TitleText.Position = UDim2.new(0, 14, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.TextColor3 = Colors.Text
TitleText.Font = Enum.Font.SourceSans
TitleText.TextSize = 14
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.ZIndex = 3
TitleText.Parent = TitleBar

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0, 120, 0, 36)
StatusLabel.Position = UDim2.new(1, -160, 0, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Loading..."
StatusLabel.TextColor3 = Colors.Accent
StatusLabel.Font = Enum.Font.SourceSans
StatusLabel.TextSize = 12
StatusLabel.TextXAlignment = Enum.TextXAlignment.Right
StatusLabel.ZIndex = 3
StatusLabel.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 26, 0, 26)
CloseBtn.Position = UDim2.new(1, -32, 0, 5)
CloseBtn.BackgroundColor3 = Colors.Error
CloseBtn.Text = "x"
CloseBtn.TextColor3 = Colors.Text
CloseBtn.Font = Enum.Font.SourceSans
CloseBtn.TextSize = 16
CloseBtn.BorderSizePixel = 0
CloseBtn.ZIndex = 3
CloseBtn.Parent = TitleBar

Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
    _G.ArsenalKit = nil
end)

-- Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 125, 1, -36)
Sidebar.Position = UDim2.new(0, 0, 0, 36)
Sidebar.BackgroundColor3 = Colors.Surface
Sidebar.BorderSizePixel = 0
Sidebar.ZIndex = 2
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

-- Content
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -125, 1, -36)
Content.Position = UDim2.new(0, 125, 0, 36)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.ZIndex = 2
Content.Parent = Main

local ActiveTab = nil
local ActiveTabBtn = nil

--// Create Tab
function ArsenalKit:CreateTab(name, icon)
    if ArsenalKit.Tabs[name] then return ArsenalKit.Tabs[name] end

    local TabBtn = Instance.new("TextButton")
    TabBtn.Name = name
    TabBtn.Size = UDim2.new(1, 0, 0, 30)
    TabBtn.BackgroundColor3 = Colors.Surface
    TabBtn.Text = "  [" .. (icon or ">") .. "]  " .. name
    TabBtn.TextColor3 = Colors.TextDim
    TabBtn.Font = Enum.Font.SourceSans
    TabBtn.TextSize = 13
    TabBtn.TextXAlignment = Enum.TextXAlignment.Left
    TabBtn.BorderSizePixel = 0
    TabBtn.AutoButtonColor = false
    TabBtn.ZIndex = 3
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
    TabPage.ZIndex = 2
    TabPage.Parent = Content

    local List = Instance.new("UIListLayout")
    List.Padding = UDim.new(0, 6)
    List.SortOrder = Enum.SortOrder.LayoutOrder
    List.Parent = TabPage

    local Pad = Instance.new("UIPadding")
    Pad.PaddingTop = UDim.new(0, 4)
    Pad.PaddingBottom = UDim.new(0, 4)
    Pad.Parent = TabPage

    TabBtn.MouseEnter:Connect(function()
        if ActiveTab ~= TabPage then
            ArsenalKit.Tween(TabBtn, {BackgroundColor3 = Colors.SurfaceHover}, 0.15)
        end
    end)

    TabBtn.MouseLeave:Connect(function()
        if ActiveTab ~= TabPage then
            ArsenalKit.Tween(TabBtn, {BackgroundColor3 = Colors.Surface}, 0.15)
        end
    end)

    TabBtn.MouseButton1Click:Connect(function()
        if ActiveTab then
            ActiveTab.Visible = false
            if ActiveTabBtn then
                ArsenalKit.Tween(ActiveTabBtn, {BackgroundColor3 = Colors.Surface, TextColor3 = Colors.TextDim}, 0.15)
            end
        end
        ActiveTab = TabPage
        ActiveTabBtn = TabBtn
        TabPage.Visible = true
        ArsenalKit.Tween(TabBtn, {BackgroundColor3 = Colors.Accent, TextColor3 = Colors.Text}, 0.15)
    end)

    ArsenalKit.Tabs[name] = TabPage
    return TabPage
end

--// Create Section
function ArsenalKit:CreateSection(parent, text)
    local Label = Instance.new("TextLabel")
    Label.Text = text:upper()
    Label.Size = UDim2.new(1, 0, 0, 18)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Colors.Accent
    Label.Font = Enum.Font.SourceSans
    Label.TextSize = 11
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = parent
    return Label
end

--// Create Toggle
function ArsenalKit:CreateToggle(parent, label, default, callback)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 0, 34)
    Container.BackgroundColor3 = Colors.Surface
    Container.BorderSizePixel = 0
    Container.Parent = parent

    Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 6)

    local LabelObj = Instance.new("TextLabel")
    LabelObj.Text = label
    LabelObj.Size = UDim2.new(1, -60, 1, 0)
    LabelObj.Position = UDim2.new(0, 12, 0, 0)
    LabelObj.BackgroundTransparency = 1
    LabelObj.TextColor3 = Colors.Text
    LabelObj.Font = Enum.Font.SourceSans
    LabelObj.TextSize = 13
    LabelObj.TextXAlignment = Enum.TextXAlignment.Left
    LabelObj.Parent = Container

    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 40, 0, 20)
    ToggleBtn.Position = UDim2.new(1, -52, 0.5, -10)
    ToggleBtn.BackgroundColor3 = default and Colors.ToggleOn or Colors.ToggleOff
    ToggleBtn.Text = ""
    ToggleBtn.BorderSizePixel = 0
    ToggleBtn.AutoButtonColor = false
    ToggleBtn.Parent = Container

    Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)

    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 16, 0, 16)
    Knob.Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    Knob.BackgroundColor3 = Colors.Text
    Knob.BorderSizePixel = 0
    Knob.Parent = ToggleBtn

    Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

    local State = default
    ToggleBtn.MouseButton1Click:Connect(function()
        State = not State
        ArsenalKit.Tween(ToggleBtn, {BackgroundColor3 = State and Colors.ToggleOn or Colors.ToggleOff}, 0.2)
        ArsenalKit.Tween(Knob, {Position = State and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}, 0.2)
        if callback then callback(State) end
    end)

    return Container, function() return State end
end

--// Create Slider
function ArsenalKit:CreateSlider(parent, label, min, max, default, callback)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 0, 48)
    Container.BackgroundColor3 = Colors.Surface
    Container.BorderSizePixel = 0
    Container.Parent = parent

    Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 6)

    local LabelObj = Instance.new("TextLabel")
    LabelObj.Text = label
    LabelObj.Size = UDim2.new(1, -60, 0, 18)
    LabelObj.Position = UDim2.new(0, 12, 0, 4)
    LabelObj.BackgroundTransparency = 1
    LabelObj.TextColor3 = Colors.Text
    LabelObj.Font = Enum.Font.SourceSans
    LabelObj.TextSize = 13
    LabelObj.TextXAlignment = Enum.TextXAlignment.Left
    LabelObj.Parent = Container

    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Text = tostring(default)
    ValueLabel.Size = UDim2.new(0, 40, 0, 18)
    ValueLabel.Position = UDim2.new(1, -52, 0, 4)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.TextColor3 = Colors.Accent
    ValueLabel.Font = Enum.Font.SourceSans
    ValueLabel.TextSize = 13
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.Parent = Container

    local Track = Instance.new("Frame")
    Track.Size = UDim2.new(1, -24, 0, 4)
    Track.Position = UDim2.new(0, 12, 0, 30)
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
    Knob.Size = UDim2.new(0, 10, 0, 10)
    Knob.Position = UDim2.new((default - min) / (max - min), -5, 0.5, -5)
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
        Knob.Position = UDim2.new(pos, -5, 0.5, -5)
        if callback then callback(val) end
    end

    Knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = true end
    end)
    Track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = true Update(input) end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then Update(input) end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end
    end)

    return Container
end

--// Create Button
function ArsenalKit:CreateButton(parent, label, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 0, 32)
    Btn.BackgroundColor3 = Colors.Accent
    Btn.Text = label
    Btn.TextColor3 = Colors.Text
    Btn.Font = Enum.Font.SourceSans
    Btn.TextSize = 13
    Btn.BorderSizePixel = 0
    Btn.AutoButtonColor = false
    Btn.Parent = parent

    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)

    Btn.MouseEnter:Connect(function()
        ArsenalKit.Tween(Btn, {BackgroundColor3 = Colors.AccentDark}, 0.15)
    end)
    Btn.MouseLeave:Connect(function()
        ArsenalKit.Tween(Btn, {BackgroundColor3 = Colors.Accent}, 0.15)
    end)
    Btn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
    return Btn
end

--// Create Dropdown (NO CLIP)
function ArsenalKit:CreateDropdown(parent, label, options, default, callback)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 0, 34)
    Container.BackgroundColor3 = Colors.Surface
    Container.BorderSizePixel = 0
    Container.Parent = parent

    Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 6)

    local LabelObj = Instance.new("TextLabel")
    LabelObj.Text = label
    LabelObj.Size = UDim2.new(1, -120, 1, 0)
    LabelObj.Position = UDim2.new(0, 12, 0, 0)
    LabelObj.BackgroundTransparency = 1
    LabelObj.TextColor3 = Colors.Text
    LabelObj.Font = Enum.Font.SourceSans
    LabelObj.TextSize = 13
    LabelObj.TextXAlignment = Enum.TextXAlignment.Left
    LabelObj.Parent = Container

    local Selected = Instance.new("TextButton")
    Selected.Size = UDim2.new(0, 100, 0, 24)
    Selected.Position = UDim2.new(1, -112, 0.5, -12)
    Selected.BackgroundColor3 = Colors.BG
    Selected.Text = default or options[1] or "Select"
    Selected.TextColor3 = Colors.Text
    Selected.Font = Enum.Font.SourceSans
    Selected.TextSize = 12
    Selected.BorderSizePixel = 0
    Selected.AutoButtonColor = false
    Selected.Parent = Container

    Instance.new("UICorner", Selected).CornerRadius = UDim.new(0, 4)

    -- Overlay for dropdown options (parented to ScreenGui)
    local DropdownOverlay = Instance.new("Frame")
    DropdownOverlay.Name = "DropdownOverlay_" .. label
    DropdownOverlay.Size = UDim2.new(0, 100, 0, 0)
    DropdownOverlay.BackgroundColor3 = Colors.Surface
    DropdownOverlay.BorderSizePixel = 0
    DropdownOverlay.Visible = false
    DropdownOverlay.ZIndex = 100
    DropdownOverlay.Parent = ScreenGui

    Instance.new("UICorner", DropdownOverlay).CornerRadius = UDim.new(0, 6)

    local Opened = false

    local function CloseDropdown()
        Opened = false
        DropdownOverlay.Visible = false
        for _, c in ipairs(DropdownOverlay:GetChildren()) do
            if c:IsA("TextButton") then c:Destroy() end
        end
    end

    local function OpenDropdown()
        if Opened then CloseDropdown() return end
        Opened = true
        for _, c in ipairs(DropdownOverlay:GetChildren()) do
            if c:IsA("TextButton") then c:Destroy() end
        end
        local absPos = Selected.AbsolutePosition
        local absSize = Selected.AbsoluteSize
        DropdownOverlay.Position = UDim2.new(0, absPos.X, 0, absPos.Y + absSize.Y + 2)
        DropdownOverlay.Size = UDim2.new(0, absSize.X, 0, #options * 26)
        DropdownOverlay.Visible = true

        for i, opt in ipairs(options) do
            local OptBtn = Instance.new("TextButton")
            OptBtn.Size = UDim2.new(1, 0, 0, 26)
            OptBtn.Position = UDim2.new(0, 0, 0, (i-1)*26)
            OptBtn.BackgroundColor3 = Colors.BG
            OptBtn.Text = opt
            OptBtn.TextColor3 = Colors.TextDim
            OptBtn.Font = Enum.Font.SourceSans
            OptBtn.TextSize = 12
            OptBtn.BorderSizePixel = 0
            OptBtn.AutoButtonColor = false
            OptBtn.ZIndex = 101
            OptBtn.Parent = DropdownOverlay

            OptBtn.MouseEnter:Connect(function()
                ArsenalKit.Tween(OptBtn, {BackgroundColor3 = Colors.SurfaceHover, TextColor3 = Colors.Text}, 0.1)
            end)
            OptBtn.MouseLeave:Connect(function()
                ArsenalKit.Tween(OptBtn, {BackgroundColor3 = Colors.BG, TextColor3 = Colors.TextDim}, 0.1)
            end)
            OptBtn.MouseButton1Click:Connect(function()
                Selected.Text = opt
                CloseDropdown()
                if callback then callback(opt) end
            end)
        end
    end

    Selected.MouseButton1Click:Connect(OpenDropdown)

    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if not Opened then return end
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        local mp = input.Position
        local dp = DropdownOverlay.AbsolutePosition
        local ds = DropdownOverlay.AbsoluteSize
        local sp = Selected.AbsolutePosition
        local ss = Selected.AbsoluteSize
        local inDrop = mp.X >= dp.X and mp.X <= dp.X + ds.X and mp.Y >= dp.Y and mp.Y <= dp.Y + ds.Y
        local inSel = mp.X >= sp.X and mp.X <= sp.X + ss.X and mp.Y >= sp.Y and mp.Y <= sp.Y + ss.Y
        if not inDrop and not inSel then CloseDropdown() end
    end)

    return Container
end

--// Create Keybind (Keyboard + Mouse)
function ArsenalKit:CreateKeybind(parent, label, defaultKey, callback)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 0, 34)
    Container.BackgroundColor3 = Colors.Surface
    Container.BorderSizePixel = 0
    Container.Parent = parent

    Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 6)

    local LabelObj = Instance.new("TextLabel")
    LabelObj.Text = label
    LabelObj.Size = UDim2.new(1, -80, 1, 0)
    LabelObj.Position = UDim2.new(0, 12, 0, 0)
    LabelObj.BackgroundTransparency = 1
    LabelObj.TextColor3 = Colors.Text
    LabelObj.Font = Enum.Font.SourceSans
    LabelObj.TextSize = 13
    LabelObj.TextXAlignment = Enum.TextXAlignment.Left
    LabelObj.Parent = Container

    local KeyBtn = Instance.new("TextButton")
    KeyBtn.Size = UDim2.new(0, 60, 0, 24)
    KeyBtn.Position = UDim2.new(1, -72, 0.5, -12)
    KeyBtn.BackgroundColor3 = Colors.Accent
    KeyBtn.TextColor3 = Colors.Text
    KeyBtn.Font = Enum.Font.SourceSans
    KeyBtn.TextSize = 12
    KeyBtn.BorderSizePixel = 0
    KeyBtn.AutoButtonColor = false
    KeyBtn.Parent = Container

    Instance.new("UICorner", KeyBtn).CornerRadius = UDim.new(0, 4)

    local CurrentKey = nil
    local CurrentMouse = nil
    local Listening = false

    local function GetBindName()
        if CurrentKey and CurrentKey ~= Enum.KeyCode.Unknown then return CurrentKey.Name end
        if CurrentMouse then
            if CurrentMouse == Enum.UserInputType.MouseButton1 then return "LMB" end
            if CurrentMouse == Enum.UserInputType.MouseButton2 then return "RMB" end
            if CurrentMouse == Enum.UserInputType.MouseButton3 then return "MMB" end
            if CurrentMouse == Enum.UserInputType.MouseButton4 then return "MB4" end
            if CurrentMouse == Enum.UserInputType.MouseButton5 then return "MB5" end
        end
        return "NONE"
    end

    local function MatchesBind(input)
        if CurrentKey and input.KeyCode == CurrentKey then return true end
        if CurrentMouse and input.UserInputType == CurrentMouse then return true end
        return false
    end

    if typeof(defaultKey) == "EnumItem" then
        if defaultKey.EnumType == Enum.KeyCode then CurrentKey = defaultKey
        elseif defaultKey.EnumType == Enum.UserInputType then CurrentMouse = defaultKey end
    end
    KeyBtn.Text = GetBindName()

    KeyBtn.MouseButton1Click:Connect(function()
        if Listening then
            Listening = false
            KeyBtn.Text = GetBindName()
            KeyBtn.BackgroundColor3 = Colors.Accent
            return
        end
        Listening = true
        KeyBtn.Text = "..."
        KeyBtn.BackgroundColor3 = Colors.ToggleOn
    end)

    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
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
            KeyBtn.BackgroundColor3 = Colors.Accent
            Listening = false
            if callback then callback(CurrentKey or CurrentMouse) end
            return
        end
        if MatchesBind(input) then
            if callback then callback(CurrentKey or CurrentMouse, true) end
        end
    end)

    return Container
end

--// Dragging
local Dragging = false
local DragStart, StartPos

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        Dragging = true
        DragStart = input.Position
        StartPos = Main.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - DragStart
        Main.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + delta.X, StartPos.Y.Scale, StartPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end
end)

--// Toggle UI
UserInputService.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.RightShift then
        Main.Visible = not Main.Visible
    end
end)

--// ==========================
--// LOAD MODULES
--// ==========================

local ModuleList = {"aimbot", "esp", "weapon", "world", "movement", "misc"}
local LoadResults = {}

for _, modName in ipairs(ModuleList) do
    task.spawn(function()
        LoadResults[modName] = LoadModule(modName)
    end)
end

task.delay(2, function()
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
            end
        end
        ActiveTab = firstTab
        firstTab.Visible = true
        for _, btn in pairs(Sidebar:GetChildren()) do
            if btn:IsA("TextButton") and btn.Name .. "Page" == firstTab.Name then
                ActiveTabBtn = btn
                ArsenalKit.Tween(btn, {BackgroundColor3 = Colors.Accent, TextColor3 = Colors.Text}, 0.15)
            end
        end
    end
end)

print("[ArsenalKit] v5 loaded. RightShift to toggle.")