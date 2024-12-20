-- debug.lua
-- Version: 1.0.1
-- Author: ProbTom

local Debug = {
    _VERSION = "1.0.1",
    _AUTHOR = "ProbTom",
    _initialized = false
}

-- Log levels
Debug.LEVELS = {
    INFO = 1,
    DEBUG = 2,
    WARN = 3,
    ERROR = 4,
    FATAL = 5
}

-- Configuration
local config = {
    enabled = true,
    logLevel = Debug.LEVELS.INFO,
    maxHistory = 1000,
    outputToConsole = true,
    timestamp = true
}

-- Log history
local logHistory = {}

-- Format timestamp using Roblox's time
local function formatTimestamp()
    local t = os.date("*t")
    return string.format("[%02d:%02d:%02d]", t.hour, t.min, t.sec)
end

-- Format message
local function formatMessage(level, msg)
    local timestamp = config.timestamp and formatTimestamp() or ""
    return string.format("%s [LUCID %s] %s", timestamp, level, tostring(msg))
end

-- Base log function
local function log(level, levelName, msg)
    if not config.enabled or level < config.logLevel then
        return
    end

    local formattedMsg = formatMessage(levelName, msg)
    
    -- Add to history
    table.insert(logHistory, {
        timestamp = os.time(),
        level = level,
        message = formattedMsg
    })
    
    -- Trim history if needed
    while #logHistory > config.maxHistory do
        table.remove(logHistory, 1)
    end
    
    -- Output to console if enabled
    if config.outputToConsole then
        if level >= Debug.LEVELS.ERROR then
            warn(formattedMsg)
        else
            print(formattedMsg)
        end
    end
    
    return true
end

-- Public logging functions
function Debug.Info(msg)
    return log(Debug.LEVELS.INFO, "INFO", msg)
end

function Debug.Debug(msg)
    return log(Debug.LEVELS.DEBUG, "DEBUG", msg)
end

function Debug.Warn(msg)
    return log(Debug.LEVELS.WARN, "WARN", msg)
end

function Debug.Error(msg)
    return log(Debug.LEVELS.ERROR, "ERROR", msg)
end

function Debug.Fatal(msg)
    return log(Debug.LEVELS.FATAL, "FATAL", msg)
end

-- Configuration functions
function Debug.SetEnabled(enabled)
    config.enabled = enabled
    Debug.Info(string.format("Debugging %s", enabled and "enabled" or "disabled"))
end

function Debug.SetLogLevel(level)
    if Debug.LEVELS[level] then
        config.logLevel = Debug.LEVELS[level]
        Debug.Info(string.format("Log level set to %s", level))
    end
end

function Debug.GetHistory()
    return table.clone(logHistory)
end

function Debug.ClearHistory()
    logHistory = {}
    Debug.Info("Log history cleared")
end

-- Module initialization
function Debug.init()
    if Debug._initialized then
        return true
    end
    
    -- Basic initialization check
    local success, err = pcall(function()
        Debug.Info("Initializing debug module...")
    end)
    
    if not success then
        warn("[LUCID DEBUG] Failed to initialize:", err)
        return false
    end
    
    Debug._initialized = true
    return true
end

return Debug
