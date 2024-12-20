-- ui.lua
-- Version: 1.0.1
-- Author: ProbTom
-- Created: 2024-12-20 18:47:46 UTC

local UI = {}

-- Dependencies
local Debug
local Events

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

-- Constants
local TWEEN_INFO = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local MIN_DRAG_DISTANCE = 5

-- UI Elements storage
local elements = {}
local activeWindows = {}
local dragInfo = nil

-- FluentUI Library (from dependencies)
local Fluent

-- Create base window
function UI.CreateWindow(options)
    if not Fluent then
        Debug.Error("FluentUI not initialized")
        return nil
    end

    options = options or {}
    local window = Fluent:CreateWindow({
        Title = options.Title or "Lucid",
        SubTitle = options.SubTitle or "",
        TabWidth = options.TabWidth or 160,
        Size = options.Size or UDim2.new(0, 600, 0, 400),
        Position = options.Position or UDim2.new(0.5, -300, 0.5, -200),
        ButtonColor = Color3.fromRGB(0, 120, 255),
        ButtonTransparency = 0,
        TabPadding = options.TabPadding or 8
    })
    
    -- Store window reference
    table.insert(activeWindows, window)
    
    return window
end

-- Create tab in window
function UI.CreateTab(window, options)
    if not window then
        Debug.Error("Window is required to create a tab")
        return nil
    end

    options = options or {}
    local tab = window:CreateTab({
        Title = options.Title or "Tab",
        Icon = options.Icon or "rbxassetid://3926305904"
    })
    
    return tab
end

-- Create button
function UI.CreateButton(tab, options)
    if not tab then
        Debug.Error("Tab is required to create a button")
        return nil
    end

    options = options or {}
    local button = tab:CreateButton({
        Title = options.Title or "Button",
        Description = options.Description,
        Callback = options.Callback or function() end
    })
    
    elements[button] = {
        type = "button",
        options = options
    }
    
    return button
end

-- Create toggle
function UI.CreateToggle(tab, options)
    if not tab then
        Debug.Error("Tab is required to create a toggle")
        return nil
    end

    options = options or {}
    local toggle = tab:CreateToggle({
        Title = options.Title or "Toggle",
        Description = options.Description,
        Default = options.Default or false,
        Callback = options.Callback or function() end
    })
    
    elements[toggle] = {
        type = "toggle",
        options = options
    }
    
    return toggle
end

-- Create slider
function UI.CreateSlider(tab, options)
    if not tab then
        Debug.Error("Tab is required to create a slider")
        return nil
    end

    options = options or {}
    local slider = tab:CreateSlider({
        Title = options.Title or "Slider",
        Description = options.Description,
        Range = options.Range or {0, 100},
        Increment = options.Increment or 1,
        Default = options.Default or 50,
        Callback = options.Callback or function() end
    })
    
    elements[slider] = {
        type = "slider",
        options = options
    }
    
    return slider
end

-- Create dropdown
function UI.CreateDropdown(tab, options)
    if not tab then
        Debug.Error("Tab is required to create a dropdown")
        return nil
    end

    options = options or {}
    local dropdown = tab:CreateDropdown({
        Title = options.Title or "Dropdown",
        Description = options.Description,
        Items = options.Items or {},
        Default = options.Default,
        Callback = options.Callback or function() end
    })
    
    elements[dropdown] = {
        type = "dropdown",
        options = options
    }
    
    return dropdown
end

-- Create input field
function UI.CreateInput(tab, options)
    if not tab then
        Debug.Error("Tab is required to create an input")
        return nil
    end

    options = options or {}
    local input = tab:CreateInput({
        Title = options.Title or "Input",
        Description = options.Description,
        Default = options.Default or "",
        Callback = options.Callback or function() end
    })
    
    elements[input] = {
        type = "input",
        options = options
    }
    
    return input
end

-- Create label
function UI.CreateLabel(tab, options)
    if not tab then
        Debug.Error("Tab is required to create a label")
        return nil
    end

    options = options or {}
    local label = tab:CreateLabel({
        Title = options.Title or "Label",
        Description = options.Description
    })
    
    elements[label] = {
        type = "label",
        options = options
    }
    
    return label
end

-- Update element
function UI.UpdateElement(element, options)
    local elementData = elements[element]
    if not elementData then
        Debug.Warn("Element not found")
        return false
    end
    
    for key, value in pairs(options) do
        if elementData.options[key] ~= nil then
            elementData.options[key] = value
            if element.Update then
                element:Update(key, value)
            end
        end
    end
    
    return true
end

-- Close all windows
function UI.CloseAll()
    for _, window in ipairs(activeWindows) do
        if window.Destroy then
            window:Destroy()
        end
    end
    activeWindows = {}
end

-- Notification system
function UI.Notify(options)
    if not Fluent then
        Debug.Error("FluentUI not initialized")
        return
    end

    options = options or {}
    Fluent:Notify({
        Title = options.Title or "Notification",
        Content = options.Content or "",
        Duration = options.Duration or 3,
        Type = options.Type or "Info"
    })
end

-- Initialize module
function UI.init(modules)
    Debug = modules.debug
    Events = modules.events
    
    -- Load FluentUI with improved error handling
    local function loadFluentUI()
        local url = "https://github.com/dawid-scripts/Fluent/releases/download/1.1.0/main.lua"
        Debug.Info("Attempting to load FluentUI from: " .. url)
        
        local success, content = pcall(function()
            return game:HttpGet(url)
        end)
        
        if not success then
            Debug.Error("Failed to fetch FluentUI: " .. tostring(content))
            return false
        end
        
        if not content or content == "" then
            Debug.Error("Empty content received from FluentUI URL")
            return false
        end
        
        -- Load the content
        local func, err = loadstring(content)
        if not func then
            Debug.Error("Failed to parse FluentUI content: " .. tostring(err))
            return false
        end
        
        -- Execute the loaded function
        local success, result = pcall(func)
        if not success then
            Debug.Error("Failed to execute FluentUI: " .. tostring(result))
            return false
        end
        
        Debug.Info("FluentUI loaded successfully")
        return result
    end
    
    -- Initialize FluentUI
    local result = loadFluentUI()
    if not result then
        return false
    end
    
    Fluent = result
    Debug.Info("UI module initialized")
    return true
end

return UI
