-- debug.lua
local Debug = {
    _initialized = false,
    _VERSION = "1.0.1"
}

function Debug.log(level, msg)
    print(string.format("[LUCID %s] %s", level, tostring(msg)))
    return true
end

function Debug.Info(msg) return Debug.log("INFO", msg) end
function Debug.Error(msg) return Debug.log("ERROR", msg) end
function Debug.Debug(msg) return Debug.log("DEBUG", msg) end
function Debug.Warn(msg) return Debug.log("WARN", msg) end
function Debug.Fatal(msg) return Debug.log("FATAL", msg) end

function Debug.init(modules)
    if Debug._initialized then return true end
    Debug._initialized = true
    Debug.log("INFO", "Debug module initialized")
    return true
end

return Debug
