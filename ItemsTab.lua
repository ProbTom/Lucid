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

-- Verify dependencies
if not getgenv().Tabs or not getgenv().Tabs.Items then
    error("ItemsTab: Missing UI dependencies")
    return false
end

local Tab = getgenv().Tabs.Items

-- Create sections
local AutoSellSection = Tab:AddSection("Auto Sell")
local RaritySection = Tab:AddSection("Rarity Selection")
local ChestSection = Tab:AddSection("Chest Collection")
local InventorySection = Tab:AddSection("Inventory Management")

-- Auto Sell Configuration
local autoSellToggle = AutoSellSection:AddToggle("AutoSell", {
    Title = "Auto Sell",
    Default = getgenv().Options.AutoSell,
    Callback = function(value)
        getgenv().Options.AutoSell = value
        
        if value then
            getgenv().Events.StartAutoSell()
        else
            getgenv().Events.StopAutoSell()
        end
        
        getgenv().Functions.ShowNotification(
            "Auto Sell",
            value and "Enabled" or "Disabled"
        )
    end
})

-- Rarity Selection System
local rarityToggles = {}
for _, rarity in ipairs(getgenv().Config.Items.FishRarities) do
    local toggle = RaritySection:AddToggle(rarity, {
        Title = rarity,
        Default = getgenv().State.SelectedRarities[rarity] or false,
        Callback = function(value)
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
end

-- Quick Rarity Selection Buttons
RaritySection:AddButton({
    Title = "Select All Rarities",
    Callback = function()
        for rarity, toggle in pairs(rarityToggles) do
            toggle:Set(true)
            getgenv().State.SelectedRarities[rarity] = true
        end
        getgenv().Functions.ShowNotification("Rarities", "Selected all rarities")
    end
})

RaritySection:AddButton({
    Title = "Deselect All Rarities",
    Callback = function()
        for rarity, toggle in pairs(rarityToggles) do
            toggle:Set(false)
            getgenv().State.SelectedRarities[rarity] = false
        end
        getgenv().Functions.ShowNotification("Rarities", "Deselected all rarities")
    end
})

-- Chest Collection Configuration
local autoChestToggle = ChestSection:AddToggle("AutoChest", {
    Title = "Auto Collect Chests",
    Default = getgenv().Options.AutoCollectChests,
    Callback = function(value)
        getgenv().Options.AutoCollectChests = value
        
        if value then
            getgenv().Events.StartAutoCollectChests()
        else
            getgenv().Events.StopAutoCollectChests()
        end
        
        getgenv().Functions.ShowNotification(
            "Auto Chest",
            value and "Enabled" or "Disabled"
        )
    end
})

ChestSection:AddSlider("ChestRange", {
    Title = "Collection Range",
    Default = getgenv().Options.ChestRange,
    Min = getgenv().Config.Items.ChestSettings.MinRange,
    Max = getgenv().Config.Items.ChestSettings.MaxRange,
    Rounding = 0,
    Callback = function(value)
        getgenv().Options.ChestRange = value
        
        if getgenv().Config.Debug then
            getgenv().Functions.ShowNotification(
                "Chest Range",
                "Set to " .. tostring(value)
            )
        end
    end
})

-- Inventory Display System
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

-- Quick Actions
InventorySection:AddButton({
    Title = "Sell All Selected Rarities",
    Callback = function()
        local sold = 0
        for rarity, selected in pairs(getgenv().State.SelectedRarities) do
            if selected then
                getgenv().Functions.sellFish(rarity)
                sold = sold + 1
            end
        end
        getgenv().Functions.ShowNotification("Inventory", "Selling items of " .. sold .. " rarities")
    end
})

-- Initialize ItemsTab
local function InitializeItemsTab()
    if not getgenv().Config then
        error("ItemsTab: Config not initialized")
        return false
    end
    
    if not getgenv().Functions then
        error("ItemsTab: Functions not initialized")
        return false
    end
    
    if not getgenv().Events then
        error("ItemsTab: Events not initialized")
        return false
    end
    
    -- Start inventory update loop
    task.spawn(function()
        while task.wait(INVENTORY_UPDATE_INTERVAL) do
            updateInventoryDisplay()
        end
    end)
    
    -- Initial inventory update
    updateInventoryDisplay()
    
    return true
end

-- Run initialization
if not InitializeItemsTab() then
    return false
end

return ItemsTab
