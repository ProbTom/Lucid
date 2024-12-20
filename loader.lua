-- loader.lua
-- Version: 2024.12.20
-- Author: ProbTom

local Loader = {
    _initialized = false,
    _connections = {},
    _modules = {}
}

-- Services
local Services = {
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService")
}

-- Debug Module
local Debug = loadstring(game:HttpGet("https://raw.githubusercontent.com/ProbTom/Lucid/main/debug.lua"))()
if not Debug then
    warn("[CRITICAL ERROR]: Failed to load Debug module")
    return false
end

-- Load required modules
local function loadModules()
    local modules = {
        Config = "config.lua",
        State = "state.lua",
        UI = "ui.lua",
        Events = "events.lua"
    }
    
    for name, file in pairs(modules) do
        local success, module = pcall(function()
            return loadstring(game:HttpGet("https://raw.githubusercontent.com/ProbTom/Lucid/main/" .. file))()
        end)
        
        if not success or not module then
            Debug.Error("Failed to load " .. name .. " module")
            return false
        end
        
        Loader._modules[name] = module
    end
    
    return true
end

-- Load UI Library
local function loadFluentUI()
    if getgenv().Fluent then
        return getgenv().Fluent
    end
    
    local success, Fluent = pcall(function()
        return loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
    end)
    
    if not success or not Fluent then
        Debug.Error("Failed to load Fluent UI")
        return false
    end
    
    getgenv().Fluent = Fluent
    return Fluent
end

-- Create window
local function createWindow(config)
    if not getgenv().Fluent then
        Debug.Error("Fluent UI not loaded")
        return false
    end
    
    local window = getgenv().Fluent:CreateWindow(config.UI.Window)
    getgenv().LucidWindow = window
    return window
end

-- Initialize loader
function Loader.Initialize()
    if Loader._initialized then
        return true
    end
    
    -- Load required modules
    if not loadModules() then
        Debug.Error("Failed to load required modules")
        return false
    end
    
    -- Initialize global state
    if not getgenv then
        Debug.Error("getgenv is not available")
        return false
    end
    
    if not getgenv().LucidState then
        getgenv().LucidState = {
            initialized = false,
            config = Loader._modules.Config,
            state = Loader._modules.State,
            ui = nil
        }
    end

[Rest of your existing loader.lua code...]
