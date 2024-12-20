-- debug.lua
local Debug = {}

-- Ensure methods exist before use
Debug.Log = function(msg)
    if type(msg) == "string" then
        print("[LUCID LOG]:", msg)
    end
end

Debug.Error = function(msg)
    if type(msg) == "string" then
        warn("[LUCID ERROR]:", msg)
    end
end

Debug.Warn = function(msg)
    if type(msg) == "string" then
        warn("[LUCID WARN]:", msg)
    end
end

return Debug
