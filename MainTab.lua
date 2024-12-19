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

-- Initialize required services
local Players = getService("Players")
local RunService = getService("RunService")
local VirtualUser = getService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

if not LocalPlayer then
    warn("LocalPlayer not found")
    return
end

-- Load Functions module with error handling
local Functions
local success, result = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/ProbTom/Lucid/main/functions.lua"))()
end)

if success then
    Functions = result
else
    warn("Failed to load Functions module:", result)
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
    if Options.autoCast.Value then
        RunService:BindToRenderStep("AutoCast", 1, function()
            if LocalPlayer.Character then
                Functions.autoCast(CastMode, LocalPlayer.Character, LocalPlayer.Character:FindFirstChild("HumanoidRootPart"))
            end
        end)
    else
        RunService:UnbindFromRenderStep("AutoCast")
    end
end)

-- Auto Shake Toggle with improved functionality
local autoShake = Tabs.Main:AddToggle("autoShake", {Title = "Auto Shake", Default = false})
autoShake:OnChanged(function()
    if Options.autoShake.Value then
        RunService:BindToRenderStep("AutoShake", 1, function()
            pcall(function()
                if LocalPlayer.PlayerGui:FindFirstChild("shakeui") and 
                   LocalPlayer.PlayerGui.shakeui.Enabled then
                    -- Direct method
                    LocalPlayer.PlayerGui.shakeui.safezone.button.Size = UDim2.new(1001, 0, 1001, 0)
                    VirtualUser:Button1Down(Vector2.new(1, 1))
                    task.wait(0.1)
                    VirtualUser:Button1Up(Vector2.new(1, 1))
                    
                    -- Functions module method
                    Functions.autoShake(ShakeMode, LocalPlayer.PlayerGui)
                end
            end)
        end)
    else
        RunService:UnbindFromRenderStep("AutoShake")
    end
end)

-- Auto Reel Toggle
local autoReel = Tabs.Main:AddToggle("autoReel", {Title = "Auto Reel", Default = false})
autoReel:OnChanged(function()
    if Options.autoReel.Value then
        RunService:BindToRenderStep("AutoReel", 1, function()
            if LocalPlayer and LocalPlayer.PlayerGui then
                Functions.autoReel(LocalPlayer.PlayerGui, ReelMode)
            end
        end)
    else
        RunService:UnbindFromRenderStep("AutoReel")
    end
end)

-- Freeze Character Toggle
local FreezeCharacter = Tabs.Main:AddToggle("FreezeCharacter", {Title = "Freeze Character", Default = false})
FreezeCharacter:OnChanged(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        hrp.Anchored = Options.FreezeCharacter.Value
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
    if Options.ZoneCast.Value and Zone then
        Functions.handleZoneCast(true, Zone, FishingZonesFolder, LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart"))
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
    if Options.ZoneCast.Value then
        Functions.handleZoneCast(true, Zone, FishingZonesFolder, LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart"))
    end
end)

-- Cleanup on script end
local function cleanup()
    RunService:UnbindFromRenderStep("AutoCast")
    RunService:UnbindFromRenderStep("AutoShake")
    RunService:UnbindFromRenderStep("AutoReel")
    
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.Anchored = false
    end
end

game:GetService("Players").PlayerRemoving:Connect(function(player)
    if player == LocalPlayer then
        cleanup()
    end
end)

return true
