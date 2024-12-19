-- events.lua
local Events = {
    Connections = {},
    Active = {},
    Heartbeat = {},
    LastTick = {}
}

-- Core Services with error handling
local function getService(serviceName)
    local success, service = pcall(function()
        return game:GetService(serviceName)
    end)
    
    if not success then
        warn("Failed to get service:", serviceName)
        return nil
    end
    
    return service
end

-- Initialize required services
local Players = getService("Players")
local ReplicatedStorage = getService("ReplicatedStorage")
local RunService = getService("RunService")

-- Constants
local MINIMUM_INTERVAL = 0.1
local CHEST_CHECK_INTERVAL = 0.5
local SELL_CHECK_INTERVAL = 1.0
local CHARACTER_LOAD_DELAY = 1.0

-- Early validation
if not Players or not ReplicatedStorage or not RunService then
    warn("Essential services not available")
    return false
end

-- Initialize or verify global state
if not getgenv or not getgenv() then
    warn("getgenv not available")
    return false
end

if not getgenv().State then
    getgenv().State = {
        AutoFishing = false,
        AutoSelling = false,
        SelectedRarities = {},
        LastReelTime = 0,
        LastShakeTime = 0,
        Events = {
            Available = {}
        }
    }
end

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

-- Safe event firing with improved error handling
local function safeFireEvent(eventName, ...)
    local success, result = pcall(function()
        local events = ReplicatedStorage:FindFirstChild("events")
        if not events then return false end

        local event = events:FindFirstChild(eventName)
        if not event then 
            if getgenv().Config and getgenv().Config.Debug then
                warn("⚠️ Event not found:", eventName)
            end
            return false 
        end

        event:FireServer(...)
        return true
    end)

    return success and result
end

-- Cleanup function
local function cleanupConnections()
    for name, connection in pairs(Events.Connections) do
        if typeof(connection) == "RBXScriptConnection" and connection.Connected then
            connection:Disconnect()
        end
        Events.Connections[name] = nil
    end
    
    Events.Active = {}
    Events.LastTick = {}
end

-- Initialize events system with improved error handling
local function InitializeEvents()
    -- Verify required modules
    if not getgenv().Functions then
        warn("Events: Functions module not loaded")
        return false
    end

    if not getgenv().Config then
        warn("Events: Config not loaded")
        return false
    end

    -- Set up event availability tracking
    local events = ReplicatedStorage:FindFirstChild("events")
    if events then
        for _, event in ipairs(events:GetChildren()) do
            getgenv().State.Events.Available[event.Name] = true
        end
    end

    -- Set up cleanup handling
    local player = Players.LocalPlayer
    if player then
        local success, _ = pcall(function()
            Events.Connections.Cleanup = player.OnTeleport:Connect(cleanupConnections)
        end)
        
        if not success then
            warn("Failed to set up cleanup connection")
        end
    end

    if getgenv().Config.Debug then
        print("✓ Events system initialized successfully")
    end

    return true
end

-- Event handler functions
Events.StartAutoFishing = function()
    if Events.Active.Fishing then return end
    Events.Active.Fishing = true
    
    local player = Players.LocalPlayer
    if not player then return end
    
    Events.Connections.Fishing = RunService.RenderStepped:Connect(function()
        if not Events.Active.Fishing then return end
        
        local gui = player:FindFirstChild("PlayerGui")
        if not gui then return end
        
        if getgenv().Options.AutoFish and not isOnCooldown("fishing") then
            pcall(function() getgenv().Functions.autoFish(gui) end)
            updateCooldown("fishing")
        end
        
        if getgenv().Options.AutoReel and not isOnCooldown("reeling") then
            pcall(function() getgenv().Functions.autoReel(gui) end)
            updateCooldown("reeling")
        end
        
        if getgenv().Options.AutoShake and not isOnCooldown("shaking") then
            pcall(function() getgenv().Functions.autoShake(gui) end)
            updateCooldown("shaking")
        end
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
            if getgenv().State.SelectedRarities then
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

-- Run initialization with proper error handling
local success, result = pcall(InitializeEvents)

if success and result then
    return Events
else
    warn("⚠️ Failed to initialize Events system:", result)
    cleanupConnections()
    return false
end
