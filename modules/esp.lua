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

local function AddConnection(conn)
    table.insert(ArsenalKit.Connections, conn)
    return conn
end

local function NewDrawing(type, props)
    local success, obj = pcall(function() return Drawing.new(type) end)
    if success then
        for k, v in pairs(props or {}) do obj[k] = v end
        return obj
    end
    return nil
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
        return Color3.fromRGB(72, 230, 155)
    else
        return Color3.fromRGB(255, 78, 98)
    end
end

local function GetHealthColor(health, maxHealth)
    local ratio = math.clamp(health / maxHealth, 0, 1)
    return Color3.fromRGB(255 * (1 - ratio), 255 * ratio, 50)
end

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

local function CreateESP(player)
    if player == LocalPlayer then return end
    if ESPObjects[player] then return end
    local obj = {
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
    for i = 1, #SkeletonJoints do
        obj.SkeletonLines[i] = {
            Line = NewDrawing("Line", {Thickness = 1.5, Visible = false}),
            Outline = NewDrawing("Line", {Thickness = 3, Visible = false, Color = Color3.fromRGB(0,0,0)})
        }
    end
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

local function RemoveESP(player)
    local obj = ESPObjects[player]
    if not obj then return end
    if obj.Box then obj.Box:Remove() end
    if obj.BoxOutline then obj.BoxOutline:Remove() end
    if obj.Name then obj.Name:Remove() end
    if obj.HealthBar then obj.HealthBar:Remove() end
    if obj.HealthBarOutline then obj.HealthBarOutline:Remove() end
    if obj.Tracer then obj.Tracer:Remove() end
    if obj.TracerOutline then obj.TracerOutline:Remove() end
    for _, joint in pairs(obj.SkeletonLines) do
        if joint.Line then joint.Line:Remove() end
        if joint.Outline then joint.Outline:Remove() end
    end
    if obj.Cham then obj.Cham:Destroy() end
    ESPObjects[player] = nil
end

local function UpdateESP()
    for player, obj in pairs(ESPObjects) do
        local character = GetCharacter(player)
        if not character or not IsAlive(character) or player.Parent == nil then
            if obj.Box then obj.Box.Visible = false end
            if obj.BoxOutline then obj.BoxOutline.Visible = false end
            if obj.Name then obj.Name.Visible = false end
            if obj.HealthBar then obj.HealthBar.Visible = false end
            if obj.HealthBarOutline then obj.HealthBarOutline.Visible = false end
            if obj.Tracer then obj.Tracer.Visible = false end
            if obj.TracerOutline then obj.TracerOutline.Visible = false end
            for _, joint in pairs(obj.SkeletonLines) do
                if joint.Line then joint.Line.Visible = false end
                if joint.Outline then joint.Outline.Visible = false end
            end
            if obj.Cham then obj.Cham.Enabled = false; obj.Cham.Adornee = nil end
            continue
        end

        local humanoid = GetHumanoid(character)
        local hrp = character:FindFirstChild("HumanoidRootPart")
        local head = character:FindFirstChild("Head")
        if not hrp or not head then continue end

        local distance = (hrp.Position - Camera.CFrame.Position).Magnitude
        if distance > Settings.MaxDistance then
            if obj.Box then obj.Box.Visible = false end
            if obj.BoxOutline then obj.BoxOutline.Visible = false end
            if obj.Name then obj.Name.Visible = false end
            if obj.HealthBar then obj.HealthBar.Visible = false end
            if obj.HealthBarOutline then obj.HealthBarOutline.Visible = false end
            if obj.Tracer then obj.Tracer.Visible = false end
            if obj.TracerOutline then obj.TracerOutline.Visible = false end
            for _, joint in pairs(obj.SkeletonLines) do
                if joint.Line then joint.Line.Visible = false end
                if joint.Outline then joint.Outline.Visible = false end
            end
            if obj.Cham then obj.Cham.Enabled = false end
            continue
        end

        local color = GetColor(player)
        if obj.Cham then
            obj.Cham.Adornee = character
            obj.Cham.Enabled = Settings.Chams
            obj.Cham.FillColor = color
        end

        local rootPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
        if not onScreen then
            if obj.Box then obj.Box.Visible = false end
            if obj.BoxOutline then obj.BoxOutline.Visible = false end
            if obj.Name then obj.Name.Visible = false end
            if obj.HealthBar then obj.HealthBar.Visible = false end
            if obj.HealthBarOutline then obj.HealthBarOutline.Visible = false end
            if obj.Tracer then obj.Tracer.Visible = false end
            if obj.TracerOutline then obj.TracerOutline.Visible = false end
            for _, joint in pairs(obj.SkeletonLines) do
                if joint.Line then joint.Line.Visible = false end
                if joint.Outline then joint.Outline.Visible = false end
            end
            continue
        end

        local headPos = Camera:WorldToViewportPoint(head.Position)
        local legPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
        local boxHeight = math.abs(headPos.Y - legPos.Y)
        local boxWidth = boxHeight * 0.6
        local boxPos = Vector2.new(rootPos.X - boxWidth / 2, headPos.Y - boxHeight * 0.1)

        if Settings.BoxESP and obj.Box and obj.BoxOutline then
            obj.Box.Size = Vector2.new(boxWidth, boxHeight)
            obj.Box.Position = boxPos
            obj.Box.Color = color
            obj.Box.Visible = true
            obj.BoxOutline.Size = Vector2.new(boxWidth, boxHeight)
            obj.BoxOutline.Position = boxPos
            obj.BoxOutline.Visible = true
        else
            if obj.Box then obj.Box.Visible = false end
            if obj.BoxOutline then obj.BoxOutline.Visible = false end
        end

        if Settings.NameESP and obj.Name then
            obj.Name.Text = player.Name .. " [" .. math.floor(distance) .. "m]"
            obj.Name.Position = Vector2.new(rootPos.X, boxPos.Y - 18)
            obj.Name.Color = color
            obj.Name.Visible = true
        else
            if obj.Name then obj.Name.Visible = false end
        end

        if Settings.HealthBar and humanoid and obj.HealthBar and obj.HealthBarOutline then
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
            if obj.HealthBar then obj.HealthBar.Visible = false end
            if obj.HealthBarOutline then obj.HealthBarOutline.Visible = false end
        end

        if Settings.Tracers and obj.Tracer and obj.TracerOutline then
            local screenBottom = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            obj.Tracer.From = screenBottom
            obj.Tracer.To = Vector2.new(rootPos.X, rootPos.Y)
            obj.Tracer.Color = color
            obj.Tracer.Visible = true
            obj.TracerOutline.From = screenBottom
            obj.TracerOutline.To = Vector2.new(rootPos.X, rootPos.Y)
            obj.TracerOutline.Visible = true
        else
            if obj.Tracer then obj.Tracer.Visible = false end
            if obj.TracerOutline then obj.TracerOutline.Visible = false end
        end

        if Settings.Skeleton then
            for i, joint in ipairs(SkeletonJoints) do
                local partA = character:FindFirstChild(joint[1])
                local partB = character:FindFirstChild(joint[2])
                if partA and partB then
                    local posA, onA = Camera:WorldToViewportPoint(partA.Position)
                    local posB, onB = Camera:WorldToViewportPoint(partB.Position)
                    if onA and onB then
                        local lineData = obj.SkeletonLines[i]
                        if lineData and lineData.Line then
                            lineData.Line.From = Vector2.new(posA.X, posA.Y)
                            lineData.Line.To = Vector2.new(posB.X, posB.Y)
                            lineData.Line.Color = color
                            lineData.Line.Visible = true
                        end
                        if lineData and lineData.Outline then
                            lineData.Outline.From = Vector2.new(posA.X, posA.Y)
                            lineData.Outline.To = Vector2.new(posB.X, posB.Y)
                            lineData.Outline.Visible = true
                        end
                    else
                        local lineData = obj.SkeletonLines[i]
                        if lineData then
                            if lineData.Line then lineData.Line.Visible = false end
                            if lineData.Outline then lineData.Outline.Visible = false end
                        end
                    end
                else
                    local lineData = obj.SkeletonLines[i]
                    if lineData then
                        if lineData.Line then lineData.Line.Visible = false end
                        if lineData.Outline then joint.Outline.Visible = false end
                    end
                end
            end
        else
            for _, joint in pairs(obj.SkeletonLines) do
                if joint.Line then joint.Line.Visible = false end
                if joint.Outline then joint.Outline.Visible = false end
            end
        end
    end
end

AddConnection(Players.PlayerAdded:Connect(CreateESP))
AddConnection(Players.PlayerRemoving:Connect(RemoveESP))
for _, player in pairs(Players:GetPlayers()) do CreateESP(player) end

ESPConnection = AddConnection(RunService.RenderStepped:Connect(UpdateESP))

-- UI
local ESPTab = ArsenalKit:CreateTab("ESP", "◉")
local Section1 = ArsenalKit:CreateSection(ESPTab, "PLAYER ESP", "Player and world information overlays.")

ArsenalKit:CreateToggle(Section1, "Box ESP", false, function(state) Settings.BoxESP = state end)
ArsenalKit:CreateToggle(Section1, "Skeleton", false, function(state) Settings.Skeleton = state end)
ArsenalKit:CreateToggle(Section1, "Name ESP", false, function(state) Settings.NameESP = state end)
ArsenalKit:CreateToggle(Section1, "Health Bar", false, function(state) Settings.HealthBar = state end)
ArsenalKit:CreateToggle(Section1, "Tracers", false, function(state) Settings.Tracers = state end)
ArsenalKit:CreateToggle(Section1, "Chams", false, function(state)
    Settings.Chams = state
    for _, obj in pairs(ESPObjects) do
        if obj.Cham then obj.Cham.Enabled = state end
    end
end)
ArsenalKit:CreateToggle(Section1, "Team Check", true, function(state) Settings.TeamCheck = state end)
ArsenalKit:CreateSlider(Section1, "Max Distance", 100, 5000, 2000, function(val) Settings.MaxDistance = val end)

print("[ArsenalKit] ESP module loaded")