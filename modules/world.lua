--// ArsenalKit Module: World
--// Features: Fullbright, No Fog, FOV Changer, No Shadows, Time Changer

local ArsenalKit = _G.ArsenalKit
--// Prevent double-load
if ArsenalKit.Modules and ArsenalKit.Modules.World then return end
ArsenalKit.Modules = ArsenalKit.Modules or {}
ArsenalKit.Modules.World = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local Camera = Workspace.CurrentCamera

--// Settings
local Settings = {
    Fullbright = false,
    NoFog = false,
    FOV = 90,
    NoShadows = false,
    TimeOfDay = 12,
    AmbientColor = Color3.fromRGB(255, 255, 255)
}

--// Original Values Cache
local OriginalAmbient = Lighting.Ambient
local OriginalBrightness = Lighting.Brightness
local OriginalFogStart = Lighting.FogStart
local OriginalFogEnd = Lighting.FogEnd
local OriginalFogColor = Lighting.FogColor
local OriginalGlobalShadows = Lighting.GlobalShadows
local OriginalTime = Lighting.TimeOfDay
local OriginalFOV = Camera.FieldOfView

--// Fullbright
RunService.RenderStepped:Connect(function()
    if Settings.Fullbright then
        Lighting.Ambient = Settings.AmbientColor
        Lighting.Brightness = 10
        Lighting.GlobalShadows = false
    elseif not Settings.NoShadows then
        Lighting.Ambient = OriginalAmbient
        Lighting.Brightness = OriginalBrightness
        Lighting.GlobalShadows = OriginalGlobalShadows
    end

    if Settings.NoFog then
        Lighting.FogStart = 0
        Lighting.FogEnd = 999999
        Lighting.FogColor = Color3.fromRGB(255, 255, 255)
    elseif not Settings.Fullbright then
        Lighting.FogStart = OriginalFogStart
        Lighting.FogEnd = OriginalFogEnd
        Lighting.FogColor = OriginalFogColor
    end

    if Settings.NoShadows then
        Lighting.GlobalShadows = false
    elseif not Settings.Fullbright then
        Lighting.GlobalShadows = OriginalGlobalShadows
    end

    Camera.FieldOfView = Settings.FOV
end)

--// Build UI
local Tab = ArsenalKit:CreateTab("World", "🌍")

ArsenalKit:CreateSection(Tab, "Visuals")

ArsenalKit:CreateToggle(Tab, "Fullbright", false, function(v)
    Settings.Fullbright = v
end)

ArsenalKit:CreateToggle(Tab, "No Fog", false, function(v)
    Settings.NoFog = v
end)

ArsenalKit:CreateToggle(Tab, "No Shadows", false, function(v)
    Settings.NoShadows = v
end)

ArsenalKit:CreateSlider(Tab, "FOV Changer", 30, 150, 90, function(v)
    Settings.FOV = v
end)

ArsenalKit:CreateSlider(Tab, "Time of Day", 0, 24, 12, function(v)
    Settings.TimeOfDay = v
    Lighting.TimeOfDay = v .. ":00:00"
end)

print("[ArsenalKit] World module loaded")