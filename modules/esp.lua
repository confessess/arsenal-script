--// ArsenalKit Module: ESP
--// Features: Box, Skeleton, Name, Health Bar, Tracers, Chams

local ArsenalKit = _G.ArsenalKit
--// Prevent double-load
if ArsenalKit.Modules and ArsenalKit.Modules.Esp then return end
ArsenalKit.Modules = ArsenalKit.Modules or {}
ArsenalKit.Modules.Esp = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer

--// Settings
local Settings = {
    BoxESP = false,
    Skeleton = false,
    NameESP = false,
    HealthBar = false,
    Tracers = false,
    Chams = false,
    TeamCheck = true,
    MaxDistance = 2000,
    BoxColor = Color3.fromRGB(255, 50, 50),
    SkeletonColor = Color3.fromRGB(0, 170, 255),
    TracerColor = Color3.fromRGB(255, 255, 255)
}

--// Drawing Objects Storage
local ESPObjects = {}

--// Utility: Create Drawing Objects
local function CreateESP(player)
    local objects = {
        Box = Drawing.new("Square"),
        BoxOutline = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        HealthBar = Drawing.new("Square"),
        HealthBarOutline = Drawing.new("Square"),
        Tracer = Drawing.new("Line"),
        Skeleton = {},
        Chams = nil
    }

    -- Box
    objects.Box.Visible = false
    objects.Box.Thickness = 1
    objects.Box.Color = Settings.BoxColor
    objects.Box.Transparency = 1
    objects.Box.Filled = false

    objects.BoxOutline.Visible = false
    objects.BoxOutline.Thickness = 3
    objects.BoxOutline.Color = Color3.new(0, 0, 0)
    objects.BoxOutline.Transparency = 1
    objects.BoxOutline.Filled = false

    -- Name
    objects.Name.Visible = false
    objects.Name.Size = 13
    objects.Name.Center = true
    objects.Name.Outline = true
    objects.Name.Color = Color3.new(1, 1, 1)
    objects.Name.Font = Drawing.Fonts.UI

    -- Health Bar
    objects.HealthBar.Visible = false
    objects.HealthBar.Thickness = 1
    objects.HealthBar.Filled = true
    objects.HealthBar.Transparency = 1

    objects.HealthBarOutline.Visible = false
    objects.HealthBarOutline.Thickness = 3
    objects.HealthBarOutline.Color = Color3.new(0, 0, 0)
    objects.HealthBarOutline.Filled = false
    objects.HealthBarOutline.Transparency = 1

    -- Tracer
    objects.Tracer.Visible = false
    objects.Tracer.Thickness = 1
    objects.Tracer.Color = Settings.TracerColor
    objects.Tracer.Transparency = 1

    -- Skeleton lines
    for i = 1, 12 do
        objects.Skeleton[i] = Drawing.new("Line")
        objects.Skeleton[i].Visible = false
        objects.Skeleton[i].Thickness = 1.5
        objects.Skeleton[i].Color = Settings.SkeletonColor
        objects.Skeleton[i].Transparency = 1
    end

    ESPObjects[player] = objects
    return objects
end

--// Utility: Remove ESP
local function RemoveESP(player)
    local objects = ESPObjects[player]
    if not objects then return end

    objects.Box:Remove()
    objects.BoxOutline:Remove()
    objects.Name:Remove()
    objects.HealthBar:Remove()
    objects.HealthBarOutline:Remove()
    objects.Tracer:Remove()
    for _, line in ipairs(objects.Skeleton) do
        line:Remove()
    end
    if objects.Chams then
        objects.Chams:Destroy()
    end

    ESPObjects[player] = nil
end

--// Utility: Get Character Parts
local function GetParts(character)
    local parts = {}
    local names = {"Head", "UpperTorso", "LowerTorso", "LeftUpperArm", "LeftLowerArm", "LeftHand",
        "RightUpperArm", "RightLowerArm", "RightHand", "LeftUpperLeg", "LeftLowerLeg", "LeftFoot",
        "RightUpperLeg", "RightLowerLeg", "RightFoot", "HumanoidRootPart"}

    for _, name in ipairs(names) do
        parts[name] = character:FindFirstChild(name)
    end
    return parts
end

--// Utility: World to Screen
local function W2S(pos)
    local screenPos, onScreen = Camera:WorldToViewportPoint(pos)
    return Vector2.new(screenPos.X, screenPos.Y), onScreen
end

--// Utility: Get Health Color
local function GetHealthColor(health, maxHealth)
    local ratio = health / maxHealth
    return Color3.fromRGB(255 * (1 - ratio), 255 * ratio, 0)
end

--// Skeleton Connections
local SkeletonConnections = {
    {"Head", "UpperTorso"},
    {"UpperTorso", "LeftUpperArm"},
    {"LeftUpperArm", "LeftLowerArm"},
    {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "RightUpperArm"},
    {"RightUpperArm", "RightLowerArm"},
    {"RightLowerArm", "RightHand"},
    {"UpperTorso", "LowerTorso"},
    {"LowerTorso", "LeftUpperLeg"},
    {"LeftUpperLeg", "LeftLowerLeg"},
    {"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso", "RightUpperLeg"},
    {"RightUpperLeg", "RightLowerLeg"},
    {"RightLowerLeg", "RightFoot"}
}

--// Update ESP
RunService.RenderStepped:Connect(function()
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end

        local objects = ESPObjects[player]
        local character = player.Character

        if not character or not character:FindFirstChild("HumanoidRootPart") or not character:FindFirstChild("Humanoid") then
            if objects then
                objects.Box.Visible = false
                objects.BoxOutline.Visible = false
                objects.Name.Visible = false
                objects.HealthBar.Visible = false
                objects.HealthBarOutline.Visible = false
                objects.Tracer.Visible = false
                for _, line in ipairs(objects.Skeleton) do
                    line.Visible = false
                end
                if objects.Chams then
                    objects.Chams.Enabled = false
                end
            end
            continue
        end

        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid.Health <= 0 then
            if objects then
                objects.Box.Visible = false
                objects.BoxOutline.Visible = false
                objects.Name.Visible = false
                objects.HealthBar.Visible = false
                objects.HealthBarOutline.Visible = false
                objects.Tracer.Visible = false
                for _, line in ipairs(objects.Skeleton) do
                    line.Visible = false
                end
                if objects.Chams then
                    objects.Chams.Enabled = false
                end
            end
            continue
        end

        if Settings.TeamCheck and player.Team == LocalPlayer.Team then
            if objects then
                objects.Box.Visible = false
                objects.BoxOutline.Visible = false
                objects.Name.Visible = false
                objects.HealthBar.Visible = false
                objects.HealthBarOutline.Visible = false
                objects.Tracer.Visible = false
                for _, line in ipairs(objects.Skeleton) do
                    line.Visible = false
                end
                if objects.Chams then
                    objects.Chams.Enabled = false
                end
            end
            continue
        end

        local hrp = character:FindFirstChild("HumanoidRootPart")
        local head = character:FindFirstChild("Head")
        if not hrp or not head then continue end

        local distance = (hrp.Position - Camera.CFrame.Position).Magnitude
        if distance > Settings.MaxDistance then
            if objects then
                objects.Box.Visible = false
                objects.BoxOutline.Visible = false
                objects.Name.Visible = false
                objects.HealthBar.Visible = false
                objects.HealthBarOutline.Visible = false
                objects.Tracer.Visible = false
                for _, line in ipairs(objects.Skeleton) do
                    line.Visible = false
                end
                if objects.Chams then
                    objects.Chams.Enabled = false
                end
            end
            continue
        end

        if not objects then
            objects = CreateESP(player)
        end

        local headPos, headOnScreen = W2S(head.Position + Vector3.new(0, 0.5, 0))
        local footPos, footOnScreen = W2S(hrp.Position - Vector3.new(0, 3, 0))

        if not headOnScreen or not footOnScreen then
            objects.Box.Visible = false
            objects.BoxOutline.Visible = false
            objects.Name.Visible = false
            objects.HealthBar.Visible = false
            objects.HealthBarOutline.Visible = false
            objects.Tracer.Visible = false
            for _, line in ipairs(objects.Skeleton) do
                line.Visible = false
            end
            if objects.Chams then
                objects.Chams.Enabled = false
            end
            continue
        end

        local boxHeight = footPos.Y - headPos.Y
        local boxWidth = boxHeight * 0.55
        local boxPos = Vector2.new(headPos.X - boxWidth / 2, headPos.Y)

        -- Box ESP
        if Settings.BoxESP then
            objects.Box.Size = Vector2.new(boxWidth, boxHeight)
            objects.Box.Position = boxPos
            objects.Box.Visible = true

            objects.BoxOutline.Size = Vector2.new(boxWidth, boxHeight)
            objects.BoxOutline.Position = boxPos
            objects.BoxOutline.Visible = true
        else
            objects.Box.Visible = false
            objects.BoxOutline.Visible = false
        end

        -- Name ESP
        if Settings.NameESP then
            objects.Name.Text = player.Name .. " [" .. math.floor(distance) .. "m]"
            objects.Name.Position = Vector2.new(headPos.X, headPos.Y - 18)
            objects.Name.Visible = true
        else
            objects.Name.Visible = false
        end

        -- Health Bar
        if Settings.HealthBar then
            local healthPercent = humanoid.Health / humanoid.MaxHealth
            local barHeight = boxHeight * healthPercent
            local barWidth = 4
            local barPos = Vector2.new(boxPos.X - barWidth - 3, boxPos.Y + boxHeight - barHeight)

            objects.HealthBar.Size = Vector2.new(barWidth, barHeight)
            objects.HealthBar.Position = barPos
            objects.HealthBar.Color = GetHealthColor(humanoid.Health, humanoid.MaxHealth)
            objects.HealthBar.Visible = true

            objects.HealthBarOutline.Size = Vector2.new(barWidth, boxHeight)
            objects.HealthBarOutline.Position = Vector2.new(boxPos.X - barWidth - 3, boxPos.Y)
            objects.HealthBarOutline.Visible = true
        else
            objects.HealthBar.Visible = false
            objects.HealthBarOutline.Visible = false
        end

        -- Tracers
        if Settings.Tracers then
            objects.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            objects.Tracer.To = Vector2.new(headPos.X, headPos.Y + boxHeight / 2)
            objects.Tracer.Visible = true
        else
            objects.Tracer.Visible = false
        end

        -- Skeleton
        if Settings.Skeleton then
            local parts = GetParts(character)
            local lineIdx = 1
            for _, conn in ipairs(SkeletonConnections) do
                local p1 = parts[conn[1]]
                local p2 = parts[conn[2]]
                if p1 and p2 and lineIdx <= #objects.Skeleton then
                    local pos1, on1 = W2S(p1.Position)
                    local pos2, on2 = W2S(p2.Position)
                    if on1 and on2 then
                        objects.Skeleton[lineIdx].From = pos1
                        objects.Skeleton[lineIdx].To = pos2
                        objects.Skeleton[lineIdx].Visible = true
                    else
                        objects.Skeleton[lineIdx].Visible = false
                    end
                    lineIdx = lineIdx + 1
                end
            end
            for i = lineIdx, #objects.Skeleton do
                objects.Skeleton[i].Visible = false
            end
        else
            for _, line in ipairs(objects.Skeleton) do
                line.Visible = false
            end
        end

        -- Chams
        if Settings.Chams then
            if not objects.Chams then
                local highlight = Instance.new("Highlight")
                highlight.FillColor = Settings.BoxColor
                highlight.OutlineColor = Color3.new(1, 1, 1)
                highlight.FillTransparency = 0.5
                highlight.OutlineTransparency = 0
                highlight.Adornee = character
                highlight.Parent = character
                objects.Chams = highlight
            end
            objects.Chams.Enabled = true
        elseif objects.Chams then
            objects.Chams.Enabled = false
        end
    end
end)

--// Cleanup on player leave
Players.PlayerRemoving:Connect(function(player)
    RemoveESP(player)
end)

--// Build UI
local Tab = ArsenalKit:CreateTab("Visuals", "👁")

ArsenalKit:CreateSection(Tab, "ESP")

ArsenalKit:CreateToggle(Tab, "Box ESP", false, function(v)
    Settings.BoxESP = v
end)

ArsenalKit:CreateToggle(Tab, "Skeleton", false, function(v)
    Settings.Skeleton = v
end)

ArsenalKit:CreateToggle(Tab, "Name ESP", false, function(v)
    Settings.NameESP = v
end)

ArsenalKit:CreateToggle(Tab, "Health Bar", false, function(v)
    Settings.HealthBar = v
end)

ArsenalKit:CreateToggle(Tab, "Tracers", false, function(v)
    Settings.Tracers = v
end)

ArsenalKit:CreateToggle(Tab, "Chams", false, function(v)
    Settings.Chams = v
end)

ArsenalKit:CreateToggle(Tab, "Team Check", true, function(v)
    Settings.TeamCheck = v
end)

ArsenalKit:CreateSlider(Tab, "Max Distance", 100, 5000, 2000, function(v)
    Settings.MaxDistance = v
end)

print("[ArsenalKit] ESP module loaded")