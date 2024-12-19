-- ui.lua
local UI = {
    _version = "1.0.1",
    _initialized = false
}

-- Prevent multiple initializations
if getgenv().LucidUI then
    return getgenv().LucidUI
end

-- Core service access
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

-- Basic validation
if not getgenv or not getgenv().Fluent then
    warn("Missing required UI dependencies")
    return false
end

-- Window creation with mandatory Title
local function createWindow()
    if not getgenv().Fluent then return nil end
    
    local window = getgenv().Fluent:CreateWindow({
        Title = "Lucid Hub", -- Required
        SubTitle = "by ProbTom", -- Required
        TabWidth = 160,
        Size = Vector2.new(580, 460),
        Acrylic = true,
        Theme = "Dark",
        MinimizeKey = Enum.KeyCode.LeftControl
    })
    
    if not window then
        warn("Failed to create window")
        return nil
    end
    
    return window
end

-- Initialize UI system
local function initialize()
    local window = createWindow()
    if not window then
        return false
    end
    
    -- Store window reference globally
    getgenv().Window = window
    
    -- Create tabs
    local tabs = {
        Main = window:AddTab({
            Title = "Main",
            Icon = "home"
        }),
        Items = window:AddTab({
            Title = "Items",
            Icon = "package"
        }),
        Settings = window:AddTab({
            Title = "Settings",
            Icon = "settings"
        })
    }
    
    -- Store tabs globally
    getgenv().Tabs = tabs
    
    -- Setup SaveManager
    if getgenv().SaveManager then
        pcall(function()
            getgenv().SaveManager:SetLibrary(getgenv().Fluent)
            getgenv().SaveManager:SetWindow(window)
            getgenv().SaveManager:Load("LucidHub")
        end)
    end
    
    UI._initialized = true
    return true
end

-- Run initialization
local success = pcall(initialize)

if success then
    getgenv().LucidUI = UI
    return UI
else
    warn("⚠️ Failed to initialize UI system")
    return false
end
