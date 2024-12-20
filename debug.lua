-- debug.lua
-- Version: 1.0.1
-- Author: ProbTom
-- Created: 2024-12-20 14:40:51 UTC

local Debug = {}

-- Configuration
local config = {
    LogPrefix = "[LUCID]",
    LogEnabled = true,
    LogLevel = 1, -- 1: Info, 2: Warning, 3: Error, 4: Debug
    LogToFile = false,
    LogPath = "lucid_logs.txt",
    MaxLogHistory = 1000
}

-- Log history
local logHistory = {}

-- Timestamp function
local function getTimestamp()
    return os.date("!%Y-%m-%d %H:%M:%S UTC")
end

-- Base logging function
function Debug.Log(message, level)
    if not config.LogEnabled then return end
    level = level or 1
    
    if level >= config.LogLevel then
        local timestamp = getTimestamp()
        local logMessage = string.format("%s %s [%s] %s",
            config.LogPrefix,
            timestamp,
            level == 1 and "INFO" or level == 2 and "WARN" or level == 3 and "ERROR" or "DEBUG",
            tostring(message)
        )
        
        -- Print to console
        if level == 1 then
            print(logMessage)
        elseif level == 2 then
            warn(logMessage)
        elseif level == 3 then
            error(logMessage)
        else
            print(logMessage)
        end
        
        -- Store in history
        table.insert(logHistory, {
            timestamp = timestamp,
            level = level,
            message = message
        })
        
        -- Trim history if needed
        if #logHistory > config.MaxLogHistory then
            table.remove(logHistory, 1)
        end
        
        -- Log to file if enabled
        if config.LogToFile then
            Debug.LogToFile(logMessage)
        end
    end
end

-- Convenience logging methods
function Debug.Info(message)
    Debug.Log(message, 1)
end

function Debug.Warn(message)
    Debug.Log(message, 2)
end

function Debug.Error(message)
    Debug.Log(message, 3)
end

function Debug.Debug(message)
    Debug.Log(message, 4)
end

-- Get log history
function Debug.GetHistory()
    return logHistory
end

-- Clear log history
function Debug.ClearHistory()
    logHistory = {}
    Debug.Info("Log history cleared")
end

-- Configure debug settings
function Debug.Configure(options)
    for key, value in pairs(options) do
        if config[key] ~= nil then
            config[key] = value
        end
    end
    Debug.Info("Debug configuration updated")
end

-- Performance monitoring
local performanceStats = {}

function Debug.StartPerfMeasure(label)
    performanceStats[label] = {
        startTime = os.clock(),
        calls = (performanceStats[label] and performanceStats[label].calls or 0) + 1
    }
end

function Debug.EndPerfMeasure(label)
    if performanceStats[label] then
        local duration = os.clock() - performanceStats[label].startTime
        performanceStats[label].lastDuration = duration
        performanceStats[label].totalDuration = (performanceStats[label].totalDuration or 0) + duration
        Debug.Debug(string.format("Performance [%s]: %.3fms (Total: %.3fms, Calls: %d)", 
            label,
            duration * 1000,
            performanceStats[label].totalDuration * 1000,
            performanceStats[label].calls
        ))
    end
end

-- Initialize module
function Debug.init()
    Debug.Info("Debug module initialized")
    return true
end

return Debug
