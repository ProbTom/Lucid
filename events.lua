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
function Events:Trigger(eventName, ...)
    if self.Handlers[eventName] then
        for _, handler in ipairs(self.Handlers[eventName]) do
            pcall(function()
                handler(...)
            end)
        end
    end
end

-- Register core events
Events:Register("RodEquipped", function(rodName)
    if getgenv().Options.AutoEquipBestRod then
        -- Check if equipped rod is best available
        local bestRod = nil
        for _, rod in ipairs(getgenv().Config.Items.RodRanking) do
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild(rod) then
                bestRod = rod
                break
            end
        end
        
        if bestRod and bestRod ~= rodName then
            getgenv().Functions.equipBestRod()
        end
    end
end)

Events:Register("ItemAdded", function(item)
    if getgenv().Options.AutoSellEnabled then
        local itemRarity = item:FindFirstChild("values") and 
                          item.values:FindFirstChild("rarity") and 
                          item.values.rarity.Value
        
        if itemRarity and getgenv().Options.SelectedRarities[itemRarity] then
            getgenv().Functions.sellFish(itemRarity)
        end
    end
end)

-- Connect to game events
LocalPlayer.Character:WaitForChild("ChildAdded"):Connect(function(child)
    if child:IsA("Tool") then
        Events:Trigger("RodEquipped", child.Name)
    end
end)

LocalPlayer:WaitForChild("Backpack").ChildAdded:Connect(function(child)
    Events:Trigger("ItemAdded", child)
end)

getgenv().Events = Events
return true