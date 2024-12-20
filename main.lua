-- main.lua
-- Version: 1.0.1
-- Author: ProbTom
-- Created: 2024-12-20 18:55:19 UTC

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

-- Constants
local VERSION = "1.0.1"

-- Modules - Using direct requires without path indexing
local Debug = require(script:WaitForChild("debug"))  -- Changed from script.Parent.modules.debug
local Utils = require(script:WaitForChild("utils"))  -- Changed from script.Parent.modules.utils
local UI = require(script:WaitForChild("ui"))        -- Changed from script.Parent.modules.ui

-- State
local initialized = false

-- Local Functions
local function initializeModules()
    if not Debug or not Utils or not UI then
        warn("Failed to load one or more modules")
        return false
    end

    Debug.Info("Starting module initialization")
    
    -- Initialize Debug first
    Debug.Info("Loading debug")
    if not Debug.init() then
        return false
    end
    
    -- Set system version
    Debug.Info("System Version: " .. VERSION)
    
    -- Initialize Utils
    Debug.Info("Loading utils")
    if not Utils.init({ debug = Debug }) then
        Debug.Error("Failed to initialize utils")
        return false
    end
    
    -- Initialize UI
    Debug.Info("Loading ui")
    if not UI.init({ debug = Debug, utils = Utils }) then
        Debug.Error("Failed to initialize ui")
        return false
    end

    -- Create the main window
    local window = UI.CreateWindow({
        Title = "Lucid",
        SubTitle = "v" .. VERSION,
        TabWidth = 160,
        Size = UDim2.new(0, 600, 0, 400),
        Position = UDim2.new(0.5, -300, 0.5, -200)
    })

    if not window then
        Debug.Error("Failed to create main window")
        return false
    end

    -- Create main tab
    local mainTab = UI.CreateTab(window, {
        Title = "Main",
        Icon = "rbxassetid://3926305904"
    })

    if not mainTab then
        Debug.Error("Failed to create main tab")
        return false
    end

    -- Add test button
    UI.CreateButton(mainTab, {
        Title = "Test Button",
        Description = "Click me to test the UI!",
        Callback = function()
            UI.Notify({
                Title = "Success",
                Content = "UI is working correctly!",
                Duration = 3,
                Type = "Success"
            })
        end
    })

    -- Add settings tab
    local settingsTab = UI.CreateTab(window, {
        Title = "Settings",
        Icon = "rbxassetid://3926307971"
    })

    -- Add some settings controls
    UI.CreateToggle(settingsTab, {
        Title = "Debug Mode",
        Description = "Enable debug logging",
        Default = false,
        Callback = function(value)
            Debug.setDebugMode(value)
            UI.Notify({
                Title = "Settings",
                Content = "Debug Mode: " .. (value and "Enabled" or "Disabled"),
                Duration = 2,
                Type = "Info"
            })
        end
    })

    Debug.Info("All modules loaded successfully")
    return true
end

-- Main Functions
local function start()
    if initialized then
        Debug.Warn("System already initialized")
        return
    end
    
    if not initializeModules() then
        Debug.Error("Failed to initialize modules")
        return
    end
    
    initialized = true
    Debug.Info("System initialization complete")
end

local function stop()
    if not initialized then
        return
    end
    
    -- Cleanup UI
    UI.CloseAll()
    
    initialized = false
    Debug.Info("System stopped")
end

-- Event Handlers
local function onPlayerAdded(player)
    if player == Players.LocalPlayer then
        start()
    end
end

local function onPlayerRemoving(player)
    if player == Players.LocalPlayer then
        stop()
    end
end

-- Initialize
do
    -- Set up player events
    Players.PlayerAdded:Connect(onPlayerAdded)
    Players.PlayerRemoving:Connect(onPlayerRemoving)
    
    -- Start if player is already in game
    if Players.LocalPlayer then
        start()
    end
end

-- Return API
return {
    Version = VERSION,
    Debug = Debug,
    Utils = Utils,
    UI = UI,
    
    -- Methods
    Start = start,
    Stop = stop,
    
    -- Properties
    Initialized = function()
        return initialized
    end
}
