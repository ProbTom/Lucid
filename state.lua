-- state.lua
-- Version: 2024.12.20
-- Author: ProbTom

local State = {
    _version = "1.0.1",
    _data = {},
    _connections = {}
}

-- Debug Module (will be replaced by global Debug)
local Debug = {
    Log = function(msg) print("[LUCID STATE]", msg) end,
    Error = function(msg) warn("[LUCID STATE ERROR]", msg) end
}

-- Set a state value
function State.Set(key, value)
    if type(key) ~= "string" then
        Debug.Error("State key must be a string")
        return false
    end
    
    State._data[key] = value
    
    -- Update global state if it exists
    if getgenv and getgenv().LucidState then
        getgenv().LucidState[key] = value
    end
    
    return true
end

-- Get a state value
function State.Get(key)
    if type(key) ~= "string" then
        Debug.Error("State key must be a string")
        return nil
    end
    
    return State._data[key]
end

-- Initialize default state
function State.Initialize()
    State._data = {
        AutoCasting = false,
        AutoReeling = false,
        AutoShaking = false,
        _initialized = false
    }
    
    -- Update global state
    if getgenv and getgenv().LucidState then
        for key, value in pairs(State._data) do
            getgenv().LucidState[key] = value
        end
    end
    
    State._data._initialized = true
    return true
end

-- Cleanup function
function State.Cleanup()
    State._data = {}
    
    for _, connection in pairs(State._connections) do
        if typeof(connection) == "RBXScriptConnection" then
            connection:Disconnect()
        end
    end
    
    State._connections = {}
end

-- Initialize state
State.Initialize()

return State
