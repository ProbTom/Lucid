-- events.lua
-- Version: 1.0.1
-- Author: ProbTom
-- Last Updated: 2024-12-20 14:49:17 UTC

-- Create the Events module
local Events = {
    _VERSION = "1.0.1",
    _DESCRIPTION = "Lucid Events System"
}

-- Early debug function
local function eventDebug(msg)
    print("[LUCID EVENTS]", msg)
end

-- Initialize storage
Events._storage = {
    events = {},
    connections = {},
    history = {},
    maxHistory = 1000
}

-- Basic event creation (without dependencies)
function Events.Create(name)
    eventDebug("Creating event: " .. tostring(name))
    
    if type(name) ~= "string" then
        eventDebug("Error: Event name must be a string")
        return nil
    end

    if Events._storage.events[name] then
        eventDebug("Warning: Event already exists: " .. name)
        return Events._storage.events[name]
    end

    local event = {
        name = name,
        handlers = {},
        lastFired = 0,
        fireCount = 0
    }

    Events._storage.events[name] = event
    eventDebug("Successfully created event: " .. name)
    return event
end

-- Safe event firing
function Events.Fire(name, ...)
    eventDebug("Attempting to fire event: " .. tostring(name))
    
    local event = Events._storage.events[name]
    if not event then
        eventDebug("Error: Event not found: " .. tostring(name))
        return false
    end

    event.lastFired = os.time()
    event.fireCount = event.fireCount + 1

    for _, handler in ipairs(event.handlers) do
        task.spawn(function()
            local success, err = pcall(handler, ...)
            if not success then
                eventDebug("Handler error: " .. tostring(err))
            end
        end)
    end

    return true
end

-- Safe event connection
function Events.Connect(name, handler)
    eventDebug("Attempting to connect to event: " .. tostring(name))
    
    if type(handler) ~= "function" then
        eventDebug("Error: Handler must be a function")
        return nil
    end

    local event = Events._storage.events[name]
    if not event then
        eventDebug("Error: Event not found: " .. tostring(name))
        return nil
    end

    table.insert(event.handlers, handler)
    
    return {
        Disconnect = function()
            for i, h in ipairs(event.handlers) do
                if h == handler then
                    table.remove(event.handlers, i)
                    break
                end
            end
        end
    }
end

-- Initialize module
function Events.init(modules)
    eventDebug("Initializing events module")
    
    if type(modules) ~= "table" then
        eventDebug("Error: modules parameter must be a table")
        return false
    end

    -- Store debug module if available
    if modules.debug then
        Events.debug = modules.debug
        eventDebug("Debug module connected")
    else
        eventDebug("Warning: Debug module not found")
    end

    eventDebug("Events module initialized successfully")
    return true
end

return Events
