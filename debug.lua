-- debug.lua
local Debug = {
    _VERSION = "1.0.1",
    _initialized = false
}

function Debug.log(level, msg)
    local timestamp = os.date("%Y-%m-%d %H:%M:%S")
    print(string.format("[%s] [LUCID %s] %s", timestamp, level, tostring(msg)))
    return true
end

function Debug.Info(msg) return Debug.log("INFO", msg) end
function Debug.Warn(msg) return Debug.log("WARN", msg) end
function Debug.Error(msg) return Debug.log("ERROR", msg) end
function Debug.Fatal(msg) return Debug.log("FATAL", msg) end

function Debug.init()
    if Debug._initialized then
        return true
    end
    
    Debug._initialized = true
    Debug.Info("Debug module initialized")
    return true
end

return Debug
