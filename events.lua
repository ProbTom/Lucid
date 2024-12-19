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

-- Wait for LocalPlayer to be available
local LocalPlayer = Players and Players.LocalPlayer
if not LocalPlayer then
    local success, player = pcall(function()
        return Players:WaitForChild("LocalPlayer", 10)
    end)
    if success then
        LocalPlayer = player
    end
end

-- Early validation
if not Players or not ReplicatedStorage or not RunService or not LocalPlayer then
    warn("Essential services or LocalPlayer not available")
    return false
end

-- Constants
local MINIMUM_INTERVAL = 0.1
local CHEST_CHECK_INTERVAL = 0.5
local SELL_CHECK_INTERVAL = 1.0
local CHARACTER_LOAD_DELAY = 1.0

-- Verify and initialize global states
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

if not getgenv().Functions then
    warn("Functions module not loaded")
    return false
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

-- Enhanced error handling for events
local function safeFireEvent(eventName, ...)
    if not getgenv().State.Events.Available[eventName] then
        if getgenv().Config and getgenv().Config.Debug then
            warn("⚠️ Event not found:", eventName)
        end
        return false
    end

    local events = ReplicatedStorage:FindFirstChild("events")
    if not events then return false end

    local event = events:FindFirstChild(eventName)
    if not event then return false end

    local success = pcall(function()
        event:FireServer(...)
    end)

    return success
end

-- Event Handling Functions with improved error checking
Events.StartAutoFishing = function()
    if Events.Active.Fishing then return end
    
    Events.Active.Fishing = true
    
    Events.Connections.Fishing = RunService.RenderStepped:Connect(function()
        if not Events.Active.Fishing then return end
        
        local gui = LocalPlayer:FindFirstChild("PlayerGui")
        if not gui then return end
        
        pcall(function()
            if getgenv().Options and getgenv().Options.AutoFish and not isOnCooldown("fishing") then
                getgenv().Functions.autoFish(gui)
                updateCooldown("fishing")
            end
            
            if getgenv().Options and getgenv().Options.AutoReel and not isOnCooldown("reeling") then
                getgenv().Functions.autoReel(gui)
                updateCooldown("reeling")
            end
            
            if getgenv().Options and getgenv().Options.AutoShake and not isOnCooldown("shaking") then
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

-- Initialize events system with improved error handling
local function InitializeEvents()
    -- Verify required modules and states
    local requirements = {
        {name = "Config", value = getgenv().Config},
        {name = "Functions", value = getgenv().Functions},
        {name = "State", value = getgenv().State}
    }
    
    for _, req in ipairs(requirements) do
        if not req.value then
            warn("Events: Missing requirement -", req.name)
            return false
        end
    end
    
    -- Check for available events in ReplicatedStorage
    local events = ReplicatedStorage:FindFirstChild("events")
    if events then
        for _, event in pairs(events:GetChildren()) do
            getgenv().State.Events.Available[event.Name] = true
        end
    end
    
    -- Set up cleanup on script end
    if game:GetService("Players").LocalPlayer then
        game:GetService("Players").LocalPlayer.OnTeleport:Connect(function()
            for _, connection in pairs(Events.Connections) do
                if typeof(connection) == "RBXScriptConnection" and connection.Connected then
                    connection:Disconnect()
                end
            end
        end)
    end
    
    if getgenv().Config.Debug then
        print("✓ Events system initialized successfully")
    end
    
    return true
end

-- Run initialization
if InitializeEvents() then
    return Events
else
    warn("⚠️ Failed to initialize Events system")
    return false
end
