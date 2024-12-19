-- ui.lua
local UI = {}

-- Core Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

-- UI Constants
local UI_CONFIG = {
    Title = "Lucid Hub",
    SubTitle = "v" .. (getgenv().Config and getgenv().Config.Version or "1.0.1"),
    Theme = "Dark",
    KeySystem = false
}

-- Theme Configuration
local THEMES = {
    Dark = {
        BackgroundColor3 = Color3.fromRGB(25, 25, 25),
        SecondaryColor3 = Color3.fromRGB(35, 35, 35),
        AccentColor3 = Color3.fromRGB(0, 150, 255),
        TextColor3 = Color3.fromRGB(240, 240, 240),
        Font = Enum.Font.GothamMedium
    },
    Light = {
        BackgroundColor3 = Color3.fromRGB(240, 240, 240),
        SecondaryColor3 = Color3.fromRGB(230, 230, 230),
        AccentColor3 = Color3.fromRGB(0, 120, 215),
        TextColor3 = Color3.fromRGB(25, 25, 25),
        Font = Enum.Font.GothamMedium
    }
}

-- Error Handler
local function handleError(context, error)
    if getgenv().Config and getgenv().Config.Debug then
        warn(string.format("[UI] %s Error: %s", context, error))
        if getgenv().Functions and getgenv().Functions.ShowNotification then
            getgenv().Functions.ShowNotification("UI Error", context .. ": " .. error)
        end
    end
end

-- UI Creation with error handling
local function createWindow()
    if getgenv().Window then
        pcall(function()
            getgenv().Window:Destroy()
        end)
    end

    local success, window = pcall(function()
        return getgenv().Fluent:CreateWindow({
            Title = UI_CONFIG.Title,
            SubTitle = UI_CONFIG.SubTitle,
            TabWidth = 160,
            Size = UDim2.fromOffset(580, 460),
            Acrylic = true,
            Theme = UI_CONFIG.Theme,
            MinimizeKey = Enum.KeyCode.LeftControl
        })
    end)

    if not success then
        handleError("Window Creation", window)
        return nil
    end

    return window
end

-- Enhanced Theme Management
UI.SetTheme = function(themeName)
    if not THEMES[themeName] then
        handleError("Theme Setting", "Invalid theme: " .. themeName)
        return false
    end

    pcall(function()
        local theme = THEMES[themeName]
        if getgenv().Window then
            getgenv().Window:SetBackgroundColor3(theme.BackgroundColor3)
            getgenv().Window:SetAccentColor3(theme.AccentColor3)
            -- Apply theme to all elements
            for _, element in pairs(getgenv().Window:GetDescendants()) do
                if element:IsA("TextLabel") or element:IsA("TextButton") then
                    element.TextColor3 = theme.TextColor3
                    element.Font = theme.Font
                end
                if element:IsA("Frame") then
                    element.BackgroundColor3 = theme.SecondaryColor3
                end
            end
        end
    end)

    UI_CONFIG.Theme = themeName
    return true
end

-- Notification System with improved error handling
UI.ShowNotification = function(title, content, duration)
    pcall(function()
        if getgenv().Window then
            getgenv().Window:Notify({
                Title = title or "Notification",
                Content = content or "",
                Duration = duration or 3
            })
        end
    end)
end

-- Enhanced Save/Load System
UI.SaveWindowState = function()
    pcall(function()
        if getgenv().SaveManager then
            getgenv().SaveManager:Save("LucidHub")
        end
    end)
end

UI.LoadWindowState = function()
    pcall(function()
        if getgenv().SaveManager then
            getgenv().SaveManager:Load("LucidHub")
        end
    end)
end

-- UI Cleanup System
UI.Cleanup = function()
    pcall(function()
        if getgenv().Window then
            UI.SaveWindowState()
            getgenv().Window:Destroy()
        end
    end)
end

-- Initialize UI System with comprehensive error handling
local function InitializeUI()
    local requirements = {
        {name = "Fluent", value = getgenv().Fluent},
        {name = "SaveManager", value = getgenv().SaveManager},
        {name = "Config", value = getgenv().Config}
    }
    
    for _, req in ipairs(requirements) do
        if not req.value then
            handleError("Initialization", "Missing requirement: " .. req.name)
            return false
        end
    end

    -- Create main window
    getgenv().Window = createWindow()
    if not getgenv().Window then
        handleError("Initialization", "Failed to create window")
        return false
    end

    -- Apply default theme
    UI.SetTheme(UI_CONFIG.Theme)

    -- Setup auto-save
    game:GetService("Players").LocalPlayer.OnTeleport:Connect(function()
        UI.SaveWindowState()
    end)

    -- Load previous state if available
    UI.LoadWindowState()

    return true
end

-- Run initialization with error handling
if not InitializeUI() then
    warn("⚠️ Failed to initialize UI system")
    return false
end

return UI
