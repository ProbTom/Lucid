-- loader.lua
local Loader = {}
local Debug = loadstring(game:HttpGet("https://raw.githubusercontent.com/ProbTom/Lucid/main/debug.lua"))()

-- Initialize global state
if not getgenv().State then
    getgenv().State = {
        AutoCasting = false,
        AutoReeling = false,
        AutoShaking = false,
        Events = {
            Available = {}
        }
    }
end

-- Ensure Fluent library is loaded only once
if not getgenv().Fluent then
    local success, Fluent = pcall(function()
        return loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
    end)

    if success and Fluent then
        getgenv().Fluent = Fluent
        Debug.Log("Fluent library loaded successfully.")
    else
        Debug.Error("Failed to load Fluent library")
        return
    end
end

-- Load Core Modules
local success, UI = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/ProbTom/Lucid/main/ui.lua"))()
end)

if not success then
    Debug.Error("Failed to load UI module")
    return
end

local success, Functions = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/ProbTom/Lucid/main/functions.lua"))()
end)

if not success then
    Debug.Error("Failed to load Functions module")
    return
end

-- Initialize modules
if type(UI.Initialize) == "function" then
    Debug.Log("Initializing UI module.")
    UI.Initialize()
end

if type(Functions.Initialize) == "function" then
    Debug.Log("Initializing Functions module.")
    Functions.Initialize()
end

-- Setup cleanup on teleport
game:GetService("Players").LocalPlayer.OnTeleport:Connect(function()
    if type(UI.Cleanup) == "function" then
        Debug.Log("Cleaning up UI module on teleport.")
        UI.Cleanup()
    end
    if type(Functions.Cleanup) == "function" then
        Debug.Log("Cleaning up Functions module on teleport.")
        Functions.Cleanup()
    end
end)

return Loader
