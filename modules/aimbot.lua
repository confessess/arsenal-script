-- ArsenalKit Combat Module v2.1
-- Aimbot + Silent Aim (HitPart remote) + Damage Multiplier + Hitbox Expander

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local ArsenalKit = _G.ArsenalKit
if not ArsenalKit then return end
if ArsenalKit.Features.CombatLoaded then return end
ArsenalKit.Features.CombatLoaded = true

local function AddConnection(conn)
    table.insert(ArsenalKit.Connections, conn)
    return conn
end

local function NewDrawing(type, props)
    local success, obj = pcall(function() return Drawing.new(type) end)
    if success then
        for k, v in pairs(props or {}) do obj[k] = v end
        return obj
    end
    return nil
end

--========================================================
-- REMOTES CACHE
--========================================================

local Remotes = {
    HitPart = ReplicatedStorage:WaitForChild("Events", 5) and ReplicatedStorage.Events:FindFirstChild("HitPart"),
    MyHitPart = ReplicatedStorage:WaitForChild("Events", 5) and ReplicatedStorage.Events:FindFirstChild("MyHitPart"),
    DamageEquation = ReplicatedStorage:WaitForChild("Events", 5) and ReplicatedStorage.Events:FindFirstChild("DamageEquation"),
    ReplicateProjectile = ReplicatedStorage:WaitForChild("Events", 5) and ReplicatedStorage.Events:FindFirstChild("ReplicateProjectile"),
    KillMe = ReplicatedStorage:WaitForChild("Events", 5) and ReplicatedStorage.Events:FindFirstChild("KillMe"),
    EquipGun = ReplicatedStorage:WaitForChild("Events", 5) and ReplicatedStorage.Events:FindFirstChild("EquipGun"),
    ApplyGun = ReplicatedStorage:WaitForChild("Events", 5) and ReplicatedStorage.Events:FindFirstChild("ApplyGun"),
    DoKillEffect = ReplicatedStorage:FindFirstChild("DoKillEffect"),
    GetWeapons = ReplicatedStorage:FindFirstChild("GetWeapons"),
    ChangeKillEffect = ReplicatedStorage:FindFirstChild("ChangeKillEffect"),
    GunSkinner = ReplicatedStorage:WaitForChild("Events", 5) and ReplicatedStorage.Events:FindFirstChild("GunSkinner"),
    HitDebug = ReplicatedStorage:WaitForChild("Events", 5) and ReplicatedStorage.Events:FindFirstChild("HitDebug"),
}

--========================================================
-- AIMBOT SETTINGS & LOGIC
--========================================================

local AimbotSettings = {
    Enabled = false,
    FOV = 120,
    Smoothing = 0.15,
    TargetPart = "Head",
    StickyTarget = false,
    WallCheck = true,
    TeamCheck = true,
    ShowFOV = true,
    AimKey = Enum.KeyCode.Q,
    CurrentTarget = nil
}

local FOVCircle = nil
if NewDrawing then
    FOVCircle = NewDrawing("Circle", {
        Visible = false,
        Thickness = 1.5,
        Color = Color3.fromRGB(0, 145, 255),
        Transparency = 0.7,
        Filled = false,
        NumSides = 64
    })
end

local function GetCharacter(plr)
    return plr.Character
end

local function GetHumanoid(character)
    return character:FindFirstChildOfClass("Humanoid")
end

local function IsTeammate(plr)
    if not AimbotSettings.TeamCheck then return false end
    return LocalPlayer.Team and plr.Team and LocalPlayer.Team == plr.Team
end

local function IsAlive(character)
    local hum = GetHumanoid(character)
    return hum and hum.Health > 0
end

local function IsVisible(targetPart)
    if not AimbotSettings.WallCheck then return true end
    if not targetPart then return false end
    local origin = Camera.CFrame.Position
    local direction = (targetPart.Position - origin).Unit
    local distance = (targetPart.Position - origin).Magnitude
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, targetPart.Parent}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    local result = Workspace:Raycast(origin, direction * distance, raycastParams)
    return result == nil
end

local function GetTargetPart(character)
    if AimbotSettings.TargetPart == "Head" then
        return character:FindFirstChild("Head")
    elseif AimbotSettings.TargetPart == "Torso" then
        return character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
    else
        return character:FindFirstChild("HumanoidRootPart")
    end
end

local function GetScreenPosition(pos)
    local screenPos, onScreen = Camera:WorldToViewportPoint(pos)
    return Vector2.new(screenPos.X, screenPos.Y), onScreen
end

local function GetClosestPlayer()
    local closest = nil
    local closestDist = AimbotSettings.FOV
    local mousePos = UserInputService:GetMouseLocation()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        local character = GetCharacter(plr)
        if not character then continue end
        if not IsAlive(character) then continue end
        if IsTeammate(plr) then continue end
        local targetPart = GetTargetPart(character)
        if not targetPart then continue end
        local screenPos, onScreen = GetScreenPosition(targetPart.Position)
        if not onScreen then continue end
        local distFromMouse = (screenPos - mousePos).Magnitude
        if distFromMouse > AimbotSettings.FOV then continue end
        if not IsVisible(targetPart) then continue end
        if distFromMouse < closestDist then
            closest = plr
            closestDist = distFromMouse
        end
    end
    return closest
end

local function GetStickyTarget()
    if not AimbotSettings.CurrentTarget then return nil end
    local character = GetCharacter(AimbotSettings.CurrentTarget)
    if not character then return nil end
    if not IsAlive(character) then return nil end
    if IsTeammate(AimbotSettings.CurrentTarget) then return nil end
    local targetPart = GetTargetPart(character)
    if not targetPart then return nil end
    local screenPos, onScreen = GetScreenPosition(targetPart.Position)
    if not onScreen then return nil end
    local mousePos = UserInputService:GetMouseLocation()
    local distFromMouse = (screenPos - mousePos).Magnitude
    if distFromMouse > AimbotSettings.FOV * 1.5 then return nil end
    if AimbotSettings.WallCheck and not IsVisible(targetPart) then return nil end
    return AimbotSettings.CurrentTarget
end

AddConnection(RunService.RenderStepped:Connect(function()
    if FOVCircle then
        FOVCircle.Position = UserInputService:GetMouseLocation()
        FOVCircle.Radius = AimbotSettings.FOV
        FOVCircle.Visible = AimbotSettings.Enabled and AimbotSettings.ShowFOV
        FOVCircle.Color = AimbotSettings.Enabled and Color3.fromRGB(72, 230, 155) or Color3.fromRGB(0, 145, 255)
    end
    if not AimbotSettings.Enabled then
        AimbotSettings.CurrentTarget = nil
        return
    end
    local target
    if AimbotSettings.StickyTarget and AimbotSettings.CurrentTarget then
        target = GetStickyTarget()
    end
    if not target then
        target = GetClosestPlayer()
        AimbotSettings.CurrentTarget = target
    end
    if not target then return end
    local character = GetCharacter(target)
    if not character then return end
    local targetPart = GetTargetPart(character)
    if not targetPart then return end
    local screenPos = Camera:WorldToViewportPoint(targetPart.Position)
    local mousePos = UserInputService:GetMouseLocation()
    local targetScreenPos = Vector2.new(screenPos.X, screenPos.Y)
    local delta = targetScreenPos - mousePos
    local smooth = AimbotSettings.Smoothing
    local moveX = delta.X * smooth
    local moveY = delta.Y * smooth
    if mousemoverel then
        mousemoverel(moveX, moveY)
    else
        local currentCF = Camera.CFrame
        local targetCF = CFrame.new(currentCF.Position, targetPart.Position)
        Camera.CFrame = currentCF:Lerp(targetCF, smooth)
    end
end))

--========================================================
-- SILENT AIM (HitPart Remote)
--========================================================

local SilentAimSettings = {
    Enabled = false,
    TargetPart = "Head",
    TeamCheck = true,
    WallCheck = false,
    AutoFire = false
}

local function SilentAimGetTarget()
    local closest = nil
    local closestDist = math.huge
    local mousePos = UserInputService:GetMouseLocation()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        local character = GetCharacter(plr)
        if not character then continue end
        if not IsAlive(character) then continue end
        if SilentAimSettings.TeamCheck then
            if LocalPlayer.Team and plr.Team and LocalPlayer.Team == plr.Team then continue end
        end
        local part = character:FindFirstChild(SilentAimSettings.TargetPart) or character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart")
        if not part then continue end
        local screenPos, onScreen = GetScreenPosition(part.Position)
        if not onScreen then continue end
        local dist = (screenPos - mousePos).Magnitude
        if dist < closestDist then
            closest = plr
            closestDist = dist
        end
    end
    return closest
end

local function FireSilentAim()
    if not SilentAimSettings.Enabled then return end
    if not Remotes.HitPart then return end
    local target = SilentAimGetTarget()
    if not target then return end
    local character = GetCharacter(target)
    if not character then return end
    local part = character:FindFirstChild(SilentAimSettings.TargetPart) or character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart")
    if not part then return end

    local hitPos = part.Position
    local normal = (Camera.CFrame.Position - hitPos).Unit
    local material = Enum.Material.Plastic

    -- Arsenal HitPart signature: FireServer(Part, Position, Normal, Material, Configuration, ...)
    pcall(function()
        Remotes.HitPart:FireServer(part, hitPos, normal, material, workspace.Terrain)
    end)

    -- Also fire MyHitPart if it exists (client-side validation)
    if Remotes.MyHitPart then
        pcall(function()
            Remotes.MyHitPart:FireServer(part, hitPos, normal, material)
        end)
    end
end

-- Hook mouse clicks for silent aim
AddConnection(UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        if SilentAimSettings.Enabled then
            FireSilentAim()
        end
    end
end))

-- Auto Fire for silent aim
AddConnection(RunService.RenderStepped:Connect(function()
    if SilentAimSettings.Enabled and SilentAimSettings.AutoFire then
        if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
            FireSilentAim()
        end
    end
end))

--========================================================
-- DAMAGE MULTIPLIER (DamageEquation hook)
--========================================================

local DamageSettings = {
    Enabled = false,
    Multiplier = 2,
    OneShot = false
}

-- Hook DamageEquation if it's a RemoteFunction
if Remotes.DamageEquation and Remotes.DamageEquation:IsA("RemoteFunction") then
    local oldInvoke = Remotes.DamageEquation.InvokeServer
    Remotes.DamageEquation.InvokeServer = function(self, ...)
        if DamageSettings.Enabled then
            local args = {...}
            -- Arsenal DamageEquation typically returns or takes damage values
            -- Try to find numeric damage values in args and multiply them
            for i, v in pairs(args) do
                if typeof(v) == "number" and v > 0 and v < 200 then
                    if DamageSettings.OneShot then
                        args[i] = 999
                    else
                        args[i] = v * DamageSettings.Multiplier
                    end
                end
            end
            return oldInvoke(self, table.unpack(args))
        end
        return oldInvoke(self, ...)
    end
end

-- Hook DamageEquation if it's a RemoteEvent (OnClientEvent)
if Remotes.DamageEquation and Remotes.DamageEquation:IsA("RemoteEvent") then
    AddConnection(Remotes.DamageEquation.OnClientEvent:Connect(function(...)
        if DamageSettings.Enabled then
            -- If server sends damage to client, we can modify it here
            -- But typically we want to modify outgoing damage, not incoming
        end
    end))
end

-- Alternative: Hook tool damage values directly
local function ApplyDamageMultiplier()
    if not DamageSettings.Enabled then return end
    local character = LocalPlayer.Character
    if not character then return end
    local tool = character:FindFirstChildOfClass("Tool")
    if not tool then return end
    local config = tool:FindFirstChild("Config") or tool:FindFirstChild("Settings") or tool:FindFirstChild("Values")
    if config then
        local damage = config:FindFirstChild("Damage") or config:FindFirstChild("BaseDamage") or config:FindFirstChild("HitDamage")
        if damage and typeof(damage.Value) == "number" then
            if DamageSettings.OneShot then
                damage.Value = 999
            else
                damage.Value = damage.Value * DamageSettings.Multiplier
            end
        end
        local headMult = config:FindFirstChild("HeadshotMultiplier") or config:FindFirstChild("HeadDamage")
        if headMult and typeof(headMult.Value) == "number" then
            if DamageSettings.OneShot then
                headMult.Value = 999
            else
                headMult.Value = headMult.Value * DamageSettings.Multiplier
            end
        end
    end
end

AddConnection(RunService.Heartbeat:Connect(ApplyDamageMultiplier))

-- Also hook HitPart to inject massive damage via one-shot
local oldHitPartFire = nil
if Remotes.HitPart and Remotes.HitPart:IsA("RemoteEvent") then
    oldHitPartFire = Remotes.HitPart.FireServer
    Remotes.HitPart.FireServer = function(self, ...)
        local args = {...}
        if DamageSettings.Enabled and DamageSettings.OneShot then
            -- Try to inject one-shot damage into HitPart args
            -- Arsenal HitPart: FireServer(Part, Position, Normal, Material, Configuration)
            -- We can't directly set damage here, but we can ensure it hits the head
            if #args >= 1 and args[1] and args[1]:IsA("BasePart") then
                local part = args[1]
                local character = part:FindFirstAncestorOfClass("Model")
                if character then
                    local head = character:FindFirstChild("Head")
                    if head then
                        args[1] = head
                        args[2] = head.Position
                    end
                end
            end
        end
        return oldHitPartFire(self, table.unpack(args))
    end
end

--========================================================
-- HITBOX EXPANDER
--========================================================

local HitboxSettings = {
    Enabled = false,
    Size = 13
}

local HitboxParts = {"RightUpperLeg", "LeftUpperLeg", "HeadHB", "HumanoidRootPart"}
local OriginalData = {}

local function StoreOriginal(part)
    if not OriginalData[part] then
        OriginalData[part] = {
            Size = part.Size,
            Transparency = part.Transparency,
            CanCollide = part.CanCollide
        }
    end
end

local function ExpandHitbox(character, size)
    for _, partName in pairs(HitboxParts) do
        local part = character:FindFirstChild(partName)
        if part and part:IsA("BasePart") then
            StoreOriginal(part)
            part.Size = Vector3.new(size, size, size)
            part.Transparency = 1
            part.CanCollide = false
        end
    end
end

local function RestoreHitbox(character)
    for _, partName in pairs(HitboxParts) do
        local part = character:FindFirstChild(partName)
        if part and OriginalData[part] then
            part.Size = OriginalData[part].Size
            part.Transparency = OriginalData[part].Transparency
            part.CanCollide = OriginalData[part].CanCollide
            OriginalData[part] = nil
        end
    end
end

local function ProcessAllHitboxes()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            if HitboxSettings.Enabled then
                ExpandHitbox(plr.Character, HitboxSettings.Size)
            else
                RestoreHitbox(plr.Character)
            end
        end
    end
end

AddConnection(Players.PlayerAdded:Connect(function(plr)
    if HitboxSettings.Enabled then
        plr.CharacterAdded:Connect(function(char)
            task.wait(0.5)
            if HitboxSettings.Enabled then
                ExpandHitbox(char, HitboxSettings.Size)
            end
        end)
    end
end))

for _, plr in pairs(Players:GetPlayers()) do
    if plr ~= LocalPlayer then
        plr.CharacterAdded:Connect(function(char)
            task.wait(0.5)
            if HitboxSettings.Enabled then
                ExpandHitbox(char, HitboxSettings.Size)
            end
        end)
        if plr.Character then
            ExpandHitbox(plr.Character, HitboxSettings.Size)
        end
    end
end

AddConnection(RunService.Heartbeat:Connect(function()
    if HitboxSettings.Enabled then
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                ExpandHitbox(plr.Character, HitboxSettings.Size)
            end
        end
    end
end))

--========================================================
-- UI
--========================================================

local CombatTab = ArsenalKit:CreateTab("Combat", "C")

-- Aimbot Section
local AimbotSection = ArsenalKit:CreateSection(CombatTab, "AIMBOT", "Mouse-movement aim assistance.")
ArsenalKit:CreateToggle(AimbotSection, "Aimbot Enabled", false, function(state) AimbotSettings.Enabled = state end)
ArsenalKit:CreateToggle(AimbotSection, "Show FOV Circle", true, function(state) AimbotSettings.ShowFOV = state end)
ArsenalKit:CreateSlider(AimbotSection, "FOV", 10, 360, 120, function(val) AimbotSettings.FOV = val end)
ArsenalKit:CreateSlider(AimbotSection, "Smoothing", 1, 100, 15, function(val) AimbotSettings.Smoothing = val / 100 end)
ArsenalKit:CreateDropdown(AimbotSection, "Target Part", {"Head", "Torso", "HumanoidRootPart"}, "Head", function(choice) AimbotSettings.TargetPart = choice end)
ArsenalKit:CreateKeybind(AimbotSection, "Aim Key", Enum.KeyCode.Q, function() AimbotSettings.Enabled = not AimbotSettings.Enabled end)
ArsenalKit:CreateToggle(AimbotSection, "Sticky Target", false, function(state) AimbotSettings.StickyTarget = state end)
ArsenalKit:CreateToggle(AimbotSection, "Wall Check", true, function(state) AimbotSettings.WallCheck = state end)
ArsenalKit:CreateToggle(AimbotSection, "Team Check", true, function(state) AimbotSettings.TeamCheck = state end)

-- Silent Aim Section
local SilentAimSection = ArsenalKit:CreateSection(CombatTab, "SILENT AIM", "Server-side hit registration via HitPart remote.")
ArsenalKit:CreateToggle(SilentAimSection, "Silent Aim Enabled", false, function(state) SilentAimSettings.Enabled = state end)
ArsenalKit:CreateToggle(SilentAimSection, "Auto Fire", false, function(state) SilentAimSettings.AutoFire = state end)
ArsenalKit:CreateDropdown(SilentAimSection, "Silent Aim Part", {"Head", "HumanoidRootPart", "Torso"}, "Head", function(choice) SilentAimSettings.TargetPart = choice end)
ArsenalKit:CreateToggle(SilentAimSection, "Silent Team Check", true, function(state) SilentAimSettings.TeamCheck = state end)

-- Damage Multiplier Section
local DamageSection = ArsenalKit:CreateSection(CombatTab, "DAMAGE MULTIPLIER", "Multiply outgoing damage via DamageEquation hook.")
ArsenalKit:CreateToggle(DamageSection, "Damage Multiplier", false, function(state) DamageSettings.Enabled = state end)
ArsenalKit:CreateSlider(DamageSection, "Multiplier", 1, 10, 2, function(val) DamageSettings.Multiplier = val end)
ArsenalKit:CreateToggle(DamageSection, "One Shot", false, function(state) DamageSettings.OneShot = state end)

-- Hitbox Expander Section
local HitboxSection = ArsenalKit:CreateSection(CombatTab, "HITBOX EXPANDER", "Expand enemy hitboxes for easier hits.")
ArsenalKit:CreateToggle(HitboxSection, "Enable Hitbox Expander", false, function(state)
    HitboxSettings.Enabled = state
    ProcessAllHitboxes()
end)
ArsenalKit:CreateSlider(HitboxSection, "Hitbox Size", 2, 25, 13, function(val)
    HitboxSettings.Size = val
    if HitboxSettings.Enabled then
        ProcessAllHitboxes()
    end
end)

print("[ArsenalKit] Combat module loaded (Aimbot + Silent Aim + Damage Multiplier + Hitbox Expander)")