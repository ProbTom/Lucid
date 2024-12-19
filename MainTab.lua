-- MainTab.lua
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Verify dependencies
if not getgenv().Tabs or not getgenv().Tabs.Main then
    error("MainTab: Missing UI dependencies")
    return false
end

local MainTab = getgenv().Tabs.Main

-- Create sections
local FishingSection = MainTab:AddSection("Fishing Controls")
local AutomationSection = MainTab:AddSection("Automation")
local StatsSection = MainTab:AddSection("Stats Tracking")

-- Fishing Controls
local autoFishToggle = FishingSection:AddToggle("AutoFish", {
    Title = "Auto Fish",
    Default = false,
    Callback = function(value)
        getgenv().Options.AutoFish = value
        if value then
            getgenv().Events.StartAutoFishing()
        else
            getgenv().Events.StopAutoFishing()
        end
        
        getgenv().Functions.ShowNotification(
            "Auto Fish",
            value and "Enabled" or "Disabled"
        )
    end
})

local autoReelToggle = FishingSection:AddToggle("AutoReel", {
    Title = "Auto Reel",
    Default = false,
    Callback = function(value)
        getgenv().Options.AutoReel = value
        getgenv().Functions.ShowNotification(
            "Auto Reel",
            value and "Enabled" or "Disabled"
        )
    end
})

local autoShakeToggle = FishingSection:AddToggle("AutoShake", {
    Title = "Auto Shake",
    Default = false,
    Callback = function(value)
        getgenv().Options.AutoShake = value
        getgenv().Functions.ShowNotification(
            "Auto Shake",
            value and "Enabled" or "Disabled"
        )
    end
})

-- Automation Controls
local autoEquipToggle = AutomationSection:AddToggle("AutoEquip", {
    Title = "Auto Equip Best Rod",
    Default = false,
    Callback = function(value)
        getgenv().Options.AutoEquipBestRod = value
        if value and getgenv().Functions then
            getgenv().Functions.equipBestRod()
        end
    end
})

-- Stats Display
local function updateStats()
    if not LocalPlayer or not ReplicatedStorage.playerstats:FindFirstChild(LocalPlayer.Name) then
        return
    end
    
    local stats = ReplicatedStorage.playerstats[LocalPlayer.Name].Stats
    local fishCaught = stats:FindFirstChild("fishcaught") and stats.fishcaught.Value or 0
    local coins = stats:FindFirstChild("coins") and stats.coins.Value or 0
    
    StatsSection:AddLabel(string.format("Fish Caught: %d", fishCaught))
    StatsSection:AddLabel(string.format("Coins: %d", coins))
end

-- Stats update loop
local function startStatsLoop()
    task.spawn(function()
        while task.wait(1) do
            pcall(updateStats)
        end
    end)
end

-- Initialize stats display
updateStats()
startStatsLoop()

-- Add keybinds
MainTab:AddKeybind({
    Title = "Toggle Auto Fish",
    Default = Enum.KeyCode.F,
    Callback = function()
        autoFishToggle:Set(not autoFishToggle.Value)
    end
})

MainTab:AddKeybind({
    Title = "Toggle Auto Reel",
    Default = Enum.KeyCode.R,
    Callback = function()
        autoReelToggle:Set(not autoReelToggle.Value)
    end
})

-- Add quick actions
local QuickActionsSection = MainTab:AddSection("Quick Actions")

QuickActionsSection:AddButton({
    Title = "Stop All Actions",
    Callback = function()
        autoFishToggle:Set(false)
        autoReelToggle:Set(false)
        autoShakeToggle:Set(false)
        autoEquipToggle:Set(false)
        getgenv().Events.CleanupAllConnections()
        getgenv().Functions.ShowNotification("Quick Actions", "All actions stopped")
    end
})

return true
