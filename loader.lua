-- loader.lua
-- Version: 2024.12.20
-- Author: ProbTom
-- Last Updated: 2024-12-20

local Loader = {
    _initialized = false,
    _connections = {},
    _version = "1.0.1"
}

-- Services
local Services = {
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService")
}

local LocalPlayer = Services.Players.LocalPlayer
local Debug = getgenv().LucidDebug

-- Protected Call Function
local function protectedCall(func, ...)
    if type(func) ~= "function" then
        Debug.Error("Protected call failed: not a function")
        return false
    end
    
    local success, result = pcall(func, ...)
    if not success then
        Debug.Error("Protected call failed: " .. tostring(result))
        return false
    end
    
    return true, result
end

-- Load Fluent UI Library
local function loadFluentUI()
    if getgenv().LucidState.UI then
        return getgenv().LucidState.UI
    end

    local success, UI = pcall(function()
        return loadstring(game:HttpGet(getgenv().LucidState.Config.URLs.FluentUI))()
    end)

    if not success or not UI then
        Debug.Error("Failed to load Fluent UI library")
        return false
    end

    getgenv().LucidState.UI = UI
    return UI
end

-- Create window (only if none exists)
local function createWindow()
    if getgenv().LucidWindow then
        return getgenv().LucidWindow
    end

    if not getgenv().LucidState.UI then
        Debug.Error("UI library not loaded")
        return false
    end

    local window = getgenv().LucidState.UI:CreateWindow(getgenv().LucidState.Config.UI.Window)
    if not window then
        Debug.Error("Failed to create window")
        return false
    end

    getgenv().LucidWindow = window
    return window
end

-- Initialize tabs
local function initializeTabs()
    local window = getgenv().LucidWindow
    if not window then return false end

    getgenv().LucidState.Tabs = {}
    local tabs = getgenv().LucidState.Config.UI.Tabs

    for tabName, tabConfig in pairs(tabs) do
        local success, tab = protectedCall(function()
            return window:AddTab({
                Title = tabConfig.Name,
                Icon = tabConfig.Icon
            })
        end)

        if success and tab then
            getgenv().LucidState.Tabs[tabName] = tab
            Debug.Log("Created tab: " .. tabName)
        else
            Debug.Error("Failed to create tab: " .. tabName)
            return false
        end
    end

    return true
end

-- Initialize features
local function initializeFeatures()
    local mainTab = getgenv().LucidState.Tabs.Main
    if not mainTab then
        Debug.Error("Main tab not found")
        return false
    end

    local section = mainTab:AddSection("Fishing Controls")
    local features = getgenv().LucidState.Config.Features

    -- Auto Cast
    section:AddToggle({
        Title = "Auto Cast",
        Default = features.AutoCast.Enabled,
        Callback = function(value)
            getgenv().LucidState.AutoCasting = value
            Debug.Log("Auto Cast: " .. tostring(value))
        end
    })

    -- Auto Reel
    section:AddToggle({
        Title = "Auto Reel",
        Default = features.AutoReel.Enabled,
        Callback = function(value)
            getgenv().LucidState.AutoReeling = value
            Debug.Log("Auto Reel: " .. tostring(value))
        end
    })

    -- Auto Shake
    section:AddToggle({
        Title = "Auto Shake",
        Default = features.AutoShake.Enabled,
        Callback = function(value)
            getgenv().LucidState.AutoShaking = value
            Debug.Log("Auto Shake: " .. tostring(value))
        end
    })

    return true
end

-- Initialize credits
local function initializeCredits()
    local creditsTab = getgenv().LucidState.Tabs.Credits
    if not creditsTab then return false end

    local section = creditsTab:AddSection("Credits")

    section:AddParagraph({
        Title = "Developer",
        Content = "ProbTom"
    })

    section:AddParagraph({
        Title = "UI Library",
        Content = "Fluent UI Library by dawid-scripts"
    })

    section:AddParagraph({
        Title = "Version",
        Content = Loader._version
    })

    return true
end

-- Initialize loader
function Loader.Initialize()
    if Loader._initialized then
        return true
    end

    -- Load UI Library
    if not loadFluentUI() then
        Debug.Error("Failed to load UI library")
        return false
    end

    -- Create window
    if not createWindow() then
        Debug.Error("Failed to create window")
        return false
    end

    -- Initialize tabs
    if not initializeTabs() then
        Debug.Error("Failed to initialize tabs")
        return false
    end

    -- Initialize features
    if not initializeFeatures() then
        Debug.Error("Failed to initialize features")
        return false
    end

    -- Initialize credits
    if not initializeCredits() then
        Debug.Error("Failed to initialize credits")
        return false
    end

    Loader._initialized = true
    Debug.Log("Loader initialization complete")
    return true
end

-- Cleanup function
function Loader.Cleanup()
    for _, connection in pairs(Loader._connections) do
        if typeof(connection) == "RBXScriptConnection" then
            connection:Disconnect()
        end
    end
    
    if getgenv().LucidWindow then
        pcall(function()
            getgenv().LucidWindow:Destroy()
        end)
        getgenv().LucidWindow = nil
    end
    
    Loader._initialized = false
    Debug.Log("Loader cleanup complete")
end

-- Register cleanup on teleport
LocalPlayer.OnTeleport:Connect(function()
    Loader.Cleanup()
end)

return Loader
