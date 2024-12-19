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
local MINIMUM_INTERVAL = 0.1
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

-- Safe Remote Event Caller
local function safeFireRemote(eventName, ...)
    local events = ReplicatedStorage:FindFirstChild("events")
    if not events then return false end
    
    local event = events:FindFirstChild(eventName)
    if not event then return false end
    
    local success, result = pcall(function()
        event:FireServer(...)
    end)
    
    if not success and getgenv().Config.Debug then
        warn("Failed to fire event:", eventName, result)
    end
    
    return success
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
                if getgenv().Functions.autoFish then
                    getgenv().Functions.autoFish(gui)
                    updateCooldown("fishing")
                end
            end
            
            if getgenv().Options.AutoReel and not isOnCooldown("reeling") then
                if getgenv().Functions.autoReel then
                    getgenv().Functions.autoReel(gui)
                    updateCooldown("reeling")
                end
            end
            
            if getgenv().Options.AutoShake and not isOnCooldown("shaking") then
                if getgenv().Functions.autoShake then
                    getgenv().Functions.autoShake(gui)
                    updateCooldown("shaking")
                end
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
            if getgenv().Functions.collectChest then
                for _, chest in pairs(workspace:GetChildren()) do
                    if chest:IsA("Model") and chest.Name:match("Chest") then
                        getgenv().Functions.collectChest(chest, getgenv().Options.ChestRange)
                    end
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
            if getgenv().Functions.sellFish then
                for rarity, enabled in pairs(getgenv().State.SelectedRarities) do
                    if enabled then
                        getgenv().Functions.sellFish(rarity)
                    end
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

-- Character Handling with improved error handling
Events.SetupCharacterHandler = function()
    local function onCharacterAdded(character)
        if not character then return end
        
        task.wait(CHARACTER_LOAD_DELAY)
        
        pcall(function()
            if getgenv().Options.AutoEquipBestRod and getgenv().Functions.equipBestRod then
                getgenv().Functions.equipBestRod()
            end
        end)
    end
    
    if LocalPlayer.Character then
        onCharacterAdded(LocalPlayer.Character)
    end
    
    Events.Connections.CharacterAdded = LocalPlayer.CharacterAdded:Connect(onCharacterAdded)
end

-- Enhanced Cleanup System
Events.CleanupConnections = function()
