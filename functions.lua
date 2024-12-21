-- functions.lua
local Functions = {
    _VERSION = "1.1.0",
    _initialized = false,
    LastUpdated = "2024-12-21"
}

local WindUI, MainWindow, Debug, Utils

function Functions.init(deps)
    if Functions._initialized then return end
    
    WindUI = deps.windui or error("WindUI dependency missing")
    MainWindow = deps.window or error("MainWindow dependency missing")
    Debug = deps.debug or error("Debug dependency missing")
    Utils = deps.utils or error("Utils dependency missing")
    
    Functions._initialized = true
    return true
end

-- Fishing Functions
function Functions.ToggleAutoFish(enabled)
    getgenv().Settings.AutoFish = enabled
    if enabled then
        Debug.Info("Auto Fish enabled", true)
    else
        Debug.Info("Auto Fish disabled", true)
    end
end

function Functions.ToggleAutoReel(enabled)
    getgenv().Settings.AutoReel = enabled
    if enabled then
        Debug.Info("Auto Reel enabled", true)
    else
        Debug.Info("Auto Reel disabled", true)
    end
end

function Functions.ToggleAutoShake(enabled)
    getgenv().Settings.AutoShake = enabled
    if enabled then
        Debug.Info("Auto Shake enabled", true)
    else
        Debug.Info("Auto Shake disabled", true)
    end
end

-- Item Functions
function Functions.ToggleChestCollector(enabled)
    getgenv().Settings.Items.ChestCollector.Enabled = enabled
    if enabled then
        Debug.Info("Chest Collector enabled", true)
    else
        Debug.Info("Chest Collector disabled", true)
    end
end

function Functions.ToggleAutoSell(enabled)
    getgenv().Settings.Items.AutoSell.Enabled = enabled
    if enabled then
        Debug.Info("Auto Sell enabled", true)
    else
        Debug.Info("Auto Sell disabled", true)
    end
end

return Functions
