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

-- Basic validation
if not getgenv or not getgenv().Fluent then
    warn("Missing required UI dependencies")
    return false
end

-- Simple window configuration
local WindowConfig = {
    Title = "Lucid Hub",
    SubTitle = "v1.0.1",
    TabWidth = 160,
    Width = 500,
    Height = 300,
    Theme = "Dark"
}

-- Create window with simplified configuration
local function createWindow()
    if not getgenv().Fluent then return nil end
    
    local success, window = pcall(function()
        return getgenv().Fluent:CreateWindow({
            Name = WindowConfig.Title, -- Use Name instead of Title
            LoadingTitle = WindowConfig.Title,
            LoadingSubtitle = WindowConfig.SubTitle,
            ConfigurationSaving = {
                Enabled = true,
                FolderName = "LucidHub",
                FileName = "LucidHub_Config"
            }
        })
    end)
    
    if not success or not window then
        warn("Window creation failed:", window)
        return nil
    end
    
    return window
end

-- Initialize tabs with error handling
local function createTabs(window)
    if not window then return false end
    
    local tabs = {
        Main = {
            name = "Main",
            icon = "home"
        },
        Items = {
            name = "Items",
            icon = "package"
        },
        Settings = {
            name = "Settings",
            icon = "settings"
        }
    }
    
    getgenv().Tabs = {}
    
    for id, info in pairs(tabs) do
        pcall(function()
            getgenv().Tabs[id] = window:AddTab(info.name, {
                Icon = info.icon
            })
        end)
    end
    
    return true
end

-- Initialize UI system
local function InitializeUI()
    -- Create window
    local window = createWindow()
    if not window then
        return false
    end
    
    -- Store window reference
    getgenv().Window = window
    
    -- Create tabs
    if not createTabs(window) then
        warn("Failed to create tabs")
        return false
    end
    
    -- Set up SaveManager
    if getgenv().SaveManager then
        pcall(function()
            getgenv().SaveManager:SetLibrary(getgenv().Fluent)
            getgenv().SaveManager:SetWindow(window)
            getgenv().SaveManager:Load("LucidHub")
        end)
    end
    
    -- Set up cleanup
    if Players.LocalPlayer then
        pcall(function()
            Players.LocalPlayer.OnTeleport:Connect(function()
                if getgenv().SaveManager then
                    getgenv().SaveManager:Save("LucidHub")
                end
                if window then
                    window:Destroy()
                end
            end)
        end)
    end
    
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
        return tab:CreateSection(name)
    end)
    
    return success and section or nil
end

-- Run initialization
local success, result = pcall(InitializeUI)

if success and result then
    return UI
else
    warn("⚠️ Failed to initialize UI system:", result)
    return false
end
