-- debug.lua
local Debug = {
    _VERSION = "1.1.0",
    _initialized = false,
    LastUpdated = "2024-12-21"
}

local WindUI, MainWindow

function Debug.init(deps)
    if Debug._initialized then return end
    
    WindUI = deps.windui or error("WindUI dependency missing")
    MainWindow = deps.window or error("MainWindow dependency missing")
    
    Debug._initialized = true
    return true
end

function Debug.Info(message, notify)
    print("[Lucid Info]", message)
    if notify and WindUI then
        WindUI:Notify({
            Title = "Lucid Info",
            Content = message,
            Duration = 5
        })
    end
end

function Debug.Warn(message, notify)
    warn("[Lucid Warning]", message)
    if notify and WindUI then
        WindUI:Notify({
            Title = "Lucid Warning",
            Content = message,
            Duration = 5
        })
    end
end

function Debug.Error(message, notify)
    error("[Lucid Error] " .. message)
    if notify and WindUI then
        WindUI:Notify({
            Title = "Lucid Error",
            Content = message,
            Duration = 10
        })
    end
end

return Debug
