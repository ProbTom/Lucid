-- events.lua
local Events = {
    Connections = {},
    Active = {},
    Heartbeat = {},
    LastTick = {}
}

-- Core Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Constants
local MINIMUM_INTERVAL = 0.05
local CHEST_CHECK_INTERVAL = 0.5
local SELL_CHECK_INTERVAL = 1.0
local CHARACTER_LOAD_DELAY = 1.0

-- Utility Functions
local function isOnCooldown(action)
    if not Events.LastTick[action] then
        Events.LastTick[action] = 0
        return false
    end
    return (tick() - Events.LastTick[action]) < MINIMUM_INTERVAL
end

local function updateCooldown(action)
    Events.LastTick[action] = tick()
end

-- Event Handling Functions
Events.StartAutoFishing = function()
    if Events.Active.Fishing then return end
    Events.Active.Fishing = true
    
    Events.Connections.Fishing = RunService.RenderStepped:Connect(function()
        if not Events.Active.Fishing then return end
        
        local gui = LocalPlayer:WaitForChild("PlayerGui")
        if not gui then return end
        
        pcall(function()
            if getgenv().Options.AutoFish and not isOnCooldown("fishing") then
                getgenv().Functions.autoFish(gui)
                updateCooldown("fishing")
            end
            
            if getgenv().Options.AutoReel and not isOnCooldown("reeling") then
                getgenv().Functions.autoReel(gui)
                updateCooldown("reeling")
            end
            
            if getgenv().Options.AutoShake and not isOnCooldown("shaking") then
                getgenv().Functions.autoShake(gui)
                updateCooldown("shaking")
            end
        end)
    end)
end

Events.StopAutoFishing = function()
    if Events.Connections.Fishing then
        Events.Connections.Fishing:Disconnect()
        Events.Connections.Fishing = nil
    end
    Events.Active.Fishing = false
end

Events.StartAutoCollectChests = function()
    if Events.Active.ChestCollection then return end
    Events.Active.ChestCollection = true
    
    Events.Connections.ChestCollection = RunService.Heartbeat:Connect(function()
        if not Events.Active.ChestCollection or isOnCooldown("chestCheck") then return end
        
        pcall(function()
            for _, chest in pairs(workspace:GetChildren()) do
                if chest:IsA("Model") and chest.Name:match("Chest") then
                    getgenv().Functions.collectChest(chest, getgenv().Options.ChestRange)
                end
            end
        end)
        
        updateCooldown("chestCheck")
    end)
end

Events.StopAutoCollectChests = function()
    if Events.Connections.ChestCollection then
        Events.Connections.ChestCollection:Disconnect()
        Events.Connections.ChestCollection = nil
    end
    Events.Active.ChestCollection = false
end

Events.StartAutoSell = function()
    if Events.Active.Selling then return end
    Events.Active.Selling = true
    
    Events.Connections.Selling = RunService.Heartbeat:Connect(function()
        if not Events.Active.Selling or isOnCooldown("selling") then return end
        
        pcall(function()
            for rarity, enabled in pairs(getgenv().State.SelectedRarities) do
                if enabled then
                    getgenv().Functions.sellFish(rarity)
                end
            end
        end)
        
        updateCooldown("selling")
    end)
end

Events.StopAutoSell = function()
    if Events.Connections.Selling then
        Events.Connections.Selling:Disconnect()
        Events.Connections.Selling = nil
    end
    Events.Active.Selling = false
end

-- Character Handling
Events.SetupCharacterHandler = function()
    local function onCharacterAdded(character)
        if not character then return end
        
        task.wait(CHARACTER_LOAD_DELAY)
        
        pcall(function()
            if getgenv().Options.AutoEquipBestRod then
                getgenv().Functions.equipBestRod()
            end
        end)
    end
    
    if LocalPlayer.Character then
        onCharacterAdded(LocalPlayer.Character)
    end
    
    Events.Connections.CharacterAdded = LocalPlayer.CharacterAdded:Connect(onCharacterAdded)
end

-- Cleanup System
Events.CleanupConnections = function()
    for _, connection in pairs(Events.Connections) do
        if typeof(connection) == "RBXScriptConnection" and connection.Connected then
            connection:Disconnect()
        end
    end
    
    Events.Connections = {}
    Events.Active = {}
    Events.LastTick = {}
end

-- Error Handler
Events.HandleError = function(context, error)
    if getgenv().Config.Debug then
        warn(string.format("[Events] %s Error: %s", context, error))
        if getgenv().Functions then
            getgenv().Functions.ShowNotification("Event Error", context .. ": " .. error)
        end
    end
end

-- Initialize events system
local function InitializeEvents()
    if not getgenv().Config then
        error("Events: Config not initialized")
        return false
    end
    
    if not getgenv().State then
        error("Events: State not initialized")
        return false
    end
    
    if not getgenv().Functions then
        error("Events: Functions not initialized")
        return false
    end
    
    -- Setup cleanup on script end
    game:GetService("Players").LocalPlayer.OnTeleport:Connect(function()
        Events.CleanupConnections()
    end)
    
    -- Setup character handler
    Events.SetupCharacterHandler()
    
    return true
end

-- Run initialization
if not InitializeEvents() then
    return false
end

return Events
