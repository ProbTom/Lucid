-- debug.lua
-- Version: 1.0.1
-- Author: ProbTom
-- Created: 2024-12-20 16:34:06 UTC

local Debug = {
    _VERSION = "1.0.1",
    _initialized = false,
    _logHistory = {},
    _maxHistory = 1000,
    _startTime = os.time()
}

-- Log levels and their colors
local LOG_LEVELS = {
    INFO = {priority = 1, color = "⚪"},
    DEBUG = {priority = 2, color = "🔵"},
    WARN = {priority = 3, color = "🟡"},
    ERROR = {priority = 4, color = "🔴"},
    FATAL = {priority = 5, color = "⛔"}
}

-- Internal logging function
local function internal_log(level, msg, stack)
    local timestamp = os.date("!%Y-%m-%d %H:%M:%S")
    local logLevel = LOG_LEVELS[level] or LOG_LEVELS.INFO
    local logEntry = {
        timestamp = timestamp,
        level = level,
        message = tostring(msg),
        stack = stack,
        priority = logLevel.priority
    }
    
    table.insert(Debug._logHistory, logEntry)
    if #Debug._logHistory > Debug._maxHistory then
        table.remove(Debug._logHistory, 1)
    end
    
    local color = logLevel.color
    print(string.format("%s %s [LUCID %s] %s", color, timestamp, level, tostring(msg)))
    
    return true
end

-- Public logging functions
function Debug.log(level, msg)
    return internal_log(level, msg, debug.traceback())
end

function Debug.Info(msg) return Debug.log("INFO", msg) end
function Debug.Debug(msg) return Debug.log("DEBUG", msg) end
function Debug.Warn(msg) return Debug.log("WARN", msg) end
function Debug.Error(msg) return Debug.log("ERROR", msg) end
function Debug.Fatal(msg) return Debug.log("FATAL", msg) end

-- System monitoring
function Debug.GetSystemState()
    return {
        version = getgenv().LucidState.Version,
        startTime = getgenv().LucidState.StartTime,
        uptime = os.time() - Debug._startTime,
        moduleCount = #getgenv().LucidState.Modules,
        memoryUsage = gcinfo()
    }
end

function Debug.GetLogHistory(level)
    if not level then
        return Debug._logHistory
    end
    return table.filter(Debug._logHistory, function(entry)
        return entry.level == level
    end)
end

function Debug.ClearLogs()
    Debug._logHistory = {}
    return Debug.Info("Log history cleared")
end

-- Initialize debug module
function Debug.init()
    if Debug._initialized then
        return true
    end
    
    Debug._initialized = true
    Debug.Info("Debug module initialized")
    Debug.Info(string.format("System Version: %s", getgenv().LucidState.Version))
    
    return true
end

return Debug
