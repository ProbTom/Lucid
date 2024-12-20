-- debug.lua
local Debug = {
    _initialized = false,
    _enabled = true
}

-- Core logging functions
function Debug.Log(message)
    if Debug._enabled then
        print("[LUCID LOG]:", tostring(message))
    end
end

function Debug.Error(message)
    if Debug._enabled then
        warn("[LUCID ERROR]:", tostring(message))
    end
end

function Debug.Warning(message)
    if Debug._enabled then
        warn("[LUCID WARNING]:", tostring(message))
    end
end

-- Enable/Disable debug output
function Debug.SetEnabled(enabled)
    Debug._enabled = enabled
end

-- Initialize debug module
function Debug.Initialize()
    if Debug._initialized then
        return
    end
    
    if getgenv().Config and getgenv().Config.Debug ~= nil then
        Debug._enabled = getgenv().Config.Debug
    end
    
    Debug._initialized = true
    Debug.Log("Debug module initialized")
end

-- Run initialization
Debug.Initialize()

return Debug
