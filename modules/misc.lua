-- ArsenalKit Misc Module
-- Anti-AFK, God Mode, Auto Respawn, Kill All, Teleport

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer

local ArsenalKit = _G.ArsenalKit
if not ArsenalKit then return end
if ArsenalKit.Features.MiscLoaded then return end
ArsenalKit.Features.MiscLoaded = true

local Settings = {
    AntiAFK = false,
    GodMode = false,
    AutoRespawn = false,
    KillAll = false,
    TeleportTarget = nil
}

local function AddConnection(conn)
    table.insert(ArsenalKit.Connections, conn)
    return conn
end

-- Anti-AFK
AddConnection(RunService.Heartbeat:Connect(function()
    if Settings.AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end))

-- God Mode
AddConnection(RunService.Heartbeat:Connect(function()
    if Settings.GodMode then
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.MaxHealth = math.huge
                humanoid.Health = math.huge
            end
        end
    end
end))

-- Auto Respawn
AddConnection(LocalPlayer.CharacterAdded:Connect(function(char)
    if Settings.AutoRespawn then
        local humanoid = char:WaitForChild("Humanoid")
        humanoid.Died:Connect(function()
            task.wait(2)
            LocalPlayer:LoadCharacter()
        end)
    end
end))

-- Kill All
local function KillAll()
    local DamageRemote = nil
    local CommonNames = {"Damage", "Hit", "Bullet", "Shoot", "Fire", "DealDamage", "TakeDamage", "DamagePlayer"}
    for _, name in pairs(CommonNames) do
        local remote = game.ReplicatedStorage:FindFirstChild(name, true)
        if remote and (remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction")) then
            DamageRemote = remote
            break
        end
    end
    if DamageRemote then
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    pcall(function() DamageRemote:FireServer(plr.Character, 999, hrp.Position, "Head") end)
                end
            end
        end
    else
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then humanoid.Health = 0 end
            end
        end
    end
end

-- Teleport
local function TeleportToPlayer(targetPlr)
    if not targetPlr or not targetPlr.Character then return end
    local targetHRP = targetPlr.Character:FindFirstChild("HumanoidRootPart")
    local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if targetHRP and myHRP then
        myHRP.CFrame = targetHRP.CFrame + Vector3.new(0, 3, 0)
    end
end

local function GetPlayerNames()
    local names = {}
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then table.insert(names, plr.Name) end
    end
    if #names == 0 then table.insert(names, "No Players") end
    return names
end

local function GetPlayerByName(name)
    for _, plr in pairs(Players:GetPlayers()) do
        if plr.Name == name then return plr end
    end
    return nil
end

-- UI
local MiscTab = ArsenalKit:CreateTab("Misc", "⚙")

local Section1 = ArsenalKit:CreateSection(MiscTab, "UTILITY", "General utility options.")
ArsenalKit:CreateToggle(Section1, "Anti-AFK", false, function(state) Settings.AntiAFK = state end)
ArsenalKit:CreateToggle(Section1, "God Mode", false, function(state) Settings.GodMode = state end)
ArsenalKit:CreateToggle(Section1, "Auto Respawn", false, function(state) Settings.AutoRespawn = state end)

local Section2 = ArsenalKit:CreateSection(MiscTab, "ACTIONS", "One-time action buttons.")
ArsenalKit:CreateButton(Section2, "Kill All", function() KillAll() end)

local TeleportDropdown = nil
local function RefreshTeleportDropdown()
    if TeleportDropdown then TeleportDropdown:Destroy() end
    local names = GetPlayerNames()
    TeleportDropdown = ArsenalKit:CreateDropdown(Section2, "Teleport Target", names, names[1] or "No Players", function(choice)
        Settings.TeleportTarget = choice
    end)
end
RefreshTeleportDropdown()

ArsenalKit:CreateButton(Section2, "Teleport to Target", function()
    if Settings.TeleportTarget and Settings.TeleportTarget ~= "No Players" then
        TeleportToPlayer(GetPlayerByName(Settings.TeleportTarget))
    end
end)
ArsenalKit:CreateButton(Section2, "Refresh Player List", function() RefreshTeleportDropdown() end)

print("[ArsenalKit] Misc module loaded")