-- ArsenalKit Weapon Module
-- No recoil, no spread, rapid fire, instant reload, auto fire, infinite ammo

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

local ArsenalKit = _G.ArsenalKit
if not ArsenalKit then return end
if ArsenalKit.Features.WeaponLoaded then return end
ArsenalKit.Features.WeaponLoaded = true

local Settings = {
    NoRecoil = false,
    NoSpread = false,
    RapidFire = false,
    InstantReload = false,
    AutoFire = false,
    InfiniteAmmo = false
}

local function AddConnection(conn)
    table.insert(ArsenalKit.Connections, conn)
    return conn
end

--========================================================
-- GLOBAL WEAPON MODS (modifies ReplicatedStorage.Weapons directly)
-- This is the method that actually works — modifies ALL weapons server-side
--========================================================

local function ApplyGlobalRapidFire()
    if not Settings.RapidFire then return end
    local Weapons = ReplicatedStorage:FindFirstChild("Weapons")
    if not Weapons then return end
    for _, v in pairs(Weapons:GetDescendants()) do
        if v.Name == "FireRate" or v.Name == "BFireRate" or v.Name == "RPM" then
            if v:IsA("NumberValue") or v:IsA("IntValue") then
                v.Value = 0.02
            end
        end
    end
end

local function ApplyGlobalNoSpread()
    if not Settings.NoSpread then return end
    local Weapons = ReplicatedStorage:FindFirstChild("Weapons")
    if not Weapons then return end
    for _, v in pairs(Weapons:GetDescendants()) do
        if v.Name == "Spread" or v.Name == "MinSpread" or v.Name == "MaxSpread" or v.Name == "BaseSpread" then
            if v:IsA("NumberValue") or v:IsA("IntValue") then
                v.Value = 0
            end
        end
    end
end

local function ApplyGlobalInstantReload()
    if not Settings.InstantReload then return end
    local Weapons = ReplicatedStorage:FindFirstChild("Weapons")
    if not Weapons then return end
    for _, v in pairs(Weapons:GetDescendants()) do
        if v.Name == "ReloadTime" or v.Name == "Reload" or v.Name == "ReloadSpeed" then
            if v:IsA("NumberValue") or v:IsA("IntValue") then
                v.Value = 0.01
            end
        end
    end
end

-- Also apply to current tool for immediate effect
local WeaponConnection = AddConnection(RunService.Heartbeat:Connect(function()
    -- Global mods (modifies ALL weapons in ReplicatedStorage)
    ApplyGlobalRapidFire()
    ApplyGlobalNoSpread()
    ApplyGlobalInstantReload()

    -- Current tool mods (for immediate effect on equipped weapon)
    local character = LocalPlayer.Character
    if not character then return end
    local Tool = character:FindFirstChildOfClass("Tool")
    if not Tool then return end

    if Settings.InfiniteAmmo then
        local Ammo = Tool:FindFirstChild("Ammo") or Tool:FindFirstChild("Clip")
        local MaxAmmo = Tool:FindFirstChild("MaxAmmo") or Tool:FindFirstChild("MaxClip")
        if Ammo and MaxAmmo then Ammo.Value = MaxAmmo.Value end
        local Stored = Tool:FindFirstChild("StoredAmmo")
        if Stored then Stored.Value = 999 end
    end

    local Config = Tool:FindFirstChild("Settings") or Tool:FindFirstChild("Config") or Tool:FindFirstChild("Values")
    if Config then
        if Settings.NoRecoil then
            local Recoil = Config:FindFirstChild("Recoil") or Config:FindFirstChild("Kick") or Config:FindFirstChild("CameraRecoil")
            if Recoil then
                if typeof(Recoil.Value) == "number" then Recoil.Value = 0
                elseif typeof(Recoil.Value) == "Vector3" then Recoil.Value = Vector3.new(0, 0, 0) end
            end
        end
    end
end))

-- Auto Fire
AddConnection(RunService.RenderStepped:Connect(function()
    if Settings.AutoFire and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
        local Tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if Tool and mouse1click then mouse1click() end
    end
end))

--========================================================
-- UI
--========================================================

local WeaponTab = ArsenalKit:CreateTab("Weapon", "⚡")
local Section1 = ArsenalKit:CreateSection(WeaponTab, "WEAPON MODS", "Gun modifications and tweaks.")

ArsenalKit:CreateToggle(Section1, "No Recoil", false, function(state) Settings.NoRecoil = state end)
ArsenalKit:CreateToggle(Section1, "No Spread", false, function(state)
    Settings.NoSpread = state
    if state then ApplyGlobalNoSpread() end
end)
ArsenalKit:CreateToggle(Section1, "Rapid Fire", false, function(state)
    Settings.RapidFire = state
    if state then ApplyGlobalRapidFire() end
end)
ArsenalKit:CreateToggle(Section1, "Instant Reload", false, function(state)
    Settings.InstantReload = state
    if state then ApplyGlobalInstantReload() end
end)
ArsenalKit:CreateToggle(Section1, "Auto Fire", false, function(state) Settings.AutoFire = state end)
ArsenalKit:CreateToggle(Section1, "Infinite Ammo", false, function(state) Settings.InfiniteAmmo = state end)

print("[ArsenalKit] Weapon module loaded (with global rapid fire)")