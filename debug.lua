-- debug.lua
local Debug = {
    _VERSION = "1.1.0",
    _initialized = false,
    LastUpdated = "2024-12-21"
}

-- Dependencies
local WindUI

-- Constants
local LOG_LEVELS = {
    INFO = "INFO",
    WARN = "WARN",
    ERROR = "ERROR",
    DEBUG = "DEBUG"
}

local LOG_COLORS = {
    INFO = Color3.fromRGB(114, 255, 114),
    WARN = Color3.fromRGB(255, 255, 114),
    ERROR = Color3.fromRGB(255, 114, 114),
    DEBUG = Color3.fromRGB(114, 114, 255)
}

function Debug.init(deps)
    if Debug._initialized then return end
    
    WindUI = deps.windui
    Debug._initialized = true
    return true
end

local function formatMessage(level, message)
    local timestamp = os.date("%H:%M:%S")
    return string.format("[LUCID %s] [%s] %s", level, timestamp, tostring(message))
end

function Debug.Log(level, message, notify)
    local formatted = formatMessage(level, message)
    
    if level == LOG_LEVELS.ERROR then
        error(formatted)
    elseif level == LOG_LEVELS.WARN then
        warn(formatted)
    else
        print(formatted)
    end
    
    if notify and WindUI then
        WindUI:Notify({
            Title = level,
            Content = tostring(message),
            Duration = level == LOG_LEVELS.ERROR and 10 or 5
        })
    end
end

function Debug.Info(message, notify)
    Debug.Log(LOG_LEVELS.INFO, message, notify)
end

function Debug.Warn(message, notify)
    Debug.Log(LOG_LEVELS.WARN, message, notify)
end

function Debug.Error(message, notify)
    Debug.Log(LOG_LEVELS.ERROR, message, notify)
end

function Debug.Debug(message)
    if game:GetService("RunService"):IsStudio() then
        Debug.Log(LOG_LEVELS.DEBUG, message, false)
    end
end

return Debug
