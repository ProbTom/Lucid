-- MainTab.lua
local MainTab = {}

-- Core Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

-- Constants
local STATS_UPDATE_INTERVAL = 1.0
local DEFAULT_KEYBINDS = {
    AutoFish = Enum.KeyCode.F,
    AutoReel = Enum.KeyCode.R,
    AutoShake = Enum.KeyCode.X
}

-- Verify dependencies
if not getgenv().Tabs or not getgenv().Tabs.Main then
    error("MainTab: Missing UI dependencies")
    return false
end

local Tab = getgenv().Tabs.Main

-- Create sections
local FishingSection = Tab:AddSection("Fishing Controls")
local AutomationSection = Tab:AddSection("Automation")
local StatsSection = Tab:AddSection("Stats Tracking")
local KeybindSection = Tab:AddSection("Keybinds")

-- Fishing Controls
local autoFishToggle = FishingSection:AddToggle("AutoFish", {
    Title = "Auto Fish",
    Default = getgenv().Options.AutoFish,
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
    Default = getgenv().Options.AutoReel,
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
    Default = getgenv().Options.AutoShake,
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
    Default = getgenv().Options.AutoEquipBestRod,
    Callback = function(value)
        getgenv().Options.AutoEquipBestRod = value
        if value then
            getgenv().Functions.equipBestRod()
        end
    end
})

-- Stats Display System
local statsLabels = {
    FishCaught = StatsSection:AddLabel("Fish Caught: 0"),
    Coins = StatsSection:AddLabel("Coins: 0"),
    CurrentRod = StatsSection:AddLabel("Current Rod: None")
}

local function updateStats()
    pcall(function()
        if not LocalPlayer or not ReplicatedStorage.playerstats:FindFirstChild(LocalPlayer.Name) then
            return
        end
        
        local stats = ReplicatedStorage.playerstats[LocalPlayer.Name].Stats
        local fishCaught = stats:FindFirstChild("fishcaught") and stats.fishcaught.Value or 0
        local coins = stats:FindFirstChild("coins") and stats.coins.Value or 0
        local currentRod = stats:FindFirstChild("rod") and stats.rod.Value or "None"
        
        statsLabels.FishCaught:Set("Fish Caught: " .. tostring(fishCaught))
        statsLabels.Coins:Set("Coins: " .. tostring(coins))
        statsLabels.CurrentRod:Set("Current Rod: " .. currentRod)
    end)
end

-- Keybind System
local function setupKeybinds()
    KeybindSection:AddKeybind({
        Title = "Toggle Auto Fish",
        Default = DEFAULT_KEYBINDS.AutoFish,
        Callback = function()
            autoFishToggle:Set(not autoFishToggle.Value)
        end
    })
    
    KeybindSection:AddKeybind({
        Title = "Toggle Auto Reel",
        Default = DEFAULT_KEYBINDS.AutoReel,
        Callback = function()
            autoReelToggle:Set(not autoReelToggle.Value)
        end
    })
    
    KeybindSection:AddKeybind({
        Title = "Toggle Auto Shake",
        Default = DEFAULT_KEYBINDS.AutoShake,
        Callback = function()
            autoShakeToggle:Set(not autoShakeToggle.Value)
        end
    })
end

-- Quick Actions
FishingSection:AddButton({
    Title = "Force Cast Rod",
    Callback = function()
        getgenv().Functions.autoFish(LocalPlayer:WaitForChild("PlayerGui"))
    end
})

-- Initialize MainTab
local function InitializeMainTab()
    if not getgenv().Config then
        error("MainTab: Config not initialized")
        return false
    end
    
    if not getgenv().Functions then
        error("MainTab: Functions not initialized")
        return false
    end
    
    if not getgenv().Events then
        error("MainTab: Events not initialized")
        return false
    end
    
    -- Start stats update loop
    task.spawn(function()
        while task.wait(STATS_UPDATE_INTERVAL) do
            updateStats()
        end
    end)
    
    -- Setup keybinds
    setupKeybinds()
    
    -- Initial stats update
    updateStats()
    
    return true
end

-- Run initialization
if not InitializeMainTab() then
    return false
end

return MainTab
