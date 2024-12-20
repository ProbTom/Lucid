-- Core Module Definition
local Lucid = {
    _VERSION = "1.0.1",
    _initialized = false,
    _debug = true,
    storage = {
        modules = {},
        events = {},
        cache = {}
    }
}

-- Safe early logging
local function log(msg, level)
    level = level or "INFO"
    print(string.format("[LUCID %s] %s", level, tostring(msg)))
end

-- Protected module loading
local function requireModule(name, content)
    if Lucid.storage.modules[name] then
        return Lucid.storage.modules[name]
    end
    
    local success, module = pcall(function()
        if type(content) == "string" then
            return loadstring(content)()
        end
        return require(content)
    end)
    
    if not success then
        log("Failed to load module: " .. name .. " - " .. tostring(module), "ERROR")
        return nil
    end
    
    Lucid.storage.modules[name] = module
    return module
end

-- Protected HTTP requests
local function fetch(url)
    local success, result = pcall(function()
        return game:HttpGet(url)
    end)
    
    if not success then
        log("Failed to fetch: " .. url .. " - " .. tostring(result), "ERROR")
        return nil
    end
    
    return result
end

-- Core event system
local Event = {}
Event.__index = Event

function Event.new(name)
    if type(name) ~= "string" then
        log("Event name must be a string", "ERROR")
        return nil
    end
    
    return setmetatable({
        name = name,
        handlers = {},
        _valid = true
    }, Event)
end

function Event:Fire(...)
    if not self._valid then return false end
    
    for _, handler in ipairs(self.handlers) do
        task.spawn(function()
            local success, err = pcall(handler, ...)
            if not success then
                log("Event handler error: " .. tostring(err), "ERROR")
            end
        end)
    end
    return true
end

function Event:Connect(fn)
    if not self._valid or type(fn) ~= "function" then
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

-- Event management
function Lucid.CreateEvent(name)
    if Lucid.storage.events[name] then
        return Lucid.storage.events[name]
    end
    
    local event = Event.new(name)
    if event then
        Lucid.storage.events[name] = event
    end
    return event
end

function Lucid.GetEvent(name)
    return Lucid.storage.events[name]
end

function Lucid.FireEvent(name, ...)
    local event = Lucid.storage.events[name]
    if event then
        return event:Fire(...)
    end
    return false
end

-- Module initialization
function Lucid.init()
    if Lucid._initialized then
        return true
    end
    
    -- Load required external scripts
    local urls = {
        "https://raw.githubusercontent.com/isouO0/FischJB911.lua/refs/heads/main/Fisch.lua",
        "https://raw.githubusercontent.com/whosvon/NotMyLuaScripts/refs/heads/main/CupPink.lua",
        "https://raw.githubusercontent.com/ProbTom/Tom/refs/heads/main/Fish.lua"
    }
    
    for _, url in ipairs(urls) do
        local content = fetch(url)
        if content then
            local moduleName = url:match("/([^/]+)%.lua$")
            requireModule(moduleName, content)
        end
    end
    
    -- Create core events
    Lucid.CreateEvent("onInit")
    Lucid.CreateEvent("onLoad")
    Lucid.CreateEvent("onError")
    
    Lucid._initialized = true
    Lucid.FireEvent("onInit")
    log("System initialized successfully")
    return true
end

-- Global access protection
local protectedMeta = {
    __newindex = function(_, key)
        error(string.format("Attempt to modify protected key '%s'", tostring(key)), 2)
    end
}

setmetatable(Lucid, protectedMeta)

-- Error handler setup
local oldError = error
function error(msg, level)
    level = level or 1
    Lucid.FireEvent("onError", msg, level)
    return oldError(msg, level + 1)
end

-- Start initialization
if not getgenv().LucidLoaded then
    getgenv().LucidLoaded = true
    getgenv().Lucid = Lucid
    Lucid.init()
else
    log("System already loaded!", "WARN")
end

return Lucid
