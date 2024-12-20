-- main.lua
-- Version: 1.0.1
-- Author: ProbTom
-- Created: 2024-12-20 19:36:55 UTC

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

-- Load a module from URL and create it in ReplicatedStorage
local function loadModuleFromURL(name)
    local success, content = pcall(function()
        return game:HttpGet(BASE_URL .. name .. ".lua")
    end)
    
    if not success then
        warn("Failed to fetch module:", name, content)
        return nil
    end
    
    -- Create ModuleScript
    local moduleScript = Instance.new("ModuleScript")
    moduleScript.Name = name
    moduleScript.Source = content
    moduleScript.Parent = lucidFolder
    
    -- Load the module
    local success, result = pcall(require, moduleScript)
    if not success then
        warn("Failed to load module:", name, result)
        return nil
    end
    
    return result
end

-- Initialize all modules in correct order
local function initializeLucid()
    -- Load debug first
    local Debug = loadModuleFromURL("debug")
    if not Debug or not Debug.init() then
        warn("Failed to initialize debug module")
        return false
    end
    modules.debug = Debug
    
    -- Load utils second
    local Utils = loadModuleFromURL("utils")
    if not Utils or not Utils.init({debug = Debug}) then
        Debug.Error("Failed to initialize utils module")
        return false
    end
    modules.utils = Utils
    
    -- Load UI last
    local UI = loadModuleFromURL("ui")
    if not UI or not UI.init({debug = Debug, utils = Utils}) then
        Debug.Error("Failed to initialize UI module")
        return false
    }
    modules.ui = UI
    
    -- Create main window
    local window = UI.CreateWindow({
        Title = "Lucid",
        SubTitle = VERSION,
        Size = UDim2.new(0, 600, 0, 400),
        Position = UDim2.new(0.5, -300, 0.5, -200)
    })
    
    -- Create main tab
    local mainTab = UI.CreateTab(window, {
        Title = "Main",
        Icon = "rbxassetid://3926305904"
    })
    
    -- Add test button
    UI.CreateButton(mainTab, {
        Title = "Test Button",
        Description = "Click me!",
        Callback = function()
            UI.Notify({
                Title = "Success",
                Content = "UI is working!",
                Duration = 3
            })
        end
    })
    
    -- Create settings tab
    local settingsTab = UI.CreateTab(window, {
        Title = "Settings",
        Icon = "rbxassetid://3926307971"
    })
    
    -- Add debug toggle
    UI.CreateToggle(settingsTab, {
        Title = "Debug Mode",
        Description = "Enable debug logging",
        Default = false,
        Callback = function(value)
            Debug.setDebugMode(value)
            UI.Notify({
                Title = "Debug Mode",
                Content = value and "Enabled" or "Disabled",
                Duration = 2
            })
        end
    })
    
    Debug.Info("Lucid initialized successfully")
    return true
end

-- Start Lucid when player is ready
local function startLucid()
    if not initializeLucid() then
        warn("Failed to initialize Lucid")
        return
    end
end

-- Initialize when player joins
if Players.LocalPlayer then
    startLucid()
else
    Players.PlayerAdded:Connect(startLucid)
end

-- Return public API
return {
    Version = VERSION,
    Modules = modules
}
