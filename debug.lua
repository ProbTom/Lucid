-- debug.lua
-- Version: 1.0.1
-- Author: ProbTom
-- Created: 2024-12-20 14:53:45 UTC

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

-- Format timestamp
local function formatTimestamp()
    return os.date("[%Y-%m-%d %H:%M:%S]")
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

function Debug.SetMaxHistory(max)
    config.maxHistory = max
    Debug.Info(string.format("Max history set to %d", max))
end

-- History functions
function Debug.GetHistory()
    return table.clone(logHistory)
end

function Debug.ClearHistory()
    logHistory = {}
    Debug.Info("Log history cleared")
end

-- Debug utilities
function Debug.Trace(...)
    local args = {...}
    local trace = ""
    
    for i, v in ipairs(args) do
        if type(v) == "table" then
            trace = trace .. Debug.TableToString(v, 0)
        else
            trace = trace .. tostring(v)
        end
        
        if i < #args then
            trace = trace .. " "
        end
    end
    
    return Debug.Debug(trace)
end

function Debug.TableToString(tbl, depth)
    if depth > 10 then return "..." end
    
    local str = "{"
    for k, v in pairs(tbl) do
        local key = type(k) == "string" and k or "[" .. tostring(k) .. "]"
        str = str .. key .. "="
        
        if type(v) == "table" then
            str = str .. Debug.TableToString(v, (depth or 0) + 1)
        else
            str = str .. tostring(v)
        end
        str = str .. ", "
    end
    return str:sub(1, -3) .. "}"
end

-- Module initialization
function Debug.init()
    if Debug._initialized then
        return true
    end
    
    Debug._initialized = true
    Debug.Info("Debug module initialized")
    return true
end

-- Module shutdown
function Debug.shutdown()
    Debug.Info("Debug module shutting down")
    Debug.ClearHistory()
    Debug._initialized = false
end

return Debug
