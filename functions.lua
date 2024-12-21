-- modules/functions.lua
local Functions = {
    _VERSION = "1.1.0",
    LastUpdated = "2024-12-21",
    _initialized = false
}

function Functions.init(deps)
    if Functions._initialized then return end
    
    assert(deps.ui, "UI dependency missing")
    assert(deps.window, "Window dependency missing")
    assert(deps.debug, "Debug dependency missing")
    assert(deps.utils, "Utils dependency missing")
    
    Functions._initialized = true
    return true
end

-- Fishing Functions
function Functions.ToggleAutoFish(state)
    if not getgenv().Settings then return end
    getgenv().Settings.AutoFish = state
end

function Functions.ToggleAutoReel(state)
    if not getgenv().Settings then return end
    getgenv().Settings.AutoReel = state
end

function Functions.ToggleAutoShake(state)
    if not getgenv().Settings then return end
    getgenv().Settings.AutoShake = state
end

function Functions.SetCastMode(mode)
    if not getgenv().Settings then return end
    getgenv().Settings.CastMode = mode
end

-- Item Functions
function Functions.ToggleChestCollector(state)
    if not getgenv().Settings or not getgenv().Settings.Items then return end
    getgenv().Settings.Items.ChestCollector.Enabled = state
end

function Functions.SetChestRange(range)
    if not getgenv().Settings or not getgenv().Settings.Items then return end
    getgenv().Settings.Items.ChestCollector.Range = range
end

return Functions
