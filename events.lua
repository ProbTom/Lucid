-- events.lua
-- Basic module structure
local Events = {
    Connections = {},
    Active = {},
    LastTick = {}
}

-- Simple cooldown system
local function isOnCooldown(action)
    Events.LastTick[action] = Events.LastTick[action] or 0
    return (tick() - Events.LastTick[action]) < 0.1
end

local function updateCooldown(action)
    Events.LastTick[action] = tick()
end

-- Safe service getter
local function getSafe(name)
    local success, service = pcall(function()
        return game:GetService(name)
    end)
    return success and service
end

-- Core services
local RunService = getSafe("RunService")
local Players = getSafe("Players")
local ReplicatedStorage = getSafe("ReplicatedStorage")

-- Basic validation
if not RunService or not Players or not ReplicatedStorage then
    warn("Required services not available")
    return false
end

-- Global state check
if not getgenv then
    warn("getgenv not available")
    return false
end

-- Initialize required states
getgenv().State = getgenv().State or {
    Events = {
        Available = {}
    }
}

-- Event handlers
Events.StartAutoFishing = function()
    if Events.Active.Fishing then return end
    Events.Active.Fishing = true
    
    pcall(function()
        Events.Connections.Fishing = RunService.RenderStepped:Connect(function()
            if not Events.Active.Fishing then return end
            
            local player = Players.LocalPlayer
            if not player then return end
            
            local gui = player:FindFirstChild("PlayerGui")
            if not gui or not getgenv().Functions then return end
            
            if getgenv().Options and getgenv().Options.AutoFish and not isOnCooldown("fishing") then
                pcall(function() 
                    getgenv().Functions.autoFish(gui)
                    updateCooldown("fishing")
                end)
            end
        end)
    end)
end

Events.StopAutoFishing = function()
    pcall(function()
        if Events.Connections.Fishing then
            Events.Connections.Fishing:Disconnect()
            Events.Connections.Fishing = nil
        end
    end)
    Events.Active.Fishing = false
end

Events.StartAutoCollectChests = function()
    if Events.Active.ChestCollection then return end
    Events.Active.ChestCollection = true
    
    pcall(function()
        Events.Connections.ChestCollection = RunService.Heartbeat:Connect(function()
            if not Events.Active.ChestCollection then return end
            if isOnCooldown("chestCheck") then return end
            
            updateCooldown("chestCheck")
            
            pcall(function()
                if not getgenv().Functions then return end
                
                for _, chest in ipairs(workspace:GetChildren()) do
                    if chest:IsA("Model") and chest.Name:match("Chest") then
                        getgenv().Functions.collectChest(chest, getgenv().Options.ChestRange or 50)
                    end
                end
            end)
        end)
    end)
end

Events.StopAutoCollectChests = function()
    pcall(function()
        if Events.Connections.ChestCollection then
            Events.Connections.ChestCollection:Disconnect()
            Events.Connections.ChestCollection = nil
        end
    end)
    Events.Active.ChestCollection = false
end

Events.StartAutoSell = function()
    if Events.Active.Selling then return end
    Events.Active.Selling = true
    
    pcall(function()
        Events.Connections.Selling = RunService.Heartbeat:Connect(function()
            if not Events.Active.Selling then return end
            if isOnCooldown("selling") then return end
            
            updateCooldown("selling")
            
            pcall(function()
                if not getgenv().Functions or not getgenv().State.SelectedRarities then return end
                
                for rarity, enabled in pairs(getgenv().State.SelectedRarities) do
                    if enabled then
                        getgenv().Functions.sellFish(rarity)
                    end
                end
            end)
        end)
    end)
end

Events.StopAutoSell = function()
    pcall(function()
        if Events.Connections.Selling then
            Events.Connections.Selling:Disconnect()
            Events.Connections.Selling = nil
        end
    end)
    Events.Active.Selling = false
end

-- Cleanup handler
local function cleanup()
    pcall(function()
        for _, connection in pairs(Events.Connections) do
            if type(connection) == "userdata" and connection.Connected then
                connection:Disconnect()
            end
        end
        Events.Connections = {}
        Events.Active = {}
    end)
end

-- Basic initialization
local function init()
    -- Set up event tracking
    local events = ReplicatedStorage:FindFirstChild("events")
    if events then
        for _, event in ipairs(events:GetChildren()) do
            getgenv().State.Events.Available[event.Name] = true
        end
    end
    
    -- Set up cleanup
    pcall(function()
        if Players.LocalPlayer then
            game:BindToClose(cleanup)
        end
    end)
    
    return true
end

-- Run initialization
local success = pcall(init)
if success then
    return Events
end

return false
