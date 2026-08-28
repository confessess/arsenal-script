--// ArsenalKit Module: Aimbot v4
--// Features: Keybind aim, FOV Circle, Smoothing, Team Check, Wall Check, Sticky Target

local ArsenalKit = _G.ArsenalKit
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer

--// Prevent double-load
if ArsenalKit.Modules and ArsenalKit.Modules.Aimbot then return end
ArsenalKit.Modules = ArsenalKit.Modules or {}
ArsenalKit.Modules.Aimbot = true

--// Settings
local Settings = {
    Enabled = false,
    Keybind = Enum.KeyCode.Q,
    FOV = 120,
    Smoothing = 0.15,
    TeamCheck = true,
    WallCheck = true,
    AimPart = "Head",
    ShowFOV = true,
    StickyTarget = false
}

--// State
local CurrentTarget = nil
local TargetLockTimer = 0

--// FOV Circle
local FOVCircle = nil
local HasDrawing = false

if typeof(Drawing) == "table" and Drawing.new then
    local ok, circle = pcall(function()
        return Drawing.new("Circle")
    end)
    if ok and circle then
        FOVCircle = circle
        FOVCircle.Visible = false
        FOVCircle.Thickness = 1.5
        FOVCircle.Color = Color3.fromRGB(0, 170, 255)
        FOVCircle.Transparency = 0.7
        FOVCircle.Filled = false
        FOVCircle.NumSides = 64
        HasDrawing = true
    end
end

--// Utility: Is Alive
local function IsAlive(character)
    local hum = character:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

--// Utility: Wall Check (Raycast)
local function IsVisible(targetPart)
    if not Settings.WallCheck then return true end
    if not targetPart then return false end

    local origin = Camera.CFrame.Position
    local targetPos = targetPart.Position
    local direction = targetPos - origin
    local distance = direction.Magnitude

    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.IgnoreWater = true

    local result = Workspace:Raycast(origin, direction.Unit * distance, raycastParams)
    if result then
        return result.Instance:IsDescendantOf(targetPart.Parent)
    end
    return true
end

--// Utility: Get Aim Position
local function GetAimPosition(player, partName)
    local char = player.Character
    if not char then return nil end
    local part = char:FindFirstChild(partName or Settings.AimPart)
    if not part then return nil end
    return part.Position
end

--// Utility: Distance from mouse to player on screen
local function GetScreenDistance(player)
    local char = player.Character
    if not char then return math.huge end
    if not IsAlive(char) then return math.huge end

    local part = char:FindFirstChild(Settings.AimPart)
    if not part then return math.huge end

    if Settings.WallCheck and not IsVisible(part) then return math.huge end

    local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
    if not onScreen then return math.huge end

    local mousePos = UserInputService:GetMouseLocation()
    return (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
end

--// Utility: Get Closest Player to Mouse
local function GetClosestPlayer()
    local closest = nil
    local minDist = Settings.FOV

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if Settings.TeamCheck and player.Team == LocalPlayer.Team then continue end

        local dist = GetScreenDistance(player)
        if dist < minDist then
            minDist = dist
            closest = player
        end
    end

    return closest
end

--// Utility: Validate sticky target
local function ValidateTarget(player)
    if not player then return false end
    if not player.Character then return false end
    if not IsAlive(player.Character) then return false end
    if Settings.TeamCheck and player.Team == LocalPlayer.Team then return false end

    local dist = GetScreenDistance(player)
    if dist > Settings.FOV * 1.5 then return false end -- allow some leeway

    return true
end

--// Main Loop
RunService.RenderStepped:Connect(function()
    local mousePos = UserInputService:GetMouseLocation()

    -- Update FOV Circle
    if HasDrawing and FOVCircle then
        FOVCircle.Position = mousePos
        FOVCircle.Radius = Settings.FOV
        FOVCircle.Visible = Settings.ShowFOV
        FOVCircle.Color = Settings.Enabled and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(0, 170, 255)
    end

    -- Sticky target logic
    if Settings.StickyTarget and CurrentTarget then
        if not ValidateTarget(CurrentTarget) then
            CurrentTarget = nil
        end
    end

    -- Find target
    if not CurrentTarget or not Settings.StickyTarget then
        CurrentTarget = GetClosestPlayer()
    end

    -- Aim
    if Settings.Enabled and CurrentTarget then
        local pos = GetAimPosition(CurrentTarget)
        if pos then
            local screenPos = Camera:WorldToViewportPoint(pos)
            local targetPos = Vector2.new(screenPos.X, screenPos.Y)
            local delta = (targetPos - mousePos) * Settings.Smoothing
            if typeof(mousemoverel) == "function" then
                mousemoverel(delta.X, delta.Y)
            end
        end
    end
end)

--// Build UI
local Tab = ArsenalKit:CreateTab("Combat", "C")

ArsenalKit:CreateSection(Tab, "Aimbot")

ArsenalKit:CreateToggle(Tab, "Enabled", false, function(v)
    Settings.Enabled = v
end)

ArsenalKit:CreateKeybind(Tab, "Aim Key", Settings.Keybind, function(key, pressed)
    if pressed then
        Settings.Enabled = not Settings.Enabled
        print("[Aimbot] " .. (Settings.Enabled and "ON" or "OFF"))
    else
        Settings.Keybind = key
    end
end)

ArsenalKit:CreateDropdown(Tab, "Aim Part", {"Head", "Torso", "HumanoidRootPart"}, "Head", function(v)
    Settings.AimPart = v
end)

ArsenalKit:CreateSlider(Tab, "FOV", 10, 500, 120, function(v)
    Settings.FOV = v
end)

ArsenalKit:CreateSlider(Tab, "Smoothing", 1, 100, 15, function(v)
    Settings.Smoothing = v / 100
end)

ArsenalKit:CreateToggle(Tab, "Show FOV Circle", true, function(v)
    Settings.ShowFOV = v
end)

ArsenalKit:CreateToggle(Tab, "Sticky Target", false, function(v)
    Settings.StickyTarget = v
end)

ArsenalKit:CreateSection(Tab, "Filters")

ArsenalKit:CreateToggle(Tab, "Team Check", true, function(v)
    Settings.TeamCheck = v
end)

ArsenalKit:CreateToggle(Tab, "Wall Check", true, function(v)
    Settings.WallCheck = v
end)

print("[ArsenalKit] Aimbot v4 loaded")