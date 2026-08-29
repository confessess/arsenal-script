-- ArsenalKit Movement Module
-- Speed, bhop, inf jump, fly, noclip, 3rd person, desync

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

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

local function AddConnection(conn)
    table.insert(ArsenalKit.Connections, conn)
    return conn
end

-- Infinite jump
AddConnection(UserInputService.JumpRequest:Connect(function()
    if Settings.InfiniteJump then
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
        end
    end
end))

-- Movement loop
local MoveConnection = AddConnection(RunService.Heartbeat:Connect(function()
    local character = LocalPlayer.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not hrp then return end

    if Settings.SpeedHack then
        local moveDir = humanoid.MoveDirection
        if moveDir.Magnitude > 0 then
            hrp.Velocity = Vector3.new(moveDir.X * Settings.SpeedValue * 16, hrp.Velocity.Y, moveDir.Z * Settings.SpeedValue * 16)
        end
    end

    if Settings.BunnyHop then
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            if humanoid.FloorMaterial ~= Enum.Material.Air then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end

    if FlyActive then
        local speed = 50
        local velocity = Vector3.new(0, 0, 0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then velocity = velocity + Camera.CFrame.LookVector * speed end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then velocity = velocity - Camera.CFrame.LookVector * speed end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then velocity = velocity - Camera.CFrame.RightVector * speed end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then velocity = velocity + Camera.CFrame.RightVector * speed end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then velocity = velocity + Vector3.new(0, speed, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then velocity = velocity - Vector3.new(0, speed, 0) end
        hrp.Velocity = velocity
        humanoid.PlatformStand = true
    else
        if humanoid.PlatformStand then humanoid.PlatformStand = false end
    end

    if NoclipActive then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end

    if Settings.ThirdPerson then
        LocalPlayer.CameraMode = Enum.CameraMode.Classic
        if Camera then
            local offset = Camera.CFrame.LookVector * -Settings.ThirdPersonDist
            Camera.CFrame = Camera.CFrame + offset
        end
    end

    if Settings.Desync then
        hrp.CFrame = hrp.CFrame * CFrame.new(math.random(-5, 5) / 10, 0, math.random(-5, 5) / 10)
    end
end))

-- UI
local MoveTab = ArsenalKit:CreateTab("Movement", "◇")

local Section1 = ArsenalKit:CreateSection(MoveTab, "SPEED", "Movement speed modifications.")
ArsenalKit:CreateToggle(Section1, "Speed Hack", false, function(state) Settings.SpeedHack = state end)
ArsenalKit:CreateSlider(Section1, "Speed Multiplier", 1, 10, 3, function(val) Settings.SpeedValue = val end)

local Section2 = ArsenalKit:CreateSection(MoveTab, "JUMP", "Jump-related modifications.")
ArsenalKit:CreateToggle(Section2, "Bunny Hop", false, function(state) Settings.BunnyHop = state end)
ArsenalKit:CreateToggle(Section2, "Infinite Jump", false, function(state) Settings.InfiniteJump = state end)

local Section3 = ArsenalKit:CreateSection(MoveTab, "FLIGHT", "Flight and aerial movement.")
ArsenalKit:CreateToggle(Section3, "Fly", false, function(state)
    Settings.Fly = state
    FlyActive = state
end)
ArsenalKit:CreateKeybind(Section3, "Fly Key", Enum.KeyCode.F, function()
    FlyActive = not FlyActive
    Settings.Fly = FlyActive
end)

local Section4 = ArsenalKit:CreateSection(MoveTab, "COLLISION", "Collision and phase modifications.")
ArsenalKit:CreateToggle(Section4, "Noclip", false, function(state)
    Settings.Noclip = state
    NoclipActive = state
end)
ArsenalKit:CreateKeybind(Section4, "Noclip Key", Enum.KeyCode.N, function()
    NoclipActive = not NoclipActive
    Settings.Noclip = NoclipActive
end)

local Section5 = ArsenalKit:CreateSection(MoveTab, "CAMERA", "Camera perspective options.")
ArsenalKit:CreateToggle(Section5, "Third Person", false, function(state)
    Settings.ThirdPerson = state
    if not state then LocalPlayer.CameraMode = Enum.CameraMode.LockFirstPerson end
end)
ArsenalKit:CreateSlider(Section5, "Camera Distance", 3, 30, 10, function(val) Settings.ThirdPersonDist = val end)

local Section6 = ArsenalKit:CreateSection(MoveTab, "DESYNC", "Position desynchronization.")
ArsenalKit:CreateToggle(Section6, "Desync", false, function(state) Settings.Desync = state end)

print("[ArsenalKit] Movement module loaded")