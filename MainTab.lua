-- Check for multiple executions
if getgenv().cuppink then
    warn("Lucid Hub: Already executed!")
    return
end
getgenv().cuppink = true

-- Load functions
local Functions = loadstring(game:HttpGet("https://raw.githubusercontent.com/ProbTom/Lucid/main/functions.lua"))()

-- Get required services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")

-- Initialize local variables
local LocalPlayer = Players.LocalPlayer
local LocalCharacter = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = LocalCharacter:FindFirstChild("HumanoidRootPart")
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local FishingZonesFolder = workspace:WaitForChild("zones"):WaitForChild("fishing")

-- Initialize state variables
local CastMode = "Legit"
local ShakeMode = "Navigation"
local ReelMode = "Blatant"
local autoCastEnabled = false
local autoShakeEnabled = false
local autoReelEnabled = false
local FreezeChar = false
local ZoneCast = false
local Zone = nil

-- Initialize connections
local autoShakeConnection
local autoReelConnection

-- Main Tab Section
local Options = getgenv().Options
local Tabs = getgenv().Tabs

-- Add Sections
local mainSection = Tabs.Main:AddSection("Auto Fishing")

-- Auto Cast Toggle
local autoCast = Tabs.Main:AddToggle("autoCast", {Title = "Auto Cast", Default = false})
autoCast:OnChanged(function()
    if Options.autoCast.Value then
        autoCastEnabled = true
        local RodName = ReplicatedStorage.playerstats[LocalPlayer.Name].Stats.rod.Value
        if LocalPlayer.Backpack:FindFirstChild(RodName) then
            LocalPlayer.Character.Humanoid:EquipTool(LocalPlayer.Backpack:FindFirstChild(RodName))
        end
        Functions.autoCast(CastMode, LocalCharacter, HumanoidRootPart)
    else
        autoCastEnabled = false
    end
end)

-- Auto Shake Toggle
local autoShake = Tabs.Main:AddToggle("autoShake", {Title = "Auto Shake", Default = false})
autoShake:OnChanged(function()
    if Options.autoShake.Value then
        autoShakeEnabled = true
        if not autoShakeConnection then
            autoShakeConnection = RunService.RenderStepped:Connect(function()
                Functions.autoShake(ShakeMode, PlayerGui)
            end)
        end
    else
        autoShakeEnabled = false
        if autoShakeConnection then
            autoShakeConnection:Disconnect()
            autoShakeConnection = nil
        end
    end
end)

-- Auto Reel Toggle
local autoReel = Tabs.Main:AddToggle("autoReel", {Title = "Auto Reel", Default = false})
autoReel:OnChanged(function()
    if Options.autoReel.Value then
        autoReelEnabled = true
        if not autoReelConnection then
            autoReelConnection = RunService.RenderStepped:Connect(function()
                Functions.autoReel(PlayerGui, ReelMode)
            end)
        end
    else
        autoReelEnabled = false
        if autoReelConnection then
            autoReelConnection:Disconnect()
            autoReelConnection = nil
        end
    end
end)

-- Freeze Character Toggle
local FreezeCharacter = Tabs.Main:AddToggle("FreezeCharacter", {Title = "Freeze Character", Default = false})
FreezeCharacter:OnChanged(function()
    local oldpos = HumanoidRootPart.CFrame
    FreezeChar = Options.FreezeCharacter.Value
    
    if FreezeChar then
        spawn(function()
            while FreezeChar and HumanoidRootPart do
                HumanoidRootPart.CFrame = oldpos
                RunService.RenderStepped:Wait()
            end
        end)
    end
end)

-- Mode Section
local modeSection = Tabs.Main:AddSection("Mode Fishing")

-- Cast Mode Dropdown
local castModeDropdown = Tabs.Main:AddDropdown("CastMode", {
    Title = "Cast Mode",
    Values = {"Legit", "Blatant"},
    Multi = false,
    Default = CastMode
})
castModeDropdown:OnChanged(function(Value)
    CastMode = Value
end)

-- Shake Mode Dropdown
local shakeModeDropdown = Tabs.Main:AddDropdown("ShakeMode", {
    Title = "Shake Mode",
    Values = {"Navigation", "Mouse"},
    Multi = false,
    Default = ShakeMode
})
shakeModeDropdown:OnChanged(function(Value)
    ShakeMode = Value
end)

-- Reel Mode Dropdown
local reelModeDropdown = Tabs.Main:AddDropdown("ReelMode", {
    Title = "Reel Mode",
    Values = {"Legit", "Blatant"},
    Multi = false,
    Default = ReelMode
})
reelModeDropdown:OnChanged(function(Value)
    ReelMode = Value
end)

-- Zone Cast Section
local zoneSection = Tabs.Main:AddSection("Zone Settings")

-- Zone Cast Toggle
local zoneToggle = Tabs.Main:AddToggle("ZoneCast", {Title = "Zone Cast", Default = false})
zoneToggle:OnChanged(function()
    ZoneCast = Options.ZoneCast.Value
    if ZoneCast then
        Functions.handleZoneCast(ZoneCast, Zone, FishingZonesFolder, HumanoidRootPart)
    end
end)

-- Zone Selection Dropdown
local zones = {}
for _, zone in ipairs(FishingZonesFolder:GetChildren()) do
    table.insert(zones, zone.Name)
end

local zoneDropdown = Tabs.Main:AddDropdown("ZoneSelect", {
    Title = "Select Zone",
    Values = zones,
    Multi = false,
    Default = zones[1]
})
zoneDropdown:OnChanged(function(Value)
    Zone = Value
    if ZoneCast then
        Functions.handleZoneCast(ZoneCast, Zone, FishingZonesFolder, HumanoidRootPart)
    end
end)

-- Setup Event Connections
PlayerGui.DescendantAdded:Connect(function(descendant)
    if autoShakeEnabled and descendant.Name == "button" 
    and descendant.Parent and descendant.Parent.Name == "safezone" then
        Functions.autoShake(ShakeMode, PlayerGui)
    end
    
    if autoReelEnabled and descendant.Name == "playerbar" 
    and descendant.Parent and descendant.Parent.Name == "bar" then
        Functions.autoReel(PlayerGui, ReelMode)
    end
end)

-- Anti-AFK
LocalPlayer.Idled:Connect(function()
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
end)

return true
