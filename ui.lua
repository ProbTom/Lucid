-- ui.lua
-- Comprehensive UI Module for Lucid Hub
local UI = {
    _version = "1.0.1",
    _initialized = false,
    _components = {},
    _cache = {}
}

-- Core service management with error handling
local Services = {
    Players = game:GetService("Players"),
    CoreGui = game:GetService("CoreGui"),
    RunService = game:GetService("RunService"),
    UserInputService = game:GetService("UserInputService"),
    TweenService = game:GetService("TweenService")
}

-- Configuration constants
local CONFIG = {
    WINDOW = {
        NAME = "Lucid Hub",
        SUBTITLE = "v1.0.1",
        TAB_WIDTH = 160,
        MIN_SIZE = {X = 500, Y = 300},
        THEME = "Dark"
    },
    SAVE = {
        FOLDER = "LucidHub",
        FILENAME = "Config"
    },
    TABS = {
        MAIN = {name = "Main", icon = "rbxassetid://10723424505"},
        ITEMS = {name = "Items", icon = "rbxassetid://10723406110"},
        SETTINGS = {name = "Settings", icon = "rbxassetid://10734898962"}
    }
}

-- Validation and initialization helpers
local function validateEnvironment()
    if not getgenv or not getgenv().Fluent then
        warn("Critical dependency missing: Fluent UI Library")
        return false
    end
    
    if not Services.Players.LocalPlayer then
        warn("LocalPlayer not available")
        return false
    }
    
    return true
end

local function createBasicWindow()
    if not getgenv().Fluent then return nil end
    
    -- Basic window creation without Vector2
    local success, window = pcall(function()
        return getgenv().Fluent:CreateWindow({
            Name = CONFIG.WINDOW.NAME,
            Title = CONFIG.WINDOW.NAME,
            SubTitle = CONFIG.WINDOW.SUBTITLE,
            TabWidth = CONFIG.WINDOW.TAB_WIDTH,
            SaveConfig = true,
            ConfigFolder = CONFIG.SAVE.FOLDER
        })
    end)
    
    if not success or not window then
        warn("Window creation failed:", window)
        return nil
    end
    
    return window
end

local function initializeTabs(window)
    if not window then return false end
    
    UI._components.Tabs = {}
    
    -- Create tabs with error handling
    for id, info in pairs(CONFIG.TABS) do
        local success, tab = pcall(function()
            return window:CreateTab({
                Name = info.name,
                Icon = info.icon
            })
        end)
        
        if success and tab then
            UI._components.Tabs[id] = tab
        else
            warn("Failed to create tab:", id)
        end
    end
    
    return true
end

-- UI Public Interface
function UI.ShowNotification(title, content, duration)
    if not getgenv().Fluent then return end
    
    pcall(function()
        getgenv().Fluent:Notify({
            Title = title or "Notification",
            Content = content or "",
            Duration = duration or 3
        })
    end)
end

function UI.CreateSection(tabName, sectionName)
    local tab = UI._components.Tabs[tabName]
    if not tab then return nil end
    
    local success, section = pcall(function()
        return tab:CreateSection(sectionName)
    end)
    
    return success and section or nil
end

function UI.Minimize()
    if UI._components.Window then
        pcall(function()
            UI._components.Window:Minimize()
        end)
    end
end

function UI.Maximize()
    if UI._components.Window then
        pcall(function()
            UI._components.Window:Maximize()
        end)
    end
end

-- Core initialization
local function initialize()
    -- Environment validation
    if not validateEnvironment() then
        return false
    end
    
    -- Create window
    local window = createBasicWindow()
    if not window then
        return false
    end
    
    -- Store window reference
    UI._components.Window = window
    getgenv().Window = window
    
    -- Initialize tabs
    if not initializeTabs(window) then
        return false
    end
    
    -- Set up SaveManager
    if getgenv().SaveManager then
        pcall(function()
            getgenv().SaveManager:SetLibrary(getgenv().Fluent)
            getgenv().SaveManager:SetWindow(window)
            getgenv().SaveManager:Load(CONFIG.SAVE.FILENAME)
        end)
    end
    
    -- Set up cleanup
    Services.Players.LocalPlayer.OnTeleport:Connect(function()
        pcall(function()
            if getgenv().SaveManager then
                getgenv().SaveManager:Save(CONFIG.SAVE.FILENAME)
            end
            if UI._components.Window then
                UI._components.Window:Destroy()
            end
        end)
    end)
    
    UI._initialized = true
    return true
end

-- Run initialization with comprehensive error handling
local success, result = pcall(initialize)

if success and result then
    if getgenv().Config and getgenv().Config.Debug then
        print("✓ UI system initialized successfully")
    end
    return UI
else
    warn("⚠️ Failed to initialize UI system:", result)
    return false
end
