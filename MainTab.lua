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

-- Verify dependencies with improved error handling
if not getgenv().Tabs then
    getgenv().Tabs = {}
end

if not getgenv().Tabs.Main then
    getgenv().Tabs.Main = getgenv().Window:AddTab({
        Title = "Main",
        Icon = "fish"
    })
end

local Tab = getgenv().Tabs.Main

-- Create sections with error checking
local function createSection(name)
    local success, section = pcall(function()
        return Tab:AddSection(name)
    end)
    
    if not success then
        warn("Failed to create section:", name)
        return Tab:AddSection("Backup " .. name)
    end
    
    return section
end

local FishingSection = createSection("Fishing Controls")
local AutomationSection = createSection("Automation")
local StatsSection = createSection("Stats Tracking")
local KeybindSection = createSection("Keybinds")

-- Enhanced toggle creation with feature availability checking
local function createToggle(section, id, options)
    -- Check if feature is available
    local isAvailable = true
    if getgenv().Compatibility then
        isAvailable = getgenv().Compatibility.IsFeatureAvailable(id)
    end

    local toggle = section:AddToggle(id, {
        Title = options.Title,
        Default = getgenv().Options[id] or false,
        Callback = function(value)
            if not isAvailable then
                getgenv().Functions.ShowNotification(
                    "Feature Unavailable",
                    options.Title .. " is currently unavailable"
                )
                return
            end

            getgenv().Options[id] = value
            
            if options.OnToggle then
                options.OnToggle(value)
            end
            
            getgenv().Functions.ShowNotification(
                options.Title,
                value and "Enabled" or "Disabled"
            )
        end
    })

    if not isAvailable then
        toggle:Set(false)
        toggle.Label.Text = toggle.Label.Text .. " (Unavailable)"
    end

    return toggle
end

-- Fishing Controls with improved error handling
local autoFishToggle = createToggle(FishingSection, "AutoFish", {
    Title = "Auto Fish",
    OnToggle = function(value)
        if value then
            getgenv().Events.StartAutoFishing()
        else
            getgenv().Events.StopAutoFishing()
        end
    end
})

local autoReelToggle = createToggle(FishingSection, "AutoReel", {
    Title = "Auto Reel",
    OnToggle = function(value)
        getgenv().Options.AutoReel = value
    end
})

local autoShakeToggle = createToggle(FishingSection, "AutoShake", {
    Title = "Auto Shake",
    OnToggle = function(value)
        getgenv().Options.AutoShake = value
    end
})

-- Automation Controls with error handling
local autoEquipToggle = createToggle(AutomationSection, "AutoEquipBestRod", {
    Title = "Auto Equip Best Rod",
    OnToggle = function(value)
        if value and getgenv().Functions.equipBestRod then
            getgenv().Functions.equipBestRod()
        end
    end
})

-- Enhanced Stats Display System
local statsLabels = {
    FishCaught = StatsSection:AddLabel("Fish Caught: Loading..."),
    Coins = StatsSection:AddLabel("Coins: Loading..."),
    CurrentRod = StatsSection:AddLabel("Current Rod: Loading...")
}

local function updateStats()
    pcall(function()
        if not LocalPlayer or not ReplicatedStorage:FindFirstChild("playerstats") then
            for _, label in pairs(statsLabels) do
                label:Set(label.Text:gsub("Loading...", "Unavailable"))
            end
            return
        end
        
        local stats = ReplicatedStorage.playerstats:FindFirstChild(LocalPlayer.Name)
        if not stats then return end
        
        stats = stats:FindFirstChild("Stats")
        if not stats then return end
        
        local fishCaught = stats:FindFirstChild("fishcaught") and stats.fishcaught.Value or 0
        local coins = stats:FindFirstChild("coins") and stats.coins.Value or 0
        local currentRod = stats:FindFirstChild("rod") and stats.rod.Value or "None"
        
        statsLabels.FishCaught:Set("Fish Caught: " .. tostring(fishCaught))
        statsLabels.Coins:Set("Coins: " .. tostring(coins))
        statsLabels.CurrentRod:Set("Current Rod: " .. currentRod)
    end)
end

-- Enhanced Keybind System with error handling
local function setupKeybinds()
    local function addKeybind(title, default, callback)
        pcall(function()
            KeybindSection:AddKeybind({
                Title = title,
                Default = default,
                Callback = callback
            })
        end)
    end

    addKeybind("Toggle Auto Fish", DEFAULT_KEYBINDS.AutoFish, function()
        autoFishToggle:Set(not autoFishToggle.Value)
    end)
    
    addKeybind("Toggle Auto Reel", DEFAULT_KEYBINDS.AutoReel, function()
        autoReelToggle:Set(not autoReelToggle.Value)
    end)
    
    addKeybind("Toggle Auto Shake", DEFAULT_KEYBINDS.AutoShake, function()
        autoShakeToggle:Set(not autoShakeToggle.Value)
    end)
end

-- Quick Actions with error handling
FishingSection:AddButton({
    Title = "Force Cast Rod",
    Callback = function()
        pcall(function()
            getgenv().Functions.autoFish(LocalPlayer:WaitForChild("PlayerGui"))
        end)
    end
})

-- Initialize MainTab with comprehensive error handling
local function InitializeMainTab()
    local requirements = {
        {name = "Config", value = getgenv().Config},
        {name = "Functions", value = getgenv().Functions},
        {name = "Events", value = getgenv().Events}
    }
    
    for _, req in ipairs(requirements) do
        if not req.value then
            warn("MainTab: Missing requirement -", req.name)
            return false
        end
    end
    
    -- Start stats update loop with error handling
    task.spawn(function()
        while task.wait(STATS_UPDATE_INTERVAL) do
            pcall(updateStats)
        end
    end)
    
    -- Setup keybinds
    pcall(setupKeybinds)
    
    -- Initial stats update
    pcall(updateStats)
    
    return true
end

-- Run initialization with error handling
if not InitializeMainTab() then
    warn("⚠️ Failed to initialize MainTab")
    return false
end

return MainTab
