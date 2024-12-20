-- state.lua
-- Version: 1.0.1
-- Author: ProbTom
-- Created: 2024-12-20 19:47:58 UTC

local State = {
    _VERSION = "1.0.1",
    _initialized = false
}

-- Dependencies
local Debug

-- State storage
local states = {}
local watchers = {}
local history = {}
local MAX_HISTORY = 50

-- State change event
local StateChanged = Instance.new("BindableEvent")

-- Helper function to deep copy tables
local function deepCopy(original)
    if type(original) ~= "table" then return original end
    
    local copy = {}
    for k, v in pairs(original) do
        if type(v) == "table" then
            copy[k] = deepCopy(v)
        else
            copy[k] = v
        end
    end
    return copy
end

-- Create a new state
function State.Create(name, initialValue)
    if states[name] then
        Debug.Warn("State already exists: " .. name)
        return false
    end
    
    states[name] = {
        value = deepCopy(initialValue),
        timestamp = os.time(),
        version = 1
    }
    
    watchers[name] = {}
    history[name] = {}
    
    Debug.Info("Created state: " .. name)
    return true
end

-- Get state value
function State.Get(name)
    if not states[name] then
        Debug.Warn("State does not exist: " .. name)
        return nil
    end
    
    return deepCopy(states[name].value)
end

-- Set state value
function State.Set(name, value)
    if not states[name] then
        Debug.Warn("State does not exist: " .. name)
        return false
    end
    
    -- Store previous state
    table.insert(history[name], 1, {
        value = deepCopy(states[name].value),
        timestamp = states[name].timestamp,
        version = states[name].version
    })
    
    -- Trim history
    if #history[name] > MAX_HISTORY then
        table.remove(history[name])
    end
    
    -- Update state
    states[name].value = deepCopy(value)
    states[name].timestamp = os.time()
    states[name].version = states[name].version + 1
    
    -- Notify watchers
    for _, callback in ipairs(watchers[name]) do
        task.spawn(function()
            callback(deepCopy(value), name)
        end)
    end
    
    StateChanged:Fire(name, value)
    Debug.Info("Updated state: " .. name)
    return true
end

-- Initialize module
function State.init(modules)
    if State._initialized then return true end
    
    Debug = modules.debug
    if not Debug then
        return false
    end
    
    State._initialized = true
    Debug.Info("State module initialized")
    return true
end

return State
