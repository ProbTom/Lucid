-- events.lua
-- Version: 1.0.1
-- Author: ProbTom
-- Created: 2024-12-20 15:02:37 UTC

local Events = {
    _VERSION = "1.0.1",
    _DESCRIPTION = "Simple event system for Lucid",
    _initialized = false
}

-- Storage for modules
local debug = nil  -- Will be set during init

-- Internal storage
local storage = {
    events = {},
    history = {},
    maxHistory = 1000
}

-- Event class
local Event = {}
Event.__index = Event

function Event.new(name)
    local self = setmetatable({
        name = name,
        handlers = {},
        lastFired = 0,
        fireCount = 0
    }, Event)
    
    if debug then
        debug.Info("Created new event: " .. name)
    end
    
    return self
end

function Event:Fire(...)
    self.lastFired = os.time()
    self.fireCount = self.fireCount + 1
    
    for _, handler in ipairs(self.handlers) do
        task.spawn(function()
            local success, err = pcall(handler, ...)
            if not success and debug then
                debug.Error(string.format("Event '%s' handler error: %s", self.name, tostring(err)))
            end
        end)
    end
end

function Event:Connect(fn)
    if type(fn) ~= "function" then
        if debug then
            debug.Error("Attempted to connect non-function to event: " .. self.name)
        end
        return nil
    end
    
    table.insert(self.handlers, fn)
    
    local connection = {
        Connected = true,
        Disconnect = function(self)
            if not self.Connected then return end
            
            for i, handler in ipairs(self.handlers) do
                if handler == fn then
                    table.remove(self.handlers, i)
                    self.Connected = false
                    if debug then
                        debug.Debug(string.format("Disconnected handler from event '%s'", self.name))
                    end
                    break
                end
            end
        end
    }
    
    if debug then
        debug.Debug(string.format("Connected handler to event '%s'", self.name))
    end
    
    return connection
end

-- Public API
function Events.Create(name)
    if type(name) ~= "string" then
        if debug then
            debug.Error("Event name must be a string")
        end
        return nil
    end
    
    if storage.events[name] then
        if debug then
            debug.Warn(string.format("Event '%s' already exists", name))
        end
        return storage.events[name]
    end
    
    local event = Event.new(name)
    storage.events[name] = event
    return event
end

function Events.Get(name)
    local event = storage.events[name]
    if not event and debug then
        debug.Warn(string.format("Event '%s' not found", name))
    end
    return event
end

function Events.Fire(name, ...)
    local event = storage.events[name]
    if not event then
        if debug then
            debug.Warn(string.format("Cannot fire non-existent event '%s'", name))
        end
        return false
    end
    
    event:Fire(...)
    return true
end

function Events.Connect(name, fn)
    local event = storage.events[name]
    if not event then
        if debug then
            debug.Warn(string.format("Cannot connect to non-existent event '%s'", name))
        end
        return nil
    end
    
    return event:Connect(fn)
end

function Events.GetHistory()
    return table.clone(storage.history)
end

function Events.ClearHistory()
    storage.history = {}
    if debug then
        debug.Info("Event history cleared")
    end
end

-- Critical: This is where we were having the nil error
function Events.init(modules)
    if Events._initialized then
        return true
    end
    
    if type(modules) ~= "table" then
        error("Events.init requires modules table")
    end
    
    -- Store debug module reference properly
    debug = modules.debug
    if not debug then
        error("Events module requires debug module")
    end
    
    Events._initialized = true
    debug.Info("Events module initialized")
    return true
end

function Events.shutdown()
    if not Events._initialized then return end
    
    if debug then
        debug.Info("Events module shutting down")
    end
    
    for name, event in pairs(storage.events) do
        event.handlers = {}
    end
    storage.events = {}
    storage.history = {}
    Events._initialized = false
end

return Events
