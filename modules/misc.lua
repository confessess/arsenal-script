--// ArsenalKit Module: Misc
--// Features: Anti-AFK, Kill All, Teleport to Random, God Mode, Auto Respawn

local ArsenalKit = _G.ArsenalKit
--// Prevent double-load
if ArsenalKit.Modules and ArsenalKit.Modules.Misc then return end
ArsenalKit.Modules = ArsenalKit.Modules or {}
ArsenalKit.Modules.Misc = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer

--// Settings
local Settings = {
    AntiAFK = false,
    GodMode = false,
    AutoRespawn = false
}

--// Anti-AFK
local AFKConnection = nil

local function StartAntiAFK()
    if AFKConnection then return end
    AFKConnection = LocalPlayer.Idled:Connect(function()
        if Settings.AntiAFK then
            VirtualUser:Button2Down(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
            task.wait(1)
            VirtualUser:Button2Up(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
        end
    end)
end

--// Kill All
local function KillAll()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.Health = 0
                end
            end
        end
    end
end

--// Teleport to Random Player
local function TeleportRandom()
    local targets = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            table.insert(targets, player)
        end
    end

    if #targets == 0 then return end

    local target = targets[math.random(1, #targets)]
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local targetHRP = target.Character:FindFirstChild("HumanoidRootPart")
    if targetHRP then
        hrp.CFrame = targetHRP.CFrame + Vector3.new(0, 3, 0)
    end
end

--// God Mode
RunService.Heartbeat:Connect(function()
    if Settings.GodMode then
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.MaxHealth = math.huge
            hum.Health = math.huge
        end
    end
end)

--// Auto Respawn
RunService.Heartbeat:Connect(function()
    if Settings.AutoRespawn then
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health <= 0 then
            -- Trigger respawn
            local pos = char:FindFirstChild("HumanoidRootPart") and char.HumanoidRootPart.Position
            LocalPlayer:LoadCharacter()
            task.wait(0.5)
            local newChar = LocalPlayer.Character
            if newChar and pos then
                local newHRP = newChar:WaitForChild("HumanoidRootPart", 3)
                if newHRP then
                    newHRP.CFrame = CFrame.new(pos)
                end
            end
        end
    end
end)

--// Build UI
local Tab = ArsenalKit:CreateTab("Misc", "X")

ArsenalKit:CreateSection(Tab, "Utility")

ArsenalKit:CreateToggle(Tab, "Anti-AFK", false, function(v)
    Settings.AntiAFK = v
    if v then
        StartAntiAFK()
    end
end)

ArsenalKit:CreateToggle(Tab, "God Mode", false, function(v)
    Settings.GodMode = v
end)

ArsenalKit:CreateToggle(Tab, "Auto Respawn", false, function(v)
    Settings.AutoRespawn = v
end)

ArsenalKit:CreateSection(Tab, "Actions")

ArsenalKit:CreateButton(Tab, "Kill All", function()
    KillAll()
end)

ArsenalKit:CreateButton(Tab, "Teleport to Random", function()
    TeleportRandom()
end)

ArsenalKit:CreateButton(Tab, "Respawn", function()
    local pos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position
    LocalPlayer:LoadCharacter()
    if pos then
        task.delay(0.5, function()
            local char = LocalPlayer.Character
            if char then
                local hrp = char:WaitForChild("HumanoidRootPart", 3)
                if hrp then
                    hrp.CFrame = CFrame.new(pos)
                end
            end
        end)
    end
end)

print("[ArsenalKit] Misc module loaded")