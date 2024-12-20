-- debug.lua
-- Version: 1.0.1
-- Author: ProbTom
-- Created: 2024-12-20 19:34:00 UTC

local Debug = {
    _VERSION = "1.0.1",
    _initialized = false,
    _debugMode = false,
    _logHistory = {}
}

-- Log levels
local LOG_LEVELS = {
    INFO = "⚪",
    WARN = "🟡",
    ERROR = "🔴",
    DEBUG = "🔵"
}

function Debug.log(level, message)
    local timestamp = os.date("%H:%M:%S")
    local icon = LOG_LEVELS[level] or "⚪"
    print(string.format("%s [%s] %s: %s", icon, timestamp, level, message))
end

function Debug.Info(message) Debug.log("INFO", message) end
function Debug.Warn(message) Debug.log("WARN", message) end
function Debug.Error(message) Debug.log("ERROR", message) end
function Debug.Debug(message) 
    if Debug._debugMode then
        Debug.log("DEBUG", message)
    end
end

function Debug.setDebugMode(enabled)
    Debug._debugMode = enabled
    Debug.Info("Debug mode " .. (enabled and "enabled" or "disabled"))
end

function Debug.init()
    if Debug._initialized then
        return true
    end
    
    Debug._initialized = true
    Debug.Info("Debug module initialized")
    return true
end

return Debug
