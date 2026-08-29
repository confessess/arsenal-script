-- ArsenalKit Aimbot Module
-- Silent aim, sticky target, wall check, team check, FOV circle

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

local ArsenalKit = _G.ArsenalKit
if not ArsenalKit then return end
if ArsenalKit.Features.AimbotLoaded then return end
ArsenalKit.Features.AimbotLoaded = true

-- Settings
local Settings = {
    Enabled = false,
    FOV = 120,
    Smoothing = 0.15,
    TargetPart = "Head",
    StickyTarget = false,
    WallCheck = true,
    TeamCheck = true,
    ShowFOV = true,
    AimKey = Enum.KeyCode.Q
}

local CurrentTarget = nil
local FOVCircle = nil
local AimbotConnection = nil

-- Create UI
local CombatTab = ArsenalKit:CreateTab("Combat")

ArsenalKit:CreateSection(CombatTab, "Aimbot")
ArsenalKit:CreateToggle(CombatTab, "Enabled", false, function(state)
    Settings.Enabled = state
end)

ArsenalKit:CreateToggle(CombatTab, "Show FOV Circle", true, function(state)
    Settings.ShowFOV = state
    if FOVCircle then
        FOVCircle.Visible = state and Settings.Enabled
    end
end)

ArsenalKit:CreateSlider(CombatTab, "FOV", 10, 360, 120, function(val)
    Settings.FOV = val
end)

ArsenalKit:CreateSlider(CombatTab, "Smoothing", 1, 100, 15, function(val)
    Settings.Smoothing = val / 100
end)

ArsenalKit:CreateDropdown(CombatTab, "Target Part", {"Head", "Torso", "HumanoidRootPart"}, "Head", function(choice)
    Settings.TargetPart = choice
end)

ArsenalKit:CreateKeybind(CombatTab, "Aim Key", Enum.KeyCode.Q, function()
    Settings.Enabled = not Settings.Enabled
end)

ArsenalKit:CreateToggle(CombatTab, "Sticky Target", false, function(state)
    Settings.StickyTarget = state
end)

ArsenalKit:CreateToggle(CombatTab, "Wall Check", true, function(state)
    Settings.WallCheck = state
end)

ArsenalKit:CreateToggle(CombatTab, "Team Check", true, function(state)
    Settings.TeamCheck = state
end)

-- Utility functions
local function GetCharacter(player)
    return player.Character
end

local function GetHumanoid(character)
    return character:FindFirstChildOfClass("Humanoid")
end

local function GetTeam(player)
    return player.Team
end

local function IsTeammate(player)
    if not Settings.TeamCheck then return false end
    local myTeam = GetTeam(LocalPlayer)
    local theirTeam = GetTeam(player)
    return myTeam and theirTeam and myTeam == theirTeam
end

local function IsAlive(character)
    local hum = GetHumanoid(character)
    return hum and hum.Health > 0
end

local function IsVisible(targetPart)
    if not Settings.WallCheck then return true end
    if not targetPart then return false end

    local origin = Camera.CFrame.Position
    local direction = (targetPart.Position - origin).Unit
    local distance = (targetPart.Position - origin).Magnitude

    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, targetPart.Parent}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

    local result = Workspace:Raycast(origin, direction * distance, raycastParams)
    return result == nil
end

local function GetTargetPart(character)
    if Settings.TargetPart == "Head" then
        return character:FindFirstChild("Head")
    elseif Settings.TargetPart == "Torso" then
        return character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
    else
        return character:FindFirstChild("HumanoidRootPart")
    end
end

local function GetDistance(pos)
    return (pos - Camera.CFrame.Position).Magnitude
end

local function GetScreenPosition(pos)
    local screenPos, onScreen = Camera:WorldToViewportPoint(pos)
    return Vector2.new(screenPos.X, screenPos.Y), onScreen
end

local function GetClosestPlayer()
    local closest = nil
    local closestDist = Settings.FOV
    local mousePos = UserInputService:GetMouseLocation()

    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end

        local character = GetCharacter(player)
        if not character then continue end

        if not IsAlive(character) then continue end
        if IsTeammate(player) then continue end

        local targetPart = GetTargetPart(character)
        if not targetPart then continue end

        local screenPos, onScreen = GetScreenPosition(targetPart.Position)
        if not onScreen then continue end

        local distFromMouse = (screenPos - mousePos).Magnitude
        if distFromMouse > Settings.FOV then continue end

        if not IsVisible(targetPart) then continue end

        if distFromMouse < closestDist then
            closest = player
            closestDist = distFromMouse
        end
    end

    return closest
end

local function GetStickyTarget()
    if not CurrentTarget then return nil end

    local character = GetCharacter(CurrentTarget)
    if not character then return nil end

    if not IsAlive(character) then return nil end
    if IsTeammate(CurrentTarget) then return nil end

    local targetPart = GetTargetPart(character)
    if not targetPart then return nil end

    local screenPos, onScreen = GetScreenPosition(targetPart.Position)
    if not onScreen then return nil end

    local mousePos = UserInputService:GetMouseLocation()
    local distFromMouse = (screenPos - mousePos).Magnitude
    if distFromMouse > Settings.FOV * 1.5 then return nil end

    if Settings.WallCheck and not IsVisible(targetPart) then return nil end

    return CurrentTarget
end

-- FOV Circle
local function CreateFOVCircle()
    local circle = Drawing.new("Circle")
    circle.Visible = false
    circle.Thickness = 1.5
    circle.Color = Color3.fromRGB(0, 210, 255)
    circle.Transparency = 0.7
    circle.Filled = false
    circle.NumSides = 64
    return circle
end

FOVCircle = CreateFOVCircle()

-- Aimbot loop
AimbotConnection = RunService.RenderStepped:Connect(function()
    -- Update FOV circle
    if FOVCircle then
        FOVCircle.Position = UserInputService:GetMouseLocation()
        FOVCircle.Radius = Settings.FOV
        FOVCircle.Visible = Settings.Enabled and Settings.ShowFOV
        FOVCircle.Color = Settings.Enabled and Color3.fromRGB(0, 255, 140) or Color3.fromRGB(0, 210, 255)
    end

    if not Settings.Enabled then
        CurrentTarget = nil
        return
    end

    -- Get target
    local target
    if Settings.StickyTarget and CurrentTarget then
        target = GetStickyTarget()
    end

    if not target then
        target = GetClosestPlayer()
        CurrentTarget = target
    end

    if not target then return end

    local character = GetCharacter(target)
    if not character then return end

    local targetPart = GetTargetPart(character)
    if not targetPart then return end

    -- Silent aim via mousemoverel
    local screenPos = Camera:WorldToViewportPoint(targetPart.Position)
    local mousePos = UserInputService:GetMouseLocation()
    local targetScreenPos = Vector2.new(screenPos.X, screenPos.Y)

    local delta = targetScreenPos - mousePos
    local smooth = Settings.Smoothing

    -- Apply smoothing
    local moveX = delta.X * smooth
    local moveY = delta.Y * smooth

    -- Use mousemoverel if available
    if mousemoverel then
        mousemoverel(moveX, moveY)
    else
        -- Fallback: rotate camera
        local currentCF = Camera.CFrame
        local targetCF = CFrame.new(currentCF.Position, targetPart.Position)
        Camera.CFrame = currentCF:Lerp(targetCF, smooth)
    end
end)

table.insert(ArsenalKit.Connections, AimbotConnection)

print("[ArsenalKit] Aimbot module loaded")