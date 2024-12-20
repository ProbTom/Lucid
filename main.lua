-- main.lua
-- Version: 1.0.1
-- Author: ProbTom
-- Created: 2024-12-20 19:28:59 UTC

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Constants
local VERSION = "1.0.1"
local BASE_URL = "https://raw.githubusercontent.com/ProbTom/Lucid/main/"

-- Create Lucid folder in ReplicatedStorage
local lucidFolder = ReplicatedStorage:FindFirstChild("Lucid") or Instance.new("Folder")
lucidFolder.Name = "Lucid"
lucidFolder.Parent = ReplicatedStorage

-- Module loading system
local modules = {}

local function loadModuleFromURL(name)
    local success, content = pcall(function()
        return game:HttpGet(BASE_URL .. name .. ".lua")
    end)
    
    if not success then
        warn("Failed to fetch module:", name, content)
        return nil
    end
    
    -- Create or get existing ModuleScript
    local moduleScript = lucidFolder:FindFirstChild(name)
    if not moduleScript then
        moduleScript = Instance.new("ModuleScript")
        moduleScript.Name = name
        moduleScript.Parent = lucidFolder
    end
    moduleScript.Source = content
    
    -- Load the module
    local success, result = pcall(require, moduleScript)
    if not success then
        warn("Failed to load module:", name, result)
        return nil
    end
    
    modules[name] = result
    return result
end

-- Load modules in correct order
local function loadModules()
    -- Load debug first since other modules depend on it
    local Debug = loadModuleFromURL("debug")
    if not Debug then return false end
    Debug.init()
    
    -- Load utils next since UI depends on it
    local Utils = loadModuleFromURL("utils")
    if not Utils then return false end
    Utils.init({ debug = Debug })
    
    -- Load UI last
    local UI = loadModuleFromURL("ui")
    if not UI then return false end
    UI.init({ debug = Debug, utils = Utils })
    
    return true
end

-- Initialize the system
local function init()
    if not loadModules() then
        warn("Failed to initialize Lucid")
        return false
    end
    
    local Debug = modules.debug
    local UI = modules.ui
    
    -- Create main window
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
    
    -- Create tabs
    local mainTab = UI.CreateTab(window, {
        Title = "Main",
        Icon = "rbxassetid://3926305904"
    })
    
    local settingsTab = UI.CreateTab(window, {
        Title = "Settings",
        Icon = "rbxassetid://3926307971"
    })
    
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
    
    -- Add debug toggle
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
    
    Debug.Info("Lucid initialized successfully")
    return true
end

-- Start initialization when player is ready
if Players.LocalPlayer then
    init()
else
    Players.PlayerAdded:Connect(init)
end

-- Return public API
return {
    Version = VERSION,
    Modules = modules
}
