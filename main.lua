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

    -- Load the correct WindUI Library
    local Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/wind'))()

    if not Library then
        warn("[Lucid] Failed to load Library")
        return false
    }

    -- Create Window with correct API
    local MainWindow = Library.CreateLib("Lucid Hub", "Ocean")

    -- Create Tabs using correct API
    local MainTab = MainWindow:NewTab("Main")
    local MainSection = MainTab:NewSection("Fishing")

    -- Add toggles with correct API
    MainSection:NewToggle("Auto Fish", "Toggles auto fishing", function(state)
        getgenv().Settings.AutoFish = state
    end)

    MainSection:NewToggle("Auto Reel", "Toggles auto reeling", function(state)
        getgenv().Settings.AutoReel = state
    end)

    MainSection:NewToggle("Auto Shake", "Toggles auto shaking", function(state)
        getgenv().Settings.AutoShake = state
    end)

    MainSection:NewDropdown("Cast Mode", "Select casting mode", {"Legit", "Semi-Legit", "Instant"}, function(currentOption)
        getgenv().Settings.CastMode = currentOption
    end)

    -- Items Tab
    local ItemsTab = MainWindow:NewTab("Items")
    local ChestSection = ItemsTab:NewSection("Chest Collector")

    ChestSection:NewToggle("Enable Chest Collector", "Toggles chest collector", function(state)
        getgenv().Settings.Items.ChestCollector.Enabled = state
    end)

    ChestSection:NewSlider("Collection Range", "Adjust collection range", 100, 10, function(value)
        getgenv().Settings.Items.ChestCollector.Range = value
    end)

    -- Settings Tab
    local SettingsTab = MainWindow:NewTab("Settings")
    local SettingsSection = SettingsTab:NewSection("Settings")

    SettingsSection:NewKeybind("Toggle UI", "Toggle the UI visibility", Enum.KeyCode.RightControl, function()
        Library:ToggleUI()
    end)

    -- Initialize settings
    getgenv().Settings = {
        AutoFish = false,
        AutoReel = false,
        AutoShake = false,
        CastMode = "Legit",
        Items = {
            ChestCollector = {
                Enabled = false,
                Range = 50
            },
            AutoSell = {
                Enabled = false,
                Rarities = {}
            }
        }
    }

    -- Create settings folder
    if not isfolder("LucidHub") then
        makefolder("LucidHub")
    end

    -- Load settings if they exist
    if isfile("LucidHub/settings.json") then
        local success, loadedSettings = pcall(function()
            return HttpService:JSONDecode(readfile("LucidHub/settings.json"))
        end)
        if success and loadedSettings then
            getgenv().Settings = loadedSettings
        end
    end

    -- Auto-save settings
    spawn(function()
        while wait(30) do
            if getgenv().Settings then
                pcall(function()
                    writefile("LucidHub/settings.json", 
                        HttpService:JSONEncode(getgenv().Settings)
                    )
                end)
            end
        end
    end)

    -- Store references
    Lucid.Library = Library
    Lucid.MainWindow = MainWindow
    Lucid.Initialized = true

    getgenv().Lucid = Lucid

    return true
end

-- Execute with protected call
local success, result = pcall(LoadLucid)
if not success then
    warn("[Lucid] Critical error during initialization:", result)
end

return getgenv().Lucid
