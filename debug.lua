-- debug.lua
local Debug = {}

function Debug.Log(message)
    print("[LOG]:", message)
end

function Debug.Error(message)
    warn("[ERROR]:", message)
end

function Debug.Warning(message)
    warn("[WARNING]:", message)
end

return Debug
