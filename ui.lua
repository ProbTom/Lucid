-- ui.lua
-- Core UI Module for Lucid Hub
if getgenv().LucidUI then
    return getgenv().LucidUI
end

local UI = {
    _version = "1.0.1",
    _initialized = false,
    _components = {}
}

-- Core services
local Services = {
    Players = game:GetService("Players"),
    CoreGui = game:GetService("CoreGui"),
    RunService = game:GetService("RunService")
}

-- Verify environment and dependencies
local function verifyEnvironment()
    -- Check for required globals
    if not getgenv or not getgenv().Config then
        warn("Missing required global: Config")
        return false
    end

    if not getgenv().Fluent then
        warn("Missing required dependency: Fluent UI")
        return false
    end

    -- Verify services
    for name, service in pairs(Services) do
        if not service then
            warn("Required service missing:", name)
            return false
        end
    end

    return true
end

-- Create window with all required parameters
local function createWindow()
    if not getgenv().Fluent then return nil end

    local Config = getgenv().Config
    if not Config or not Config.UI or not Config.UI.Window then
        warn("Missing UI configuration")
        return nil
    end

    local success, window = pcall(function()
        return getgenv().Fluent:CreateWindow({
            -- Required parameters
            Name = Config.UI.Window.Name,
            Title = Config.UI.Window.Title,
            SubTitle = Config.UI.Window.SubTitle,
            LoadingTitle = Config.UI.Window.LoadingTitle,
            LoadingSubtitle = Config.UI.Window.LoadingSubtitle,
            
            -- Optional parameters
            TabWidth = Config.UI.Window.TabWidth,
            Size = Config.UI.Window.Size,
            Theme = Config.UI.Window.Theme,
            MinimizeKey = Config.UI.Window.MinimizeKey,
            
            -- Save configuration
            ConfigurationSaving = {
                Enabled = Config.Save.Enabled,
                FolderName = Config.Save.FolderName,
                FileName = Config.Save.FileName
            }
        })
    end)

    if not success or not window then
        warn("Failed to create window:", tostring(window))
        return nil
    end

    return window
end

-- Create tabs with comprehensive error handling
local function createTabs(window)
    if not window then return false end
    
    local Config = getgenv().Config
    if not Config or not Config.UI or not Config.UI.Tabs then
        warn("Missing tab configuration")
        return false
    end
    
    UI._components.Tabs = {}
    
    for _, tabInfo in ipairs(Config.UI.Tabs) do
        local success, tab = pcall(function()
            return window:AddTab({
                Title = tabInfo.Name,
                Icon = tabInfo.Icon
            })
        end)
        
        if success and tab then
            UI._components.Tabs[tabInfo.Name] = tab
        else
            warn("Failed to create tab:", tabInfo.Name)
        end
    end
    
    return true
end

-- Public interface
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

function UI.GetWindow()
    return UI._components.Window
end

function UI.GetTab(name)
    return UI._components.Tabs and UI._components.Tabs[name]
end

function UI.CreateSection(tabName, sectionName)
    local tab = UI._components.Tabs and UI._components.Tabs[tabName]
    if not tab then return nil end
    
    local success, section = pcall(function()
        return tab:CreateSection(sectionName)
    end)
    
    return success and section or nil
end

-- Initialize UI system
local function initialize()
    if UI._initialized then
        return true
    end

    if not verifyEnvironment() then
        return false
    end

    local window = createWindow()
    if not window then
        return false
    end

    -- Store window references
    UI._components.Window = window
    getgenv().Window = window
    getgenv().LucidWindow = window

    if not createTabs(window) then
        return false
    end

    -- Initialize SaveManager
    if getgenv().SaveManager then
        pcall(function()
            getgenv().SaveManager:SetLibrary(getgenv().Fluent)
            getgenv().SaveManager:SetWindow(window)
            getgenv().SaveManager:Load(getgenv().Config.Save.FileName)
        end)
    end

    -- Setup cleanup
    Services.Players.LocalPlayer.OnTeleport:Connect(function()
        pcall(function()
            if getgenv().SaveManager then
                getgenv().SaveManager:Save(getgenv().Config.Save.FileName)
            end
            if UI._components.Window then
                UI._components.Window:Destroy()
            end
        end)
    end)

    UI._initialized = true
    return true
end

-- Run initialization with proper error handling
local success, result = pcall(initialize)

if success and result then
    getgenv().LucidUI = UI
    return UI
else
    warn("⚠️ Failed to initialize UI system:", tostring(result))
    return false
end
