-- debug.lua
-- Version: 2024.12.20
-- Author: ProbTom

local Debug = {
    _enabled = true,
    _version = "1.0.1"
}

function Debug.Log(msg)
    if Debug._enabled and type(msg) == "string" then
        print("[LUCID INFO]", msg)
    end
end

function Debug.Error(msg)
    if Debug._enabled and type(msg) == "string" then
        warn("[LUCID ERROR]", msg)
    end
end

function Debug.Warn(msg)
    if Debug._enabled and type(msg) == "string" then
        warn("[LUCID WARN]", msg)
    end
end

function Debug.SetEnabled(enabled)
    Debug._enabled = enabled and true or false
end

Debug.Log("Debug module initialized")

return Debug
