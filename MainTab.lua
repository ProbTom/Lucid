-- Check for multiple executions
if getgenv().cuppink then
    warn("Lucid Hub: Already executed!")
    return
end
getgenv().cuppink = true

-- Check for required globals
if not getgenv().Tabs then
    warn("Tabs not found in global environment")
    return
end

if not getgenv().Fluent then
    warn("Fluent UI not found in global environment")
    return
end

-- Get required services with error handling
local function getService(serviceName)
    local success, service = pcall(function()
        return game:GetService(serviceName)
    end)
    if success then
        return service
    else
        warn("Failed to get service: " .. serviceName)
        return nil
    end
end

local Players = getService("Players")
local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    warn("LocalPlayer not found")
    return
end

local FishingZonesFolder = workspace:WaitForChild("zones"):WaitForChild("fishing")

-- Initialize state variables
local CastMode = "Legit"
local ShakeMode = "Navigation"
local ReelMode = "Blatant"
local Zone = nil

-- Main Section
local mainSection = Tabs.Main:AddSection("Auto Fishing")

-- Auto Cast Toggle
local autoCast = Tabs.Main:AddToggle("autoCast", {Title = "Auto Cast", Default = false})
autoCast:OnChanged(function()
    -- Empty callback
end)

-- Auto Shake Toggle
local autoShake = Tabs.Main:AddToggle("autoShake", {Title = "Auto Shake", Default = false})
autoShake:OnChanged(function()
    if Options.autoShake.Value then
        -- Start Auto Shake
        game:GetService("RunService"):BindToRenderStep("AutoShake", 1, function()
            pcall(function()
                if game.Players.LocalPlayer.PlayerGui:FindFirstChild("shakeui") and 
                   game.Players.LocalPlayer.PlayerGui.shakeui.Enabled then
                    game.Players.LocalPlayer.PlayerGui.shakeui.safezone.button.Size = UDim2.new(1001, 0, 1001, 0)
                    game:GetService("VirtualUser"):Button1Down(Vector2.new(1, 1))
                    game:GetService("VirtualUser"):Button1Up(Vector2.new(1, 1))
                end
            end)
        end)
    else
        -- Stop Auto Shake
        game:GetService("RunService"):UnbindFromRenderStep("AutoShake")
    end
end)

-- Auto Reel Toggle
local autoReel = Tabs.Main:AddToggle("autoReel", {Title = "Auto Reel", Default = false})
autoReel:OnChanged(function()
    -- Empty callback
end)

-- Freeze Character Toggle
local FreezeCharacter = Tabs.Main:AddToggle("FreezeCharacter", {Title = "Freeze Character", Default = false})
FreezeCharacter:OnChanged(function()
    -- Empty callback
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
    -- Empty callback
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
end)

return true
