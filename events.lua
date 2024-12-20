-- events.lua
-- Version: 1.0.1
-- Author: ProbTom
-- Created: 2024-12-20 14:54:58 UTC

local Events = {
    _VERSION = "1.0.1",
    _AUTHOR = "ProbTom",
    _initialized = false
}

-- Storage
local eventStorage = {
    events = {},
    connections = {},
    history = {},
    maxHistory = 1000
}

-- Forward declaration of dependencies
local Debug

-- Event class
local Event = {}
Event.__index = Event

function Event.new(name)
    local self = setmetatable({
        Name = name,
        Handlers = {},
        LastFired = 0,
        FireCount = 0,
        Active = true
    }, Event)
    return self
end

function Event:Fire(...)
    if not self.Active then return end
    
    self.LastFired = os.time()
    self.FireCount = self.FireCount + 1
    
    -- Log event
    if Debug then
        Debug.Debug(string.format("Event '%s' fired", self.Name))
    end
    
    -- Record in history
    table.insert(eventStorage.history, {
        name = self.Name,
        timestamp = self.LastFired,
        args = {...}
    })
    
    -- Trim history if needed
    while #eventStorage.history > eventStorage.maxHistory do
        table.remove(eventStorage.history, 1)
    end
    
    -- Fire handlers
    for _, handler in ipairs(self.Handlers) do
        task.spawn(function()
            local success, err = pcall(handler, ...)
            if not success and Debug then
                Debug.Error(string.format("Event handler error in '%s': %s", self.Name, err))
            end
        end)
    end
end

function Event:Connect(handler)
    if type(handler) ~= "function" then
        if Debug then
            Debug.Error("Event handler must be a function")
        end
        return nil
    end
    
    table.insert(self.Handlers, handler)
    
    local connection = {
        Connected = true,
        Disconnect = function(self)
            if not self.Connected then return end
            
            for i, h in ipairs(self.Handlers) do
                if h == handler then
                    table.remove(self.Handlers, i)
                    break
                end
            end
            
            self.Connected = false
            if Debug then
                Debug.Debug(string.format("Disconnected handler from event '%s'", self.Name))
            end
        end
    }
    
    table.insert(eventStorage.connections, connection)
    return connection
end

-- Public API
function Events.Create(name)
    if not name or type(name) ~= "string" then
        if Debug then Debug.Error("Event name must be a string") end
        return nil
    end
    
    if eventStorage.events[name] then
        if Debug then Debug.Warn(string.format("Event '%s' already exists", name)) end
        return eventStorage.events[name]
    end
    
    local event = Event.new(name)
    eventStorage.events[name] = event
    
    if Debug then
        Debug.Info(string.format("Created event: %s", name))
    end
    
    return event
end

function Events.Get(name)
    return eventStorage.events[name]
end

function Events.Fire(name, ...)
    local event = eventStorage.events[name]
    if not event then
        if Debug then Debug.Warn(string.format("Event '%s' does not exist", name)) end
        return false
    end
    
    event:Fire(...)
    return true
end

function Events.Connect(name, handler)
    local event = eventStorage.events[name]
    if not event then
        if Debug then Debug.Warn(string.format("Event '%s' does not exist", name)) end
        return nil
    end
    
    return event:Connect(handler)
end

function Events.GetHistory()
    return table.clone(eventStorage.history)
end

function Events.ClearHistory()
    eventStorage.history = {}
    if Debug then Debug.Info("Event history cleared") end
end

function Events.GetStats(name)
    local event = eventStorage.events[name]
    if not event then
        if Debug then Debug.Warn(string.format("Event '%s' does not exist", name)) end
        return nil
    end
    
    return {
        name = event.Name,
        handlers = #event.Handlers,
        lastFired = event.LastFired,
        fireCount = event.FireCount
    }
end

-- Module initialization
function Events.init(modules)
    if Events._initialized then
        return true
    end
    
    if type(modules) ~= "table" then
        return false, "Invalid modules parameter"
    end
    
    -- Store debug module reference
    Debug = modules.debug
    if not Debug then
        return false, "Debug module is required"
    end
    
    Events._initialized = true
    Debug.Info("Events module initialized")
    return true
end

-- Module shutdown
function Events.shutdown()
    if not Events._initialized then return end
    
    -- Clear all events and connections
    for name, event in pairs(eventStorage.events) do
        event.Active = false
        event.Handlers = {}
    end
    
    eventStorage.events = {}
    eventStorage.connections = {}
    eventStorage.history = {}
    
    Events._initialized = false
    if Debug then Debug.Info("Events module shut down") end
end

return Events
