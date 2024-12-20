-- events.lua
-- Version: 1.0.1
-- Author: ProbTom
-- Created: 2024-12-20 14:58:20 UTC

-- Create Events module with minimal dependencies
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

-- Simple print function for early debugging
local function log(...)
    print("[LUCID EVENTS]", ...)
end

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

function Event:Fire(...)
    self.lastFired = os.time()
    self.fireCount = self.fireCount + 1
    
    for _, handler in ipairs(self.handlers) do
        task.spawn(function()
            local success = pcall(handler, ...)
            if not success then
                log("Handler error in event:", self.name)
            end
        end)
    end
end

function Event:Connect(fn)
    if type(fn) ~= "function" then
        return nil
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

-- Public API
function Events.Create(name)
    if type(name) ~= "string" then
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

function Events.Fire(name, ...)
    local event = storage.events[name]
    if event then
        event:Fire(...)
        return true
    end
    return false
end

function Events.Connect(name, fn)
    local event = storage.events[name]
    if event then
        return event:Connect(fn)
    end
    return nil
end

function Events.GetHistory()
    return table.clone(storage.history)
end

function Events.ClearHistory()
    storage.history = {}
end

-- Safe initialization
function Events.init(modules)
    if Events._initialized then
        return true
    end
    
    Events._initialized = true
    log("Events system initialized")
    return true
end

-- Clean shutdown
function Events.shutdown()
    for name, event in pairs(storage.events) do
        event.handlers = {}
    end
    storage.events = {}
    storage.history = {}
    Events._initialized = false
end

return Events
