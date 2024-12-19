-- ui.lua
-- Core UI Module for Lucid Hub
local UI = {
    _loaded = false,
    _components = {},
    _cache = {},
    _initialized = false,
    _version = "1.0.1"
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

-- Window Configuration based on Fluent documentation
local Config = {
    Window = {
        -- Required fields per Fluent documentation
        Title = "Lucid Hub",
        SubTitle = "v1.0.1",
        Icon = "rbxassetid://10723424505", -- Default icon
        ButtonColor = Color3.fromRGB(0, 120, 215),
        TabWidth = 160,
        UseAcrylic = true,
        MinimizeKey = Enum.KeyCode.RightControl
    },
    SaveConfig = {
        Enabled = true,
        FolderName = "LucidHub",
        FileName = "Config"
    },
    Tabs = {
        {
            Title = "Main",
            Icon = "rbxassetid://10723424505"
        },
        {
            Title = "Items",
            Icon = "rbxassetid://10723406110"
        },
        {
            Title = "Settings",
            Icon = "rbxassetid://10734898962"
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

    return true
end

-- Create window with correct parameters
local function createWindow()
    if not getgenv().Fluent then return nil end
    
    local success, window = pcall(function()
        -- Create window using exact parameter structure from Fluent docs
        return getgenv().Fluent:CreateWindow({
            Title = Config.Window.Title,
            SubTitle = Config.Window.SubTitle,
            Icon = Config.Window.Icon,
            ButtonColor = Config.Window.ButtonColor,
            TabWidth = Config.Window.TabWidth,
            UseAcrylic = Config.Window.UseAcrylic,
            MinimizeKey = Config.Window.MinimizeKey,
            SaveConfiguration = Config.SaveConfig
        })
    end)

    if not success or not window then
        warn("Window creation failed:", tostring(window))
        return nil
    end

    return window
end

-- Create tabs with proper parameters
local function createTabs(window)
    if not window then return false end
    
    UI._components.Tabs = {}
    
    for _, tabInfo in ipairs(Config.Tabs) do
        local success, tab = pcall(function()
            return window:AddTab({
                Title = tabInfo.Title,
                Icon = tabInfo.Icon
            })
        end)
        
        if success and tab then
            UI._components.Tabs[tabInfo.Title] = tab
        else
            warn("Failed to create tab:", tabInfo.Title)
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

function UI.CreateSection(tab, name)
    if not tab then return nil end
    
    local success, section = pcall(function()
        return tab:AddSection(name)
    end)
    
    return success and section or nil
end

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

-- Initialize UI system
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
    
    -- Set up SaveManager if available
    if getgenv().SaveManager then
        pcall(function()
            getgenv().SaveManager:SetLibrary(getgenv().Fluent)
            getgenv().SaveManager:SetWindow(window)
            getgenv().SaveManager:Load(Config.SaveConfig.FileName)
        end)
    end
    
    -- Set up cleanup
    Services.Players.LocalPlayer.OnTeleport:Connect(function()
        pcall(function()
            if getgenv().SaveManager then
                getgenv().SaveManager:Save(Config.SaveConfig.FileName)
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

-- Run initialization with proper error handling
local success, result = pcall(initialize)

if success and result then
    getgenv().LucidUI = UI
    return UI
else
    warn("⚠️ Failed to initialize UI system:", tostring(result))
    return false
end
