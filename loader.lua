-- loader.lua
local Loader = {
    _initialized = false,
    _connections = {}
}

-- Services
local Services = {
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    Players = game:GetService("Players")
}

local LocalPlayer = Services.Players.LocalPlayer

-- Load Debug module
local Debug = loadstring(game:HttpGet("https://raw.githubusercontent.com/ProbTom/Lucid/main/debug.lua"))()
if not Debug then
    warn("[CRITICAL ERROR]: Failed to load Debug module")
    return false
end

-- Load Config
local Config = loadstring(game:HttpGet("https://raw.githubusercontent.com/ProbTom/Lucid/main/config.lua"))()
if not Config then
    Debug.Error("Failed to load Config")
    return false
end

-- Load State
local State = loadstring(game:HttpGet("https://raw.githubusercontent.com/ProbTom/Lucid/main/state.lua"))()
if not State then
    Debug.Error("Failed to load State")
    return false
end

-- Initialize global state
local function initializeGlobalState()
    if not getgenv then
        Debug.Error("getgenv is not available")
        return false
    end

    if not getgenv().LucidState then
        getgenv().LucidState = {
            initialized = false,
            config = Config,
            ui = nil,
            modules = {}
        }
    end
    return true
end

-- Load UI Library
local function loadFluentUI()
    if getgenv().Fluent then
        return getgenv().Fluent
    end

    local success, result = pcall(function()
        return loadstring(game:HttpGet(Config.URLs.FluentUI))()
    end)

    if not success or not result then
        Debug.Error("Failed to load Fluent UI")
        return false
    end

    getgenv().Fluent = result
    return result
end

-- Create window
local function createWindow(config)
    if not getgenv().Fluent then
        Debug.Error("Fluent UI not loaded")
        return false
    end
    
    local window = getgenv().Fluent:CreateWindow(config.UI.Window)
    if not window then
        Debug.Error("Failed to create window")
        return false
    end

    getgenv().LucidWindow = window
    return window
end

-- Initialize loader
function Loader.Initialize()
    if Loader._initialized then
        return true
    end

    -- Initialize global state
    if not initializeGlobalState() then
        Debug.Error("Failed to initialize global state")
        return false
    end

[rest of your existing loader.lua code...]
