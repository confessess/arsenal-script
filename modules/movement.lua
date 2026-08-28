--// ArsenalKit Module: Movement
--// Features: Speed Hack, Bunny Hop, Infinite Jump, Fly, No Clip

local ArsenalKit = _G.ArsenalKit
--// Prevent double-load
if ArsenalKit.Modules and ArsenalKit.Modules.Movement then return end
ArsenalKit.Modules = ArsenalKit.Modules or {}
ArsenalKit.Modules.Movement = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

--// Settings
local Settings = {
    SpeedHack = false,
    SpeedMult = 2,
    BunnyHop = false,
    InfiniteJump = false,
    Fly = false,
    FlySpeed = 50,
    NoClip = false
}

--// State
local IsFlying = false
local FlyBodyVelocity = nil
local FlyBodyGyro = nil
local WasJumping = false

--// Speed Hack
RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end

    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    if Settings.SpeedHack then
        humanoid.WalkSpeed = 16 * Settings.SpeedMult
    else
        humanoid.WalkSpeed = 16
    end

    -- Bunny Hop
    if Settings.BunnyHop then
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            humanoid.Jump = true
        end
    end

    -- No Clip
    if Settings.NoClip then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

--// Infinite Jump
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Space and Settings.InfiniteJump then
        local char = LocalPlayer.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.Velocity = Vector3.new(hrp.Velocity.X, 50, hrp.Velocity.Z)
            end
        end
    end
end)

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

--// Build UI
local Tab = ArsenalKit:CreateTab("Movement", "🏃")

ArsenalKit:CreateSection(Tab, "Speed")

ArsenalKit:CreateToggle(Tab, "Speed Hack", false, function(v)
    Settings.SpeedHack = v
end)

ArsenalKit:CreateSlider(Tab, "Speed Multiplier", 1, 10, 2, function(v)
    Settings.SpeedMult = v
end)

ArsenalKit:CreateSection(Tab, "Jump")

ArsenalKit:CreateToggle(Tab, "Bunny Hop", false, function(v)
    Settings.BunnyHop = v
end)

ArsenalKit:CreateToggle(Tab, "Infinite Jump", false, function(v)
    Settings.InfiniteJump = v
end)

ArsenalKit:CreateSection(Tab, "Flight")

ArsenalKit:CreateToggle(Tab, "Fly (WASD + Space/Shift)", false, function(v)
    Settings.Fly = v
    if v then
        StartFly()
    else
        StopFly()
    end
end)

ArsenalKit:CreateSlider(Tab, "Fly Speed", 10, 200, 50, function(v)
    Settings.FlySpeed = v
end)

ArsenalKit:CreateSection(Tab, "Collision")

ArsenalKit:CreateToggle(Tab, "No Clip", false, function(v)
    Settings.NoClip = v
end)

print("[ArsenalKit] Movement module loaded")