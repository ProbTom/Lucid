-- ui.lua
-- Core UI Module for Lucid Hub
local UI = {
    _version = "1.0.1",
    _initialized = false,
    _components = {}
}

-- Protection against multiple initializations
if getgenv().LucidUI then
    return getgenv().LucidUI
end

-- Core services with protection
local Services = {
    Players = game:GetService("Players"),
    CoreGui = game:GetService("CoreGui")
}

-- Configuration constants with required fields
local Config = {
    WINDOW = {
        Name = "Lucid Hub",
        Title = "Lucid Hub", -- Required
        LoadingTitle = "Lucid Hub", -- Required
        SubTitle = "by ProbTom", -- Required
        LoadingSubtitle = "by ProbTom", -- Required
        TabWidth = 160,
        Size = UDim2.fromOffset(580, 460),
        Theme = "Dark",
        ConfigurationSaving = {
            Enabled = true,
            FolderName = "LucidHub",
            FileName = "Config"
        }
    },
    TABS = {
        {Name = "Home", Icon = "home"},
        {Name = "Main", Icon = "list"},
        {Name = "Items", Icon = "package"},
        {Name = "Teleports", Icon = "map-pin"},
        {Name = "Misc", Icon = "file-text"},
        {Name = "Trade", Icon = "gift"},
        {Name = "Credit", Icon = "heart"}
    }
}

-- Dependency verification
local function verifyDependencies()
    if not getgenv or not getgenv().Fluent then
        warn("Critical dependency missing: Fluent UI Library")
        return false
    end

    if not Services.Players.LocalPlayer then
        warn("LocalPlayer not available")
        return false
    end

    return true
end

-- Create window with mandatory parameters
local function createWindow()
    if not getgenv().Fluent then return nil end

    -- Use pcall to catch any errors
    local success, window = pcall(function()
        -- Create window with all required parameters
        return getgenv().Fluent:CreateWindow({
            Name = Config.WINDOW.Name,           -- Required
            Title = Config.WINDOW.Title,         -- Required
            SubTitle = Config.WINDOW.SubTitle,   -- Required
            TabWidth = Config.WINDOW.TabWidth,
            Size = Config.WINDOW.Size,
            Theme = Config.WINDOW.Theme,
            ConfigurationSaving = Config.WINDOW.ConfigurationSaving
        })
    end)

    if not success or not window then
        warn("Failed to create window:", tostring(window))
        return nil
    end

    return window
end

-- Create tabs with proper error handling
local function createTabs(window)
    if not window then return false end
    
    UI._components.Tabs = {}
    
    for _, tabInfo in ipairs(Config.TABS) do
        -- Use pcall for tab creation
        local success, tab = pcall(function()
            return window:AddTab({
                Name = tabInfo.Name,    -- Required
                Title = tabInfo.Name,   -- Required
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

-- Core initialization
local function initialize()
    if UI._initialized then
        return true
    end

    if not verifyDependencies() then
        return false
    end

    -- Create window
    local window = createWindow()
    if not window then
        return false
    end

    -- Store window references
    UI._components.Window = window
    getgenv().Window = window
    getgenv().LucidWindow = window  -- For compatibility

    -- Create tabs
    if not createTabs(window) then
        return false
    end

    -- Initialize SaveManager if available
    if getgenv().SaveManager then
        pcall(function()
            getgenv().SaveManager:SetLibrary(getgenv().Fluent)
            getgenv().SaveManager:SetWindow(window)
            getgenv().SaveManager:Load(Config.WINDOW.ConfigurationSaving.FileName)
        end)
    end

    -- Setup cleanup
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
    return true
end

-- Public interface
function UI.GetWindow()
    return UI._components.Window
end

function UI.GetTab(name)
    return UI._components.Tabs and UI._components.Tabs[name]
end

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

-- Run initialization with proper error handling
local success, result = pcall(initialize)

if success and result then
    getgenv().LucidUI = UI
    return UI
else
    warn("⚠️ Failed to initialize UI system:", tostring(result))
    return false
end
