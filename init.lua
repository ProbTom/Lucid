-- init.lua
-- Version: 2024.12.20
-- Author: ProbTom

-- Wait for game to load
if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- Debug Module
local Debug = {
    Enabled = true,
    Log = function(msg) if Debug.Enabled then print("[Lucid] " .. tostring(msg)) end end,
    Error = function(msg) if Debug.Enabled then warn("[Lucid Error] " .. tostring(msg)) end end
}

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

-- Initialize Global State
local function initializeGlobalState()
    -- Initialize core tables if they don't exist
    if not getgenv then
        Debug.Error("getgenv function not available")
        return false
    end

    if not getgenv().LucidState then
        getgenv().LucidState = {
            Version = "1.0.1",
            AutoCasting = false,
            AutoReeling = false,
            AutoShaking = false,
            Events = { Available = {} },
            UI = { Initialized = false },
            Options = {},
            Functions = {}
        }
    end
    return true
end

-- Load UI Library
local function loadUILibrary()
    if getgenv().Fluent then
        return true, getgenv().Fluent
    end

    local success, Fluent = pcall(function()
        return loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
    end)

    if not success or not Fluent then
        Debug.Error("Failed to load Fluent UI library")
        return false
    end

    getgenv().Fluent = Fluent
    return true, Fluent
end

-- Initialize UI Window
local function initializeWindow()
    if getgenv().LucidWindow then
        return true, getgenv().LucidWindow
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
    return true, window
end

-- Main Initialization
local function initialize()
    -- Step 1: Initialize Global State
    if not initializeGlobalState() then
        Debug.Error("Failed to initialize global state")
        return false
    end

    -- Step 2: Load UI Library
    local uiSuccess = loadUILibrary()
    if not uiSuccess then
        Debug.Error("Failed to load UI library")
        return false
    end

    -- Step 3: Initialize Window
    local windowSuccess = initializeWindow()
    if not windowSuccess then
        Debug.Error("Failed to initialize window")
        return false
    end

    -- Step 4: Load Core Modules
    local moduleUrls = {
        Functions = "https://raw.githubusercontent.com/ProbTom/Lucid/main/functions.lua",
        UI = "https://raw.githubusercontent.com/ProbTom/Lucid/main/ui.lua",
        Events = "https://raw.githubusercontent.com/ProbTom/Lucid/main/events.lua",
        Tabs = "https://raw.githubusercontent.com/ProbTom/Lucid/main/Tab.lua"
    }

    for name, url in pairs(moduleUrls) do
        local success = protectedCall(function()
            return loadstring(game:HttpGet(url))()
        end)
        if not success then
            Debug.Error("Failed to load " .. name .. " module")
            return false
        end
    end

    -- Step 5: Initialize Save Manager
    if not getgenv().SaveManager then
        local success = protectedCall(function()
            getgenv().SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
            getgenv().SaveManager:SetLibrary(getgenv().Fluent)
            getgenv().SaveManager:SetFolder("LucidHub")
            getgenv().SaveManager:Load("LucidHub")
        end)
        if not success then
            Debug.Error("Failed to initialize SaveManager")
            return false
        end
    end

    Debug.Log("Initialization complete")
    return true
end

-- Run Initialization
if not initialize() then
    Debug.Error("Failed to initialize Lucid Hub")
    return
end

return true
