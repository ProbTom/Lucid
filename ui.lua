-- ui.lua
-- Version: 1.0.1
-- Author: ProbTom
-- Created: 2024-12-20 19:49:16 UTC

local UI = {
    _VERSION = "1.0.1",
    _initialized = false,
    _windows = {},
    _tabs = {},
    _elements = {}
}

-- Dependencies
local Debug
local Utils

-- Services
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

-- Constants
local UI_CONFIG = {
    DEFAULT_WINDOW_SIZE = UDim2.new(0, 600, 0, 400),
    DEFAULT_WINDOW_POSITION = UDim2.new(0.5, -300, 0.5, -200),
    DEFAULT_TAB_WIDTH = 160,
    DEFAULT_ANIMATION_DURATION = 0.3
}

-- Create window
function UI.CreateWindow(options)
    options = options or {}
    local window = {
        Title = options.Title or "Lucid",
        SubTitle = options.SubTitle or UI._VERSION,
        Size = options.Size or UI_CONFIG.DEFAULT_WINDOW_SIZE,
        Position = options.Position or UI_CONFIG.DEFAULT_WINDOW_POSITION,
        Tabs = {}
    }
    
    -- Create window UI elements here
    -- Using a protected call to load the UI library
    local success, Fluent = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Fluent.txt"))()
    end)
    
    if not success then
        Debug.Error("Failed to load UI library")
        return nil
    end
    
    -- Create window using Fluent
    local WindowInstance = Fluent:CreateWindow({
        Title = window.Title,
        SubTitle = window.SubTitle,
        TabWidth = UI_CONFIG.DEFAULT_TAB_WIDTH,
        Size = window.Size,
        Position = window.Position,
        Theme = "Dark",
        Enabled = true
    })
    
    window.Instance = WindowInstance
    table.insert(UI._windows, window)
    
    Debug.Info("Created window: " .. window.Title)
    return WindowInstance
end

-- Create tab
function UI.CreateTab(window, options)
    options = options or {}
    
    if not window then
        Debug.Error("Window is required to create tab")
        return nil
    end
    
    local tab = window:CreateTab({
        Title = options.Title or "New Tab",
        Icon = options.Icon or ""
    })
    
    table.insert(UI._tabs, tab)
    Debug.Info("Created tab: " .. options.Title)
    return tab
end

-- Create button
function UI.CreateButton(tab, options)
    options = options or {}
    
    if not tab then
        Debug.Error("Tab is required to create button")
        return nil
    end
    
    local button = tab:CreateButton({
        Title = options.Title or "Button",
        Description = options.Description,
        Callback = function()
            if type(options.Callback) == "function" then
                Utils.SafeCall(options.Callback)
            end
        end
    })
    
    table.insert(UI._elements, button)
    return button
end

-- Create toggle
function UI.CreateToggle(tab, options)
    options = options or {}
    
    if not tab then
        Debug.Error("Tab is required to create toggle")
        return nil
    end
    
    local toggle = tab:CreateToggle({
        Title = options.Title or "Toggle",
        Description = options.Description,
        Default = options.Default or false,
        Callback = function(value)
            if type(options.Callback) == "function" then
                Utils.SafeCall(options.Callback, value)
            end
        end
    })
    
    table.insert(UI._elements, toggle)
    return toggle
end

-- Show notification
function UI.Notify(options)
    options = options or {}
    
    if UI._windows[1] and UI._windows[1].Instance then
        UI._windows[1].Instance:Notify({
            Title = options.Title or "Notification",
            Content = options.Content or "",
            Duration = options.Duration or 3,
            Type = options.Type or "Info"
        })
    end
end

-- Close all windows
function UI.CloseAll()
    for _, window in ipairs(UI._windows) do
        if window.Instance and typeof(window.Instance.Destroy) == "function" then
            window.Instance:Destroy()
        end
    end
    
    UI._windows = {}
    UI._tabs = {}
    UI._elements = {}
    
    Debug.Info("Closed all UI windows")
end

-- Initialize module
function UI.init(modules)
    if UI._initialized then return true end
    
    Debug = modules.debug
    Utils = modules.utils
    
    if not Debug or not Utils then
        return false
    end
    
    UI._initialized = true
    Debug.Info("UI module initialized")
    return true
end

return UI
