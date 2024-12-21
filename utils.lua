-- utils.lua
local Utils = {
    _VERSION = "1.1.0",
    _initialized = false,
    LastUpdated = "2024-12-21"
}

local WindUI, MainWindow, Debug

function Utils.init(deps)
    if Utils._initialized then return end
    
    WindUI = deps.windui or error("WindUI dependency missing")
    MainWindow = deps.window or error("MainWindow dependency missing")
    Debug = deps.debug or error("Debug dependency missing")
    
    Utils._initialized = true
    return true
end

function Utils.SaveSettings(settings)
    if not isfolder("LucidHub") then
        makefolder("LucidHub")
    end
    
    local success, err = pcall(function()
        writefile("LucidHub/settings.json", game:GetService("HttpService"):JSONEncode(settings))
    end)
    
    if not success then
        Debug.Warn("Failed to save settings: " .. tostring(err))
        return false
    end
    return true
end

function Utils.LoadSettings()
    if not isfile("LucidHub/settings.json") then
        return nil
    end
    
    local success, settings = pcall(function()
        return game:GetService("HttpService"):JSONDecode(readfile("LucidHub/settings.json"))
    end)
    
    if not success then
        Debug.Warn("Failed to load settings: " .. tostring(settings))
        return nil
    end
    return settings
end

function Utils.DeepCopy(original)
    local copy = {}
    for k, v in pairs(original) do
        if type(v) == "table" then
            copy[k] = Utils.DeepCopy(v)
        else
            copy[k] = v
        end
    end
    return copy
end

return Utils
