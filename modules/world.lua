-- ArsenalKit World Module
-- Fullbright, no fog, custom sky, FOV changer

local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

local ArsenalKit = _G.ArsenalKit
if not ArsenalKit then return end
if ArsenalKit.Features.WorldLoaded then return end
ArsenalKit.Features.WorldLoaded = true

local Settings = {
    Fullbright = false,
    NoFog = false,
    CustomSky = false,
    SkyType = "Night",
    FOVChanger = false,
    FOVValue = 90
}

local function AddConnection(conn)
    table.insert(ArsenalKit.Connections, conn)
    return conn
end

local WorldTab = ArsenalKit:CreateTab("World", "◆")

local Section1 = ArsenalKit:CreateSection(WorldTab, "WORLD VISUALS", "Environment and world visualization options.")

ArsenalKit:CreateToggle(Section1, "Fullbright", false, function(state)
    Settings.Fullbright = state
    if state then
        Lighting.Brightness = 10
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
    else
        Lighting.Brightness = 2
        Lighting.GlobalShadows = true
        Lighting.Ambient = Color3.fromRGB(128, 128, 128)
        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    end
end)

ArsenalKit:CreateToggle(Section1, "No Fog", false, function(state)
    Settings.NoFog = state
    if state then
        Lighting.FogStart = 999999
        Lighting.FogEnd = 999999
        Lighting.FogColor = Color3.fromRGB(0, 0, 0)
    end
end)

ArsenalKit:CreateToggle(Section1, "Custom Sky", false, function(state)
    Settings.CustomSky = state
    if state then
        for _, v in pairs(Lighting:GetChildren()) do
            if v:IsA("Sky") then v:Destroy() end
        end
        local sky = Instance.new("Sky")
        if Settings.SkyType == "Night" then
            sky.SkyboxBk = "rbxassetid://159454299"
            sky.SkyboxDn = "rbxassetid://159454299"
            sky.SkyboxFt = "rbxassetid://159454299"
            sky.SkyboxLf = "rbxassetid://159454299"
            sky.SkyboxRt = "rbxassetid://159454299"
            sky.SkyboxUp = "rbxassetid://159454299"
        elseif Settings.SkyType == "Space" then
            sky.SkyboxBk = "rbxassetid://159248188"
            sky.SkyboxDn = "rbxassetid://159248188"
            sky.SkyboxFt = "rbxassetid://159248188"
            sky.SkyboxLf = "rbxassetid://159248188"
            sky.SkyboxRt = "rbxassetid://159248188"
            sky.SkyboxUp = "rbxassetid://159248188"
        elseif Settings.SkyType == "Sunset" then
            sky.SkyboxBk = "rbxassetid://150335524"
            sky.SkyboxDn = "rbxassetid://150335524"
            sky.SkyboxFt = "rbxassetid://150335524"
            sky.SkyboxLf = "rbxassetid://150335524"
            sky.SkyboxRt = "rbxassetid://150335524"
            sky.SkyboxUp = "rbxassetid://150335524"
        end
        sky.Parent = Lighting
    end
end)

ArsenalKit:CreateDropdown(Section1, "Sky Type", {"Night", "Space", "Sunset"}, "Night", function(choice)
    Settings.SkyType = choice
end)

ArsenalKit:CreateToggle(Section1, "FOV Changer", false, function(state)
    Settings.FOVChanger = state
end)

ArsenalKit:CreateSlider(Section1, "FOV", 30, 140, 90, function(val)
    Settings.FOVValue = val
end)

local WorldConnection = AddConnection(RunService.RenderStepped:Connect(function()
    if Settings.FOVChanger then
        local camera = workspace.CurrentCamera
        if camera then camera.FieldOfView = Settings.FOVValue end
    end
    if Settings.NoFog then
        Lighting.FogStart = 999999
        Lighting.FogEnd = 999999
    end
    if Settings.Fullbright then
        Lighting.Brightness = 10
        Lighting.GlobalShadows = false
    end
end))

print("[ArsenalKit] World module loaded")