-- events.lua
-- Core events module for Lucid Hub
local Events = {
    _version = "1.0.1",
    _initialized = false,
    _debug = false  -- Control debug output
}

-- Core services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Event configuration
local EVENT_CONFIG = {
    required = {
        castrod = false,    -- Optional event
        reelfinished = false, -- Optional event
        character = false   -- Optional event
    },
    retryAttempts = 3,
    retryDelay = 1
}

-- Utility functions
local function debugLog(...)
    if Events._debug and getgenv().Config and getgenv().Config.Debug then
        print(...)
    end
end

-- Initialize state if not exists
local function ensureStateExists()
    if not getgenv().State then
        getgenv().State = {}
    end
    
    if not getgenv().State.Events then
        getgenv().State.Events = {
            Available = {},
            Initialized = false
        }
    end
end

-- Check for event availability with retry
local function checkEventAvailability(eventContainer, eventName, attempts)
    for i = 1, attempts do
        local event = eventContainer:FindFirstChild(eventName)
        if event then
            return true
        end
        if i < attempts then
            task.wait(EVENT_CONFIG.retryDelay)
        end
    end
    return false
end

-- Initialize events system
local function initialize()
    if Events._initialized then
        return true
    end

    ensureStateExists()

    -- Wait for game load if needed
    if not game:IsLoaded() then
        game.Loaded:Wait()
    end

    local events = ReplicatedStorage:FindFirstChild("events")
    if not events then
        debugLog("📢 Events container not found - This is normal for some games")
        return true  -- Return true as this might be expected
    end

    -- Check and store event availability
    for eventName, isRequired in pairs(EVENT_CONFIG.required) do
        local eventExists = checkEventAvailability(events, eventName, EVENT_CONFIG.retryAttempts)
        getgenv().State.Events.Available[eventName] = eventExists

        -- Only show warning if event is required
        if not eventExists and isRequired then
            warn("⚠️ Required event not found:", eventName)
        elseif not eventExists then
            debugLog("📢 Optional event not available:", eventName)
        end
    end

    -- Mark events as initialized
    getgenv().State.Events.Initialized = true
    Events._initialized = true
    
    debugLog("✓ Events system initialized successfully")
    return true
end

-- Public interface
function Events.IsEventAvailable(eventName)
    return getgenv().State and 
           getgenv().State.Events and 
           getgenv().State.Events.Available and 
           getgenv().State.Events.Available[eventName] == true
end

function Events.GetEvent(eventName)
    if not Events.IsEventAvailable(eventName) then
        return nil
    end
    
    local events = ReplicatedStorage:FindFirstChild("events")
    return events and events:FindFirstChild(eventName)
end

function Events.FireEvent(eventName, ...)
    local event = Events.GetEvent(eventName)
    if not event then
        return false
    end
    
    local success, result = pcall(function()
        return event:FireServer(...)
    end)
    
    return success
end

-- Run initialization with proper error handling
local success = pcall(initialize)

if success then
    debugLog("✓ Successfully loaded module: events")
else
    warn("❌ Failed to initialize events system")
end

return Events
