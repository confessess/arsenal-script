--// ArsenalKit Module: Aimbot
--// Features: Silent Aim, Auto-Aim, FOV Circle, Smoothing
--// Safe for all executors - checks every function before calling

local ArsenalKit = _G.ArsenalKit
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

--// Prevent double-load
if ArsenalKit.Modules and ArsenalKit.Modules.Aimbot then return end
ArsenalKit.Modules = ArsenalKit.Modules or {}
ArsenalKit.Modules.Aimbot = true

--// Settings
local Settings = {
    SilentAim = false,
    AutoAim = false,
    FOV = 120,
    Smoothing = 0.15,
    TeamCheck = true,
    WallCheck = false,
    AimPart = "Head"
}

--// FOV Circle (only if Drawing library exists)
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

--// Utility: Get Character
local function GetCharacter(player)
    return player.Character
end

--// Utility: Is Alive
local function IsAlive(character)
    local hum = character:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

--// Utility: Get Closest Player to Mouse
local function GetClosestPlayer()
    local closest = nil
    local minDist = Settings.FOV
    local mousePos = Vector2.new(Mouse.X, Mouse.Y + 36)

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if Settings.TeamCheck and player.Team == LocalPlayer.Team then continue end

        local char = GetCharacter(player)
        if not char then continue end
        if not IsAlive(char) then continue end

        local part = char:FindFirstChild(Settings.AimPart)
        if not part then continue end

        local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
        if not onScreen then continue end

        local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
        if dist < minDist then
            minDist = dist
            closest = player
        end
    end

    return closest
end

--// Utility: Get Aim Position
local function GetAimPosition(player)
    local char = GetCharacter(player)
    if not char then return nil end
    local part = char:FindFirstChild(Settings.AimPart)
    if not part then return nil end
    return part.Position
end

--// Silent Aim via __namecall hook (if supported)
local SilentAimTarget = nil
local NamecallHooked = false

--// Check if we have the required functions for silent aim
local CanHookNamecall = false
if typeof(hookmetamethod) == "function" and typeof(getnamecallmethod) == "function" then
    CanHookNamecall = true
end

if CanHookNamecall then
    local hookOk = pcall(function()
        local oldNamecall
        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            local args = {...}

            if Settings.SilentAim and method == "FireServer" and SilentAimTarget then
                local pos = GetAimPosition(SilentAimTarget)
                if pos then
                    for i, arg in ipairs(args) do
                        if typeof(arg) == "Vector3" then
                            args[i] = pos
                        elseif typeof(arg) == "CFrame" then
                            args[i] = CFrame.new(pos)
                        end
                    end
                end
            end

            return oldNamecall(self, unpack(args))
        end)
        NamecallHooked = true
    end)

    if not hookOk then
        warn("[Aimbot] Silent Aim hook failed - executor may not support hookmetamethod")
    end
end

--// Update silent aim target every frame
RunService.RenderStepped:Connect(function()
    if Settings.SilentAim and NamecallHooked then
        SilentAimTarget = GetClosestPlayer()
    else
        SilentAimTarget = nil
    end

    -- Update FOV Circle
    if HasDrawing and FOVCircle then
        FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
        FOVCircle.Radius = Settings.FOV
        FOVCircle.Visible = (Settings.SilentAim or Settings.AutoAim) and Settings.FOV > 0
    end

    -- Auto-Aim
    if Settings.AutoAim and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = GetClosestPlayer()
        if target then
            local pos = GetAimPosition(target)
            if pos then
                local screenPos = Camera:WorldToViewportPoint(pos)
                local mousePos = Vector2.new(Mouse.X, Mouse.Y)
                local targetPos = Vector2.new(screenPos.X, screenPos.Y)
                local delta = (targetPos - mousePos) * Settings.Smoothing
                if typeof(mousemoverel) == "function" then
                    mousemoverel(delta.X, delta.Y)
                end
            end
        end
    end
end)

--// Build UI
local Tab = ArsenalKit:CreateTab("Combat", "C")

ArsenalKit:CreateSection(Tab, "Aimbot")

ArsenalKit:CreateToggle(Tab, "Silent Aim", false, function(v)
    if v and not NamecallHooked then
        warn("[Aimbot] Silent Aim unavailable - hookmetamethod not supported by executor")
        Settings.SilentAim = false
        return
    end
    Settings.SilentAim = v
end)

ArsenalKit:CreateToggle(Tab, "Auto-Aim (RMB)", false, function(v)
    Settings.AutoAim = v
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

ArsenalKit:CreateToggle(Tab, "Team Check", true, function(v)
    Settings.TeamCheck = v
end)

ArsenalKit:CreateToggle(Tab, "Wall Check", false, function(v)
    Settings.WallCheck = v
end)

print("[ArsenalKit] Aimbot module loaded")