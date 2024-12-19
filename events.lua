-- events.lua
-- Core events module for Lucid Hub
local Events = {
    _version = "1.0.1",
    _initialized = false
}

-- Core services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Initialize events system
local function initialize()
    if Events._initialized then
        return true
    end

    local events = ReplicatedStorage:FindFirstChild("events")
    if not events then
        warn("Events container not found")
        return false
    end

    -- Register required events
    local requiredEvents = {
        "castrod",
        "reelfinished",
        "character"
    }

    -- Check and store event availability
    if not getgenv().State then
        getgenv().State = {}
    end
    
    if not getgenv().State.Events then
        getgenv().State.Events = {
            Available = {}
        }
    end

    for _, eventName in ipairs(requiredEvents) do
        local eventExists = events:FindFirstChild(eventName) ~= nil
        getgenv().State.Events.Available[eventName] = eventExists
        
        if not eventExists and getgenv().Config and getgenv().Config.Debug then
            warn("⚠️ Event not found:", eventName)
        end
    end

    Events._initialized = true
    return true
end

-- Run initialization
local success = initialize()

if success then
    if getgenv().Config and getgenv().Config.Debug then
        print("✓ Successfully loaded module: events")
    end
else
    warn("Failed to initialize events system")
end

return Events
