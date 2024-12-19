-- ui.lua
-- Core UI Module for Lucid Hub
local UI = {
    _loaded = false,
    _components = {},
    _cache = {},
    _initialized = false
}

-- Protection against re-initialization
if getgenv().LucidUI then
    return getgenv().LucidUI
end

-- Core service access with protection
local function getService(name)
    local success, service = pcall(function()
        return game:GetService(name)
    end)
    return success and service
end

-- Required services
local Services = {
    Players = getService("Players"),
    CoreGui = getService("CoreGui"),
    RunService = getService("RunService")
}

-- Configuration
local Config = {
    WINDOW_SETTINGS = {
        Name = "Lucid Hub",
        LoadingTitle = "Lucid Hub",
        LoadingSubtitle = "by ProbTom",
        Discord = "https://discord.gg/example",
        ConfigurationSaving = {
            Enabled = true,
            FolderName = "LucidHub",
            FileName = "Configuration"
        }
    },
    TABS = {
        Main = {
            Name = "Main",
            Icon = "home"
        },
        Items = {
            Name = "Items",
            Icon = "package"
        },
        Settings = {
            Name = "Settings",
            Icon = "settings"
        }
    }
}

-- Dependency verification
local function verifyDependencies()
    -- Check required global functions
    if not getgenv or not getgenv().Fluent then
        warn("Critical dependency missing: Fluent UI Library")
        return false
    end

    -- Check required services
    for name, service in pairs(Services) do
        if not service then
            warn("Required service missing:", name)
            return false
        end
    end

    -- Check LocalPlayer
    if not Services.Players.LocalPlayer then
        warn("LocalPlayer not available")
        return false
    end

    return true
end

-- Safe window creation
local function createWindow()
    if not getgenv().Fluent then
        return nil
    end

    local success, window = pcall(function()
        -- Create window with minimal configuration to avoid Offset issues
        return getgenv().Fluent:CreateWindow({
            Name = Config.WINDOW_SETTINGS.Name,
            LoadingTitle = Config.WINDOW_SETTINGS.LoadingTitle,
            LoadingSubtitle = Config.WINDOW_SETTINGS.LoadingSubtitle,
            ConfigurationSaving = Config.WINDOW_SETTINGS.ConfigurationSaving
        })
    end)

    if not success or not window then
        warn("Failed to create window:", window)
        return nil
    end

    return window
end

-- Tab creation with error handling
local function createTabs(window)
    if not window then return false end
    
    UI._components.Tabs = {}
    
    for id, info in pairs(Config.TABS) do
        local success, tab = pcall(function()
            return window:CreateTab(info)
        end)
        
        if success and tab then
            UI._components.Tabs[id] = tab
        else
            warn("Failed to create tab:", id)
        end
    end
    
    return true
end

-- Safe notification system
function UI.Notify(title, content, duration)
    if not getgenv().Fluent then return end
    
    pcall(function()
        getgenv().Fluent:Notify({
            Title = title or "Notification",
            Content = content or "",
            Duration = duration or 3
        })
    end)
end

-- Section creation with error handling
function UI.CreateSection(tabName, sectionName)
    local tab = UI._components.Tabs and UI._components.Tabs[tabName]
    if not tab then return nil end
    
    local success, section = pcall(function()
        return tab:CreateSection(sectionName)
    end)
    
    return success and section or nil
end

-- Window control functions
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
    -- Verify dependencies first
    if not verifyDependencies() then
        return false
    end
    
    -- Create window
    local window = createWindow()
    if not window then
        return false
    end
    
    -- Store window reference
    UI._components.Window = window
    
    -- Create tabs
    if not createTabs(window) then
        return false
    end
    
    -- Initialize SaveManager if available
    if getgenv().SaveManager then
        pcall(function()
            getgenv().SaveManager:SetLibrary(getgenv().Fluent)
            getgenv().SaveManager:SetWindow(window)
            getgenv().SaveManager:Load(Config.WINDOW_SETTINGS.ConfigurationSaving.FileName)
        end)
    end
    
    -- Set up cleanup
    Services.Players.LocalPlayer.OnTeleport:Connect(function()
        pcall(function()
            if getgenv().SaveManager then
                getgenv().SaveManager:Save(Config.WINDOW_SETTINGS.ConfigurationSaving.FileName)
            end
            if UI._components.Window then
                UI._components.Window:Destroy()
            end
        end)
    end)
    
    UI._initialized = true
    UI._loaded = true
    return true
end

-- Module finalization
local success, result = pcall(initialize)

if success and result then
    getgenv().LucidUI = UI
    if getgenv().Config and getgenv().Config.Debug then
        print("✓ UI system initialized successfully")
    end
    return UI
else
    warn("⚠️ Failed to initialize UI system:", result)
    return false
end
