-- loader.lua
local Loader = {}

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
    else
        warn("Failed to load Fluent library")
        return
    end
end

-- Load Core Modules
local success, UI = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/ProbTom/Lucid/main/ui.lua"))()
end)

if not success then
    warn("Failed to load UI module")
    return
end

local success, Functions = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/ProbTom/Lucid/main/functions.lua"))()
end)

if not success then
    warn("Failed to load Functions module")
    return
end

-- Initialize modules
if type(UI.Initialize) == "function" then
    UI.Initialize()
end

if type(Functions.Initialize) == "function" then
    Functions.Initialize()
end

-- Setup cleanup on teleport
game:GetService("Players").LocalPlayer.OnTeleport:Connect(function()
    if type(UI.Cleanup) == "function" then
        UI.Cleanup()
    end
    if type(Functions.Cleanup) == "function" then
        Functions.Cleanup()
    end
end)

return Loader
