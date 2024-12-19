-- events.lua
local Events = {
    Handlers = {},
    Connected = {}
}

-- Core game services
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Event registration
function Events:Register(eventName, handler)
    if not self.Handlers[eventName] then
        self.Handlers[eventName] = {}
    end
    table.insert(self.Handlers[eventName], handler)
end

-- Event triggering
function Events:Trigger(eventName, data)
    if self.Handlers[eventName] then
        for _, handler in ipairs(self.Handlers[eventName]) do
            task.spawn(function()
                pcall(function()
                    handler(data)
                end)
            end)
        end
    end
end

-- Register core events
Events:Register("RodEquipped", function(rodName)
    if not getgenv().Options or not getgenv().Options.AutoEquipBestRod then return end
    
    if getgenv().Config and getgenv().Config.Items then
        local bestRod = nil
        for _, rod in ipairs(getgenv().Config.Items.RodRanking) do
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild(rod) then
                bestRod = rod
                break
            end
        end
        
        if bestRod and bestRod ~= rodName then
            if getgenv().Functions and type(getgenv().Functions.equipBestRod) == "function" then
                getgenv().Functions.equipBestRod()
            end
        end
    end
end)

Events:Register("ItemAdded", function(item)
    if not getgenv().Options or not getgenv().Options.AutoSellEnabled then return end
    
    if item and item:FindFirstChild("values") and item.values:FindFirstChild("rarity") then
        local itemRarity = item.values.rarity.Value
        if getgenv().Options.SelectedRarities and 
           getgenv().Options.SelectedRarities[itemRarity] and
           getgenv().Functions and 
           type(getgenv().Functions.sellFish) == "function" then
            getgenv().Functions.sellFish(itemRarity)
        end
    end
end)

-- Connect to game events
local function setupCharacterConnections(character)
    if not character then return end
    
    character.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            Events:Trigger("RodEquipped", child.Name)
        end
    end)
end

-- Initial character setup
if LocalPlayer.Character then
    setupCharacterConnections(LocalPlayer.Character)
end

-- Future character connections
LocalPlayer.CharacterAdded:Connect(setupCharacterConnections)

-- Backpack connections
if LocalPlayer:FindFirstChild("Backpack") then
    LocalPlayer.Backpack.ChildAdded:Connect(function(child)
        Events:Trigger("ItemAdded", child)
    end)
end

-- Set global events table
getgenv().Events = Events
return true
