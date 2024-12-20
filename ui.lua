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

local Debug = loadstring(game:HttpGet("https://raw.githubusercontent.com/ProbTom/Lucid/main/debug.lua"))()

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
        if getgenv().Fluent then
            Debug.Log("Fluent UI library loaded successfully.")
        else
            Debug.Error("Failed to load Fluent UI library.")
        end
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
        Debug.Log("UI window created successfully.")
    else
        Debug.Error("UI window already exists.")
    end
    return UI._window
end

-- Create main tabs with proper icons
function UI.CreateTabs()
    if not UI._window then
        Debug.Error("UI window not created. Cannot create tabs.")
        return
    end

    -- Main tab with fishing icon
    UI._tabs.Main = UI._window:AddTab({
        Title = "Main",
        Icon = UI._icons.main
    })
    Debug.Log("Main tab created.")

    -- Settings tab with proper gear icon
    UI._tabs.Settings = UI._window:AddTab({
        Title = "Settings",
        Icon = UI._icons.settings
    })
    Debug.Log("Settings tab created.")

    return UI._tabs
end

-- Create main sections
function UI.CreateMainSections()
    if not UI._tabs.Main then
        Debug.Error("Main tab not created. Cannot create sections.")
        return
    end

    local sections = {}
    
    -- Fishing Controls Section
    sections.Fishing = UI._tabs.Main:AddSection("Fishing Controls")
    Debug.Log("Fishing Controls section created.")
    
    -- Auto Cast Toggle
    sections.Fishing:AddToggle("AutoCast", {
        Title = "Auto Cast",
        Default = false,
        Callback = function(value)
            if getgenv().State then
                getgenv().State.AutoCasting = value
                Debug.Log("Auto Cast set to " .. tostring(value))
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
                Debug.Log("Auto Reel set to " .. tostring(value))
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
                Debug.Log("Auto Shake set to " .. tostring(value))
            end
        end
    })

    return sections
end

-- Initialize UI system
function UI.Initialize()
    if UI._initialized then
        Debug.Log("UI module already initialized.")
        return true
    end

    Debug.Log("Loading UI libraries.")
    if not loadUILibraries() then
        Debug.Error("Failed to load UI libraries.")
        return false
    end

    Debug.Log("Creating UI window.")
    UI.CreateWindow()
    Debug.Log("Creating UI tabs.")
    UI.CreateTabs()
    Debug.Log("Creating UI sections.")
    UI.CreateMainSections()

    UI._initialized = true
    Debug.Log("UI module initialized successfully.")
    
    return true
end

-- Cleanup function
function UI.Cleanup()
    for _, connection in pairs(UI._connections) do
        if typeof(connection) == "RBXScriptConnection" then
            connection:Disconnect()
            Debug.Log("Disconnected a connection.")
        end
    end
    UI._connections = {}
end

-- Run initialization
local success = UI.Initialize()

if not success then
    Debug.Error("Failed to initialize UI system")
end

-- Setup cleanup on teleport
game:GetService("Players").LocalPlayer.OnTeleport:Connect(function()
    UI.Cleanup()
    Debug.Log("UI cleanup on teleport.")
end)

return UI
