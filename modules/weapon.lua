-- ArsenalKit ESP Module
-- Box, skeleton, name, health bar, tracers, chams

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local ArsenalKit = _G.ArsenalKit
if not ArsenalKit then return end
if ArsenalKit.Features.ESPLoaded then return end
ArsenalKit.Features.ESPLoaded = true

-- Settings
local Settings = {
    BoxESP = false,
    Skeleton = false,
    NameESP = false,
    HealthBar = false,
    Tracers = false,
    Chams = false,
    TeamCheck = true,
    MaxDistance = 2000
}

local ESPObjects = {}
local ESPConnection = nil

-- Create UI
local VisualsTab = ArsenalKit:CreateTab("Visuals")

ArsenalKit:CreateSection(VisualsTab, "ESP")
ArsenalKit:CreateToggle(VisualsTab, "Box ESP", false, function(state)
    Settings.BoxESP = state
end)

ArsenalKit:CreateToggle(VisualsTab, "Skeleton", false, function(state)
    Settings.Skeleton = state
end)

ArsenalKit:CreateToggle(VisualsTab, "Name ESP", false, function(state)
    Settings.NameESP = state
end)

ArsenalKit:CreateToggle(VisualsTab, "Health Bar", false, function(state)
    Settings.HealthBar = state
end)

ArsenalKit:CreateToggle(VisualsTab, "Tracers", false, function(state)
    Settings.Tracers = state
end)

ArsenalKit:CreateToggle(VisualsTab, "Chams", false, function(state)
    Settings.Chams = state
    for _, obj in pairs(ESPObjects) do
        if obj.Cham then
            obj.Cham.Enabled = state
        end
    end
end)

ArsenalKit:CreateToggle(VisualsTab, "Team Check", true, function(state)
    Settings.TeamCheck = state
end)

ArsenalKit:CreateSlider(VisualsTab, "Max Distance", 100, 5000, 2000, function(val)
    Settings.MaxDistance = val
end)

-- Drawing functions
local function NewDrawing(type, props)
    local obj = Drawing.new(type)
    for k, v in pairs(props or {}) do
        obj[k] = v
    end
    return obj
end

local function GetCharacter(player)
    return player.Character
end

local function GetHumanoid(character)
    return character:FindFirstChildOfClass("Humanoid")
end

local function IsTeammate(player)
    if not Settings.TeamCheck then return false end
    return LocalPlayer.Team and player.Team and LocalPlayer.Team == player.Team
end

local function IsAlive(character)
    local hum = GetHumanoid(character)
    return hum and hum.Health > 0
end

local function GetColor(player)
    if IsTeammate(player) then
        return Color3.fromRGB(0, 255, 140)
    else
        return Color3.fromRGB(255, 70, 90)
    end
end

local function GetHealthColor(health, maxHealth)
    local ratio = health / maxHealth
    return Color3.fromRGB(255 * (1 - ratio), 255 * ratio, 50)
end

-- Skeleton joints
local SkeletonJoints = {
    {"Head", "UpperTorso"},
    {"UpperTorso", "RightUpperArm"},
    {"RightUpperArm", "RightLowerArm"},
    {"RightLowerArm", "RightHand"},
    {"UpperTorso", "LeftUpperArm"},
    {"LeftUpperArm", "LeftLowerArm"},
    {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "LowerTorso"},
    {"LowerTorso", "RightUpperLeg"},
    {"RightUpperLeg", "RightLowerLeg"},
    {"RightLowerLeg", "RightFoot"},
    {"LowerTorso", "LeftUpperLeg"},
    {"LeftUpperLeg", "LeftLowerLeg"},
    {"LeftLowerLeg", "LeftFoot"}
}

-- Create ESP for player
local function CreateESP(player)
    if player == LocalPlayer then return end
    if ESPObjects[player] then return end

    local obj = {
        Player = player,
        Box = NewDrawing("Square", {Thickness = 1.5, Filled = false, Visible = false}),
        BoxOutline = NewDrawing("Square", {Thickness = 3, Filled = false, Visible = false, Color = Color3.fromRGB(0,0,0)}),
        Name = NewDrawing("Text", {Size = 14, Center = true, Outline = true, Visible = false}),
        HealthBar = NewDrawing("Square", {Thickness = 1, Filled = true, Visible = false}),
        HealthBarOutline = NewDrawing("Square", {Thickness = 1, Filled = false, Visible = false, Color = Color3.fromRGB(0,0,0)}),
        Tracer = NewDrawing("Line", {Thickness = 1.5, Visible = false}),
        TracerOutline = NewDrawing("Line", {Thickness = 3, Visible = false, Color = Color3.fromRGB(0,0,0)}),
        SkeletonLines = {},
        Cham = nil
    }

    -- Create skeleton lines
    for i = 1, #SkeletonJoints do
        obj.SkeletonLines[i] = {
            Line = NewDrawing("Line", {Thickness = 1.5, Visible = false}),
            Outline = NewDrawing("Line", {Thickness = 3, Visible = false, Color = Color3.fromRGB(0,0,0)})
        }
    end

    -- Create chams highlight
    local highlight = Instance.new("Highlight")
    highlight.FillColor = Color3.fromRGB(255, 0, 0)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.Enabled = false
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    obj.Cham = highlight

    ESPObjects[player] = obj
end

-- Remove ESP
local function RemoveESP(player)
    local obj = ESPObjects[player]
    if not obj then return end

    obj.Box:Remove()
    obj.BoxOutline:Remove()
    obj.Name:Remove()
    obj.HealthBar:Remove()
    obj.HealthBarOutline:Remove()
    obj.Tracer:Remove()
    obj.TracerOutline:Remove()

    for _, joint in pairs(obj.SkeletonLines) do
        joint.Line:Remove()
        joint.Outline:Remove()
    end

    if obj.Cham then
        obj.Cham:Destroy()
    end

    ESPObjects[player] = nil
end

-- Update ESP
local function UpdateESP()
    for player, obj in pairs(ESPObjects) do
        local character = GetCharacter(player)

        if not character or not IsAlive(character) or player.Parent == nil then
            obj.Box.Visible = false
            obj.BoxOutline.Visible = false
            obj.Name.Visible = false
            obj.HealthBar.Visible = false
            obj.HealthBarOutline.Visible = false
            obj.Tracer.Visible = false
            obj.TracerOutline.Visible = false
            for _, joint in pairs(obj.SkeletonLines) do
                joint.Line.Visible = false
                joint.Outline.Visible = false
            end
            if obj.Cham then
                obj.Cham.Enabled = false
                obj.Cham.Adornee = nil
            end
            continue
        end

        local humanoid = GetHumanoid(character)
        local hrp = character:FindFirstChild("HumanoidRootPart")
        local head = character:FindFirstChild("Head")

        if not hrp or not head then
            continue
        end

        local distance = (hrp.Position - Camera.CFrame.Position).Magnitude
        if distance > Settings.MaxDistance then
            obj.Box.Visible = false
            obj.BoxOutline.Visible = false
            obj.Name.Visible = false
            obj.HealthBar.Visible = false
            obj.HealthBarOutline.Visible = false
            obj.Tracer.Visible = false
            obj.TracerOutline.Visible = false
            for _, joint in pairs(obj.SkeletonLines) do
                joint.Line.Visible = false
                joint.Outline.Visible = false
            end
            if obj.Cham then
                obj.Cham.Enabled = false
            end
            continue
        end

        local color = GetColor(player)

        -- Update chams
        if obj.Cham then
            obj.Cham.Adornee = character
            obj.Cham.Enabled = Settings.Chams
            obj.Cham.FillColor = color
        end

        -- Get bounding box
        local torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
        if not torso then continue end

        local rootPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
        if not onScreen then
            obj.Box.Visible = false
            obj.BoxOutline.Visible = false
            obj.Name.Visible = false
            obj.HealthBar.Visible = false
            obj.HealthBarOutline.Visible = false
            obj.Tracer.Visible = false
            obj.TracerOutline.Visible = false
            for _, joint in pairs(obj.SkeletonLines) do
                joint.Line.Visible = false
                joint.Outline.Visible = false
            end
            continue
        end

        local headPos = Camera:WorldToViewportPoint(head.Position)
        local legPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))

        local boxHeight = math.abs(headPos.Y - legPos.Y)
        local boxWidth = boxHeight * 0.6

        local boxPos = Vector2.new(rootPos.X - boxWidth / 2, headPos.Y - boxHeight * 0.1)

        -- Box ESP
        if Settings.BoxESP then
            obj.Box.Size = Vector2.new(boxWidth, boxHeight)
            obj.Box.Position = boxPos
            obj.Box.Color = color
            obj.Box.Visible = true

            obj.BoxOutline.Size = Vector2.new(boxWidth, boxHeight)
            obj.BoxOutline.Position = boxPos
            obj.BoxOutline.Visible = true
        else
            obj.Box.Visible = false
            obj.BoxOutline.Visible = false
        end

        -- Name ESP
        if Settings.NameESP then
            obj.Name.Text = player.Name .. " [" .. math.floor(distance) .. "m]"
            obj.Name.Position = Vector2.new(rootPos.X, boxPos.Y - 18)
            obj.Name.Color = color
            obj.Name.Visible = true
        else
            obj.Name.Visible = false
        end

        -- Health bar
        if Settings.HealthBar and humanoid then
            local health = humanoid.Health
            local maxHealth = humanoid.MaxHealth
            local healthPercent = health / maxHealth

            local barWidth = 4
            local barHeight = boxHeight
            local barPos = Vector2.new(boxPos.X - barWidth - 4, boxPos.Y)

            obj.HealthBarOutline.Size = Vector2.new(barWidth + 2, barHeight + 2)
            obj.HealthBarOutline.Position = Vector2.new(barPos.X - 1, barPos.Y - 1)
            obj.HealthBarOutline.Visible = true

            obj.HealthBar.Size = Vector2.new(barWidth, barHeight * healthPercent)
            obj.HealthBar.Position = Vector2.new(barPos.X, barPos.Y + barHeight * (1 - healthPercent))
            obj.HealthBar.Color = GetHealthColor(health, maxHealth)
            obj.HealthBar.Visible = true
        else
            obj.HealthBar.Visible = false
            obj.HealthBarOutline.Visible = false
        end

        -- Tracers
        if Settings.Tracers then
            local screenBottom = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            obj.Tracer.From = screenBottom
            obj.Tracer.To = Vector2.new(rootPos.X, rootPos.Y)
            obj.Tracer.Color = color
            obj.Tracer.Visible = true

            obj.TracerOutline.From = screenBottom
            obj.TracerOutline.To = Vector2.new(rootPos.X, rootPos.Y)
            obj.TracerOutline.Visible = true
        else
            obj.Tracer.Visible = false
            obj.TracerOutline.Visible = false
        end

        -- Skeleton
        if Settings.Skeleton then
            for i, joint in ipairs(SkeletonJoints) do
                local partA = character:FindFirstChild(joint[1])
                local partB = character:FindFirstChild(joint[2])

                if partA and partB then
                    local posA, onA = Camera:WorldToViewportPoint(partA.Position)
                    local posB, onB = Camera:WorldToViewportPoint(partB.Position)

                    if onA and onB then
                        local lineData = obj.SkeletonLines[i]
                        lineData.Line.From = Vector2.new(posA.X, posA.Y)
                        lineData.Line.To = Vector2.new(posB.X, posB.Y)
                        lineData.Line.Color = color
                        lineData.Line.Visible = true

                        lineData.Outline.From = Vector2.new(posA.X, posA.Y)
                        lineData.Outline.To = Vector2.new(posB.X, posB.Y)
                        lineData.Outline.Visible = true
                    else
                        local lineData = obj.SkeletonLines[i]
                        lineData.Line.Visible = false
                        lineData.Outline.Visible = false
                    end
                else
                    local lineData = obj.SkeletonLines[i]
                    lineData.Line.Visible = false
                    lineData.Outline.Visible = false
                end
            end
        else
            for _, joint in pairs(obj.SkeletonLines) do
                joint.Line.Visible = false
                joint.Outline.Visible = false
            end
        end
    end
end

-- Player added/removed
Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(RemoveESP)

for _, player in pairs(Players:GetPlayers()) do
    CreateESP(player)
end

-- ESP loop
ESPConnection = RunService.RenderStepped:Connect(UpdateESP)
table.insert(ArsenalKit.Connections, ESPConnection)

print("[ArsenalKit] ESP module loaded")