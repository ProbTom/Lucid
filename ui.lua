-- ui.lua
local UI = {
    _VERSION = "1.1.0",
    _initialized = false,
    LastUpdated = "2024-12-21"
}

-- Dependencies
local WindUI
local Debug
local Utils
local Functions

-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- UI Elements Storage
UI.Elements = {
    Window = nil,
    Tabs = {},
    Controls = {},
    Stats = {}
}

function UI.init(deps)
    if UI._initialized then return end
    
    WindUI = deps.windui or error("WindUI dependency missing")
    Debug = deps.debug or error("Debug dependency missing")
    Utils = deps.utils or error("Utils dependency missing")
    Functions = deps.functions or error("Functions dependency missing")

    -- Create main window
    UI.Elements.Window = WindUI:CreateWindow({
        Title = "Lucid Hub",
        Icon = "fish", -- Fishing theme icon
        Author = "ProbTom",
        Theme = "Dark",
        Folder = "LucidHub"
    })

    -- Initialize UI components
    UI:InitMainTab()
    UI:InitItemsTab()
    UI:InitSettingsTab()

    -- Set up window handlers
    UI:SetupWindowHandlers()

    UI._initialized = true
    Debug.Info("UI System Initialized")
    return true
end

function UI:InitMainTab()
    local MainTab = UI.Elements.Window:Tab({
        Title = "Fishing",
        Icon = "fish"
    })
    UI.Elements.Tabs.Main = MainTab

    -- Fishing Controls Section
    local FishingSection = MainTab:Section({
        Title = "Fishing Controls"
    })

    -- Auto Fish Toggle
    UI.Elements.Controls.AutoFish = FishingSection:Toggle({
        Title = "Auto Fish",
        Value = false,
        Callback = function(value)
            Functions.ToggleAutoFish(value)
        end
    })

    -- Auto Reel Toggle
    UI.Elements.Controls.AutoReel = FishingSection:Toggle({
        Title = "Auto Reel",
        Value = false,
        Callback = function(value)
            Functions.ToggleAutoReel(value)
        end
    })

    -- Auto Shake Toggle
    UI.Elements.Controls.AutoShake = FishingSection:Toggle({
        Title = "Auto Shake",
        Value = false,
        Callback = function(value)
            Functions.ToggleAutoShake(value)
        end
    })

    -- Cast Mode Dropdown
    UI.Elements.Controls.CastMode = FishingSection:Dropdown({
        Title = "Cast Mode",
        Values = {"Legit", "Instant"},
        Default = "Legit",
        Callback = function(value)
            getgenv().Options.CastMode = value
        end
    })

    -- Stats Section
    local StatsSection = MainTab:Section({
        Title = "Stats Tracker"
    })

    UI.Elements.Stats = {
        FishCaught = StatsSection:Label("Fish Caught: 0"),
        Coins = StatsSection:Label("Coins: 0"),
        CurrentRod = StatsSection:Label("Current Rod: None")
    }
end

function UI:InitItemsTab()
    local ItemsTab = UI.Elements.Window:Tab({
        Title = "Items",
        Icon = "package"
    })
    UI.Elements.Tabs.Items = ItemsTab

    -- Chest Collector Section
    local ChestSection = ItemsTab:Section({
        Title = "Chest Collector"
    })

    UI.Elements.Controls.ChestCollector = ChestSection:Toggle({
        Title = "Auto Collect Chests",
        Value = false,
        Callback = function(value)
            Functions.ToggleChestCollector(value)
        end
    })

    UI.Elements.Controls.ChestRange = ChestSection:Slider({
        Title = "Collection Range",
        Min = 10,
        Max = 100,
        Default = 50,
        Callback = function(value)
            getgenv().Options.Items.ChestCollector.Range = value
        end
    })

    -- Auto Sell Section
    local SellSection = ItemsTab:Section({
        Title = "Auto Sell"
    })

    UI.Elements.Controls.AutoSell = SellSection:Toggle({
        Title = "Auto Sell Items",
        Value = false,
        Callback = function(value)
            Functions.ToggleAutoSell(value)
        end
    })

    -- Rarity Settings
    local rarities = {
        "Common", "Uncommon", "Rare", "Epic", "Legendary", 
        "Mythical", "Enchant Relics", "Exotic", "Limited", "Gemstones"
    }

    for _, rarity in ipairs(rarities) do
        UI.Elements.Controls[rarity.."Sell"] = SellSection:Toggle({
            Title = "Sell "..rarity,
            Value = false,
            Callback = function(value)
                getgenv().Options.Items.AutoSell.Rarities[rarity] = value
            end
        })
    end
end

function UI:InitSettingsTab()
    local SettingsTab = UI.Elements.Window:Tab({
        Title = "Settings",
        Icon = "settings"
    })
    UI.Elements.Tabs.Settings = SettingsTab

    -- Theme Section
    local ThemeSection = SettingsTab:Section({
        Title = "Interface"
    })

    -- Get available themes
    local themes = {}
    for name, _ in pairs(WindUI:GetThemes()) do
        table.insert(themes, name)
    end

    UI.Elements.Controls.Theme = ThemeSection:Dropdown({
        Title = "Theme",
        Values = themes,
        Default = "Dark",
        Callback = function(theme)
            WindUI:SetTheme(theme)
            getgenv().Options.UI.Theme = theme
        end
    })

    -- Transparency Toggle
    UI.Elements.Controls.Transparency = ThemeSection:Toggle({
        Title = "Window Transparency",
        Value = false,
        Callback = function(value)
            UI.Elements.Window:ToggleTransparency(value)
            getgenv().Options.UI.Transparency = value and 0.5 or 0
        end
    })

    -- Settings Management
    local ConfigSection = SettingsTab:Section({
        Title = "Configuration"
    })

    ConfigSection:Button({
        Title = "Save Settings",
        Callback = function()
            Utils.SaveToFile("settings.json", getgenv().Options)
            UI:Notify("Settings Saved", "Your settings have been saved successfully.")
        end
    })

    ConfigSection:Button({
        Title = "Reset Settings",
        Callback = function()
            getgenv().Options = Utils.DeepCopy(require("options"))
            UI:UpdateAllControls()
            UI:Notify("Settings Reset", "All settings have been reset to default.")
        end
    })
end

function UI:SetupWindowHandlers()
    -- Keybind for toggling UI
    game:GetService("UserInputService").InputBegan:Connect(function(input)
        if input.KeyCode == getgenv().Options.UI.MinimizeKey then
            UI.Elements.Window:Minimize()
        end
    end)
end

function UI:UpdateStats(stats)
    if not UI._initialized then return end
    
    UI.Elements.Stats.FishCaught:SetText("Fish Caught: "..tostring(stats.fishCaught or 0))
    UI.Elements.Stats.Coins:SetText("Coins: "..tostring(stats.coins or 0))
    UI.Elements.Stats.CurrentRod:SetText("Current Rod: "..tostring(stats.currentRod or "None"))
end

function UI:UpdateAllControls()
    if not UI._initialized then return end
    
    local options = getgenv().Options
    
    -- Update main controls
    UI.Elements.Controls.AutoFish:SetValue(options.AutoFish)
    UI.Elements.Controls.AutoReel:SetValue(options.AutoReel)
    UI.Elements.Controls.AutoShake:SetValue(options.AutoShake)
    UI.Elements.Controls.CastMode:SetValue(options.CastMode)
    
    -- Update item controls
    UI.Elements.Controls.ChestCollector:SetValue(options.Items.ChestCollector.Enabled)
    UI.Elements.Controls.ChestRange:SetValue(options.Items.ChestCollector.Range)
    UI.Elements.Controls.AutoSell:SetValue(options.Items.AutoSell.Enabled)
    
    -- Update rarity toggles
    for rarity, enabled in pairs(options.Items.AutoSell.Rarities) do
        if UI.Elements.Controls[rarity.."Sell"] then
            UI.Elements.Controls[rarity.."Sell"]:SetValue(enabled)
        end
    end
    
    -- Update theme settings
    UI.Elements.Controls.Theme:SetValue(options.UI.Theme)
    UI.Elements.Controls.Transparency:SetValue(options.UI.Transparency > 0)
end

function UI:Notify(title, content, duration)
    if not UI._initialized then return end
    
    WindUI:Notify({
        Title = title,
        Content = content,
        Duration = duration or 5
    })
end

return UI
