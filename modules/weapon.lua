-- ArsenalKit Weapon Module
-- No recoil, no spread, rapid fire, instant reload, gun color changer, weapon scanner

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local ArsenalKit = _G.ArsenalKit
if not ArsenalKit then return end
if ArsenalKit.Features.WeaponLoaded then return end
ArsenalKit.Features.WeaponLoaded = true

-- Settings
local Settings = {
    NoRecoil = false,
    NoSpread = false,
    RapidFire = false,
    InstantReload = false,
    InfiniteAmmo = false,
    GunColor = false,
    GunColorValue = Color3.fromRGB(0, 210, 255),
    DebugMode = false
}

local WeaponConnection = nil
local ColorConnection = nil
local OriginalValues = {}

-- Create UI
local WeaponTab = ArsenalKit:CreateTab("Weapon")

ArsenalKit:CreateSection(WeaponTab, "Weapon Mods")
ArsenalKit:CreateToggle(WeaponTab, "No Recoil", false, function(state)
    Settings.NoRecoil = state
end)

ArsenalKit:CreateToggle(WeaponTab, "No Spread", false, function(state)
    Settings.NoSpread = state
end)

ArsenalKit:CreateToggle(WeaponTab, "Rapid Fire", false, function(state)
    Settings.RapidFire = state
end)

ArsenalKit:CreateToggle(WeaponTab, "Instant Reload", false, function(state)
    Settings.InstantReload = state
end)

ArsenalKit:CreateToggle(WeaponTab, "Infinite Ammo", false, function(state)
    Settings.InfiniteAmmo = state
end)

ArsenalKit:CreateSection(WeaponTab, "Gun Color")
ArsenalKit:CreateToggle(WeaponTab, "Enable Color", false, function(state)
    Settings.GunColor = state
end)

ArsenalKit:CreateColorPicker(WeaponTab, "Gun Color", Color3.fromRGB(0, 210, 255), function(color)
    Settings.GunColorValue = color
end)

ArsenalKit:CreateSection(WeaponTab, "Debug")
ArsenalKit:CreateToggle(WeaponTab, "Debug Mode", false, function(state)
    Settings.DebugMode = state
end)

ArsenalKit:CreateButton(WeaponTab, "Scan Current Weapon", function()
    local character = LocalPlayer.Character
    if not character then
        print("[ArsenalKit] No character found")
        return
    end

    local tool = character:FindFirstChildOfClass("Tool")
    if not tool then
        print("[ArsenalKit] No tool equipped")
        return
    end

    print("[ArsenalKit] === WEAPON SCAN: " .. tool.Name .. " ===")

    -- Scan all descendants
    for _, desc in pairs(tool:GetDescendants()) do
        if desc:IsA("BaseValue") then
            print("[ArsenalKit] Value: " .. desc.Name .. " = " .. tostring(desc.Value) .. " (" .. desc.ClassName .. ")")
        end
        if desc:IsA("BasePart") then
            print("[ArsenalKit] Part: " .. desc.Name .. " Color=" .. tostring(desc.Color))
        end
        -- Check attributes
        for attrName, attrValue in pairs(desc:GetAttributes()) do
            print("[ArsenalKit] Attribute: " .. desc.Name .. "." .. attrName .. " = " .. tostring(attrValue))
        end
    end

    -- Check tool attributes
    for attrName, attrValue in pairs(tool:GetAttributes()) do
        print("[ArsenalKit] Tool Attribute: " .. attrName .. " = " .. tostring(attrValue))
    end

    print("[ArsenalKit] === END SCAN ===")
end)

-- Known Arsenal weapon names (common ones)
local KnownWeapons = {
    "M4A1", "AK-47", "Deagle", "AWP", "P90", "MAC-10", "AA-12", "SPAS-12",
    "AUG A3", "M249", "SCAR-H", "SCAR-L", "G11", "FAMAS", "Galil",
    "M1911", "Glock-18", "Python", "Luger", "Makarov", "Webley",
    "MP5K", "MP7", "UMP-45", "P250", "Five-SeveN", "Tec-9",
    "M40", "Dragunov", "Springfield Rifle", "SKS", "Mosin-Nagant",
    "DB Shotgun", "Lever Shotgun", "Pump Shotgun", "Trench Gun",
    "Minigun", "Gatling Gun", "MG36", "BAR", "M1919A6",
    "Rocket Launcher", "RPG", "Railgun", "Laser Rifle", "Plasma Launcher",
    "Crossbow", "Autobow", "Bow", "Golden Bow",
    "Flamethrower", "Concussion Rifle", "Spellbook", "Firebrand",
    "Golden Gun", "Windicator", "Hush Puppy", "Golden Hush Puppy",
    "Tommy Gun", "Grease Gun", "STEN", "M3",
    "R800", "Handcannon", "Hi-Power", "Pathbringer", "Peacemaker",
    "Armament", "Dispensor", "Cone Launcher", "Acid Spitter",
    "Nailgun", "Peppergun", "Ice Stars", "Sunflower Sun",
    "Potassium Power", "Trash Can", "Literal Gun", "Falkour",
    "XR15", "MK18", "M16A2", "M14", "Henry Rifle",
    "DB Chauchat", "Inertial Shotgun", "MAG-7", "Nova",
    "Sawed Off", "XM1014", "Benelli M4", "KSG-12",
    "Dual LCRs", "Union Pistol", "FMG-9", "Micro Uzis",
    "Uzi", "Vector", "KRISS", "Scorpion",
    "Candy Cane Miniguns", "Peppermint Rifle", "Presents",
    "Snowball", "Water Balloon", "Ultraball", "Trowel",
    "PIZZA", "Machete", "Bat", "Pan", "Butterfly Knife",
    "Brass Knuckles", "Fisticuffs", "Icicle", "Battle Axe",
    "Musket", "G-19X", "Maxim-9", "Creagle", "Golden Creagle",
    "Admin Launcher", "Influencer Launcher"
}

-- Get current tool
local function GetCurrentTool()
    local character = LocalPlayer.Character
    if not character then return nil end
    return character:FindFirstChildOfClass("Tool")
end

-- Apply gun color
local function ApplyGunColor(tool)
    if not tool then return end
    if not Settings.GunColor then return end

    for _, part in pairs(tool:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "Handle" then
            part.Color = Settings.GunColorValue
            part.Material = Enum.Material.Neon
        end
    end
end

-- Weapon mod loop
WeaponConnection = RunService.Heartbeat:Connect(function()
    local tool = GetCurrentTool()
    if not tool then return end

    -- Apply color
    if Settings.GunColor then
        ApplyGunColor(tool)
    end

    -- Scan for weapon values
    for _, desc in pairs(tool:GetDescendants()) do
        if desc:IsA("NumberValue") or desc:IsA("IntValue") then
            local name = desc.Name:lower()

            -- No recoil
            if Settings.NoRecoil then
                if name:find("recoil") or name:find("kick") or name:find("rise") then
                    if not OriginalValues[desc] then
                        OriginalValues[desc] = desc.Value
                    end
                    desc.Value = 0
                end
            elseif OriginalValues[desc] then
                desc.Value = OriginalValues[desc]
                OriginalValues[desc] = nil
            end

            -- No spread
            if Settings.NoSpread then
                if name:find("spread") or name:find("accuracy") or name:find("cone") then
                    if not OriginalValues[desc] then
                        OriginalValues[desc] = desc.Value
                    end
                    desc.Value = 0
                end
            elseif OriginalValues[desc] then
                desc.Value = OriginalValues[desc]
                OriginalValues[desc] = nil
            end

            -- Rapid fire
            if Settings.RapidFire then
                if name:find("firerate") or name:find("fire_rate") or name:find("rpm") or name:find("cooldown") then
                    if not OriginalValues[desc] then
                        OriginalValues[desc] = desc.Value
                    end
                    if name:find("cooldown") then
                        desc.Value = 0.01
                    else
                        desc.Value = 9999
                    end
                end
            elseif OriginalValues[desc] then
                desc.Value = OriginalValues[desc]
                OriginalValues[desc] = nil
            end

            -- Instant reload
            if Settings.InstantReload then
                if name:find("reload") or name:find("reloadtime") then
                    if not OriginalValues[desc] then
                        OriginalValues[desc] = desc.Value
                    end
                    desc.Value = 0.01
                end
            elseif OriginalValues[desc] then
                desc.Value = OriginalValues[desc]
                OriginalValues[desc] = nil
            end

            -- Infinite ammo
            if Settings.InfiniteAmmo then
                if name:find("ammo") or name:find("clip") or name:find("mag") then
                    if not OriginalValues[desc] then
                        OriginalValues[desc] = desc.Value
                    end
                    desc.Value = 999
                end
            elseif OriginalValues[desc] then
                desc.Value = OriginalValues[desc]
                OriginalValues[desc] = nil
            end
        end

        -- Check attributes too
        if Settings.DebugMode then
            for attrName, attrValue in pairs(desc:GetAttributes()) do
                local attrLower = attrName:lower()
                if attrLower:find("recoil") or attrLower:find("spread") or attrLower:find("firerate") or attrLower:find("reload") then
                    print("[ArsenalKit] Attribute found: " .. desc.Name .. "." .. attrName .. " = " .. tostring(attrValue))
                end
            end
        end
    end

    -- Tool-level attributes
    for attrName, attrValue in pairs(tool:GetAttributes()) do
        local attrLower = attrName:lower()

        if Settings.NoRecoil and (attrLower:find("recoil") or attrLower:find("kick")) then
            if not OriginalValues["tool_" .. attrName] then
                OriginalValues["tool_" .. attrName] = attrValue
            end
            tool:SetAttribute(attrName, 0)
        end

        if Settings.NoSpread and attrLower:find("spread") then
            if not OriginalValues["tool_" .. attrName] then
                OriginalValues["tool_" .. attrName] = attrValue
            end
            tool:SetAttribute(attrName, 0)
        end

        if Settings.RapidFire and (attrLower:find("firerate") or attrLower:find("rpm")) then
            if not OriginalValues["tool_" .. attrName] then
                OriginalValues["tool_" .. attrName] = attrValue
            end
            tool:SetAttribute(attrName, 9999)
        end

        if Settings.InstantReload and attrLower:find("reload") then
            if not OriginalValues["tool_" .. attrName] then
                OriginalValues["tool_" .. attrName] = attrValue
            end
            tool:SetAttribute(attrName, 0.01)
        end
    end
end)

table.insert(ArsenalKit.Connections, WeaponConnection)

print("[ArsenalKit] Weapon module loaded")
print("[ArsenalKit] Known Arsenal weapons: " .. #KnownWeapons .. " in database")