-- events.lua
-- Version: 1.0.1
-- Author: ProbTom
-- Created: 2024-12-20 14:47:24 UTC

local Events = {}

-- Dependencies (with nil checks)
local Debug
local success, err = pcall(function()
    if not Debug then
        error("Debug module not loaded")
    end
end)

if not success then
    warn("[LUCID] Events module initialization warning: Debug module not found")
    -- Provide fallback debug functions
    Debug = {
        Info = function(msg) print("[LUCID INFO]", msg) end,
        Warn = function(msg) warn("[LUCID WARN]", msg) end,
        Error = function(msg) error("[LUCID ERROR] " .. msg) end,
        Debug = function(msg) print("[LUCID DEBUG]", msg) end
    }
end

-- Storage for events with initialization
local events = {}
local connections = {}
local eventHistory = {}
local MAX_HISTORY = 1000

-- Event class with error handling
local Event = {}
Event.__index = Event

function Event.new(name)
    if type(name) ~= "string" then
        Debug.Error("Event name must be a string")
        return nil
    end

    local self = setmetatable({}, Event)
    self.Name = name
    self.Handlers = {}
    self.LastFired = 0
    self.FireCount = 0
    return self
end

-- Safe event firing
function Event:Fire(...)
    if not self or type(self.Handlers) ~= "table" then
        Debug.Error("Invalid event object")
        return
    end

    self.LastFired = os.time()
    self.FireCount = self.FireCount + 1
    
    -- Safe history logging
    pcall(function()
        table.insert(eventHistory, {
            name = self.Name,
            timestamp = self.LastFired,
            args = {...}
        })
        
        if #eventHistory > MAX_HISTORY then
            table.remove(eventHistory, 1)
        end
    end)
    
    -- Safe handler execution
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

-- Safe connection handling
function Event:Connect(handler)
    if type(handler) ~= "function" then
        Debug.Error("Event handler must be a function")
        return nil
    end
    
    -- Ensure Handlers table exists
    if type(self.Handlers) ~= "table" then
        self.Handlers = {}
    end
    
    table.insert(self.Handlers, handler)
    
    local connection = {
        Disconnect = function()
            if type(self.Handlers) ~= "table" then return end
            for i, h in ipairs(self.Handlers) do
                if h == handler then
                    table.remove(self.Handlers, i)
                    break
                end
            end
        end
    }
    
    -- Safe connection storage
    pcall(function()
        table.insert(connections, connection)
    end)
    
    return connection
end

-- Safe event creation
function Events.Create(name)
    if type(name) ~= "string" then
        Debug.Error("Event name must be a string")
        return nil
    end

    if events[name] then
        Debug.Warn(string.format("Event '%s' already exists", name))
        return events[name]
    end
    
    local event = Event.new(name)
    if not event then
        Debug.Error("Failed to create event: " .. name)
        return nil
    end
    
    events[name] = event
    Debug.Info(string.format("Created event: %s", name))
    return event
end

-- Safe event retrieval
function Events.Get(name)
    if type(name) ~= "string" then
        Debug.Error("Event name must be a string")
        return nil
    end
    return events[name]
end

-- Safe event firing
function Events.Fire(name, ...)
    if type(name) ~= "string" then
        Debug.Error("Event name must be a string")
        return false
    end

    local event = events[name]
    if not event then
        Debug.Warn(string.format("Event '%s' does not exist", name))
        return false
    end
    
    return pcall(function()
        event:Fire(...)
    end)
end

-- Safe event connection
function Events.Connect(name, handler)
    if type(name) ~= "string" then
        Debug.Error("Event name must be a string")
        return nil
    end

    local event = events[name]
    if not event then
        Debug.Warn(string.format("Event '%s' does not exist", name))
        return nil
    end
    
    return event:Connect(handler)
end

-- Safe history retrieval
function Events.GetHistory()
    return table.clone(eventHistory)
end

-- Safe history clearing
function Events.ClearHistory()
    eventHistory = {}
    Debug.Info("Event history cleared")
end

-- Safe stats retrieval
function Events.GetStats(name)
    if type(name) ~= "string" then
        Debug.Error("Event name must be a string")
        return nil
    end

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

-- Initialize module with error handling
function Events.init(modules)
    if type(modules) ~= "table" then
        error("Invalid modules parameter")
        return false
    end

    Debug = modules.debug
    if not Debug then
        error("Debug module is required")
        return false
    end

    Debug.Info("Events module initialized")
    return true
end

return Events
