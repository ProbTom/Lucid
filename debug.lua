-- debug.lua
local Debug = {
    _initialized = false,
    Enabled = true,
    _lastMessage = "",
    _messageCount = 0
}

-- Log levels
Debug.Level = {
    INFO = "INFO",
    WARN = "WARN",
    ERROR = "ERROR",
    DEBUG = "DEBUG"
}

-- Core logging function with protection against nil values
local function safeLog(level, message)
    if not Debug.Enabled then return end
    
    -- Convert any type to string safely
    local function toString(value)
        if value == nil then return "nil" end
        local success, result = pcall(tostring, value)
        return success and result or "<<invalid>>"
    end
    
    message = toString(message)
    
    -- Prevent spam of the same message
    if message == Debug._lastMessage then
        Debug._messageCount = Debug._messageCount + 1
        if Debug._messageCount > 1 then
            return -- Skip duplicate messages
        end
    else
        Debug._lastMessage = message
        Debug._messageCount = 1
    end
    
    -- Format the message
    local formattedMessage = string.format("[LUCID %s] %s", level, message)
    
    -- Output based on level
    if level == Debug.Level.ERROR then
        warn(formattedMessage)
    elseif level == Debug.Level.WARN then
        warn(formattedMessage)
    else
        print(formattedMessage)
    end
end

-- Public logging functions
function Debug.Log(message)
    safeLog(Debug.Level.INFO, message)
end

function Debug.Warn(message)
    safeLog(Debug.Level.WARN, message)
end

function Debug.Error(message)
    safeLog(Debug.Level.ERROR, message)
end

function Debug.Debug(message)
    safeLog(Debug.Level.DEBUG, message)
end

-- Initialize debug module with config integration
function Debug.Initialize()
    if Debug._initialized then return end
    
    -- Try to get debug setting from config
    if getgenv and getgenv().Config then
        Debug.Enabled = getgenv().Config.Debug or Debug.Enabled
    end
    
    Debug._initialized = true
    Debug.Log("Debug module initialized")
    return true
end

-- Cleanup function
function Debug.Cleanup()
    Debug._initialized = false
    Debug._lastMessage = ""
    Debug._messageCount = 0
end

-- Run initialization
Debug.Initialize()

-- Setup cleanup on teleport
if game then
    game:GetService("Players").LocalPlayer.OnTeleport:Connect(function()
        Debug.Cleanup()
    end)
end

return Debug
