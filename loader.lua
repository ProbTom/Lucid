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

-- Check for existing instance and clean up
local function cleanupExisting()
    if getgenv().LucidWindow then
        pcall(function()
            getgenv().LucidWindow:Destroy()
        end)
        getgenv().LucidWindow = nil
    end
    
    if getgenv().Fluent then
        getgenv().Fluent = nil
    end
    
    if getgenv().LucidState then
        getgenv().LucidState = nil
    end
    
    if getgenv().Tabs then
        getgenv().Tabs = nil
    end
end

-- Load Debug module
local Debug = loadstring(game:HttpGet("https://raw.githubusercontent.com/ProbTom/Lucid/main/debug.lua"))()
if not Debug then
    warn("[CRITICAL ERROR]: Failed to load Debug module")
    return false
end

-- Protected Call Function
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

-- Load Fluent UI Library
local function loadFluentUI()
    local success, Fluent = pcall(function()
        return loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
    end)

    if not success or not Fluent then
        Debug.Error("Failed to load Fluent UI library")
        return false
    end

    getgenv().Fluent = Fluent
    return Fluent
end

-- Create window
local function createWindow()
    if getgenv().LucidWindow then
        return getgenv().LucidWindow
    end

    if not getgenv().Fluent then
        Debug.Error("Fluent UI library not loaded")
        return false
    end

    local window = getgenv().Fluent:CreateWindow({
        Title = "Lucid Hub",
        SubTitle = "by ProbTom",
        TabWidth = 160,
        Size = UDim2.fromOffset(580, 460),
        Theme = "Dark",
        MinimizeKeybind = Enum.KeyCode.RightControl
    })

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

    local tabs = {
        {Name = "Home", Icon = "home"},
        {Name = "Main", Icon = "list"},
        {Name = "Items", Icon = "package"},
        {Name = "Teleports", Icon = "map-pin"},
        {Name = "Misc", Icon = "file-text"},
        {Name = "Settings", Icon = "settings"},
        {Name = "Credits", Icon = "heart"}
    }

    getgenv().Tabs = {}

    for _, tabInfo in ipairs(tabs) do
        local success, tab = protectedCall(function()
            return window:AddTab({
                Title = tabInfo.Name,
                Icon = tabInfo.Icon
            })
        end)

        if success and tab then
            getgenv().Tabs[tabInfo.Name] = tab
            Debug.Log("Created tab: " .. tabInfo.Name)
        else
            Debug.Error("Failed to create tab: " .. tabInfo.Name)
            return false
        end
    end

    return true
end

-- Initialize features
local function initializeFeatures()
    local mainTab = getgenv().Tabs.Main
    if not mainTab then
        Debug.Error("Main tab not found")
        return false
    end

    local section = mainTab:AddSection("Fishing Controls")

    -- Auto Cast
    section:AddToggle({
        Title = "Auto Cast",
        Default = false,
        Callback = function(value)
            if getgenv().LucidState then
                getgenv().LucidState.AutoCasting = value
                Debug.Log("Auto Cast: " .. tostring(value))
            end
        end
    })

    -- Auto Reel
    section:AddToggle({
        Title = "Auto Reel",
        Default = false,
        Callback = function(value)
            if getgenv().LucidState then
                getgenv().LucidState.AutoReeling = value
                Debug.Log("Auto Reel: " .. tostring(value))
            end
        end
    })

    -- Auto Shake
    section:AddToggle({
        Title = "Auto Shake",
        Default = false,
        Callback = function(value)
            if getgenv().LucidState then
                getgenv().LucidState.AutoShaking = value
                Debug.Log("Auto Shake: " .. tostring(value))
            end
        end
    })

    return true
end

-- Initialize credits
local function initializeCredits()
    local creditsTab = getgenv().Tabs.Credits
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

    -- Clean up any existing instances
    cleanupExisting()

    -- Initialize global state
    if not getgenv then
        Debug.Error("getgenv is not available")
        return false
    end

    getgenv().LucidState = {
        Version = Loader._version,
        AutoCasting = false,
        AutoReeling = false,
        AutoShaking = false,
        Events = { Available = {} },
        UI = { Initialized = false },
        initialized = false
    }

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
    getgenv().LucidState.initialized = true
    Debug.Log("Initialization complete")
    return true
end

-- Cleanup function
function Loader.Cleanup()
    for _, connection in pairs(Loader._connections) do
        if typeof(connection) == "RBXScriptConnection" then
            connection:Disconnect()
        end
    end
    
    cleanupExisting()
    Loader._initialized = false
end

-- Register cleanup on teleport
LocalPlayer.OnTeleport:Connect(function()
    Loader.Cleanup()
end)

-- Run initialization
if not Loader.Initialize() then
    Debug.Error("Failed to initialize Lucid Hub")
end

return Loader
