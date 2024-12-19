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

-- Window Configuration - Updated with all required fields
local Config = {
    WINDOW = {
        Title = "Lucid Hub", -- Required field
        SubTitle = "v1.0.1", -- Required field
        TabWidth = 160,
        Size = Vector2.new(550, 350),
        UseAcrylic = true,
        Theme = "Dark",
        MinimizeKey = Enum.KeyCode.RightShift,
        MinimizeKeybind = "RightShift", -- Backup format
        ConfigurationSaving = {
            Enabled = true,
            FolderName = "LucidHub",
            FileName = "Config"
        },
        Discord = {
            Enabled = false,
            Invite = "discord.gg/example"
        },
        KeySystem = false
    },
    TABS = {
        Main = {
            Title = "Main",
            Icon = "rbxassetid://4483345998"
        },
        Items = {
            Title = "Items",
            Icon = "rbxassetid://4483345998"
        },
        Settings = {
            Title = "Settings",
            Icon = "rbxassetid://4483345998"
        }
    }
}

-- Dependency verification
local function verifyDependencies()
    if not getgenv or not getgenv().Fluent then
        warn("Critical dependency missing: Fluent UI Library")
        return false
    end

    for name, service in pairs(Services) do
        if not service then
            warn("Required service missing:", name)
            return false
        end
    end

    if not Services.Players.LocalPlayer then
        warn("LocalPlayer not available")
        return false
    end

    return true
end

-- Safe window creation with all required parameters
local function createWindow()
    if not getgenv().Fluent then
        return nil
    end

    local success, window = pcall(function()
        return getgenv().Fluent:CreateWindow({
            -- Required parameters
            Title = Config.WINDOW.Title,
            SubTitle = Config.WINDOW.SubTitle,
            TabWidth = Config.WINDOW.TabWidth,
            Size = Config.WINDOW.Size,
            
            -- Window configuration
            Acrylic = Config.WINDOW.UseAcrylic,
            Theme = Config.WINDOW.Theme,
            MinimizeKey = Config.WINDOW.MinimizeKey,
            MinimizeKeybind = Config.WINDOW.MinimizeKeybind,
            
            -- Additional configurations
            ConfigurationSaving = Config.WINDOW.ConfigurationSaving,
            Discord = Config.WINDOW.Discord,
            KeySystem = Config.WINDOW.KeySystem
        })
    end)

    if not success or not window then
        warn("Failed to create window:", tostring(window))
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
            return window:CreateTab({
                Title = info.Title,
                Icon = info.Icon
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
    if not verifyDependencies() then
        return false
    end
    
    local window = createWindow()
    if not window then
        return false
    end
    
    UI._components.Window = window
    
    if not createTabs(window) then
        return false
    end
    
    if getgenv().SaveManager then
        pcall(function()
            getgenv().SaveManager:SetLibrary(getgenv().Fluent)
            getgenv().SaveManager:SetWindow(window)
            getgenv().SaveManager:Load(Config.WINDOW.ConfigurationSaving.FileName)
        end)
    end
    
    Services.Players.LocalPlayer.OnTeleport:Connect(function()
        pcall(function()
            if getgenv().SaveManager then
                getgenv().SaveManager:Save(Config.WINDOW.ConfigurationSaving.FileName)
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

-- Run initialization with error handling
local success, result = pcall(initialize)

if success and result then
    getgenv().LucidUI = UI
    if getgenv().Config and getgenv().Config.Debug then
        print("✓ UI system initialized successfully")
    end
    return UI
else
    warn("⚠️ Failed to initialize UI system:", tostring(result))
    return false
end
