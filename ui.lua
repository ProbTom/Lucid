-- ui.lua
local UI = {
    _version = "1.0.1",
    _initialized = false,
    _window = nil,
    _tabs = {},
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
    Players = game:GetService("Players")
}

-- Initialize UI system
local function initializeUI()
    if not getgenv().Fluent then
        warn("Missing UI configuration")
        return false
    end

    -- Create main window
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

    -- Add main sections
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

    -- Add settings sections
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
    end

    -- Initialize InterfaceManager
    if getgenv().InterfaceManager then
        getgenv().InterfaceManager:SetLibrary(getgenv().Fluent)
        getgenv().InterfaceManager:SetFolder("LucidHub")
        getgenv().InterfaceManager:BuildInterfaceSection(UI._tabs.Settings)
    end

    return true
end

-- Initialize the UI module
local function initialize()
    if UI._initialized then
        return true
    end

    local success = pcall(initializeUI)
    if not success then
        warn("⚠️ Failed to initialize UI system:", success)
        return false
    end

    UI._initialized = true
    return true
end

-- Run initialization
local success = initialize()

if not success then
    warn("⚠️ Failed to initialize UI system:", success)
    return false
end

if getgenv().Config and getgenv().Config.Debug then
    print("✓ UI module initialized successfully")
end

return UI
