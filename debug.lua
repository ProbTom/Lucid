-- debug.lua
local Debug = {
    _VERSION = "1.0.1",
    _initialized = false,
    _debugMode = false
}

function Debug.init()
    if Debug._initialized then
        return true
    end
    
    Debug._initialized = true
    print("Debug module initialized")
    return true
end

function Debug.setDebugMode(enabled)
    Debug._debugMode = enabled
end

function Debug.Info(msg)
    print("INFO:", msg)
end

function Debug.Warn(msg)
    warn("WARN:", msg)
end

function Debug.Error(msg)
    warn("ERROR:", msg)
end

return Debug
