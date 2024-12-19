-- events.lua
local Events = {
    _version = "1.0.1",
    _initialized = false,
    _eventStatus = {},
    REQUIRED_EVENTS = {
        "castrod",
        "reelfinished",
        "character"
    }
}

-- Core services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Set global reference immediately
getgenv().Events = Events

-- Check events availability
function Events.CheckEvent(eventName)
    if Events._eventStatus[eventName] ~= nil then
        return Events._eventStatus[eventName]
    end
    
    local events = ReplicatedStorage:FindFirstChild("events")
    if not events then
        Events._eventStatus[eventName] = false
        return false
    end

    local exists = events:FindFirstChild(eventName) ~= nil
    Events._eventStatus[eventName] = exists
    
    -- Only warn once per event
    if not exists and getgenv().Config and getgenv().Config.Debug then
        warn("⚠️ Event not found:", eventName)
    end
    
    return exists
end

-- Initialize events system
function Events.Initialize()
    if Events._initialized then
        return true
    end

    -- Ensure state exists
    if not getgenv().State then
        getgenv().State = {}
    end
    
    if not getgenv().State.Events then
        getgenv().State.Events = {
            Available = {}
        }
    end

    -- Check all required events once
    for _, eventName in ipairs(Events.REQUIRED_EVENTS) do
        getgenv().State.Events.Available[eventName] = Events.CheckEvent(eventName)
    end

    Events._initialized = true
    return true
end

-- Public interface
function Events.IsAvailable(eventName)
    return Events._eventStatus[eventName] == true
end

function Events.GetEvent(eventName)
    if not Events.IsAvailable(eventName) then
        return nil
    end
    
    local events = ReplicatedStorage:FindFirstChild("events")
    return events and events:FindFirstChild(eventName)
end

-- Run initialization
local success = Events.Initialize()

if success then
    if getgenv().Config and getgenv().Config.Debug then
        print("✓ Successfully loaded module: events")
    end
else
    warn("Failed to initialize events system")
end

return Events
