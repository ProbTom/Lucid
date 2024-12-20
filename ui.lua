-- ui.lua
-- Version: 2024.12.20
-- Author: ProbTom

local UI = {
    _version = "1.0.1",
    _initialized = false,
    _tabs = {},
    _connections = {}
}

-- Debug Module (local version)
local Debug = {
    Log = function(msg) print("[Lucid UI] " .. tostring(msg)) end,
    Error = function(msg) warn("[Lucid UI Error] " .. tostring(msg)) end
}

-- Protected function call wrapper
local function protectedCall(func, ...)
    if type(func) ~= "function" then
        Debug.Error("Attempted to call a nil value or non-function")
        return false
    end
    
    local success, result = pcall(func, ...)
    if not success then
        Debug.Error(result)
        return false
    end
    return true, result
end

-- Check if UI system is ready
function UI.IsReady()
    return getgenv and getgenv().LucidWindow and getgenv().Fluent
end

-- Create a new section
function UI.CreateSection(tab, name)
    if not UI.IsReady() or not tab then
        Debug.Error("Cannot create section - UI not ready or tab not provided")
        return nil
    end

    local success, section = protectedCall(function()
        return tab:AddSection(name)
    end)

    if not success then
        Debug.Error("Failed to create section: " .. tostring(name))
        return nil
    end

    return section
end

-- Add a toggle to a section
function UI.AddToggle(section, name, default, callback)
    if not section then
        Debug.Error("Cannot add toggle - section not provided")
        return nil
    end

    local success, toggle = protectedCall(function()
        return section:AddToggle({
            Title = name,
            Default = default or false,
            Callback = function(value)
                if type(callback) == "function" then
                    protectedCall(callback, value)
                end
            end
        })
    end)

    if not success then
        Debug.Error("Failed to create toggle: " .. tostring(name))
        return nil
    end

    return toggle
end

-- Add a button to a section
function UI.AddButton(section, name, callback)
    if not section then
        Debug.Error("Cannot add button - section not provided")
        return nil
    end

    local success, button = protectedCall(function()
        return section:AddButton({
            Title = name,
            Callback = function()
                if type(callback) == "function" then
                    protectedCall(callback)
                end
            end
        })
    end)

    if not success then
        Debug.Error("Failed to create button: " .. tostring(name))
        return nil
    end

    return button
end

-- Initialize UI system
function UI.Initialize()
    if UI._initialized then
        return true
    end

    if not UI.IsReady() then
        Debug.Error("UI system not ready for initialization")
        return false
    end

    UI._initialized = true
    Debug.Log("UI system initialized successfully")
    return true
end

-- Cleanup function
function UI.Cleanup()
    for _, connection in pairs(UI._connections) do
        if typeof(connection) == "RBXScriptConnection" then
            connection:Disconnect()
        end
    end
    UI._connections = {}
    Debug.Log("UI cleanup completed")
end

-- Setup cleanup on teleport
game:GetService("Players").LocalPlayer.OnTeleport:Connect(function()
    UI.Cleanup()
end)

return UI
