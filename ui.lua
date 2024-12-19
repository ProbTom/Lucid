-- ui.lua
local UI = {}

-- Core Services with error handling
local function getService(serviceName)
    local success, service = pcall(function()
        return game:GetService(serviceName)
    end)
    
    if not success then
        warn("Failed to get service:", serviceName)
        return nil
    end
    
    return service
end

local Players = getService("Players")
local CoreGui = getService("CoreGui")
local TweenService = getService("TweenService")
local LocalPlayer = Players and Players.LocalPlayer

-- UI Constants
local UI_CONFIG = {
    Title = "Lucid Hub",
    SubTitle = "by ProbTom",
    TabWidth = 160,
    MinimumWidth = 500,
    MinimumHeight = 300,
    Theme = "Dark",
    KeySystem = false
}

-- Theme Configuration
local THEME_COLORS = {
    Dark = {
        Background = Color3.fromRGB(25, 25, 25),
        Foreground = Color3.fromRGB(35, 35, 35),
        Accent = Color3.fromRGB(0, 125, 255),
        Text = Color3.fromRGB(255, 255, 255),
        SubText = Color3.fromRGB(180, 180, 180)
    }
}

-- Enhanced error handling for UI creation
local function createWindow()
    if not getgenv().Fluent then
        warn("Fluent UI library not loaded")
        return nil
    end
    
    local success, window = pcall(function()
        return getgenv().Fluent:CreateWindow({
            Title = UI_CONFIG.Title,
            SubTitle = UI_CONFIG.SubTitle,
            TabWidth = UI_CONFIG.TabWidth,
            Size = Vector2.new(UI_CONFIG.MinimumWidth, UI_CONFIG.MinimumHeight),
            Acrylic = true,
            Theme = UI_CONFIG.Theme,
            MinimizeKey = Enum.KeyCode.LeftControl
        })
    end)
    
    if not success then
        warn("Failed to create window:", window)
        return nil
    end
    
    return window
end

-- Initialize SaveManager with error handling
local function initializeSaveManager(window)
    if not window or not getgenv().SaveManager then return end
    
    pcall(function()
        getgenv().SaveManager:SetLibrary(getgenv().Fluent)
        getgenv().SaveManager:SetWindow(window)
        getgenv().SaveManager:SetFolder("LucidHub/Configs")
        getgenv().SaveManager:BuildConfigSection(window.Tabs.Settings)
        getgenv().SaveManager:LoadAutoloadConfig()
    end)
end

-- Initialize InterfaceManager with error handling
local function initializeInterfaceManager(window)
    if not window or not getgenv().InterfaceManager then return end
    
    pcall(function()
        getgenv().InterfaceManager:SetLibrary(getgenv().Fluent)
        getgenv().InterfaceManager:SetWindow(window)
        getgenv().InterfaceManager:BuildInterfaceSection(window.Tabs.Settings)
    end)
end

-- Enhanced notification system
UI.ShowNotification = function(title, content, duration)
    if not getgenv().Fluent then return end
    
    pcall(function()
        getgenv().Fluent:Notify({
            Title = title or "Notification",
            Content = content or "",
            Duration = duration or 3,
            Theme = UI_CONFIG.Theme
        })
    end)
end

-- Window management functions
UI.MinimizeWindow = function()
    if not getgenv().Window then return end
    
    pcall(function()
        getgenv().Window:Minimize()
    end)
end

UI.MaximizeWindow = function()
    if not getgenv().Window then return end
    
    pcall(function()
        getgenv().Window:Maximize()
    end)
end

-- Tab management with error handling
UI.CreateTab = function(name, icon)
    if not getgenv().Window then return nil end
    
    local success, tab = pcall(function()
        return getgenv().Window:AddTab({
            Title = name,
            Icon = icon or "home"
        })
    end)
    
    if not success then
        warn("Failed to create tab:", name)
        return nil
    end
    
    return tab
end

-- Section management with error handling
UI.CreateSection = function(tab, name)
    if not tab then return nil end
    
    local success, section = pcall(function()
        return tab:AddSection(name)
    end)
    
    if not success then
        warn("Failed to create section:", name)
        return nil
    end
    
    return section
end

-- Enhanced cleanup system
UI.Cleanup = function()
    pcall(function()
        if getgenv().SaveManager then
            getgenv().SaveManager:SaveAutoloadConfig()
        end
        
        if getgenv().Window then
            getgenv().Window:Destroy()
        end
    end)
end

-- Initialize UI with comprehensive error handling
local function InitializeUI()
    -- Validate environment
    if not getgenv then
        warn("Missing getgenv environment")
        return false
    end
    
    -- Create window
    local window = createWindow()
    if not window then
        warn("Failed to create main window")
        return false
    end
    
    -- Store window reference globally
    getgenv().Window = window
    
    -- Initialize managers
    initializeSaveManager(window)
    initializeInterfaceManager(window)
    
    -- Set up cleanup handler
    game:GetService("Players").LocalPlayer.OnTeleport:Connect(function()
        UI.Cleanup()
    end)
    
    -- Create default tabs
    if not getgenv().Tabs then
        getgenv().Tabs = {}
    end
    
    -- Initialize successful
    if getgenv().Config and getgenv().Config.Debug then
        UI.ShowNotification("Initialization", "UI system loaded successfully")
    end
    
    return true
end

-- Run initialization with error handling
if not InitializeUI() then
    warn("⚠️ Failed to initialize UI system")
    return false
end

return UI
