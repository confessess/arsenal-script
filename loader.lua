-- ArsenalKit Modular Loader v3.0
-- Loader + UI Framework - loads modules from GitHub raw URLs

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

-- Clean up old
for _, gui in pairs(LocalPlayer:WaitForChild("PlayerGui"):GetChildren()) do
    if gui.Name == "ArsenalKit" then
        gui:Destroy()
    end
end

-- ArsenalKit API
getgenv().ArsenalKit = {
    Tabs = {},
    ActiveTab = nil,
    Keybinds = {},
    UI = {},
    BindMode = false,
    BindCallback = nil,
    Features = {},
    Connections = {}
}

local ArsenalKit = getgenv().ArsenalKit

-- Theme
local Theme = {
    Background = Color3.fromRGB(10, 14, 28),
    Surface = Color3.fromRGB(18, 24, 44),
    SurfaceHover = Color3.fromRGB(28, 36, 64),
    Accent = Color3.fromRGB(0, 210, 255),
    AccentSoft = Color3.fromRGB(0, 180, 220),
    Text = Color3.fromRGB(235, 245, 255),
    TextDim = Color3.fromRGB(140, 160, 190),
    Border = Color3.fromRGB(50, 130, 255),
    Positive = Color3.fromRGB(0, 255, 140),
    Negative = Color3.fromRGB(255, 70, 90),
    Track = Color3.fromRGB(35, 45, 70)
}

-- Utility
local function Create(class, props)
    local obj = Instance.new(class)
    for k, v in pairs(props) do
        if k ~= "Parent" then
            obj[k] = v
        end
    end
    if props.Parent then
        obj.Parent = props.Parent
    end
    return obj
end

local function Tween(obj, info, props)
    local tween = TweenService:Create(obj, info, props)
    tween:Play()
    return tween
end

-- Main ScreenGui
local ScreenGui = Create("ScreenGui", {
    Name = "ArsenalKit",
    Parent = LocalPlayer:WaitForChild("PlayerGui"),
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    DisplayOrder = 999999
})

ArsenalKit.UI.ScreenGui = ScreenGui

-- Main Frame
local MainFrame = Create("Frame", {
    Name = "MainFrame",
    Parent = ScreenGui,
    Size = UDim2.new(0, 620, 0, 440),
    Position = UDim2.new(0.5, -310, 0.5, -220),
    BackgroundColor3 = Theme.Background,
    BackgroundTransparency = 0.12,
    BorderSizePixel = 0,
    ClipsDescendants = true,
    Active = true
})

Create("UICorner", {
    Parent = MainFrame,
    CornerRadius = UDim.new(0, 16)
})

Create("UIStroke", {
    Parent = MainFrame,
    Color = Theme.Border,
    Thickness = 1.2,
    Transparency = 0.5
})

-- Animated glow
local Glow = Create("Frame", {
    Name = "Glow",
    Parent = MainFrame,
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundColor3 = Theme.Accent,
    BackgroundTransparency = 0.94,
    BorderSizePixel = 0,
    ZIndex = 0
})
Create("UICorner", {
    Parent = Glow,
    CornerRadius = UDim.new(0, 16)
})

local GlowGrad = Create("UIGradient", {
    Parent = Glow,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Theme.Accent),
        ColorSequenceKeypoint.new(0.5, Theme.Background),
        ColorSequenceKeypoint.new(1, Theme.AccentSoft)
    }),
    Rotation = 0,
    Transparency = NumberSequence.new(0.96)
})

spawn(function()
    local angle = 0
    while MainFrame and MainFrame.Parent do
        angle = (angle + 0.25) % 360
        GlowGrad.Rotation = angle
        RunService.RenderStepped:Wait()
    end
end)

-- Title Bar
local TitleBar = Create("Frame", {
    Name = "TitleBar",
    Parent = MainFrame,
    Size = UDim2.new(1, 0, 0, 42),
    BackgroundColor3 = Theme.Surface,
    BackgroundTransparency = 0.2,
    BorderSizePixel = 0
})

Create("UICorner", {
    Parent = TitleBar,
    CornerRadius = UDim.new(0, 16)
})

local TitleFix = Create("Frame", {
    Parent = TitleBar,
    Size = UDim2.new(1, 0, 0.5, 0),
    Position = UDim2.new(0, 0, 0.5, 0),
    BackgroundColor3 = Theme.Surface,
    BackgroundTransparency = 0.2,
    BorderSizePixel = 0
})

local TitleText = Create("TextLabel", {
    Parent = TitleBar,
    Size = UDim2.new(0.55, 0, 1, 0),
    Position = UDim2.new(0, 18, 0, 0),
    BackgroundTransparency = 1,
    Text = "ArsenalKit",
    TextColor3 = Theme.Text,
    Font = Enum.Font.SourceSans,
    TextSize = 20,
    TextXAlignment = Enum.TextXAlignment.Left
})

local VerBadge = Create("TextLabel", {
    Parent = TitleBar,
    Size = UDim2.new(0, 40, 0, 20),
    Position = UDim2.new(0, 130, 0.5, -10),
    BackgroundColor3 = Theme.Accent,
    BackgroundTransparency = 0.85,
    Text = "v3.0",
    TextColor3 = Theme.Accent,
    Font = Enum.Font.SourceSans,
    TextSize = 12,
    TextXAlignment = Enum.TextXAlignment.Center
})
Create("UICorner", {
    Parent = VerBadge,
    CornerRadius = UDim.new(0, 10)
})

local AccentLine = Create("Frame", {
    Parent = TitleBar,
    Size = UDim2.new(1, 0, 0, 2),
    Position = UDim2.new(0, 0, 1, -1),
    BackgroundColor3 = Theme.Accent,
    BackgroundTransparency = 0.35,
    BorderSizePixel = 0
})

-- Close button
local CloseBtn = Create("TextButton", {
    Parent = TitleBar,
    Size = UDim2.new(0, 32, 0, 32),
    Position = UDim2.new(1, -42, 0, 5),
    BackgroundColor3 = Theme.Negative,
    BackgroundTransparency = 0.75,
    Text = "x",
    TextColor3 = Theme.Text,
    Font = Enum.Font.SourceSans,
    TextSize = 18,
    BorderSizePixel = 0,
    AutoButtonColor = false
})
Create("UICorner", {
    Parent = CloseBtn,
    CornerRadius = UDim.new(0, 8)
})

CloseBtn.MouseEnter:Connect(function()
    Tween(CloseBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0.35})
end)
CloseBtn.MouseLeave:Connect(function()
    Tween(CloseBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0.75})
end)
CloseBtn.MouseButton1Click:Connect(function()
    Tween(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0)
    }).Completed:Connect(function()
        ScreenGui:Destroy()
        getgenv().ArsenalKit = nil
    end)
end)

-- Sidebar
local Sidebar = Create("Frame", {
    Name = "Sidebar",
    Parent = MainFrame,
    Size = UDim2.new(0, 150, 1, -42),
    Position = UDim2.new(0, 0, 0, 42),
    BackgroundColor3 = Theme.Surface,
    BackgroundTransparency = 0.35,
    BorderSizePixel = 0
})

Create("UICorner", {
    Parent = Sidebar,
    CornerRadius = UDim.new(0, 0, 0, 16)
})

-- Content area
local Content = Create("Frame", {
    Name = "Content",
    Parent = MainFrame,
    Size = UDim2.new(1, -150, 1, -42),
    Position = UDim2.new(0, 150, 0, 42),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ClipsDescendants = true
})

-- Tab indicator
local TabGlow = Create("Frame", {
    Parent = Sidebar,
    Size = UDim2.new(0, 4, 0, 32),
    Position = UDim2.new(0, 8, 0, 12),
    BackgroundColor3 = Theme.Accent,
    BorderSizePixel = 0
})
Create("UICorner", {
    Parent = TabGlow,
    CornerRadius = UDim.new(0, 2)
})
Create("UIStroke", {
    Parent = TabGlow,
    Color = Theme.Accent,
    Thickness = 2,
    Transparency = 0.4
})

-- Draggable
local dragging, dragStart, startPos
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- Open animation
MainFrame.Size = UDim2.new(0, 0, 0, 0)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
Tween(MainFrame, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Size = UDim2.new(0, 620, 0, 440),
    Position = UDim2.new(0.5, -310, 0.5, -220)
})

-- Toggle UI
local UIVisible = true
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.RightShift then
        UIVisible = not UIVisible
        if UIVisible then
            MainFrame.Visible = true
            Tween(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 620, 0, 440)
            })
        else
            Tween(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Size = UDim2.new(0, 0, 0, 0)
            }).Completed:Connect(function()
                MainFrame.Visible = false
            end)
        end
    end
end)

-- Create Tab
function ArsenalKit:CreateTab(name)
    local tabIndex = #ArsenalKit.Tabs

    local tabBtn = Create("Frame", {
        Parent = Sidebar,
        Size = UDim2.new(1, -20, 0, 36),
        Position = UDim2.new(0, 10, 0, 12 + (tabIndex * 44)),
        BackgroundColor3 = Theme.Surface,
        BackgroundTransparency = 1,
        BorderSizePixel = 0
    })
    Create("UICorner", {
        Parent = tabBtn,
        CornerRadius = UDim.new(0, 10)
    })

    local tabText = Create("TextLabel", {
        Parent = tabBtn,
        Size = UDim2.new(1, -16, 1, 0),
        Position = UDim2.new(0, 14, 0, 0),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = Theme.TextDim,
        Font = Enum.Font.SourceSans,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local clickZone = Create("TextButton", {
        Parent = tabBtn,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        BorderSizePixel = 0
    })

    local tabContent = Create("ScrollingFrame", {
        Parent = Content,
        Size = UDim2.new(1, -14, 1, -14),
        Position = UDim2.new(0, 7, 0, 7),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Visible = false
    })

    local layout = Create("UIListLayout", {
        Parent = tabContent,
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder
    })

    Create("UIPadding", {
        Parent = tabContent,
        PaddingLeft = UDim.new(0, 6),
        PaddingRight = UDim.new(0, 6),
        PaddingTop = UDim.new(0, 6),
        PaddingBottom = UDim.new(0, 6)
    })

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tabContent.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 12)
    end)

    local tab = {
        Name = name,
        Button = tabBtn,
        TextLabel = tabText,
        Content = tabContent,
        Layout = layout,
        Index = tabIndex
    }
    table.insert(ArsenalKit.Tabs, tab)

    clickZone.MouseButton1Click:Connect(function()
        ArsenalKit:SwitchTab(tab)
    end)

    clickZone.MouseEnter:Connect(function()
        if ArsenalKit.ActiveTab ~= tab then
            Tween(tabBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0.5})
            Tween(tabText, TweenInfo.new(0.2), {TextColor3 = Theme.Text})
        end
    end)

    clickZone.MouseLeave:Connect(function()
        if ArsenalKit.ActiveTab ~= tab then
            Tween(tabBtn, TweenInfo.new(0.2), {BackgroundTransparency = 1})
            Tween(tabText, TweenInfo.new(0.2), {TextColor3 = Theme.TextDim})
        end
    end)

    if #ArsenalKit.Tabs == 1 then
        ArsenalKit:SwitchTab(tab)
    end

    return tabContent
end

-- Switch Tab
function ArsenalKit:SwitchTab(targetTab)
    for _, tab in pairs(ArsenalKit.Tabs) do
        tab.Content.Visible = false
        Tween(tab.Button, TweenInfo.new(0.2), {BackgroundTransparency = 1})
        Tween(tab.TextLabel, TweenInfo.new(0.2), {TextColor3 = Theme.TextDim})
    end

    ArsenalKit.ActiveTab = targetTab
    targetTab.Content.Visible = true
    Tween(targetTab.Button, TweenInfo.new(0.25), {BackgroundTransparency = 0.4})
    Tween(targetTab.TextLabel, TweenInfo.new(0.25), {TextColor3 = Theme.Text})

    local btnPos = targetTab.Button.Position
    Tween(TabGlow, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.new(0, 8, 0, btnPos.Y.Offset + 2),
        Size = UDim2.new(0, 4, 0, 32)
    })
end

-- Create Section
function ArsenalKit:CreateSection(parent, text)
    local section = Create("Frame", {
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 28),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        LayoutOrder = #parent:GetChildren()
    })

    Create("TextLabel", {
        Parent = section,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Theme.Accent,
        Font = Enum.Font.SourceSans,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    Create("Frame", {
        Parent = section,
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, -2),
        BackgroundColor3 = Theme.Accent,
        BackgroundTransparency = 0.6,
        BorderSizePixel = 0
    })

    return section
end

-- Create Toggle
function ArsenalKit:CreateToggle(parent, text, default, callback)
    local toggle = Create("Frame", {
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 38),
        BackgroundColor3 = Theme.Surface,
        BackgroundTransparency = 0.55,
        BorderSizePixel = 0,
        LayoutOrder = #parent:GetChildren()
    })
    Create("UICorner", {
        Parent = toggle,
        CornerRadius = UDim.new(0, 10)
    })

    Create("TextLabel", {
        Parent = toggle,
        Size = UDim2.new(0.6, 0, 1, 0),
        Position = UDim2.new(0, 14, 0, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Theme.Text,
        Font = Enum.Font.SourceSans,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local btn = Create("TextButton", {
        Parent = toggle,
        Size = UDim2.new(0, 50, 0, 26),
        Position = UDim2.new(1, -62, 0.5, -13),
        BackgroundColor3 = default and Theme.Positive or Theme.Negative,
        Text = "",
        BorderSizePixel = 0,
        AutoButtonColor = false
    })
    Create("UICorner", {
        Parent = btn,
        CornerRadius = UDim.new(0, 13)
    })

    local knob = Create("Frame", {
        Parent = btn,
        Size = UDim2.new(0, 22, 0, 22),
        Position = default and UDim2.new(1, -24, 0.5, -11) or UDim2.new(0, 2, 0.5, -11),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0
    })
    Create("UICorner", {
        Parent = knob,
        CornerRadius = UDim.new(0, 11)
    })

    local state = default

    local function update()
        state = not state
        local targetColor = state and Theme.Positive or Theme.Negative
        local targetPos = state and UDim2.new(1, -24, 0.5, -11) or UDim2.new(0, 2, 0.5, -11)

        Tween(btn, TweenInfo.new(0.25), {BackgroundColor3 = targetColor})
        Tween(knob, TweenInfo.new(0.25), {Position = targetPos})

        if callback then
            callback(state)
        end
    end

    btn.MouseButton1Click:Connect(update)

    return {
        Frame = toggle,
        GetState = function() return state end,
        SetState = function(newState)
            if state ~= newState then update() end
        end
    }
end

-- Create Slider
function ArsenalKit:CreateSlider(parent, text, min, max, default, callback)
    local slider = Create("Frame", {
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 56),
        BackgroundColor3 = Theme.Surface,
        BackgroundTransparency = 0.55,
        BorderSizePixel = 0,
        LayoutOrder = #parent:GetChildren()
    })
    Create("UICorner", {
        Parent = slider,
        CornerRadius = UDim.new(0, 10)
    })

    Create("TextLabel", {
        Parent = slider,
        Size = UDim2.new(0.55, 0, 0, 24),
        Position = UDim2.new(0, 14, 0, 6),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Theme.Text,
        Font = Enum.Font.SourceSans,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local valueLabel = Create("TextLabel", {
        Parent = slider,
        Size = UDim2.new(0.35, 0, 0, 24),
        Position = UDim2.new(0.6, 0, 0, 6),
        BackgroundTransparency = 1,
        Text = tostring(default),
        TextColor3 = Theme.Accent,
        Font = Enum.Font.SourceSans,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Right
    })

    local track = Create("Frame", {
        Parent = slider,
        Size = UDim2.new(1, -28, 0, 5),
        Position = UDim2.new(0, 14, 0, 36),
        BackgroundColor3 = Theme.Track,
        BorderSizePixel = 0
    })
    Create("UICorner", {
        Parent = track,
        CornerRadius = UDim.new(0, 3)
    })

    local fill = Create("Frame", {
        Parent = track,
        Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0
    })
    Create("UICorner", {
        Parent = fill,
        CornerRadius = UDim.new(0, 3)
    })

    local knob = Create("Frame", {
        Parent = track,
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new((default - min) / (max - min), -8, 0.5, -8),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0
    })
    Create("UICorner", {
        Parent = knob,
        CornerRadius = UDim.new(0, 8)
    })

    local dragging = false

    local function setValue(input)
        local pos = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local val = math.floor(min + (max - min) * pos)

        fill.Size = UDim2.new(pos, 0, 1, 0)
        knob.Position = UDim2.new(pos, -8, 0.5, -8)
        valueLabel.Text = tostring(val)

        if callback then
            callback(val)
        end
    end

    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            setValue(input)
            dragging = true
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            setValue(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    return slider
end

-- Create Dropdown
function ArsenalKit:CreateDropdown(parent, text, options, default, callback)
    local dropdown = Create("Frame", {
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 38),
        BackgroundColor3 = Theme.Surface,
        BackgroundTransparency = 0.55,
        BorderSizePixel = 0,
        LayoutOrder = #parent:GetChildren(),
        ClipsDescendants = false
    })
    Create("UICorner", {
        Parent = dropdown,
        CornerRadius = UDim.new(0, 10)
    })

    Create("TextLabel", {
        Parent = dropdown,
        Size = UDim2.new(0.5, 0, 1, 0),
        Position = UDim2.new(0, 14, 0, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Theme.Text,
        Font = Enum.Font.SourceSans,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local btn = Create("TextButton", {
        Parent = dropdown,
        Size = UDim2.new(0, 140, 0, 28),
        Position = UDim2.new(1, -154, 0.5, -14),
        BackgroundColor3 = Theme.Background,
        Text = default or options[1],
        TextColor3 = Theme.Text,
        Font = Enum.Font.SourceSans,
        TextSize = 14,
        BorderSizePixel = 0,
        AutoButtonColor = false
    })
    Create("UICorner", {
        Parent = btn,
        CornerRadius = UDim.new(0, 6)
    })

    Create("TextLabel", {
        Parent = btn,
        Size = UDim2.new(0, 20, 1, 0),
        Position = UDim2.new(1, -20, 0, 0),
        BackgroundTransparency = 1,
        Text = "v",
        TextColor3 = Theme.TextDim,
        Font = Enum.Font.SourceSans,
        TextSize = 12
    })

    local optionsFrame = Create("Frame", {
        Parent = ScreenGui,
        Size = UDim2.new(0, 140, 0, math.min(#options * 28, 168)),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Theme.Surface,
        BackgroundTransparency = 0.02,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 100
    })
    Create("UICorner", {
        Parent = optionsFrame,
        CornerRadius = UDim.new(0, 8)
    })
    Create("UIStroke", {
        Parent = optionsFrame,
        Color = Theme.Border,
        Thickness = 1,
        Transparency = 0.4
    })

    local optsScroll = Create("ScrollingFrame", {
        Parent = optionsFrame,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, #options * 28)
    })

    for i, opt in ipairs(options) do
        local optBtn = Create("TextButton", {
            Parent = optsScroll,
            Size = UDim2.new(1, 0, 0, 28),
            Position = UDim2.new(0, 0, 0, (i - 1) * 28),
            BackgroundColor3 = Theme.Surface,
            BackgroundTransparency = 1,
            Text = opt,
            TextColor3 = Theme.Text,
            Font = Enum.Font.SourceSans,
            TextSize = 14,
            BorderSizePixel = 0,
            AutoButtonColor = false,
            ZIndex = 100
        })

        optBtn.MouseEnter:Connect(function()
            Tween(optBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0.4})
        end)
        optBtn.MouseLeave:Connect(function()
            Tween(optBtn, TweenInfo.new(0.15), {BackgroundTransparency = 1})
        end)
        optBtn.MouseButton1Click:Connect(function()
            btn.Text = opt
            optionsFrame.Visible = false
            if callback then
                callback(opt)
            end
        end)
    end

    btn.MouseButton1Click:Connect(function()
        optionsFrame.Visible = not optionsFrame.Visible
        local absPos = btn.AbsolutePosition
        optionsFrame.Position = UDim2.new(0, absPos.X, 0, absPos.Y + 30)
    end)

    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and optionsFrame.Visible then
            local mousePos = UserInputService:GetMouseLocation()
            local dropPos = dropdown.AbsolutePosition
            local dropSize = dropdown.AbsoluteSize
            local optPos = optionsFrame.AbsolutePosition
            local optSize = optionsFrame.AbsoluteSize

            local inDropdown = mousePos.X >= dropPos.X and mousePos.X <= dropPos.X + dropSize.X and
                              mousePos.Y >= dropPos.Y and mousePos.Y <= dropPos.Y + dropSize.Y
            local inOptions = mousePos.X >= optPos.X and mousePos.X <= optPos.X + optSize.X and
                             mousePos.Y >= optPos.Y and mousePos.Y <= optPos.Y + optSize.Y

            if not inDropdown and not inOptions then
                optionsFrame.Visible = false
            end
        end
    end)

    return dropdown
end

-- Create Keybind
function ArsenalKit:CreateKeybind(parent, text, defaultKey, callback)
    local keybind = Create("Frame", {
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 38),
        BackgroundColor3 = Theme.Surface,
        BackgroundTransparency = 0.55,
        BorderSizePixel = 0,
        LayoutOrder = #parent:GetChildren()
    })
    Create("UICorner", {
        Parent = keybind,
        CornerRadius = UDim.new(0, 10)
    })

    Create("TextLabel", {
        Parent = keybind,
        Size = UDim2.new(0.6, 0, 1, 0),
        Position = UDim2.new(0, 14, 0, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Theme.Text,
        Font = Enum.Font.SourceSans,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local keyText = defaultKey or "None"
    if typeof(keyText) == "EnumItem" then
        keyText = keyText.Name
    end

    local btn = Create("TextButton", {
        Parent = keybind,
        Size = UDim2.new(0, 100, 0, 28),
        Position = UDim2.new(1, -114, 0.5, -14),
        BackgroundColor3 = Theme.Background,
        Text = keyText,
        TextColor3 = Theme.Accent,
        Font = Enum.Font.SourceSans,
        TextSize = 14,
        BorderSizePixel = 0,
        AutoButtonColor = false
    })
    Create("UICorner", {
        Parent = btn,
        CornerRadius = UDim.new(0, 6)
    })

    local currentKey = defaultKey

    local bindEntry = {
        Key = currentKey,
        Callback = callback,
        Button = btn
    }
    table.insert(ArsenalKit.Keybinds, bindEntry)

    btn.MouseButton1Click:Connect(function()
        btn.Text = "..."
        ArsenalKit.BindMode = true
        ArsenalKit.BindCallback = function(input)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                currentKey = input.KeyCode
                btn.Text = input.KeyCode.Name
            elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
                currentKey = input.UserInputType
                btn.Text = "LMB"
            elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
                currentKey = input.UserInputType
                btn.Text = "RMB"
            elseif input.UserInputType == Enum.UserInputType.MouseButton3 then
                currentKey = input.UserInputType
                btn.Text = "MMB"
            elseif input.UserInputType == Enum.UserInputType.MouseWheel then
                currentKey = input.UserInputType
                btn.Text = "Wheel"
            end
            bindEntry.Key = currentKey
            ArsenalKit.BindMode = false
            ArsenalKit.BindCallback = nil
        end
    end)

    return keybind
end

-- Create Button
function ArsenalKit:CreateButton(parent, text, callback)
    local btnFrame = Create("Frame", {
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 38),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        LayoutOrder = #parent:GetChildren()
    })

    local btn = Create("TextButton", {
        Parent = btnFrame,
        Size = UDim2.new(1, -12, 0, 32),
        Position = UDim2.new(0, 6, 0, 3),
        BackgroundColor3 = Theme.Accent,
        BackgroundTransparency = 0.25,
        Text = text,
        TextColor3 = Theme.Text,
        Font = Enum.Font.SourceSans,
        TextSize = 15,
        BorderSizePixel = 0,
        AutoButtonColor = false
    })
    Create("UICorner", {
        Parent = btn,
        CornerRadius = UDim.new(0, 8)
    })

    btn.MouseEnter:Connect(function()
        Tween(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.1})
    end)
    btn.MouseLeave:Connect(function()
        Tween(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.25})
    end)
    btn.MouseButton1Click:Connect(function()
        if callback then
            callback()
        end
    end)

    return btnFrame
end

-- Create Color Picker
function ArsenalKit:CreateColorPicker(parent, text, defaultColor, callback)
    local picker = Create("Frame", {
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 38),
        BackgroundColor3 = Theme.Surface,
        BackgroundTransparency = 0.55,
        BorderSizePixel = 0,
        LayoutOrder = #parent:GetChildren()
    })
    Create("UICorner", {
        Parent = picker,
        CornerRadius = UDim.new(0, 10)
    })

    Create("TextLabel", {
        Parent = picker,
        Size = UDim2.new(0.6, 0, 1, 0),
        Position = UDim2.new(0, 14, 0, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Theme.Text,
        Font = Enum.Font.SourceSans,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local colorBtn = Create("TextButton", {
        Parent = picker,
        Size = UDim2.new(0, 60, 0, 26),
        Position = UDim2.new(1, -74, 0.5, -13),
        BackgroundColor3 = defaultColor or Color3.fromRGB(255, 255, 255),
        Text = "",
        BorderSizePixel = 0,
        AutoButtonColor = false
    })
    Create("UICorner", {
        Parent = colorBtn,
        CornerRadius = UDim.new(0, 6)
    })

    local colors = {
        Color3.fromRGB(255, 0, 0), Color3.fromRGB(0, 255, 0), Color3.fromRGB(0, 0, 255),
        Color3.fromRGB(255, 255, 0), Color3.fromRGB(255, 0, 255), Color3.fromRGB(0, 255, 255),
        Color3.fromRGB(255, 255, 255), Color3.fromRGB(0, 0, 0), Color3.fromRGB(255, 128, 0),
        Color3.fromRGB(128, 0, 255), Color3.fromRGB(0, 210, 255), Color3.fromRGB(255, 0, 128)
    }
    local colorIndex = 1

    colorBtn.MouseButton1Click:Connect(function()
        colorIndex = (colorIndex % #colors) + 1
        local newColor = colors[colorIndex]
        Tween(colorBtn, TweenInfo.new(0.2), {BackgroundColor3 = newColor})
        if callback then
            callback(newColor)
        end
    end)

    return picker
end

-- Global input handler
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if ArsenalKit.BindMode and ArsenalKit.BindCallback then
        if input.UserInputType ~= Enum.UserInputType.MouseMovement then
            ArsenalKit.BindCallback(input)
        end
        return
    end

    if gameProcessed then return end

    for _, bind in pairs(ArsenalKit.Keybinds) do
        local match = false
        if typeof(bind.Key) == "EnumItem" then
            if bind.Key.EnumType == Enum.KeyCode and input.KeyCode == bind.Key then
                match = true
            elseif bind.Key.EnumType == Enum.UserInputType and input.UserInputType == bind.Key then
                match = true
            end
        end

        if match and bind.Callback then
            bind.Callback()
        end
    end
end)

-- Module loading
local BaseURL = "https://raw.githubusercontent.com/confessess/arsenal-script/main/modules/"
local ModuleList = {
    "aimbot",
    "esp",
    "weapon",
    "world",
    "movement",
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

print("[ArsenalKit] Loader initialized - " .. LoadedCount .. "/" .. #ModuleList .. " modules loaded")