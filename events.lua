-- events.lua
local Events = {}

-- Initialize tables
Events.Handlers = {}
Events.Connected = {}

-- Core services
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Basic event system functions
function Events:Register(eventName, handler)
    if not self.Handlers[eventName] then
        self.Handlers[eventName] = {}
    end
    self.Handlers[eventName][#self.Handlers[eventName] + 1] = handler
end

function Events:Fire(eventName, data)
    if not self.Handlers[eventName] then return end
    
    for _, handler in ipairs(self.Handlers[eventName]) do
        coroutine.wrap(function()
            local success, err = pcall(function()
                handler(data)
            end)
            if not success then
                warn("[Lucid Events] Error in", eventName, "-", err)
            end
        end)()
    end
end

-- Register core game events
function Events:Init()
    -- Rod equipment handling
    self:Register("RodEquipped", function(rodName)
        local Options = getgenv().Options
        local Config = getgenv().Config
        local Functions = getgenv().Functions
        
        if not Options or not Options.AutoEquipBestRod then return end
        if not Config or not Config.Items then return end
        if not Functions or not Functions.equipBestRod then return end
        
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

    -- Item handling
    self:Register("ItemAdded", function(item)
        local Options = getgenv().Options
        local Functions = getgenv().Functions
        
        if not Options or not Options.AutoSellEnabled then return end
        if not Functions or not Functions.sellFish then return end
        
        if item and item:FindFirstChild("values") then
            local values = item:FindFirstChild("values")
            if values and values:FindFirstChild("rarity") then
                local rarity = values.rarity.Value
                if Options.SelectedRarities and Options.SelectedRarities[rarity] then
                    Functions.sellFish(rarity)
                end
            end
        end
    end)
end

-- Setup game connections
function Events:SetupConnections()
    local function connectCharacter(character)
        if not character then return end
        
        character.ChildAdded:Connect(function(child)
            if child:IsA("Tool") then
                self:Fire("RodEquipped", child.Name)
            end
        end)
    end

    -- Connect current character
    if LocalPlayer.Character then
        connectCharacter(LocalPlayer.Character)
    end

    -- Connect future characters
    LocalPlayer.CharacterAdded:Connect(connectCharacter)

    -- Connect backpack
    if LocalPlayer:FindFirstChild("Backpack") then
        LocalPlayer.Backpack.ChildAdded:Connect(function(child)
            self:Fire("ItemAdded", child)
        end)
    end
end

-- Initialize the event system
Events:Init()
Events:SetupConnections()

-- Set global reference
getgenv().Events = Events

return true
