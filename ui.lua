-- ui.lua
local UI = {
    _version = "1.0.1",
    _initialized = false,
    _window = nil,
    _tabs = {},
    _connections = {},
    _config = {
        Title = "Lucid Hub",
        SubTitle = "by ProbTom",
        TabWidth = 160,
        Size = UDim2.fromOffset(600, 400),
        Theme = "Dark",
        MinimizeKeybind = Enum.KeyCode.LeftControl
    }
}

-- Core services
local Services = {
    Players = game:GetService("Players"),
    HttpService = game:GetService("HttpService")
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

    -- Load Fluent UI if not already loaded
    if not getgenv().Fluent then
        getgenv().Fluent = fetchLibrary("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua", 3)
    end

    -- Load UI addons
    if not getgenv().SaveManager then
        getgenv().SaveManager = fetchLibrary("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua", 3)
    end

    if not getgenv().InterfaceManager then
        getgenv().InterfaceManager = fetchLibrary("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua", 3)
    end

    return getgenv().Fluent ~= nil
end

-- Create main window and tabs
local function createMainWindow()
    UI._window = getgenv().Fluent:CreateWindow({
        Title = UI._config.Title,
        SubTitle = UI._config.SubTitle,
        TabWidth = UI._config.TabWidth,
        Size = UI._config.Size,
        Theme = UI._config.Theme,
        MinimizeKeybind = UI._config.MinimizeKeybind
    })

    -- Create main tabs
    UI._tabs.Main = UI._window:AddTab({ Title = "Main", Icon = "rbxassetid://10723424505" })
    UI._tabs.Settings = UI._window:AddTab({ Title = "Settings", Icon = "rbxassetid://10734931430" })

    return true
end

-- Create main sections and elements
local function createMainSections()
    -- Fishing section
    local fishingSection = UI._tabs.Main:AddSection("Fishing")
    
    local autoFishToggle = fishingSection:AddToggle("AutoFish", {
        Title = "Auto Fish",
        Default = false,
        Callback = function(value)
            if getgenv().State then
                getgenv().State.AutoFishing = value
            end
        end
    })

    local autoSellToggle = fishingSection:AddToggle("AutoSell", {
        Title = "Auto Sell",
        Default = false,
        Callback = function(value)
            if getgenv().State then
                getgenv().State.AutoSelling = value
            end
        end
    })

    -- Settings section
    local configSection = UI._tabs.Settings:AddSection("Configuration")
    
    local debugToggle = configSection:AddToggle("DebugMode", {
        Title = "Debug Mode",
        Default = true,
        Callback = function(value)
            if getgenv().Config then
                getgenv().Config.Debug = value
            end
        end
    })

    -- Initialize SaveManager
    if getgenv().SaveManager then
        getgenv().SaveManager:SetLibrary(getgenv().Fluent)
        getgenv().SaveManager:SetFolder("LucidHub")
        getgenv().SaveManager:BuildConfigSection(UI._tabs.Settings)
        getgenv().SaveManager:Load("auto")
    end

    -- Initialize InterfaceManager
    if getgenv().InterfaceManager then
        getgenv().InterfaceManager:SetLibrary(getgenv().Fluent)
        getgenv().InterfaceManager:SetFolder("LucidHub")
        getgenv().InterfaceManager:BuildInterfaceSection(UI._tabs.Settings)
    end

    return true
end

-- Initialize UI system
local function initializeUI()
    if not loadUILibraries() then
        warn("Failed to load UI libraries")
        return false
    end

    if not createMainWindow() then
        warn("Failed to create main window")
        return false
    end

    if not createMainSections() then
        warn("Failed to create UI sections")
        return false
    end

    return true
end

-- Main initialization
local function initialize()
    if UI._initialized then
        return true
    end

    local success = pcall(initializeUI)
    if not success then
        warn("⚠️ Failed to initialize UI system")
        return false
    end

    UI._initialized = true
    
    if getgenv().Config and getgenv().Config.Debug then
        print("✓ UI module initialized successfully")
    end
    
    return true
end

-- Cleanup function
function UI.Cleanup()
    if getgenv().SaveManager then
        getgenv().SaveManager:Save("auto")
    end
    
    for _, connection in pairs(UI._connections) do
        if typeof(connection) == "RBXScriptConnection" then
            connection:Disconnect()
        end
    end
    UI._connections = {}
end

-- Run initialization
local success = initialize()

if not success then
    warn("⚠️ Failed to initialize UI system")
    return false
end

-- Setup cleanup on teleport
game:GetService("Players").LocalPlayer.OnTeleport:Connect(function()
    UI.Cleanup()
end)

return UI
