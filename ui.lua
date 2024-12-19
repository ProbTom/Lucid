-- ui.lua
local UI = {
    _version = "1.0.1",
    _initialized = false,
    _window = nil,
    _tabs = {},
    _connections = {},
    _icons = {
        main = "rbxassetid://10723424505",
        settings = "rbxassetid://10734931430"
    }
}

-- Core services
local Services = {
    Players = game:GetService("Players"),
    HttpService = game:GetService("HttpService")
}

-- UI Configuration
local UIConfig = {
    Title = "Lucid Hub",
    SubTitle = "by ProbTom",
    TabWidth = 160,
    Size = UDim2.fromOffset(600, 400),
    Theme = "Dark",
    MinimizeKeybind = Enum.KeyCode.LeftControl
}

-- Load required UI libraries
local function loadUILibraries()
    local function fetchLibrary(url, retries)
        for i = 1, retries do
            local success, result = pcall(function()
                return loadstring(game:HttpGet(url))()
            end)
            if success and result then
                return result
            end
            task.wait(1)
        end
        return nil
    end

    if not getgenv().Fluent then
        getgenv().Fluent = fetchLibrary("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua", 3)
    end

    return getgenv().Fluent ~= nil
end

-- Create main window and tabs
function UI.CreateWindow()
    if not UI._window then
        UI._window = getgenv().Fluent:CreateWindow({
            Title = UIConfig.Title,
            SubTitle = UIConfig.SubTitle,
            TabWidth = UIConfig.TabWidth,
            Size = UIConfig.Size,
            Theme = UIConfig.Theme,
            MinimizeKeybind = UIConfig.MinimizeKeybind
        })
    end
    return UI._window
end

-- Create main tabs with proper icons
function UI.CreateTabs()
    -- Main tab with fishing icon
    UI._tabs.Main = UI._window:AddTab({
        Title = "Main",
        Icon = UI._icons.main
    })

    -- Settings tab with proper gear icon
    UI._tabs.Settings = UI._window:AddTab({
        Title = "Settings",
        Icon = UI._icons.settings
    })

    return UI._tabs
end

-- Create main sections
function UI.CreateMainSections()
    local sections = {}
    
    -- Fishing Controls Section
    sections.Fishing = UI._tabs.Main:AddSection("Fishing Controls")
    
    -- Auto Cast Toggle
    sections.Fishing:AddToggle("AutoCast", {
        Title = "Auto Cast",
        Default = false,
        Callback = function(value)
            if getgenv().State then
                getgenv().State.AutoCasting = value
            end
        end
    })

    -- Auto Reel Toggle
    sections.Fishing:AddToggle("AutoReel", {
        Title = "Auto Reel",
        Default = false,
        Callback = function(value)
            if getgenv().State then
                getgenv().State.AutoReeling = value
            end
        end
    })

    -- Auto Shake Toggle
    sections.Fishing:AddToggle("AutoShake", {
        Title = "Auto Shake",
        Default = false,
        Callback = function(value)
            if getgenv().State then
                getgenv().State.AutoShaking = value
            end
        end
    })

    return sections
end

-- Initialize UI system
function UI.Initialize()
    if UI._initialized then
        return true
    end

    if not loadUILibraries() then
        warn("Failed to load UI libraries")
        return false
    end

    UI.CreateWindow()
    UI.CreateTabs()
    UI.CreateMainSections()

    UI._initialized = true
    
    if getgenv().Config and getgenv().Config.Debug then
        print("✓ UI module initialized successfully")
    end
    
    return true
end

-- Cleanup function
function UI.Cleanup()
    for _, connection in pairs(UI._connections) do
        if typeof(connection) == "RBXScriptConnection" then
            connection:Disconnect()
        end
    end
    UI._connections = {}
end

-- Run initialization
local success = UI.Initialize()

if not success then
    warn("⚠️ Failed to initialize UI system")
end

-- Setup cleanup on teleport
game:GetService("Players").LocalPlayer.OnTeleport:Connect(function()
    UI.Cleanup()
end)

return UI
