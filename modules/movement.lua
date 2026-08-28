--// ArsenalKit Module: Movement v3
--// Features: Speed, Bunny Hop, Infinite Jump, Fly, No Clip - all with keybinds

local ArsenalKit = _G.ArsenalKit
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

--// Prevent double-load
if ArsenalKit.Modules and ArsenalKit.Modules.Movement then return end
ArsenalKit.Modules = ArsenalKit.Modules or {}
ArsenalKit.Modules.Movement = true

--// Settings
local Settings = {
    SpeedHack = false,
    SpeedKey = Enum.KeyCode.LeftShift,
    SpeedMult = 2,
    BunnyHop = false,
    BunnyHopKey = Enum.KeyCode.Space,
    InfiniteJump = false,
    InfJumpKey = Enum.KeyCode.Space,
    Fly = false,
    FlyKey = Enum.KeyCode.F,
    FlySpeed = 50,
    NoClip = false,
    NoClipKey = Enum.KeyCode.N
}

--// State
local IsFlying = false
local FlyBodyVelocity = nil
local FlyBodyGyro = nil
local AutoFireConnection = nil
local SpeedConnection = nil

--// Speed Hack
local function StartSpeedHack()
    if SpeedConnection then return end
    SpeedConnection = RunService.Heartbeat:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if not humanoid then return end

        if Settings.SpeedHack then
            humanoid.WalkSpeed = 16 * Settings.SpeedMult
        else
            humanoid.WalkSpeed = 16
        end
    end)
end

--// Fly System
local function StartFly()
    if IsFlying then return end
    IsFlying = true

    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    FlyBodyGyro = Instance.new("BodyGyro")
    FlyBodyGyro.P = 9e4
    FlyBodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    FlyBodyGyro.CFrame = hrp.CFrame
    FlyBodyGyro.Parent = hrp

    FlyBodyVelocity = Instance.new("BodyVelocity")
    FlyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
    FlyBodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    FlyBodyVelocity.Parent = hrp
end

local function StopFly()
    if not IsFlying then return end
    IsFlying = false

    if FlyBodyGyro then
        FlyBodyGyro:Destroy()
        FlyBodyGyro = nil
    end
    if FlyBodyVelocity then
        FlyBodyVelocity:Destroy()
        FlyBodyVelocity = nil
    end
end

RunService.RenderStepped:Connect(function()
    if IsFlying and FlyBodyVelocity and FlyBodyGyro then
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local cam = Workspace.CurrentCamera
        local moveDir = Vector3.new(0, 0, 0)

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveDir = moveDir + cam.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveDir = moveDir - cam.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveDir = moveDir - cam.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveDir = moveDir + cam.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveDir = moveDir + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            moveDir = moveDir - Vector3.new(0, 1, 0)
        end

        if moveDir.Magnitude > 0 then
            moveDir = moveDir.Unit * Settings.FlySpeed
        end

        FlyBodyVelocity.Velocity = moveDir
        FlyBodyGyro.CFrame = cam.CFrame
    end
end)

--// Bunny Hop
RunService.Heartbeat:Connect(function()
    if Settings.BunnyHop then
        local char = LocalPlayer.Character
        if not char then return end
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if not humanoid then return end
        if UserInputService:IsKeyDown(Settings.BunnyHopKey) then
            humanoid.Jump = true
        end
    end
end)

--// Infinite Jump
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Settings.InfJumpKey and Settings.InfiniteJump then
        local char = LocalPlayer.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.Velocity = Vector3.new(hrp.Velocity.X, 50, hrp.Velocity.Z)
            end
        end
    end
end)

--// No Clip
RunService.Heartbeat:Connect(function()
    if Settings.NoClip then
        local char = LocalPlayer.Character
        if not char then return end
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

--// Start speed hack loop
StartSpeedHack()

--// Build UI
local Tab = ArsenalKit:CreateTab("Movement", "M")

ArsenalKit:CreateSection(Tab, "Speed")

ArsenalKit:CreateToggle(Tab, "Speed Hack", false, function(v)
    Settings.SpeedHack = v
end)

ArsenalKit:CreateKeybind(Tab, "Speed Key", Settings.SpeedKey, function(key, pressed)
    if pressed then
        Settings.SpeedHack = not Settings.SpeedHack
    else
        Settings.SpeedKey = key
    end
end)

ArsenalKit:CreateSlider(Tab, "Speed Multiplier", 1, 10, 2, function(v)
    Settings.SpeedMult = v
end)

ArsenalKit:CreateSection(Tab, "Jump")

ArsenalKit:CreateToggle(Tab, "Bunny Hop", false, function(v)
    Settings.BunnyHop = v
end)

ArsenalKit:CreateKeybind(Tab, "BHop Key", Settings.BunnyHopKey, function(key, pressed)
    if not pressed then
        Settings.BunnyHopKey = key
    end
end)

ArsenalKit:CreateToggle(Tab, "Infinite Jump", false, function(v)
    Settings.InfiniteJump = v
end)

ArsenalKit:CreateKeybind(Tab, "InfJump Key", Settings.InfJumpKey, function(key, pressed)
    if not pressed then
        Settings.InfJumpKey = key
    end
end)

ArsenalKit:CreateSection(Tab, "Flight")

ArsenalKit:CreateToggle(Tab, "Fly (WASD + Space/Shift)", false, function(v)
    Settings.Fly = v
    if v then StartFly() else StopFly() end
end)

ArsenalKit:CreateKeybind(Tab, "Fly Key", Settings.FlyKey, function(key, pressed)
    if pressed then
        Settings.Fly = not Settings.Fly
        if Settings.Fly then StartFly() else StopFly() end
    else
        Settings.FlyKey = key
    end
end)

ArsenalKit:CreateSlider(Tab, "Fly Speed", 10, 200, 50, function(v)
    Settings.FlySpeed = v
end)

ArsenalKit:CreateSection(Tab, "Collision")

ArsenalKit:CreateToggle(Tab, "No Clip", false, function(v)
    Settings.NoClip = v
end)

ArsenalKit:CreateKeybind(Tab, "NoClip Key", Settings.NoClipKey, function(key, pressed)
    if pressed then
        Settings.NoClip = not Settings.NoClip
    else
        Settings.NoClipKey = key
    end
end)

print("[ArsenalKit] Movement v3 loaded")