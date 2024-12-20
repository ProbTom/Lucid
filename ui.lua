-- ui.lua
-- Version: 2024.12.20
-- Author: ProbTom
-- Last Updated: 2024-12-20 14:31:15

local UI = {
    _version = "1.0.1",
    _initialized = false,
    _elements = {},
    _connections = {},
    _activeNotifications = {}
}

local Debug = getgenv().LucidDebug

-- Services
local Services = {
    TweenService = game:GetService("TweenService"),
    UserInputService = game:GetService("UserInputService"),
    RunService = game:GetService("RunService")
}

-- UI Constants
local TWEEN_INFO = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local MAX_NOTIFICATIONS = 5
local NOTIFICATION_DURATION = 5

-- Utility Functions
local function createTween(instance, properties)
    return Services.TweenService:Create(instance, TWEEN_INFO, properties)
end

local function safeDestroy(instance)
    if instance and typeof(instance) == "Instance" then
        pcall(function()
            instance:Destroy()
        end)
    end
end

-- Notification System
function UI.Notify(options)
    options = type(options) == "table" and options or {
        Title = type(options) == "string" and options or "Notification",
        Content = type(options) == "string" and options or "",
        Duration = NOTIFICATION_DURATION,
        Type = "Info" -- Info, Success, Warning, Error
    }
    
    if #UI._activeNotifications >= MAX_NOTIFICATIONS then
        local oldest = table.remove(UI._activeNotifications, 1)
        safeDestroy(oldest.Instance)
    end
    
    if getgenv().LucidWindow then
        getgenv().LucidWindow:Notify(options)
    end
end

-- Tab Management
function UI.CreateTab(tabConfig)
    if not getgenv().LucidWindow then
        Debug.Error("Window not initialized")
        return false
    end
    
    local tab = getgenv().LucidWindow:AddTab(tabConfig)
    if not tab then
        Debug.Error("Failed to create tab: " .. tabConfig.Title)
        return false
    end
    
    UI._elements[tabConfig.Title] = {
        Tab = tab,
        Sections = {}
    }
    
    return tab
end

-- Section Management
function UI.CreateSection(tabName, sectionConfig)
    local tabData = UI._elements[tabName]
    if not tabData or not tabData.Tab then
        Debug.Error("Tab not found: " .. tabName)
        return false
    end
    
    local section = tabData.Tab:AddSection(sectionConfig)
    if not section then
        Debug.Error("Failed to create section: " .. sectionConfig.Title)
        return false
    end
    
    tabData.Sections[sectionConfig.Title] = section
    return section
end

-- Element Creation Functions
function UI.AddToggle(tabName, sectionName, config)
    local tabData = UI._elements[tabName]
    if not tabData or not tabData.Sections[sectionName] then
        Debug.Error("Tab or section not found")
        return false
    end
    
    local section = tabData.Sections[sectionName]
    return section:AddToggle(config)
end

function UI.AddButton(tabName, sectionName, config)
    local tabData = UI._elements[tabName]
    if not tabData or not tabData.Sections[sectionName] then
        Debug.Error("Tab or section not found")
        return false
    end
    
    local section = tabData.Sections[sectionName]
    return section:AddButton(config)
end

function UI.AddSlider(tabName, sectionName, config)
    local tabData = UI._elements[tabName]
    if not tabData or not tabData.Sections[sectionName] then
        Debug.Error("Tab or section not found")
        return false
    end
    
    local section = tabData.Sections[sectionName]
    return section:AddSlider(config)
end

function UI.AddDropdown(tabName, sectionName, config)
    local tabData = UI._elements[tabName]
    if not tabData or not tabData.Sections[sectionName] then
        Debug.Error("Tab or section not found")
        return false
    end
    
    local section = tabData.Sections[sectionName]
    return section:AddDropdown(config)
end

-- UI State Management
function UI.SetEnabled(enabled)
    if getgenv().LucidWindow then
        if enabled then
            getgenv().LucidWindow:Show()
        else
            getgenv().LucidWindow:Hide()
        end
    end
end

function UI.ToggleVisibility()
    if getgenv().LucidWindow then
        getgenv().LucidWindow:Toggle()
    end
end

-- Keybind Management
function UI.SetupKeybinds()
    Services.UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == getgenv().LucidState.Config.UI.Window.MinimizeKeybind then
            UI.ToggleVisibility()
        end
    end)
end

-- Initialize UI System
function UI.Initialize()
    if UI._initialized then
        return true
    end
    
    -- Setup keybinds
    UI.SetupKeybinds()
    
    -- Create tabs from config
    local config = getgenv().LucidState.Config
    for tabName, tabConfig in pairs(config.UI.Tabs) do
        local tab = UI.CreateTab({
            Title = tabConfig.Name,
            Icon = tabConfig.Icon
        })
        
        if tab and tabConfig.Sections then
            for sectionName, sectionConfig in pairs(tabConfig.Sections) do
                UI.CreateSection(tabName, {
                    Title = sectionConfig.Title
                })
            end
        end
    end
    
    UI._initialized = true
    Debug.Log("UI system initialized")
    return true
end

-- Cleanup
function UI.Cleanup()
    for _, connection in pairs(UI._connections) do
        if typeof(connection) == "RBXScriptConnection" then
            connection:Disconnect()
        end
    end
    
    for _, notification in ipairs(UI._activeNotifications) do
        safeDestroy(notification.Instance)
    end
    
    UI._connections = {}
    UI._activeNotifications = {}
    UI._elements = {}
    UI._initialized = false
    
    Debug.Log("UI system cleaned up")
end

return UI
