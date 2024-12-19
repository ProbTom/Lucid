-- ItemsTab.lua
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Verify dependencies
if not getgenv().Tabs or not getgenv().Tabs.Items then
    error("ItemsTab: Missing UI dependencies")
    return false
end

local ItemsTab = getgenv().Tabs.Items

-- Create sections
local AutoSellSection = ItemsTab:AddSection("Auto Sell")
local RaritySection = ItemsTab:AddSection("Rarity Selection") 
local ChestSection = ItemsTab:AddSection("Chest Collection")
local InventorySection = ItemsTab:AddSection("Inventory Management")

-- Auto Sell Configuration
local autoSellToggle = AutoSellSection:AddToggle("AutoSell", {
    Title = "Auto Sell",
    Default = false,
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

-- Rarity Selection
local rarityToggles = {}
for _, rarity in ipairs(getgenv().Config.Items.FishRarities) do
    local toggle = RaritySection:AddToggle(rarity, {
        Title = rarity,
        Default = false,
        Callback = function(value)
            getgenv().State.SelectedRarities[rarity] = value
        end
    })
    rarityToggles[rarity] = toggle
end

-- Quick Rarity Selection Buttons
RaritySection:AddButton({
    Title = "Select All",
    Callback = function()
        for rarity, toggle in pairs(rarityToggles) do
            toggle:Set(true)
            getgenv().State.SelectedRarities[rarity] = true
        end
    end
})

RaritySection:AddButton({
    Title = "Select None",
    Callback = function()
        for rarity, toggle in pairs(rarityToggles) do
            toggle:Set(false)
            getgenv().State.SelectedRarities[rarity] = false
        end
    end
})

-- Chest Collection Configuration
local autoChestToggle = ChestSection:AddToggle("AutoChest", {
    Title = "Auto Collect Chests",
    Default = false,
    Callback = function(value)
        getgenv().Options.AutoCollectChests = value
        if value then
            getgenv().Events.StartAutoCollectChests()
        else
            getgenv().Events.StopAutoCollectChests()
        end
    end
})

ChestSection:AddSlider("ChestRange", {
    Title = "Collection Range",
    Default = getgenv().Config.Items.ChestRange.Default,
    Min = getgenv().Config.Items.ChestRange.Min,
    Max = getgenv().Config.Items.ChestRange.Max,
    Rounding = 0,
    Callback = function(value)
        getgenv().Options.ChestRange = value
    end
})

-- Inventory Management
InventorySection:AddButton({
    Title = "Sell All Selected Rarities",
    Callback = function()
        for rarity, selected in pairs(getgenv().State.SelectedRarities) do
            if selected and getgenv().Functions then
                getgenv().Functions.sellFish(rarity)
            end
        end
        getgenv().Functions.ShowNotification("Inventory", "Selling all selected rarities...")
    end
})

-- Inventory Stats Display
local function updateInventoryStats()
    local backpack = LocalPlayer:WaitForChild("Backpack")
    local rarityCount = {}
    
    -- Initialize counts
    for _, rarity in ipairs(getgenv().Config.Items.FishRarities) do
        rarityCount[rarity] = 0
    end
    
    -- Count items by rarity
    for _, item in pairs(backpack:GetChildren()) do
        if item:FindFirstChild("values") and item.values:FindFirstChild("rarity") then
            local rarity = item.values.rarity.Value
            if rarityCount[rarity] then
                rarityCount[rarity] = rarityCount[rarity] + 1
            end
        end
    end
    
    -- Update display labels
    InventorySection:AddLabel("Inventory Contents:")
    for rarity, count in pairs(rarityCount) do
        if count > 0 then
            InventorySection:AddLabel(string.format("%s: %d", rarity, count))
        end
    end
end

-- Rod Management
local RodSection = ItemsTab:AddSection("Rod Management")

-- Rod Selection Display
local function updateRodDisplay()
    local character = LocalPlayer.Character
    if not character then return end
    
    local equippedRod = nil
    for _, rodName in ipairs(getgenv().Config.Items.RodRanking) do
        if character:FindFirstChild(rodName) then
            equippedRod = rodName
            break
        end
    end
    
    if equippedRod then
        RodSection:AddLabel("Equipped Rod: " .. equippedRod)
    end
end

RodSection:AddButton({
    Title = "Equip Best Rod",
    Callback = function()
        if getgenv().Functions then
            getgenv().Functions.equipBestRod()
            task.wait(0.5)
            updateRodDisplay()
        end
    end
})

-- Auto-refresh displays
local function startAutoRefresh()
    task.spawn(function()
        while task.wait(5) do -- Update every 5 seconds
            pcall(function()
                updateInventoryStats()
                updateRodDisplay()
            end)
        end
    end)
end

-- Initialize displays
updateInventoryStats()
updateRodDisplay()
startAutoRefresh()

-- Add keybinds
ItemsTab:AddKeybind({
    Title = "Toggle Auto Sell",
    Default = Enum.KeyCode.X,
    Callback = function()
        autoSellToggle:Set(not autoSellToggle.Value)
    end
})

ItemsTab:AddKeybind({
    Title = "Toggle Chest Collection",
    Default = Enum.KeyCode.C,
    Callback = function()
        autoChestToggle:Set(not autoChestToggle.Value)
    end
})

-- Save/Load Configuration
local SaveSection = ItemsTab:AddSection("Save Configuration")

SaveSection:AddButton({
    Title = "Save Current Settings",
    Callback = function()
        if getgenv().SaveManager then
            local config = {
                AutoSell = autoSellToggle.Value,
                SelectedRarities = getgenv().State.SelectedRarities,
                ChestRange = getgenv().Options.ChestRange,
                AutoCollectChests = autoChestToggle.Value
            }
            getgenv().SaveManager:Save("ItemSettings", config)
            getgenv().Functions.ShowNotification("Settings", "Item settings saved!")
        end
    end
})

SaveSection:AddButton({
    Title = "Load Saved Settings",
    Callback = function()
        if getgenv().SaveManager then
            local config = getgenv().SaveManager:Load("ItemSettings")
            if config then
                -- Apply saved settings
                autoSellToggle:Set(config.AutoSell)
                for rarity, value in pairs(config.SelectedRarities) do
                    if rarityToggles[rarity] then
                        rarityToggles[rarity]:Set(value)
                    end
                end
                getgenv().Options.ChestRange = config.ChestRange
                autoChestToggle:Set(config.AutoCollectChests)
                getgenv().Functions.ShowNotification("Settings", "Item settings loaded!")
            end
        end
    end
})

return true
