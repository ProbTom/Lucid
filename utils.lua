-- utils.lua
-- Version: 1.0.1
-- Author: ProbTom
-- Created: 2024-12-20 19:34:00 UTC

local Utils = {
    _VERSION = "1.0.1",
    _initialized = false
}

-- Dependencies
local Debug

function Utils.ProtectGui(gui)
    if syn and syn.protect_gui then
        syn.protect_gui(gui)
    elseif gethui then
        gui.Parent = gethui()
    else
        gui.Parent = game:GetService("CoreGui")
    end
end

function Utils.SafeCall(callback, ...)
    local success, result = pcall(callback, ...)
    if not success then
        Debug.Error("Function call failed: " .. tostring(result))
    end
    return success, result
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

function Utils.init(modules)
    if Utils._initialized then
        return true
    end
    
    Debug = modules.debug
    
    Utils._initialized = true
    Debug.Info("Utils module initialized")
    return true
end

return Utils
