-- ui.lua
local UI = {
    _VERSION = "1.1.0",
    _initialized = false,
    LastUpdated = "2024-12-21"
}

local WindUI, MainWindow, Debug, Utils, Functions
local Tabs = {}

function UI.init(deps)
    if UI._initialized then return end
    
    WindUI = deps.windui or error("WindUI dependency missing")
    MainWindow = deps.window or error("MainWindow dependency missing")
    Debug = deps.debug or error("Debug dependency missing")
    Utils = deps.utils or error("Utils dependency missing")
    Functions = deps.functions or error("Functions dependency missing")
    
    -- Initialize UI Tabs
    UI:InitMainTab()
    UI:InitItemsTab()
    UI:InitSettingsTab()
    
    -- Set minimize keybind
    MainWindow:SetKey(getgenv().Settings.UI.MinimizeKey or Enum.KeyCode.RightControl)
    
    UI._initialized = true
    return true
end

function UI:InitMainTab()
    local MainTab = MainWindow:CreateTab({
        Name = "Main",
        Icon = "rbxassetid://7733960981"
    })
    
    -- Auto Fish Section
    local AutoFishSection = MainTab:CreateSection("Fishing")
    
    AutoFishSection:AddToggle({
        Name = "Auto Fish",
        Flag = "AutoFish",
        Default = getgenv().Settings.AutoFish,
        Callback = function(Value)
            Functions.ToggleAutoFish(Value)
        end
    })
    
    AutoFishSection:AddToggle({
        Name = "Auto Reel",
        Flag = "AutoReel",
        Default = getgenv().Settings.AutoReel,
        Callback = function(Value)
            Functions.ToggleAutoReel(Value)
        end
    })
    
    AutoFishSection:AddToggle({
        Name = "Auto Shake",
        Flag = "AutoShake",
        Default = getgenv().Settings.AutoShake,
        Callback = function(Value)
            Functions.ToggleAutoShake(Value)
        end
    })
    
    AutoFishSection:AddDropdown({
        Name = "Cast Mode",
        Flag = "CastMode",
        Default = getgenv().Settings.CastMode,
        Options = {"Legit", "Semi-Legit", "Instant"},
        Callback = function(Option)
            getgenv().Settings.CastMode = Option
            Debug.Info("Cast Mode set to: " .. Option)
        end
    })
    
    Tabs.Main = MainTab
end

function UI:InitItemsTab()
    local ItemsTab = MainWindow:CreateTab({
        Name = "Items",
        Icon = "rbxassetid://7734053495"
    })
    
    -- Chest Collector Section
    local ChestSection = ItemsTab:CreateSection("Chest Collector")
    
    ChestSection:AddToggle({
        Name = "Enable Chest Collector",
        Flag = "ChestCollector",
        Default = getgenv().Settings.Items.ChestCollector.Enabled,
        Callback = function(Value)
            Functions.ToggleChestCollector(Value)
        end
    })
    
    ChestSection:AddSlider({
        Name = "Collection Range",
        Flag = "ChestRange",
        Default = getgenv().Settings.Items.ChestCollector.Range,
        Min = 10,
        Max = 100,
        Increment = 5,
        Callback = function(Value)
            getgenv().Settings.Items.ChestCollector.Range = Value
        end
    })
    
    -- Auto Sell Section
    local SellSection = ItemsTab:CreateSection("Auto Sell")
    
    SellSection:AddToggle({
        Name = "Enable Auto Sell",
        Flag = "AutoSell",
        Default = getgenv().Settings.Items.AutoSell.Enabled,
        Callback = function(Value)
            Functions.ToggleAutoSell(Value)
        end
    })
    
    -- Rarity Toggles
    local rarities = {
        "Common",
        "Uncommon",
        "Rare",
        "Epic",
        "Legendary",
        "Mythical",
        "Enchant Relics",
        "Exotic",
        "Limited",
        "Gemstones"
    }
    
    for _, rarity in ipairs(rarities) do
        SellSection:AddToggle({
            Name = "Sell " .. rarity,
            Flag = "Sell" .. rarity:gsub("%s+", ""),
            Default = getgenv().Settings.Items.AutoSell.Rarities[rarity],
            Callback = function(Value)
                getgenv().Settings.Items.AutoSell.Rarities[rarity] = Value
            end
        })
    end
    
    Tabs.Items = ItemsTab
end

function UI:InitSettingsTab()
    local SettingsTab = MainWindow:CreateTab({
        Name = "Settings",
        Icon = "rbxassetid://7734039272"
    })
    
    local UISection = SettingsTab:CreateSection("UI Settings")
    
    UISection:AddDropdown({
        Name = "Theme",
        Flag = "Theme",
        Default = getgenv().Settings.UI.Theme,
        Options = {"Light", "Dark", "Mocha", "Aqua"},
        Callback = function(Value)
            getgenv().Settings.UI.Theme = Value
            MainWindow:ChangeTheme(Value)
        end
    })
    
    UISection:AddSlider({
        Name = "UI Transparency",
        Flag = "UITransparency",
        Default = getgenv().Settings.UI.Transparency,
        Min = 0,
        Max = 100,
        Increment = 5,
        Callback = function(Value)
            getgenv().Settings.UI.Transparency = Value
            MainWindow:SetTransparency(Value/100)
        end
    })
    
    UISection:AddKeybind({
        Name = "Toggle UI",
        Flag = "ToggleUI",
        Default = getgenv().Settings.UI.MinimizeKey,
        Callback = function(Key)
            getgenv().Settings.UI.MinimizeKey = Key
            MainWindow:SetKey(Key)
        end
    })
    
    local ConfigSection = SettingsTab:CreateSection("Configuration")
    
    ConfigSection:AddButton({
        Name = "Save Settings",
        Callback = function()
            if Utils.SaveSettings(getgenv().Settings) then
                Debug.Info("Settings saved successfully", true)
            else
                Debug.Warn("Failed to save settings", true)
            end
        end
    })
    
    ConfigSection:AddButton({
        Name = "Reset Settings",
        Callback = function()
            getgenv().Settings = Utils.DeepCopy(Options.DefaultSettings)
            Debug.Info("Settings reset to default", true)
            UI:RefreshUI()
        end
    })
    
    Tabs.Settings = SettingsTab
end

function UI:RefreshUI()
    -- Refresh all UI elements with current settings
    MainWindow:Destroy()
    UI:InitMainTab()
    UI:InitItemsTab()
    UI:InitSettingsTab()
end

return UI
