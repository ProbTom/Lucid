-- events.lua
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Initialize Events system with proper type checking
local Events = {
    Handlers = setmetatable({}, {
        __index = function(t, k)
            t[k] = {}
            return t[k]
        end
    }),
    Connected = {}
}

-- Safe event registration with parameter validation
function Events:Register(eventName, handler)
    assert(type(eventName) == "string", "Event name must be a string")
    assert(type(handler) == "function", "Handler must be a function")
    
    self.Handlers[eventName][#self.Handlers[eventName] + 1] = handler
    return true
end

-- Safe event firing with error handling
function Events:Fire(eventName, data)
    if not self.Handlers[eventName] then return false end
    
    for _, handler in ipairs(self.Handlers[eventName]) do
        task.spawn(function()
            local success, err = xpcall(
                function() handler(data) end,
                function(err)
                    if getgenv().Config and getgenv().Config.Debug then
                        warn("[Lucid Events Error]", eventName, err, debug.traceback())
                    end
                    return err
                end
            )
        end)
    end
    return true
end

-- Initialize core event handlers
function Events:InitializeHandlers()
    -- Rod equipment handler
    self:Register("RodEquipped", function(rodName)
        if not getgenv().Options or not getgenv().Options.AutoEquipBestRod then return end
        if not getgenv().Config or not getgenv().Config.Items then return end
        if not getgenv().Functions or type(getgenv().Functions.equipBestRod) ~= "function" then return end
        
        for _, rod in ipairs(getgenv().Config.Items.RodRanking) do
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild(rod) then
                if rod ~= rodName then
                    getgenv().Functions.equipBestRod()
                end
                break
            end
        end
    end)

    -- Item addition handler
    self:Register("ItemAdded", function(item)
        if not getgenv().Options or not getgenv().Options.AutoSellEnabled then return end
        if not getgenv().Functions or type(getgenv().Functions.sellFish) ~= "function" then return end
        
        if not item or not item:IsA("Tool") then return end
        
        local values = item:FindFirstChild("values")
        if not values then return end
        
        local rarity = values:FindFirstChild("rarity")
        if not rarity then return end
        
        if getgenv().Options.SelectedRarities and 
           getgenv().Options.SelectedRarities[rarity.Value] then
            getgenv().Functions.sellFish(rarity.Value)
        end
    end)
end

-- Initialize game connections with proper cleanup
function Events:InitializeConnections()
    local function setupCharacterConnections(character)
        if not character then return end
        
        -- Clean up existing connections
        if self.Connected[character] then
            for _, connection in pairs(self.Connected[character]) do
                connection:Disconnect()
            end
            self.Connected[character] = nil
        end
        
        self.Connected[character] = {}
        
        -- Set up new connections
        table.insert(self.Connected[character], 
            character.ChildAdded:Connect(function(child)
                if child:IsA("Tool") then
                    self:Fire("RodEquipped", child.Name)
                end
            end)
        )
    end
    
    -- Set up character connections
    if LocalPlayer.Character then
        setupCharacterConnections(LocalPlayer.Character)
    end
    
    -- Handle future characters
    table.insert(self.Connected, 
        LocalPlayer.CharacterAdded:Connect(setupCharacterConnections)
    )
    
    -- Set up backpack connections
    if LocalPlayer:FindFirstChild("Backpack") then
        table.insert(self.Connected, 
            LocalPlayer.Backpack.ChildAdded:Connect(function(child)
                self:Fire("ItemAdded", child)
            end)
        )
    end
end

-- Initialize the event system
Events:InitializeHandlers()
Events:InitializeConnections()

-- Set global reference
getgenv().Events = Events
return true
