-- ItemsTab.lua
local ItemsTab = {}

-- Core Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Constants
local INVENTORY_UPDATE_INTERVAL = 1.0
local MAX_DISPLAY_ITEMS = 50

-- Initialize tab with error handling
if not getgenv().Tabs then
    getgenv().Tabs = {}
end

if not getgenv().Tabs.Items then
    getgenv().Tabs.Items = getgenv().Window:AddTab({
        Title = "Items",
        Icon = "package"
    })
end

local Tab = getgenv().Tabs.Items

-- Create sections with error handling
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

local AutoSellSection = createSection("Auto Sell")
local RaritySection = createSection("Rarity Selection")
local ChestSection = createSection("Chest Collection")
local InventorySection = createSection("Inventory Management")

-- Auto Sell Configuration with improved error handling
local autoSellToggle = AutoSellSection:AddToggle("AutoSell", {
    Title = "Auto Sell",
    Default = getgenv().Options.AutoSell or false,
    Callback = function(value)
        getgenv().Options.AutoSell = value
        
        pcall(function()
            if value then
                getgenv().Events.StartAutoSell()
            else
                getgenv().Events.StopAutoSell()
            end
            
            getgenv().Functions.ShowNotification(
                "Auto Sell",
                value and "Enabled" or "Disabled"
            )
        end)
    end
})

-- Enhanced Rarity Selection System
local rarityToggles = {}
if getgenv().Config and getgenv().Config.Items and getgenv().Config.Items.FishRarities then
    for _, rarity in ipairs(getgenv().Config.Items.FishRarities) do
        pcall(function()
            local toggle = RaritySection:AddToggle(rarity, {
                Title = rarity,
                Default = getgenv().State.SelectedRarities[rarity] or false,
                Callback = function(value)
                    if not getgenv().State.SelectedRarities then
                        getgenv().State.SelectedRarities = {}
                    end
                    getgenv().State.SelectedRarities[rarity] = value
                    
                    if getgenv().Config.Debug then
                        getgenv().Functions.ShowNotification(
                            "Rarity Toggle",
                            string.format("%s: %s", rarity, value and "Selected" or "Unselected")
                        )
                    end
                end
            })
            rarityToggles[rarity] = toggle
        end)
    end
end

-- Quick Rarity Selection Buttons with error handling
RaritySection:AddButton({
    Title = "Select All Rarities",
    Callback = function()
        pcall(function()
            for rarity, toggle in pairs(rarityToggles) do
                toggle:Set(true)
                if not getgenv().State.SelectedRarities then
                    getgenv().State.SelectedRarities = {}
                end
                getgenv().State.SelectedRarities[rarity] = true
            end
            getgenv().Functions.ShowNotification("Rarities", "Selected all rarities")
        end)
    end
})

RaritySection:AddButton({
    Title = "Deselect All Rarities",
    Callback = function()
        pcall(function()
            for rarity, toggle in pairs(rarityToggles) do
                toggle:Set(false)
                if not getgenv().State.SelectedRarities then
                    getgenv().State.SelectedRarities = {}
                end
                getgenv().State.SelectedRarities[rarity] = false
            end
            getgenv().Functions.ShowNotification("Rarities", "Deselected all rarities")
        end)
    end
})

-- Enhanced Chest Collection Configuration
local autoChestToggle = ChestSection:AddToggle("AutoChest", {
    Title = "Auto Collect Chests",
    Default = getgenv().Options.AutoCollectChests or false,
    Callback = function(value)
        getgenv().Options.AutoCollectChests = value
        
        pcall(function()
            if value then
                getgenv().Events.StartAutoCollectChests()
            else
                getgenv().Events.StopAutoCollectChests()
            end
            
            getgenv().Functions.ShowNotification(
                "Auto Chest",
                value and "Enabled" or "Disabled"
            )
        end)
    end
})

-- Chest Range Slider with validation
ChestSection:AddSlider("ChestRange", {
    Title = "Collection Range",
    Default = getgenv().Options.ChestRange or 50,
    Min = getgenv().Config.Items.ChestSettings.MinRange or 10,
    Max = getgenv().Config.Items.ChestSettings.MaxRange or 100,
    Rounding = 0,
    Callback = function(value)
        pcall(function()
            getgenv().Options.ChestRange = value
            
            if getgenv().Config.Debug then
                getgenv().Functions.ShowNotification(
                    "Chest Range",
                    "Set to " .. tostring(value)
                )
            end
        end)
    end
})

-- Enhanced Inventory Display System
local inventoryLabels = {
    TotalItems = InventorySection:AddLabel("Total Items: 0"),
    CommonItems = InventorySection:AddLabel("Common: 0"),
    RareItems = InventorySection:AddLabel("Rare: 0"),
    LegendaryItems = InventorySection:AddLabel("Legendary: 0")
}

local function updateInventoryDisplay()
    pcall(function()
        local backpack = LocalPlayer:WaitForChild("Backpack")
        local counts = {
            Total = 0,
            Common = 0,
            Rare = 0,
            Legendary = 0
        }
        
        for _, item in pairs(backpack:GetChildren()) do
            if item:FindFirstChild("values") and item.values:FindFirstChild("rarity") then
                counts.Total = counts.Total + 1
                local rarity = item.values.rarity.Value
                if counts[rarity] then
                    counts[rarity] = counts[rarity] + 1
                end
            end
        end
        
        inventoryLabels.TotalItems:Set("Total Items: " .. counts.Total)
        inventoryLabels.CommonItems:Set("Common: " .. counts.Common)
        inventoryLabels.RareItems:Set("Rare: " .. counts.Rare)
        inventoryLabels.LegendaryItems:Set("Legendary: " .. counts.Legendary)
    end)
end

-- Quick Actions with error handling
InventorySection:AddButton({
    Title = "Sell All Selected Rarities",
    Callback = function()
        pcall(function()
            local sold = 0
            if not getgenv().State.SelectedRarities then
                getgenv().State.SelectedRarities = {}
            end
            
            for rarity, selected in pairs(getgenv().State.SelectedRarities) do
                if selected then
                    getgenv().Functions.sellFish(rarity)
                    sold = sold + 1
                end
            end
            getgenv().Functions.ShowNotification("Inventory", "Selling items of " .. sold .. " rarities")
        end)
    end
})

-- Initialize ItemsTab with comprehensive error handling
local function InitializeItemsTab()
    local requirements = {
        {name = "Config", value = getgenv().Config},
        {name = "Functions", value = getgenv().Functions},
        {name = "Events", value = getgenv().Events}
    }
    
    for _, req in ipairs(requirements) do
        if not req.value then
            warn("ItemsTab: Missing requirement -", req.name)
            return false
        end
    end
    
    -- Start inventory update loop with error handling
    task.spawn(function()
        while task.wait(INVENTORY_UPDATE_INTERVAL) do
            pcall(updateInventoryDisplay)
        end
    end)
    
    -- Initial inventory update
    pcall(updateInventoryDisplay)
    
    return true
end

-- Run initialization with error handling
if not InitializeItemsTab() then
    warn("⚠️ Failed to initialize ItemsTab")
    return false
end

return ItemsTab
