-- debug.lua
-- Version: 1.0.1
-- Author: ProbTom
-- Created: 2024-12-20 16:30:00 UTC

local Debug = {
    _VERSION = "1.0.1",
    _initialized = false,
    _logHistory = {},
    _maxHistory = 1000,
    _startTime = os.time()
}

-- Log levels and their colors (for formatting)
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
    
    -- Add to history
    table.insert(Debug._logHistory, logEntry)
    if #Debug._logHistory > Debug._maxHistory then
        table.remove(Debug._logHistory, 1)
    end
    
    -- Format console output
    local color = logLevel.color
    local output = string.format("%s %s [LUCID %s] %s", color, timestamp, level, tostring(msg))
    print(output)
    
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

-- System monitoring functions
function Debug.GetLoadedModules()
    if not getgenv().LucidState then
        return Debug.Error("LucidState not initialized")
    end
    
    local modules = {}
    for name, module in pairs(getgenv().LucidState.Modules) do
        modules[name] = {
            loaded = module ~= nil,
            version = type(module) == "table" and module._VERSION or "unknown",
            initialized = type(module) == "table" and module._initialized or false
        }
    end
    return modules
end

function Debug.GetSystemState()
    if not getgenv().LucidState then
        return {
            loaded = false,
            error = "System not initialized"
        }
    end
    
    return {
        version = getgenv().LucidState.Version,
        startTime = getgenv().LucidState.StartTime,
        uptime = os.time() - Debug._startTime,
        loaded = getgenv().LucidState.Loaded,
        moduleCount = #Debug.GetLoadedModules(),
        lastError = Debug._logHistory[#Debug._logHistory],
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

function Debug.CheckSystemHealth()
    local state = Debug.GetSystemState()
    local modules = Debug.GetLoadedModules()
    local health = {
        status = "healthy",
        issues = {},
        recommendations = {}
    }
    
    -- Check system state
    if not state.loaded then
        health.status = "critical"
        table.insert(health.issues, "System not fully loaded")
    end
    
    -- Check module health
    for name, info in pairs(modules) do
        if not info.loaded then
            health.status = "warning"
            table.insert(health.issues, string.format("Module '%s' failed to load", name))
        elseif not info.initialized then
            table.insert(health.issues, string.format("Module '%s' not initialized", name))
        end
    end
    
    -- Memory usage check
    if state.memoryUsage > 1000 then
        table.insert(health.recommendations, "High memory usage detected. Consider cleanup.")
    end
    
    return health
end

-- Initialize debug module
function Debug.init(modules)
    if Debug._initialized then
        return true
    end
    
    Debug._initialized = true
    Debug.Info("Debug module initialized")
    Debug.Info(string.format("System Version: %s", getgenv().LucidState.Version))
    
    -- Initial health check
    local health = Debug.CheckSystemHealth()
    if health.status ~= "healthy" then
        for _, issue in ipairs(health.issues) do
            Debug.Warn(issue)
        end
    end
    
    return true
end

-- Set up error handler
local oldError = error
error = function(msg, level)
    level = level or 1
    Debug.Error(msg)
    return oldError(msg, level + 1)
end

return Debug
