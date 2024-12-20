-- events.lua
local Events = {
    _VERSION = "1.0.1",
    _DESCRIPTION = "Simple event system for Lucid",
    _initialized = false
}

-- Storage for modules
local debug = nil
local storage = {
    events = {},
    history = {},
    maxHistory = 1000
}

-- Event class
local Event = {}
Event.__index = Event

-- Safe logging function that doesn't require debug module
local function safeLog(msg, level)
    print(string.format("[LUCID %s] %s", level or "INFO", tostring(msg)))
end

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
            local success, err = pcall(handler, ...)
            if not success then
                safeLog(string.format("Event '%s' handler error: %s", self.name, tostring(err)), "ERROR")
            end
        end)
    end
end

function Event:Connect(fn)
    if type(fn) ~= "function" then
        safeLog("Attempted to connect non-function to event: " .. self.name, "ERROR")
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
        safeLog("Event name must be a string", "ERROR")
        return nil
    end
    
    if storage.events[name] then
        safeLog(string.format("Event '%s' already exists", name), "WARN")
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
    if not event then
        safeLog(string.format("Cannot fire non-existent event '%s'", name), "WARN")
        return false
    end
    
    event:Fire(...)
    return true
end

function Events.Connect(name, fn)
    local event = storage.events[name]
    if not event then
        safeLog(string.format("Cannot connect to non-existent event '%s'", name), "WARN")
        return nil
    end
    
    return event:Connect(fn)
end

function Events.GetHistory()
    return table.clone(storage.history)
end

function Events.ClearHistory()
    storage.history = {}
    safeLog("Event history cleared")
end

function Events.init(modules)
    if Events._initialized then
        return true
    end
    
    -- Save debug module for later use
    debug = modules.debug
    
    Events._initialized = true
    safeLog("Events module initialized")
    return true
end

return Events
