-- ui.lua
local UI = {}

-- Safe service getter
local function getSafe(name)
    local success, service = pcall(function()
        return game:GetService(name)
    end)
    return success and service
end

-- Core Services
local Players = getSafe("Players")
local CoreGui = getSafe("CoreGui")
local UserInputService = getSafe("UserInputService")

-- UI Constants
local UI_CONFIG = {
    Title = "Lucid Hub",
    SubTitle = "v1.0.1",
    Size = {
        Width = 500,
        Height = 300
    },
    Theme = "Dark"
}

-- Validate environment
if not getgenv or not getgenv().Fluent then
    warn("Required UI dependencies not available")
    return false
end

-- Create window with error handling
local function createWindow()
    local success, window = pcall(function()
        return getgenv().Fluent:CreateWindow({
            Title = UI_CONFIG.Title,
            SubTitle = UI_CONFIG.SubTitle,
            TabWidth = 160,
            Size = Vector2.new(UI_CONFIG.Size.Width, UI_CONFIG.Size.Height),
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

-- Initialize UI system
local function InitializeUI()
    -- Create main window
    local window = createWindow()
    if not window then
        return false
    end
    
    -- Store window reference
    getgenv().Window = window
    
    -- Initialize tabs container
    getgenv().Tabs = {}
    
    -- Create default tabs
    local mainTab = window:AddTab({
        Title = "Main",
        Icon = "home"
    })
    
    local itemsTab = window:AddTab({
        Title = "Items",
        Icon = "package"
    })
    
    local settingsTab = window:AddTab({
        Title = "Settings",
        Icon = "settings"
    })
    
    -- Store tab references
    getgenv().Tabs.Main = mainTab
    getgenv().Tabs.Items = itemsTab
    getgenv().Tabs.Settings = settingsTab
    
    -- Initialize SaveManager if available
    if getgenv().SaveManager then
        pcall(function()
            getgenv().SaveManager:SetLibrary(getgenv().Fluent)
            getgenv().SaveManager:SetWindow(window)
            getgenv().SaveManager:SetFolder("LucidHub")
            getgenv().SaveManager:BuildConfigSection(settingsTab)
            getgenv().SaveManager:Load("LucidHub")
        end)
    end
    
    -- Initialize InterfaceManager if available
    if getgenv().InterfaceManager then
        pcall(function()
            getgenv().InterfaceManager:SetLibrary(getgenv().Fluent)
            getgenv().InterfaceManager:SetWindow(window)
            getgenv().InterfaceManager:BuildInterfaceSection(settingsTab)
        end)
    end
    
    -- Set up cleanup
    game:GetService("Players").LocalPlayer.OnTeleport:Connect(function()
        pcall(function()
            if getgenv().SaveManager then
                getgenv().SaveManager:Save("LucidHub")
            end
            if window then
                window:Destroy()
            end
        end)
    end)
    
    return true
end

-- UI Helper Functions
UI.ShowNotification = function(title, content, duration)
    pcall(function()
        if getgenv().Fluent then
            getgenv().Fluent:Notify({
                Title = title or "Notification",
                Content = content or "",
                Duration = duration or 3
            })
        end
    end)
end

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

UI.Minimize = function()
    pcall(function()
        if getgenv().Window then
            getgenv().Window:Minimize()
        end
    end)
end

UI.Maximize = function()
    pcall(function()
        if getgenv().Window then
            getgenv().Window:Maximize()
        end
    end)
end

-- Run initialization
local success = pcall(InitializeUI)
if success then
    return UI
else
    warn("⚠️ Failed to initialize UI system")
    return false
end
