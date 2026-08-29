-- ArsenalKit Weapon Module
-- No recoil, no spread, rapid fire, instant reload, auto fire, infinite ammo

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

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

-- Weapon loop
local WeaponConnection = AddConnection(RunService.Heartbeat:Connect(function()
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
        if Settings.NoSpread then
            local Spread = Config:FindFirstChild("Spread") or Config:FindFirstChild("MinSpread") or Config:FindFirstChild("MaxSpread")
            if Spread then Spread.Value = 0 end
        end
        if Settings.RapidFire then
            local FireRate = Config:FindFirstChild("FireRate") or Config:FindFirstChild("RPM") or Config:FindFirstChild("Cooldown")
            if FireRate and typeof(FireRate.Value) == "number" and FireRate.Value > 0 then FireRate.Value = 0.01 end
        end
        if Settings.InstantReload then
            local ReloadTime = Config:FindFirstChild("ReloadTime") or Config:FindFirstChild("Reload")
            if ReloadTime and typeof(ReloadTime.Value) == "number" then ReloadTime.Value = 0.01 end
        end
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

-- UI
local WeaponTab = ArsenalKit:CreateTab("Weapon", "⚡")
local Section1 = ArsenalKit:CreateSection(WeaponTab, "WEAPON MODS", "Gun modifications and tweaks.")

ArsenalKit:CreateToggle(Section1, "No Recoil", false, function(state) Settings.NoRecoil = state end)
ArsenalKit:CreateToggle(Section1, "No Spread", false, function(state) Settings.NoSpread = state end)
ArsenalKit:CreateToggle(Section1, "Rapid Fire", false, function(state) Settings.RapidFire = state end)
ArsenalKit:CreateToggle(Section1, "Instant Reload", false, function(state) Settings.InstantReload = state end)
ArsenalKit:CreateToggle(Section1, "Auto Fire", false, function(state) Settings.AutoFire = state end)
ArsenalKit:CreateToggle(Section1, "Infinite Ammo", false, function(state) Settings.InfiniteAmmo = state end)

print("[ArsenalKit] Weapon module loaded")