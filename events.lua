-- events.lua
-- Version: 1.0.1
-- Author: ProbTom
-- Created: 2024-12-20 14:43:08 UTC

local Events = {}

-- Dependencies
local Debug

-- Storage for events
local events = {}
local connections = {}
local eventHistory = {}
local MAX_HISTORY = 1000

-- Event class
local Event = {}
Event.__index = Event

function Event.new(name)
    local self = setmetatable({}, Event)
    self.Name = name
    self.Handlers = {}
    self.LastFired = 0
    self.FireCount = 0
    return self
end

function Event:Fire(...)
    self.LastFired = os.time()
    self.FireCount = self.FireCount + 1
    
    -- Log to history
    table.insert(eventHistory, {
        name = self.Name,
        timestamp = self.LastFired,
        args = {...}
    })
    
    -- Trim history if needed
    if #eventHistory > MAX_HISTORY then
        table.remove(eventHistory, 1)
    end
    
    -- Fire handlers
    for _, handler in ipairs(self.Handlers) do
        task.spawn(function()
            local success, err = pcall(handler, ...)
            if not success then
                Debug.Error(string.format("Error in event handler for '%s': %s", self.Name, err))
            end
        end)
    end
    
    Debug.Debug(string.format("Event '%s' fired with %d handlers", self.Name, #self.Handlers))
end

function Event:Connect(handler)
    if type(handler) ~= "function" then
        Debug.Error("Event handler must be a function")
        return nil
    end
    
    table.insert(self.Handlers, handler)
    local connection = {
        Disconnect = function()
            for i, h in ipairs(self.Handlers) do
                if h == handler then
                    table.remove(self.Handlers, i)
                    break
                end
            end
        end
    }
    
    table.insert(connections, connection)
    return connection
end

-- Create new event
function Events.Create(name)
    if events[name] then
        Debug.Warn(string.format("Event '%s' already exists", name))
        return events[name]
    end
    
    events[name] = Event.new(name)
    Debug.Info(string.format("Created event: %s", name))
    return events[name]
end

-- Get existing event
function Events.Get(name)
    return events[name]
end

-- Fire event
function Events.Fire(name, ...)
    local event = events[name]
    if not event then
        Debug.Warn(string.format("Event '%s' does not exist", name))
        return false
    end
    
    event:Fire(...)
    return true
end

-- Connect to event
function Events.Connect(name, handler)
    local event = events[name]
    if not event then
        Debug.Warn(string.format("Event '%s' does not exist", name))
        return nil
    end
    
    return event:Connect(handler)
end

-- Get event history
function Events.GetHistory()
    return eventHistory
end

-- Clear event history
function Events.ClearHistory()
    eventHistory = {}
    Debug.Info("Event history cleared")
end

-- Get event statistics
function Events.GetStats(name)
    local event = events[name]
    if not event then
        Debug.Warn(string.format("Event '%s' does not exist", name))
        return nil
    end
    
    return {
        name = event.Name,
        handlers = #event.Handlers,
        lastFired = event.LastFired,
        fireCount = event.FireCount
    }
end

-- Get all events
function Events.GetAll()
    local allEvents = {}
    for name, event in pairs(events) do
        allEvents[name] = {
            name = event.Name,
            handlers = #event.Handlers,
            lastFired = event.LastFired,
            fireCount = event.FireCount
        }
    end
    return allEvents
end

-- Initialize module
function Events.init(modules)
    Debug = modules.debug
    Debug.Info("Events module initialized")
    return true
end

return Events
