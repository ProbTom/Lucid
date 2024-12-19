-- events.lua
-- Core events module for Lucid Hub
if getgenv().LucidEvents then
    return getgenv().LucidEvents
end

local Events = {
    _version = "1.0.1",
    _initialized = false,
    _debug = false
}

-- Core services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Event configuration
local EVENT_CONFIG = {
    events = {
        castrod = {required = false, retry = true},
        reelfinished = {required = false, retry = true},
        character = {required = false, retry = true}
    },
    retryAttempts = 3,
    retryDelay = 1
}

-- Initialize events system with single execution guarantee
local function initialize()
    if Events._initialized then
        return true
    end

    -- Ensure state exists
    if not getgenv().State then
        getgenv().State = {}
    end
    if not getgenv().State.Events then
        getgenv().State.Events = {
            Available = {},
            Initialized = false
        }
    end

    -- Get events container
    local events = ReplicatedStorage:FindFirstChild("events")
    
    -- Check events availability silently
    for eventName, config in pairs(EVENT_CONFIG.events) do
        local eventExists = false
        if events then
            eventExists = events:FindFirstChild(eventName) ~= nil
        end
        getgenv().State.Events.Available[eventName] = eventExists
    end

    Events._initialized = true
    getgenv().State.Events.Initialized = true
    return true
end

-- Run initialization once
local success = pcall(initialize)

if success then
    getgenv().LucidEvents = Events
    return Events
else
    warn("Failed to initialize events system")
    return false
end
