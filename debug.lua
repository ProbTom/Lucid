-- debug.lua
-- Version: 1.0.1
-- Author: ProbTom
-- Created: 2024-12-20 19:46:51 UTC

local Debug = {
    _VERSION = "1.0.1",
    _initialized = false,
    _logHistory = {},
    _maxHistory = 1000
}

-- Log levels with emojis
local LOG_LEVELS = {
    INFO = {color = "⚪"},
    DEBUG = {color = "🔵"},
    WARN = {color = "🟡"},
    ERROR = {color = "🔴"},
    FATAL = {color = "⛔"}
}

-- Basic logging function
function Debug.log(level, msg)
    local timestamp = os.date("!%Y-%m-%d %H:%M:%S")
    local logLevel = LOG_LEVELS[level] or LOG_LEVELS.INFO
    
    -- Create log entry
    local logEntry = {
        timestamp = timestamp,
        level = level,
        message = tostring(msg)
    }
    
    -- Store in history
    table.insert(Debug._logHistory, logEntry)
    if #Debug._logHistory > Debug._maxHistory then
        table.remove(Debug._logHistory, 1)
    end
    
    -- Print with color
    print(string.format("%s %s [LUCID %s] %s", 
        logLevel.color,
        timestamp,
        level,
        tostring(msg)
    ))
    
    return true
end

-- Convenience methods
function Debug.Info(msg) return Debug.log("INFO", msg) end
function Debug.Warn(msg) return Debug.log("WARN", msg) end
function Debug.Error(msg) return Debug.log("ERROR", msg) end
function Debug.Fatal(msg) return Debug.log("FATAL", msg) end

-- Get log history
function Debug.GetLogs(level)
    if not level then
        return Debug._logHistory
    end
    
    return table.filter(Debug._logHistory, function(entry)
        return entry.level == level
    end)
end

-- Clear logs
function Debug.ClearLogs()
    Debug._logHistory = {}
    Debug.Info("Log history cleared")
    return true
end

-- Initialize module
function Debug.init()
    if Debug._initialized then
        return true
    end
    
    Debug._initialized = true
    Debug.Info("Debug module initialized")
    return true
end

return Debug
