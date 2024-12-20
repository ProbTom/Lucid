-- state.lua
-- Version: 2024.12.20
-- Author: ProbTom
-- Last Updated: 2024-12-20 14:29:21

local State = {
    _version = "1.0.1",
    _data = {},
    _cache = {},
    _connections = {},
    _lastUpdate = os.time(),
    _initialized = false
}

local Debug = getgenv().LucidDebug

-- Utility Functions
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

local function isValidKey(key)
    return type(key) == "string" and key:match("^[%w_]+$") ~= nil
end

local function validateValue(value)
    local valueType = type(value)
    return valueType == "string" or 
           valueType == "number" or 
           valueType == "boolean" or 
           valueType == "table"
end

-- Core State Management
function State.Set(key, value, options)
    if not isValidKey(key) then
        Debug.Error("Invalid state key: " .. tostring(key))
        return false
    end
    
    if not validateValue(value) then
        Debug.Error("Invalid value type for key: " .. key)
        return false
    end
    
    options = options or {}
    local oldValue = State._data[key]
    
    -- Deep copy for table values
    if type(value) == "table" then
        State._data[key] = deepCopy(value)
    else
        State._data[key] = value
    end
    
    -- Update cache
    State._cache[key] = {
        value = State._data[key],
        timestamp = os.time(),
        type = type(value)
    }
    
    -- Update global state
    if getgenv().LucidState then
        getgenv().LucidState[key] = State._data[key]
    end
    
    -- Trigger change event
    if options.notify ~= false and oldValue ~= value then
        State.TriggerChange(key, value, oldValue)
    end
    
    State._lastUpdate = os.time()
    return true
end

function State.Get(key, defaultValue)
    if not isValidKey(key) then
        Debug.Error("Invalid state key: " .. tostring(key))
        return defaultValue
    end
    
    return State._data[key] ~= nil and State._data[key] or defaultValue
end

function State.Delete(key)
    if not isValidKey(key) then
        Debug.Error("Invalid state key: " .. tostring(key))
        return false
    end
    
    State._data[key] = nil
    State._cache[key] = nil
    
    if getgenv().LucidState then
        getgenv().LucidState[key] = nil
    end
    
    return true
end

-- Event Management
function State.TriggerChange(key, newValue, oldValue)
    if State._connections[key] then
        for _, callback in ipairs(State._connections[key]) do
            task.spawn(function()
                pcall(callback, newValue, oldValue)
            end)
        end
    end
end

function State.OnChange(key, callback)
    if not isValidKey(key) or type(callback) ~= "function" then
        Debug.Error("Invalid parameters for OnChange")
        return false
    end
    
    State._connections[key] = State._connections[key] or {}
    table.insert(State._connections[key], callback)
    
    return true
end

-- State Persistence
function State.Save()
    local saveData = {
        version = State._version,
        timestamp = os.time(),
        data = deepCopy(State._data)
    }
    
    if writefile then
        pcall(function()
            writefile("LucidState.json", game:GetService("HttpService"):JSONEncode(saveData))
        end)
    end
    
    return true
end

function State.Load()
    if not readfile then return false end
    
    local success, data = pcall(function()
        return game:GetService("HttpService"):JSONDecode(readfile("LucidState.json"))
    end)
    
    if success and data then
        for k, v in pairs(data.data) do
            State.Set(k, v, {notify = false})
        end
        return true
    end
    
    return false
end

-- Cache Management
function State.CleanCache()
    local currentTime = os.time()
    local cacheTimeout = getgenv().LucidState.Config.Performance.CacheTime
    
    for key, cache in pairs(State._cache) do
        if currentTime - cache.timestamp > cacheTimeout then
            State._cache[key] = nil
        end
    end
end

-- Initialization
function State.Initialize()
    if State._initialized then
        return true
    end
    
    -- Load saved state if available
    State.Load()
    
    -- Set default values from config
    local config = getgenv().LucidState.Config
    if config and config.Features then
        for featureName, featureConfig in pairs(config.Features) do
            State.Set(featureName .. "Enabled", featureConfig.Enabled, {notify = false})
        end
    end
    
    -- Setup auto-save
    if config and config.Performance.AutoCleanup then
        task.spawn(function()
            while true do
                State.CleanCache()
                State.Save()
                task.wait(30)
            end
        end)
    end
    
    State._initialized = true
    Debug.Log("State system initialized")
    return true
end

-- Cleanup
function State.Cleanup()
    State.Save()
    
    for _, connections in pairs(State._connections) do
        for _, connection in ipairs(connections) do
            if typeof(connection) == "RBXScriptConnection" then
                connection:Disconnect()
            end
        end
    end
    
    State._connections = {}
    State._cache = {}
    Debug.Log("State system cleaned up")
end

return State
