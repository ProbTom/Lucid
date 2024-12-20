-- events.lua
-- Version: 1.0.1
-- Author: ProbTom
-- Created: 2024-12-20 16:00:34 UTC

local Events = {
    _VERSION = "1.0.1",
    _DESCRIPTION = "Simple event system for Lucid",
    _initialized = false
}

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
    return setmetatable({
        name = name,
        handlers = {},
        lastFired = 0,
        fireCount = 0
    }, Event)
end

-- Fixed Fire method to ensure 'self' is properly bound
function Event:Fire(...)
    if not self or type(self) ~= "table" then
        return false
    end
    
    self.lastFired = os.time()
    self.fireCount = (self.fireCount or 0) + 1
    
    if not self.handlers then
        self.handlers = {}
        return false
    end
    
    for _, handler in ipairs(self.handlers) do
        task.spawn(function()
            local success = pcall(handler, ...)
            if not success and _G.Debug then
                _G.Debug.Error("Handler error in event: " .. tostring(self.name))
            end
        end)
    end
    return true
end

function Event:Connect(fn)
    if type(fn) ~= "function" then
        if _G.Debug then _G.Debug.Error("Cannot connect non-function to event") end
        return nil
    end
    
    if not self.handlers then
        self.handlers = {}
    end
    
    table.insert(self.handlers, fn)
    
    return {
        Connected = true,
        Disconnect = function(self)
            if not self.Connected then return end
            for i, handler in ipairs(self.handlers) do
                if handler == fn then
                    table.remove(self.handlers, i)
                    self.Connected = false
                    break
                end
            end
        end
    }
end

function Events.Create(name)
    if type(name) ~= "string" then
        if _G.Debug then _G.Debug.Error("Event name must be a string") end
        return nil
    end
    
    if storage.events[name] then
        return storage.events[name]
    end
    
    local event = Event.new(name)
    storage.events[name] = event
    return event
end

function Events.Get(name)
    return storage.events[name]
end

-- Fixed Fire method to ensure proper method call
function Events.Fire(name, ...)
    local event = storage.events[name]
    if not event then
        if _G.Debug then _G.Debug.Warn("Event '" .. name .. "' does not exist") end
        return false
    end
    
    -- Use proper method call syntax
    return event:Fire(...)
end

function Events.Connect(name, fn)
    local event = storage.events[name]
    if not event then
        if _G.Debug then _G.Debug.Warn("Event '" .. name .. "' does not exist") end
        return nil
    end
    
    return event:Connect(fn)
end

function Events.GetHistory()
    return table.clone(storage.history)
end

function Events.ClearHistory()
    storage.history = {}
    if _G.Debug then _G.Debug.Info("Event history cleared") end
end

function Events.init(modules)
    if Events._initialized then
        return true
    end
    
    if type(modules) ~= "table" then
        return false, "Invalid modules parameter"
    end
    
    if modules.debug then
        _G.Debug = modules.debug
    end
    
    Events._initialized = true
    if _G.Debug then _G.Debug.Info("Events module initialized") end
    return true
end

function Events.shutdown()
    for name, event in pairs(storage.events) do
        event.handlers = {}
    end
    storage.events = {}
    storage.history = {}
    Events._initialized = false
    if _G.Debug then _G.Debug.Info("Events module shut down") end
end

return Events
