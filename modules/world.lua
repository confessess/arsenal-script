--// ArsenalKit Module: Weapon
--// Features: No Recoil, No Spread, Rapid Fire, Instant Reload, Auto Fire, Infinite Ammo

local ArsenalKit = _G.ArsenalKit
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

--// Settings
local Settings = {
    NoRecoil = false,
    NoSpread = false,
    RapidFire = false,
    InstantReload = false,
    AutoFire = false,
    InfiniteAmmo = false,
    FireRate = 0.05
}

--// Weapon Cache
local WeaponCache = {}
local OriginalValues = {}

--// Utility: Get Current Weapon
local function GetCurrentWeapon()
    local char = LocalPlayer.Character
    if not char then return nil end

    for _, obj in ipairs(char:GetDescendants()) do
        if obj:IsA("Tool") then
            return obj
        end
    end

    -- Some games use Backpack or custom systems
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then
                return tool
            end
        end
    end

    return nil
end

--// Utility: Get Weapon Values
local function CacheWeaponValues(tool)
    if not tool or WeaponCache[tool] then return end

    WeaponCache[tool] = true
    OriginalValues[tool] = {}

    for _, obj in ipairs(tool:GetDescendants()) do
        if obj:IsA("NumberValue") or obj:IsA("IntValue") then
            OriginalValues[tool][obj.Name] = obj.Value
        end
    end
end

--// No Recoil / No Spread
RunService.Heartbeat:Connect(function()
    local weapon = GetCurrentWeapon()
    if not weapon then return end

    CacheWeaponValues(weapon)

    for _, obj in ipairs(weapon:GetDescendants()) do
        if obj:IsA("NumberValue") or obj:IsA("IntValue") then
            local name = obj.Name:lower()

            -- No Recoil
            if Settings.NoRecoil then
                if name:find("recoil") or name:find("kick") or name:find("camkick") then
                    obj.Value = 0
                end
                if name:find("spread") then
                    obj.Value = 0
                end
            end

            -- No Spread (standalone)
            if Settings.NoSpread then
                if name:find("spread") or name:find("accuracy") or name:find("cone") then
                    obj.Value = 0
                end
            end

            -- Rapid Fire
            if Settings.RapidFire then
                if name:find("firerate") or name:find("rpm") or name:find("speed") then
                    obj.Value = 1 / Settings.FireRate
                end
                if name:find("cooldown") or name:find("delay") then
                    obj.Value = Settings.FireRate
                end
            end

            -- Instant Reload
            if Settings.InstantReload then
                if name:find("reload") and not name:find("time") then
                    -- skip
                elseif name:find("reloadtime") or name:find("reload") then
                    obj.Value = 0.01
                end
            end

            -- Infinite Ammo
            if Settings.InfiniteAmmo then
                if name:find("ammo") or name:find("clip") or name:find("mag") then
                    if not name:find("max") and not name:find("reserve") then
                        obj.Value = 999
                    end
                end
            end
        end
    end
end)

--// Auto Fire (hold to spam click)
local AutoFireConnection = nil

local function StartAutoFire()
    if AutoFireConnection then return end
    AutoFireConnection = RunService.Heartbeat:Connect(function()
        if not Settings.AutoFire then return end
        local tool = GetCurrentWeapon()
        if tool then
            tool:Activate()
        end
    end)
end

local function StopAutoFire()
    if AutoFireConnection then
        AutoFireConnection:Disconnect()
        AutoFireConnection = nil
    end
end

--// Build UI
local Tab = ArsenalKit:CreateTab("Weapon", "🔫")

ArsenalKit:CreateSection(Tab, "Weapon Mods")

ArsenalKit:CreateToggle(Tab, "No Recoil", false, function(v)
    Settings.NoRecoil = v
end)

ArsenalKit:CreateToggle(Tab, "No Spread", false, function(v)
    Settings.NoSpread = v
end)

ArsenalKit:CreateToggle(Tab, "Rapid Fire", false, function(v)
    Settings.RapidFire = v
end)

ArsenalKit:CreateSlider(Tab, "Fire Rate", 1, 50, 20, function(v)
    Settings.FireRate = 1 / v
end)

ArsenalKit:CreateToggle(Tab, "Instant Reload", false, function(v)
    Settings.InstantReload = v
end)

ArsenalKit:CreateToggle(Tab, "Auto Fire", false, function(v)
    Settings.AutoFire = v
    if v then
        StartAutoFire()
    else
        StopAutoFire()
    end
end)

ArsenalKit:CreateToggle(Tab, "Infinite Ammo", false, function(v)
    Settings.InfiniteAmmo = v
end)

print("[ArsenalKit] Weapon module loaded")