local function waitForDependency(name, path)
    local startTime = tick()
    while not (getgenv()[name] and (not path or path(getgenv()[name]))) do
        if tick() - startTime > 10 then
            error(string.format("Failed to load dependency: %s after 10 seconds", name))
            return false
        end
        task.wait(0.1)
    end
    return true
end

-- Wait for critical dependencies
if not waitForDependency("Tabs", function(t) return t.Items end) then return false end
if not waitForDependency("Functions") then return false end
if not waitForDependency("Options") then return false end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Cache ItemsTab reference
local ItemsTab = getgenv().Tabs.Items

-- Create sections
local ChestSection = ItemsTab:AddSection("Chest Management")
local FishSection = ItemsTab:AddSection("Fish Management")
local RodSection = ItemsTab:AddSection("Rod Management")

-- Chest Management
local autoCollectChest = ChestSection:AddToggle("autoCollectChest", {
    Title = "Auto Collect Chests",
    Default = false
})

local chestRange = ChestSection:AddSlider("chestRange", {
    Title = "Chest Collection Range",
    Default = 50,
    Min = 10,
    Max = 100,
    Rounding = 0,
})

-- Fish Management
local autoSellFish = FishSection:AddToggle("autoSellFish", {
    Title = "Auto Sell Fish",
    Default = false
})

local selectedRarities = FishSection:AddDropdown("fishRarities", {
    Title = "Fish Rarities to Sell",
    Values = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythical"},
    Default = {"Common"},
    Multi = true,
})

-- Rod Management
local autoEquipBestRod = RodSection:AddToggle("autoEquipBestRod", {
    Title = "Auto Equip Best Rod",
    Default = false
})

-- Handlers
autoCollectChest:OnChanged(function()
    pcall(function()
        if autoCollectChest.Value then
            RunService:BindToRenderStep("AutoCollectChests", Enum.RenderPriority.Character.Value, function()
                for _, chest in pairs(workspace:GetChildren()) do
                    if chest:IsA("Model") and chest.Name:find("Chest") then
                        Functions.collectChest(chest, chestRange.Value)
                    end
                end
            end)
        else
            RunService:UnbindFromRenderStep("AutoCollectChests")
        end
    end)
end)

autoSellFish:OnChanged(function()
    pcall(function()
        if autoSellFish.Value then
            RunService:BindToRenderStep("AutoSellFish", Enum.RenderPriority.Character.Value, function()
                for _, rarity in pairs(selectedRarities:GetValue()) do
                    Functions.sellFish(rarity)
                end
            end)
        else
            RunService:UnbindFromRenderStep("AutoSellFish")
        end
    end)
end)

autoEquipBestRod:OnChanged(function()
    pcall(function()
        if autoEquipBestRod.Value then
            RunService:BindToRenderStep("AutoEquipBestRod", Enum.RenderPriority.Character.Value, function()
                Functions.equipBestRod()
            end)
        else
            RunService:UnbindFromRenderStep("AutoEquipBestRod")
        end
    end)
end)

-- Add cleanup handler
local function cleanupTab()
    pcall(function()
        RunService:UnbindFromRenderStep("AutoCollectChests")
        RunService:UnbindFromRenderStep("AutoSellFish")
        RunService:UnbindFromRenderStep("AutoEquipBestRod")
        
        -- Reset toggles
        if autoCollectChest then autoCollectChest:SetValue(false) end
        if autoSellFish then autoSellFish:SetValue(false) end
        if autoEquipBestRod then autoEquipBestRod:SetValue(false) end
    end)
end

-- Add cleanup to global cleanup function
if getgenv().cleanup then
    local oldCleanup = getgenv().cleanup
    getgenv().cleanup = function()
        cleanupTab()
        oldCleanup()
    end
end

return true
