-- ArsenalKit Misc Module
-- Anti-AFK, hitbox expander

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local ArsenalKit = _G.ArsenalKit
if not ArsenalKit then return end
if ArsenalKit.Features.MiscLoaded then return end
ArsenalKit.Features.MiscLoaded = true

local Settings = {
    AntiAFK = false,
    HitboxExpander = false,
    HitboxSize = 5,
    HitboxTransparency = 0.7
}

local MiscTab = ArsenalKit:CreateTab("Misc")

ArsenalKit:CreateSection(MiscTab, "Utilities")
ArsenalKit:CreateToggle(MiscTab, "Anti-AFK", false, function(state)
    Settings.AntiAFK = state
end)

ArsenalKit:CreateSection(MiscTab, "Hitbox Expander")
ArsenalKit:CreateToggle(MiscTab, "Expand Hitboxes", false, function(state)
    Settings.HitboxExpander = state
    if not state then
        -- Reset all hitboxes
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local character = player.Character
                if character then
                    local head = character:FindFirstChild("Head")
                    if head then
                        head.Size = Vector3.new(2, 1, 1)
                        head.Transparency = 0
                        head.CanCollide = true
                    end
                end
            end
        end
    end
end)

ArsenalKit:CreateSlider(MiscTab, "Hitbox Size", 2, 20, 5, function(val)
    Settings.HitboxSize = val
end)

ArsenalKit:CreateSlider(MiscTab, "Hitbox Transparency", 0, 100, 70, function(val)
    Settings.HitboxTransparency = val / 100
end)

-- Anti-AFK
LocalPlayer.Idled:Connect(function()
    if Settings.AntiAFK then
        VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        wait(1)
        VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    end
end)

-- Hitbox expander loop
local MiscConnection = RunService.Heartbeat:Connect(function()
    if Settings.HitboxExpander then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local character = player.Character
                if character then
                    local head = character:FindFirstChild("Head")
                    if head then
                        head.Size = Vector3.new(Settings.HitboxSize, Settings.HitboxSize, Settings.HitboxSize)
                        head.Transparency = Settings.HitboxTransparency
                        head.CanCollide = false
                        head.Material = Enum.Material.Neon
                        head.Color = Color3.fromRGB(255, 0, 0)
                    end
                end
            end
        end
    end
end)

table.insert(ArsenalKit.Connections, MiscConnection)

print("[ArsenalKit] Misc module loaded")