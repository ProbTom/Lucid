-- events.lua
local Events = {
    _VERSION = "1.0.1",
    _DESCRIPTION = "Simple event system for Lucid",
    _initialized = false
}

-- Storage for modules
local debug
local storage = {
    events = {},
    history = {},
    maxHistory = 1000
}

-- Event class
local Event = {}
Event.__index = Event

local function safeLog(level, msg)
    if debug and type(debug[level]) == "function" then
        debug[level](msg)
    end
end

function Event.new(name)
    local self = setmetatable({
        name = name,
        handlers = {},
        lastFired = 0,
        fireCount = 0
    }, Event)
    
    safeLog("Info", "Created new event: " .. name)
    return self
end

function Event:Fire(...)
    self.lastFired = os.time()
    self.fireCount = self.fireCount + 1
    
    for _, handler in ipairs(self.handlers) do
        task.spawn(function()
            local success, err = pcall(handler, ...)
            if not success then
                safeLog("Error", string.format("Event '%s' handler error: %s", self.name, tostring(err)))
            end
        end)
    end
end

function Event:Connect(fn)
    if type(fn) ~= "function" then
        safeLog("Error", "Attempted to connect non-function to event: " .. self.name)
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
                    safeLog("Debug", string.format("Disconnected handler from event '%s'", self.name))
                    break
                end
            end
        end
    }
    
    safeLog("Debug", string.format("Connected handler to event '%s'", self.name))
    return connection
end

function Events.Create(name)
    if type(name) ~= "string" then
        safeLog("Error", "Event name must be a string")
        return nil
    end
    
    if storage.events[name] then
        safeLog("Warn", string.format("Event '%s' already exists", name))
        return storage.events[name]
    end
    
    local event = Event.new(name)
    storage.events[name] = event
    return event
end

function Events.Get(name)
    local event = storage.events[name]
    if not event then
        safeLog("Warn", string.format("Event '%s' not found", name))
    end
    return event
end

function Events.Fire(name, ...)
    local event = storage.events[name]
    if not event then
        safeLog("Warn", string.format("Cannot fire non-existent event '%s'", name))
        return false
    end
    
    event:Fire(...)
    return true
end

function Events.Connect(name, fn)
    local event = storage.events[name]
    if not event then
        safeLog("Warn", string.format("Cannot connect to non-existent event '%s'", name))
        return nil
    end
    
    return event:Connect(fn)
end

function Events.init(modules)
    if Events._initialized then
        return true
    end
    
    if type(modules) ~= "table" then
        error("Events.init requires modules table")
    end
    
    debug = modules.debug
    if not debug then
        error("Events module requires debug module")
    end
    
    Events._initialized = true
    debug.Info("Events module initialized")
    return true
end

return Events
