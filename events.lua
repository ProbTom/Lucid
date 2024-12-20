-- events.lua
-- Version: 1.0.1
-- Author: ProbTom
-- Created: 2024-12-20 17:22:00 UTC

-- Core module definition with strict type checking
local Events = {
    _VERSION = "1.0.1",
    _DESCRIPTION = "Simple event system for Lucid",
    _initialized = false,
    _modules = {},  -- Store module references locally
    storage = {     -- Move storage into main table for better scope control
        events = {},
        history = {},
        maxHistory = 1000
    }
}

-- Event prototype with strict metatable control
local Event = {}
Event.__index = Event
Event.__metatable = "locked"  -- Prevent external metatable modification

-- Internal logging with fallback
local function log(msg, level)
    level = level or "INFO"
    if Events._modules.debug and type(Events._modules.debug.log) == "function" then
        Events._modules.debug.log(level, msg)
    else
        print(string.format("[LUCID %s] %s", level, tostring(msg)))
    end
end

-- Constructor with validation
function Event.new(name)
    assert(type(name) == "string", "Event name must be a string")
    
    local self = {
        name = name,
        handlers = {},
        lastFired = 0,
        fireCount = 0,
        _valid = true  -- Internal state tracking
    }
    return setmetatable(self, Event)
end

-- Protected event firing
function Event:Fire(...)
    if not self._valid then return false end
    
    self.lastFired = os.time()
    self.fireCount = self.fireCount + 1
    
    for _, handler in ipairs(self.handlers) do
        task.spawn(function()
            local success, err = pcall(handler, ...)
            if not success then
                log(string.format("Event '%s' handler error: %s", self.name, tostring(err)), "ERROR")
            end
        end)
    end
    return true
end

-- Protected connection management
function Event:Connect(fn)
    if not self._valid then return nil end
    assert(type(fn) == "function", "Handler must be a function")
    
    table.insert(self.handlers, fn)
    
    local connection = {
        Connected = true,
        Event = self,
        _handler = fn,
        Disconnect = function(self)
            if not self.Connected then return end
            
            for i, handler in ipairs(self.Event.handlers) do
                if handler == self._handler then
                    table.remove(self.Event.handlers, i)
                    self.Connected = false
                    break
                end
            end
        end
    }
    
    return connection
end

-- Public API with strict validation
function Events.Create(name)
    assert(type(name) == "string", "Event name must be a string")
    
    if Events.storage.events[name] then
        log(string.format("Event '%s' already exists", name), "WARN")
        return Events.storage.events[name]
    end
    
    local event = Event.new(name)
    Events.storage.events[name] = event
    return event
end

function Events.Get(name)
    local event = Events.storage.events[name]
    if not event then
        log(string.format("Event '%s' not found", name), "WARN")
    end
    return event
end

function Events.Fire(name, ...)
    local event = Events.storage.events[name]
    if not event then
        log(string.format("Cannot fire non-existent event '%s'", name), "WARN")
        return false
    end
    return event:Fire(...)
end

function Events.Connect(name, fn)
    local event = Events.storage.events[name]
    if not event then
        log(string.format("Cannot connect to non-existent event '%s'", name), "WARN")
        return nil
    end
    return event:Connect(fn)
end

function Events.GetHistory()
    local historyCopy = {}
    for k, v in pairs(Events.storage.history) do
        if type(v) == "table" then
            historyCopy[k] = table.clone(v)
        else
            historyCopy[k] = v
        end
    end
    return historyCopy
end

function Events.ClearHistory()
    Events.storage.history = {}
    log("Event history cleared")
end

-- Protected initialization
function Events.init(modules)
    if Events._initialized then 
        return true 
    end
    
    assert(type(modules) == "table", "Events.init requires modules table")
    assert(type(modules.debug) == "table", "Events module requires debug module")
    
    -- Store module references locally
    Events._modules = modules
    Events._initialized = true
    
    -- Use debug module directly after verification
    modules.debug.Info("Events module initialized")
    return true
end

-- Prevent modification of core module properties
setmetatable(Events, {
    __newindex = function()
        error("Cannot modify Events module core properties", 2)
    end
})

return Events
