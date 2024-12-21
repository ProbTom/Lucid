-- main.lua
local function LoadLucid()
    local HttpService = game:GetService("HttpService")

    -- Initialize base structure
    local Lucid = {
        Name = "Lucid Hub",
        Version = "1.1.0",
        Author = "ProbTom",
        LastUpdated = "2024-12-21",
        Initialized = false
    }

    -- Create Window Library
    local Window = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/source.lua"))()

    if not Window then
        warn("[Lucid] Failed to load Window Library")
        return false
    end

    -- Create main window
    local MainWindow = Window:Create({
        Name = "Lucid Hub",
        Theme = "Dark",
        Size = UDim2.new(0, 555, 0, 400)
    })

    -- Create Tabs
    local MainTab = MainWindow:Tab("Main", "rbxassetid://7733960981")
    local ItemsTab = MainWindow:Tab("Items", "rbxassetid://7734053495")
    local SettingsTab = MainWindow:Tab("Settings", "rbxassetid://7734039272")

    -- Initialize sections
    local FishingSection = MainTab:Section("Fishing")
    
    -- Add toggles
    FishingSection:Toggle({
        Name = "Auto Fish",
        Default = false,
        Flag = "AutoFish",
        Callback = function(Value)
            print("Auto Fish:", Value)
        end
    })

    FishingSection:Toggle({
        Name = "Auto Reel",
        Default = false,
        Flag = "AutoReel",
        Callback = function(Value)
            print("Auto Reel:", Value)
        end
    })

    -- Add dropdowns
    FishingSection:Dropdown({
        Name = "Cast Mode",
        Default = "Legit",
        Options = {"Legit", "Semi-Legit", "Instant"},
        Flag = "CastMode",
        Callback = function(Value)
            print("Cast Mode:", Value)
        end
    })

    -- Items Tab
    local ChestSection = ItemsTab:Section("Chest Collector")
    
    ChestSection:Toggle({
        Name = "Enable Chest Collector",
        Default = false,
        Flag = "ChestCollector",
        Callback = function(Value)
            print("Chest Collector:", Value)
        end
    })

    ChestSection:Slider({
        Name = "Collection Range",
        Default = 50,
        Min = 10,
        Max = 100,
        Increment = 5,
        Flag = "ChestRange",
        Callback = function(Value)
            print("Chest Range:", Value)
        end
    })

    -- Settings Tab
    local SettingsSection = SettingsTab:Section("Settings")

    SettingsSection:Dropdown({
        Name = "Theme",
        Default = "Dark",
        Options = {"Light", "Dark", "Mocha", "Aqua"},
        Flag = "Theme",
        Callback = function(Value)
            MainWindow:ChangeTheme(Value)
        end
    })

    SettingsSection:Button({
        Name = "Save Settings",
        Callback = function()
            local settings = Window:GetSettings()
            writefile("LucidHub/settings.json", HttpService:JSONEncode(settings))
        end
    })

    -- Initialize settings folder
    if not isfolder("LucidHub") then
        makefolder("LucidHub")
    end

    -- Load settings if they exist
    if isfile("LucidHub/settings.json") then
        local success, settings = pcall(function()
            return HttpService:JSONDecode(readfile("LucidHub/settings.json"))
        end)
        if success and settings then
            Window:LoadSettings(settings)
        end
    end

    -- Auto-save settings
    spawn(function()
        while wait(30) do
            local settings = Window:GetSettings()
            writefile("LucidHub/settings.json", HttpService:JSONEncode(settings))
        end
    end)

    -- Store in global environment
    getgenv().Lucid = Lucid
    getgenv().Window = Window
    
    Lucid.Window = Window
    Lucid.MainWindow = MainWindow
    Lucid.Initialized = true

    return true
end

-- Execute with protected call
local success, result = pcall(LoadLucid)
if not success then
    warn("[Lucid] Critical error during initialization:", result)
end

return getgenv().Lucid
