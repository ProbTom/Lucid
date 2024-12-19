-- events.lua
local Events = {
    Handlers = {},
    Connected = {}
}

-- Core game services
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Event registration with single parameter
function Events:Register(eventName, handler)
    if not self.Handlers[eventName] then
        self.Handlers[eventName] = {}
    end
    table.insert(self.Handlers[eventName], handler)
end

-- Event triggering with single parameter
function Events:Fire(eventName, data)
    if self.Handlers[eventName] then
        for _, handler in ipairs(self.Handlers[eventName]) do
            task.spawn(function()
                local success, err = pcall(handler, data)
                if not success then
                    warn("Event handler error:", err)
                end
            end)
        end
    end
end

-- Register core events
Events:Register("RodEquipped", function(rodName)
    local Options = getgenv().Options
    local Config = getgenv().Config
    local Functions = getgenv().Functions
    
    if not Options or not Options.AutoEquipBestRod then return end
    if not Config or not Config.Items then return end
    if not Functions or type(Functions.equipBestRod) ~= "function" then return end
    
    local bestRod = nil
    for _, rod in ipairs(Config.Items.RodRanking) do
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild(rod) then
            bestRod = rod
            break
        end
    end
    
    if bestRod and bestRod ~= rodName then
        Functions.equipBestRod()
    end
end)

Events:Register("ItemAdded", function(item)
    local Options = getgenv().Options
    local Functions = getgenv().Functions
    
    if not Options or not Options.AutoSellEnabled then return end
    if not Functions or type(Functions.sellFish) ~= "function" then return end
    
    if item and item:FindFirstChild("values") and item.values:FindFirstChild("rarity") then
        local itemRarity = item.values.rarity.Value
        if Options.SelectedRarities and Options.SelectedRarities[itemRarity] then
            Functions.sellFish(itemRarity)
        end
    end
end)

-- Setup character connections
local function setupCharacterConnections(character)
    if not character then return end
    
    character.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            Events:Fire("RodEquipped", child.Name)
        end
    end)
end

-- Initial setup
if LocalPlayer.Character then
    setupCharacterConnections(LocalPlayer.Character)
end

-- Setup future character connections
LocalPlayer.CharacterAdded:Connect(setupCharacterConnections)

-- Setup backpack connections
if LocalPlayer:FindFirstChild("Backpack") then
    LocalPlayer.Backpack.ChildAdded:Connect(function(child)
        Events:Fire("ItemAdded", child)
    end)
end

-- Set global events table
getgenv().Events = Events
return true
