-- state.lua
-- Version: 1.0.1
-- Author: ProbTom
-- Created: 2024-12-20 14:42:19 UTC

local State = {}

-- Dependencies
local Debug

-- State storage
local states = {}
local watchers = {}
local history = {}
local MAX_HISTORY = 100

-- State change event
local StateChanged = Instance.new("BindableEvent")

-- Helper function to deep copy tables
local function deepCopy(original)
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
        Debug.Warn("State '" .. name .. "' already exists")
        return false
    end
    
    states[name] = {
        value = initialValue,
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
        Debug.Warn("State '" .. name .. "' does not exist")
        return nil
    end
    
    return deepCopy(states[name].value)
end

-- Set state value
function State.Set(name, value)
    if not states[name] then
        Debug.Warn("State '" .. name .. "' does not exist")
        return false
    end
    
    -- Store previous state in history
    table.insert(history[name], 1, {
        value = deepCopy(states[name].value),
        timestamp = states[name].timestamp,
        version = states[name].version
    })
    
    -- Trim history if needed
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
            callback(value, name)
        end)
    end
    
    -- Fire change event
    StateChanged:Fire(name, value)
    
    Debug.Info("Updated state: " .. name)
    return true
end

-- Watch state changes
function State.Watch(name, callback)
    if not states[name] then
        Debug.Warn("State '" .. name .. "' does not exist")
        return false
    end
    
    table.insert(watchers[name], callback)
    return #watchers[name]
end

-- Remove state watcher
function State.Unwatch(name, watcherId)
    if not states[name] then
        Debug.Warn("State '" .. name .. "' does not exist")
        return false
    end
    
    table.remove(watchers[name], watcherId)
    return true
end

-- Get state history
function State.GetHistory(name)
    if not states[name] then
        Debug.Warn("State '" .. name .. "' does not exist")
        return nil
    end
    
    return deepCopy(history[name])
end

-- Revert state to previous value
function State.Revert(name)
    if not states[name] or #history[name] == 0 then
        Debug.Warn("Cannot revert state '" .. name .. "'")
        return false
    end
    
    local previous = table.remove(history[name], 1)
    states[name].value = deepCopy(previous.value)
    states[name].timestamp = previous.timestamp
    states[name].version = previous.version
    
    -- Notify watchers
    for _, callback in ipairs(watchers[name]) do
        task.spawn(function()
            callback(states[name].value, name)
        end)
    end
    
    StateChanged:Fire(name, states[name].value)
    
    Debug.Info("Reverted state: " .. name)
    return true
end

-- Get all states
function State.GetAll()
    local allStates = {}
    for name, state in pairs(states) do
        allStates[name] = deepCopy(state)
    end
    return allStates
end

-- Clear state history
function State.ClearHistory(name)
    if not states[name] then
        Debug.Warn("State '" .. name .. "' does not exist")
        return false
    end
    
    history[name] = {}
    Debug.Info("Cleared history for state: " .. name)
    return true
end

-- Initialize module
function State.init(modules)
    Debug = modules.debug
    Debug.Info("State module initialized")
    return true
end

return State
