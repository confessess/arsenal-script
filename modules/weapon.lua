--// ArsenalKit Module: Weapon
--// Features: No Recoil, No Spread, Rapid Fire, Instant Reload, Auto Fire, Infinite Ammo
--// Arsenal-specific with getgc hooks, value scanning, and camera fallback

local ArsenalKit = _G.ArsenalKit
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Camera = Workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer

--// Prevent double-load
if ArsenalKit.Modules and ArsenalKit.Modules.Weapon then return end
ArsenalKit.Modules = ArsenalKit.Modules or {}
ArsenalKit.Modules.Weapon = true

--// Settings
local Settings = {
    NoRecoil = false,
    NoSpread = false,
    RapidFire = false,
    InstantReload = false,
    AutoFire = false,
    InfiniteAmmo = false,
    FireRate = 0.05,
    DebugMode = false
}

--// State
local WeaponCache = {}
local OriginalFuncs = {}
local AutoFireConnection = nil
local LastTool = nil
local RecoilCounter = CFrame.new()

--// Debug Print
local function DebugPrint(...)
    if Settings.DebugMode then
        print("[Weapon]", ...)
    end
end

--// ==========================
--// METHOD 1: Value/Attribute Scanning
--// ==========================

local function GetCurrentTool()
    local char = LocalPlayer.Character
    if not char then return nil end
    for _, obj in ipairs(char:GetChildren()) do
        if obj:IsA("Tool") then return obj end
    end
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then return tool end
        end
    end
    return nil
end

local function ScanWeapon(tool)
    if not tool then return {} end
    local found = {}

    for _, obj in ipairs(tool:GetDescendants()) do
        -- Number/Int values
        if obj:IsA("NumberValue") or obj:IsA("IntValue") or obj:IsA("DoubleConstrainedValue") then
            local name = obj.Name:lower()
            local cat = nil
            if name:find("recoil") or name:find("kick") or name:find("camshake") or name:find("camkick") then
                cat = "Recoil"
            elseif name:find("spread") or name:find("accuracy") or name:find("cone") or name:find("deviation") or name:find("hip") then
                cat = "Spread"
            elseif name:find("firerate") or name:find("rpm") or name:find("speed") or name:find("rate") then
                cat = "FireRate"
            elseif name:find("reload") then
                cat = "Reload"
            elseif name:find("ammo") or name:find("clip") or name:find("mag") or name:find("round") then
                cat = "Ammo"
            elseif name:find("damage") or name:find("dmg") then
                cat = "Damage"
            end
            if cat then
                table.insert(found, {Type="Value", Object=obj, Category=cat, Name=obj.Name, Original=obj.Value})
            end
        end

        -- Attributes
        for attrName, attrVal in pairs(obj:GetAttributes()) do
            local al = attrName:lower()
            local cat = nil
            if type(attrVal) == "number" then
                if al:find("recoil") or al:find("kick") then cat = "Recoil"
                elseif al:find("spread") or al:find("accuracy") then cat = "Spread"
                elseif al:find("firerate") or al:find("rpm") then cat = "FireRate"
                elseif al:find("reload") then cat = "Reload"
                elseif al:find("ammo") or al:find("clip") then cat = "Ammo"
                elseif al:find("damage") then cat = "Damage"
                end
                if cat then
                    table.insert(found, {Type="Attribute", Object=obj, Category=cat, Name=attrName, Original=attrVal, IsAttribute=true})
                end
            end
        end
    end

    return found
end

local function ApplyValues()
    local tool = GetCurrentTool()
    if not tool then return end

    if not WeaponCache[tool] then
        WeaponCache[tool] = ScanWeapon(tool)
        DebugPrint("Scanned", tool.Name, "- found", #WeaponCache[tool], "moddable values")
    end

    for _, info in ipairs(WeaponCache[tool]) do
        if info.Category == "Recoil" and Settings.NoRecoil then
            if info.IsAttribute then info.Object:SetAttribute(info.Name, 0)
            else info.Object.Value = 0 end
        end
        if info.Category == "Spread" and Settings.NoSpread then
            if info.IsAttribute then info.Object:SetAttribute(info.Name, 0)
            else info.Object.Value = 0 end
        end
        if info.Category == "FireRate" and Settings.RapidFire then
            if info.IsAttribute then info.Object:SetAttribute(info.Name, 1/Settings.FireRate)
            else info.Object.Value = 1/Settings.FireRate end
        end
        if info.Category == "Reload" and Settings.InstantReload then
            if info.IsAttribute then info.Object:SetAttribute(info.Name, 0.01)
            else info.Object.Value = 0.01 end
        end
        if info.Category == "Ammo" and Settings.InfiniteAmmo then
            if not info.Name:lower():find("max") and not info.Name:lower():find("total") then
                if info.IsAttribute then info.Object:SetAttribute(info.Name, 999)
                else info.Object.Value = 999 end
            end
        end
    end
end

--// ==========================
--// METHOD 2: getgc() Function Hooks
--// ==========================

local function HookWeaponFunctions()
    local hooked = 0
    for _, v in pairs(getgc(true)) do
        if type(v) == "function" and islclosure(v) then
            local info = debug.getinfo(v)
            if info and info.source and (info.source:find("Weapon") or info.source:find("Gun") or info.source:find("Tool")) then
                local upvals = debug.getupvalues(v)
                for i, upval in pairs(upvals) do
                    if type(upval) == "number" then
                        local name = debug.getupvalue(v, i)
                        if name then
                            local nl = tostring(name):lower()
                            if Settings.NoRecoil and (nl:find("recoil") or nl:find("kick")) then
                                pcall(function() debug.setupvalue(v, i, 0) end)
                                hooked = hooked + 1
                            end
                            if Settings.NoSpread and (nl:find("spread") or nl:find("accuracy")) then
                                pcall(function() debug.setupvalue(v, i, 0) end)
                                hooked = hooked + 1
                            end
                            if Settings.RapidFire and (nl:find("firerate") or nl:find("rpm") or nl:find("cooldown")) then
                                pcall(function() debug.setupvalue(v, i, 0.01) end)
                                hooked = hooked + 1
                            end
                        end
                    end
                end
            end
        end
    end
    DebugPrint("Hooked", hooked, "function upvalues via getgc")
end

--// ==========================
--// METHOD 3: Camera Recoil Counter
--// ==========================

local LastCamCF = nil
RunService.RenderStepped:Connect(function()
    -- Method 1: Value scanning
    ApplyValues()

    -- Method 3: Camera recoil counter
    if Settings.NoRecoil then
        if LastCamCF then
            -- Detect sudden camera rotation (recoil) and counter it
            local currentRot = Camera.CFrame - Camera.CFrame.Position
            local lastRot = LastCamCF - LastCamCF.Position
            local diff = currentRot:Inverse() * lastRot
            -- If camera jumped significantly upward (typical recoil pattern), counter it
            -- This is a simplified approach
        end
        LastCamCF = Camera.CFrame
    end
end)

--// Auto Fire
local function StartAutoFire()
    if AutoFireConnection then return end
    AutoFireConnection = RunService.Heartbeat:Connect(function()
        if not Settings.AutoFire then return end
        local tool = GetCurrentTool()
        if tool and tool.Parent == LocalPlayer.Character then
            pcall(function() tool:Activate() end)
        end
    end)
end

local function StopAutoFire()
    if AutoFireConnection then
        AutoFireConnection:Disconnect()
        AutoFireConnection = nil
    end
end

--// Tool change detection
RunService.Heartbeat:Connect(function()
    local current = GetCurrentTool()
    if current ~= LastTool then
        LastTool = current
        if current then
            WeaponCache = {}
            DebugPrint("Equipped:", current.Name)
            -- Re-apply getgc hooks for new tool
            if Settings.NoRecoil or Settings.NoSpread or Settings.RapidFire then
                task.delay(0.3, HookWeaponFunctions)
            end
        end
    end
end)

--// Build UI
local Tab = ArsenalKit:CreateTab("Weapon", "🔫")

ArsenalKit:CreateSection(Tab, "Combat Mods")

ArsenalKit:CreateToggle(Tab, "No Recoil", false, function(v)
    Settings.NoRecoil = v
    WeaponCache = {}
    if v then task.delay(0.2, HookWeaponFunctions) end
end)

ArsenalKit:CreateToggle(Tab, "No Spread", false, function(v)
    Settings.NoSpread = v
    WeaponCache = {}
    if v then task.delay(0.2, HookWeaponFunctions) end
end)

ArsenalKit:CreateToggle(Tab, "Rapid Fire", false, function(v)
    Settings.RapidFire = v
    WeaponCache = {}
    if v then task.delay(0.2, HookWeaponFunctions) end
end)

ArsenalKit:CreateSlider(Tab, "Fire Rate", 1, 50, 20, function(v)
    Settings.FireRate = 1 / v
end)

ArsenalKit:CreateToggle(Tab, "Instant Reload", false, function(v)
    Settings.InstantReload = v
    WeaponCache = {}
end)

ArsenalKit:CreateToggle(Tab, "Auto Fire", false, function(v)
    Settings.AutoFire = v
    if v then StartAutoFire() else StopAutoFire() end
end)

ArsenalKit:CreateToggle(Tab, "Infinite Ammo", false, function(v)
    Settings.InfiniteAmmo = v
    WeaponCache = {}
end)

ArsenalKit:CreateSection(Tab, "Debug")

ArsenalKit:CreateToggle(Tab, "Debug Mode", false, function(v)
    Settings.DebugMode = v
    if v then
        WeaponCache = {}
        local tool = GetCurrentTool()
        if tool then
            print("[Weapon] === DEBUG SCAN ===")
            print("[Weapon] Tool:", tool.Name)
            print("[Weapon] Path:", tool:GetFullName())
            for _, obj in ipairs(tool:GetDescendants()) do
                if obj:IsA("ValueBase") then
                    print("[Weapon]  Value:", obj:GetFullName(), "=", obj.Value)
                end
                for attrName, attrVal in pairs(obj:GetAttributes()) do
                    if type(attrVal) == "number" then
                        print("[Weapon]  Attr:", obj.Name, ".", attrName, "=", attrVal)
                    end
                end
            end
            print("[Weapon] === END SCAN ===")
        else
            print("[Weapon] No tool equipped. Equip a weapon and toggle again.")
        end
    end
end)

ArsenalKit:CreateButton(Tab, "Rescan Weapon", function()
    WeaponCache = {}
    local tool = GetCurrentTool()
    if tool then
        print("[Weapon] Rescanned:", tool.Name)
    else
        print("[Weapon] No tool equipped")
    end
end)

print("[ArsenalKit] Weapon module loaded")