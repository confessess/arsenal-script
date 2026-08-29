-- ArsenalKit Movement Module
-- Speed, bhop, inf jump, fly, noclip, 3rd person, desync

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local ArsenalKit = _G.ArsenalKit
if not ArsenalKit then return end
if ArsenalKit.Features.MovementLoaded then return end
ArsenalKit.Features.MovementLoaded = true

local Settings = {
    SpeedHack = false,
    SpeedValue = 3,
    BunnyHop = false,
    InfiniteJump = false,
    Fly = false,
    FlyKey = Enum.KeyCode.F,
    Noclip = false,
    NoclipKey = Enum.KeyCode.N,
    ThirdPerson = false,
    ThirdPersonDist = 10,
    Desync = false
}

local FlyActive = false
local NoclipActive = false

local MoveTab = ArsenalKit:CreateTab("Movement")

ArsenalKit:CreateSection(MoveTab, "Speed")
ArsenalKit:CreateToggle(MoveTab, "Speed Hack", false, function(state)
    Settings.SpeedHack = state
end)
ArsenalKit:CreateSlider(MoveTab, "Speed Multiplier", 1, 10, 3, function(val)
    Settings.SpeedValue = val
end)

ArsenalKit:CreateSection(MoveTab, "Jump")
ArsenalKit:CreateToggle(MoveTab, "Bunny Hop", false, function(state)
    Settings.BunnyHop = state
end)
ArsenalKit:CreateToggle(MoveTab, "Infinite Jump", false, function(state)
    Settings.InfiniteJump = state
end)

ArsenalKit:CreateSection(MoveTab, "Flight")
ArsenalKit:CreateToggle(MoveTab, "Fly", false, function(state)
    Settings.Fly = state
    FlyActive = state
end)
ArsenalKit:CreateKeybind(MoveTab, "Fly Key", Enum.KeyCode.F, function()
    FlyActive = not FlyActive
    Settings.Fly = FlyActive
end)

ArsenalKit:CreateSection(MoveTab, "Collision")
ArsenalKit:CreateToggle(MoveTab, "Noclip", false, function(state)
    Settings.Noclip = state
    NoclipActive = state
end)
ArsenalKit:CreateKeybind(MoveTab, "Noclip Key", Enum.KeyCode.N, function()
    NoclipActive = not NoclipActive
    Settings.Noclip = NoclipActive
end)

ArsenalKit:CreateSection(MoveTab, "Camera")
ArsenalKit:CreateToggle(MoveTab, "Third Person", false, function(state)
    Settings.ThirdPerson = state
    if not state then
        LocalPlayer.CameraMode = Enum.CameraMode.LockFirstPerson
    end
end)
ArsenalKit:CreateSlider(MoveTab, "Camera Distance", 3, 30, 10, function(val)
    Settings.ThirdPersonDist = val
end)

ArsenalKit:CreateSection(MoveTab, "Desync")
ArsenalKit:CreateToggle(MoveTab, "Desync", false, function(state)
    Settings.Desync = state
end)

-- Infinite jump
UserInputService.JumpRequest:Connect(function()
    if Settings.InfiniteJump then
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end
end)

-- Movement loop
local MoveConnection = RunService.Heartbeat:Connect(function()
    local character = LocalPlayer.Character
    if not character then return end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not hrp then return end

    -- Speed hack
    if Settings.SpeedHack then
        local moveDir = humanoid.MoveDirection
        if moveDir.Magnitude > 0 then
            hrp.Velocity = Vector3.new(
                moveDir.X * Settings.SpeedValue * 16,
                hrp.Velocity.Y,
                moveDir.Z * Settings.SpeedValue * 16
            )
        end
    end

    -- Bunny hop
    if Settings.BunnyHop then
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            if humanoid.FloorMaterial ~= Enum.Material.Air then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end

    -- Fly
    if FlyActive then
        local speed = 50
        local velocity = Vector3.new(0, 0, 0)

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            velocity = velocity + workspace.CurrentCamera.CFrame.LookVector * speed
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            velocity = velocity - workspace.CurrentCamera.CFrame.LookVector * speed
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            velocity = velocity - workspace.CurrentCamera.CFrame.RightVector * speed
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            velocity = velocity + workspace.CurrentCamera.CFrame.RightVector * speed
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            velocity = velocity + Vector3.new(0, speed, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            velocity = velocity - Vector3.new(0, speed, 0)
        end

        hrp.Velocity = velocity
        humanoid.PlatformStand = true
    else
        if humanoid.PlatformStand then
            humanoid.PlatformStand = false
        end
    end

    -- Noclip
    if NoclipActive then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end

    -- Third person
    if Settings.ThirdPerson then
        LocalPlayer.CameraMode = Enum.CameraMode.Classic
        local camera = workspace.CurrentCamera
        if camera then
            local offset = camera.CFrame.LookVector * -Settings.ThirdPersonDist
            camera.CFrame = camera.CFrame + offset
        end
    end

    -- Desync (fake lag / position desync)
    if Settings.Desync then
        hrp.CFrame = hrp.CFrame * CFrame.new(math.random(-5, 5) / 10, 0, math.random(-5, 5) / 10)
    end
end)

table.insert(ArsenalKit.Connections, MoveConnection)

print("[ArsenalKit] Movement module loaded")