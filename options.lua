-- options.lua
local Options = {
    _VERSION = "1.1.0",
    _initialized = false
}

local WindUI
local Debug
local Utils
local Functions

-- Default settings
local defaultOptions = {
    AutoFish = false,
    AutoCast = false,
    AutoReel = false,
    AutoShake = false,
    CastMode = "Legit",
    ReelMode = "Legit",
    ZoneCast = false,
    SelectedZone = "None",

    Items = {
        ChestCollector = {
            Enabled = false,
            Range = 50
        },
        AutoSell = {
            Enabled = false,
            Rarities = {
                Common = true,
                Uncommon = false,
                Rare = false,
                Epic = false,
                Legendary = false,
                Mythical = false,
                ["Enchant Relics"] = false,
                Exotic = false,
                Limited = false,
                Gemstones = false
            }
        },
        RodManager = {
            AutoEquipBest = false,
            LastEquipped = nil
        }
    },

    UI = {
        SaveSettings = true,
        LoadSettings = true,
        Theme = "Dark",
        Transparency = 0,
        MinimizeKey = Enum.KeyCode.RightControl
    }
}

-- Initialize options handler
function Options.init(deps)
    if Options._initialized then return end
    
    WindUI = deps.windui
    Debug = deps.debug
    Utils = deps.utils
    Functions = deps.functions

    -- Create window
    Options.Window = WindUI:CreateWindow({
        Title = "Lucid Hub",
        Icon = "fish", -- Fishing theme icon
        Author = "ProbTom",
        Theme = Options.UI.Theme,
        Folder = "LucidHub"
    })

    -- Initialize tabs
    Options:InitMainTab()
    Options:InitItemsTab()
    Options:InitSettingsTab()

    -- Load saved settings
    Options:LoadSettings()
    
    Options._initialized = true
    return true
end

function Options:InitMainTab()
    local MainTab = Options.Window:Tab({
        Title = "Fishing",
        Icon = "fish"
    })

    -- Fishing Controls
    local FishingSection = MainTab:Section({ Title = "Fishing Controls" })

    -- Auto Fish Toggle
    Options.Controls = {}
    Options.Controls.AutoFish = FishingSection:Toggle({
        Title = "Auto Fish",
        Value = Options.AutoFish,
        Callback = function(value)
            Options.AutoFish = value
            Functions.ToggleAutoFish(value)
        end
    })

    -- Auto Reel Toggle
    Options.Controls.AutoReel = FishingSection:Toggle({
        Title = "Auto Reel",
        Value = Options.AutoReel,
        Callback = function(value)
            Options.AutoReel = value
            Functions.ToggleAutoReel(value)
        end
    })

    -- Auto Shake Toggle
    Options.Controls.AutoShake = FishingSection:Toggle({
        Title = "Auto Shake",
        Value = Options.AutoShake,
        Callback = function(value)
            Options.AutoShake = value
            Functions.ToggleAutoShake(value)
        end
    })

    -- Cast Mode Dropdown
    Options.Controls.CastMode = FishingSection:Dropdown({
        Title = "Cast Mode",
        Values = {"Legit", "Instant"},
        Default = Options.CastMode,
        Callback = function(value)
            Options.CastMode = value
        end
    })

    -- Stats Section
    local StatsSection = MainTab:Section({ Title = "Stats" })
    
    Options.Stats = {
        FishCaught = StatsSection:Label("Fish Caught: 0"),
        Coins = StatsSection:Label("Coins: 0"),
        CurrentRod = StatsSection:Label("Current Rod: None")
    }
end

function Options:InitItemsTab()
    local ItemsTab = Options.Window:Tab({
        Title = "Items",
        Icon = "package"
    })

    -- Chest Collector Section
    local ChestSection = ItemsTab:Section({ Title = "Chest Collector" })

    Options.Controls.ChestCollector = ChestSection:Toggle({
        Title = "Auto Collect Chests",
        Value = Options.Items.ChestCollector.Enabled,
        Callback = function(value)
            Options.Items.ChestCollector.Enabled = value
            Functions.ToggleChestCollector(value)
        end
    })

    Options.Controls.ChestRange = ChestSection:Slider({
        Title = "Collection Range",
        Min = 10,
        Max = 100,
        Value = Options.Items.ChestCollector.Range,
        Callback = function(value)
            Options.Items.ChestCollector.Range = value
        end
    })

    -- Auto Sell Section
    local SellSection = ItemsTab:Section({ Title = "Auto Sell" })

    Options.Controls.AutoSell = SellSection:Toggle({
        Title = "Auto Sell Items",
        Value = Options.Items.AutoSell.Enabled,
        Callback = function(value)
            Options.Items.AutoSell.Enabled = value
            Functions.ToggleAutoSell(value)
        end
    })

    -- Rarity Settings
    local rarities = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythical", "Enchant Relics", "Exotic", "Limited", "Gemstones"}
    for _, rarity in ipairs(rarities) do
        Options.Controls[rarity.."Sell"] = SellSection:Toggle({
            Title = "Sell "..rarity,
            Value = Options.Items.AutoSell.Rarities[rarity],
            Callback = function(value)
                Options.Items.AutoSell.Rarities[rarity] = value
            end
        })
    end
end

function Options:InitSettingsTab()
    local SettingsTab = Options.Window:Tab({
        Title = "Settings",
        Icon = "settings"
    })

    -- Theme Section
    local ThemeSection = SettingsTab:Section({ Title = "Interface" })

    local themes = {}
    for name, _ in pairs(WindUI:GetThemes()) do
        table.insert(themes, name)
    end

    ThemeSection:Dropdown({
        Title = "Theme",
        Values = themes,
        Default = Options.UI.Theme,
        Callback = function(theme)
            Options.UI.Theme = theme
            WindUI:SetTheme(theme)
            Options:SaveSettings()
        end
    })

    ThemeSection:Toggle({
        Title = "Window Transparency",
        Value = Options.UI.Transparency > 0,
        Callback = function(value)
            Options.UI.Transparency = value and 0.5 or 0
            Options.Window:ToggleTransparency(value)
            Options:SaveSettings()
        end
    })

    -- Save Management
    local SaveSection = SettingsTab:Section({ Title = "Settings" })

    SaveSection:Button({
        Title = "Save Settings",
        Callback = function()
            Options:SaveSettings()
            WindUI:Notify({
                Title = "Settings Saved",
                Content = "Your settings have been saved successfully.",
                Duration = 3
            })
        end
    })

    SaveSection:Button({
        Title = "Reset Settings",
        Callback = function()
            Options:ResetSettings()
            WindUI:Notify({
                Title = "Settings Reset",
                Content = "All settings have been reset to default.",
                Duration = 3
            })
        end
    })
end

function Options:SaveSettings()
    if not Options._initialized then return end
    
    local data = Utils.DeepCopy({
        AutoFish = Options.AutoFish,
        AutoReel = Options.AutoReel,
        AutoShake = Options.AutoShake,
        CastMode = Options.CastMode,
        Items = Options.Items,
        UI = Options.UI
    })

    writefile("LucidHub/settings.json", HttpService:JSONEncode(data))
end

function Options:LoadSettings()
    if not Options._initialized then return end
    
    if isfile("LucidHub/settings.json") then
        local success, data = pcall(function()
            return HttpService:JSONDecode(readfile("LucidHub/settings.json"))
        end)

        if success and data then
            Utils.Merge(Options, data)
            Options:UpdateAllControls()
        end
    end
end

function Options:ResetSettings()
    Utils.Merge(Options, defaultOptions)
    Options:UpdateAllControls()
    Options:SaveSettings()
end

function Options:UpdateAllControls()
    if not Options._initialized then return end
    
    -- Update all toggles and controls
    Options.Controls.AutoFish:SetValue(Options.AutoFish)
    Options.Controls.AutoReel:SetValue(Options.AutoReel)
    Options.Controls.AutoShake:SetValue(Options.AutoShake)
    Options.Controls.CastMode:SetValue(Options.CastMode)
    
    -- Update items controls
    Options.Controls.ChestCollector:SetValue(Options.Items.ChestCollector.Enabled)
    Options.Controls.ChestRange:SetValue(Options.Items.ChestCollector.Range)
    Options.Controls.AutoSell:SetValue(Options.Items.AutoSell.Enabled)
    
    -- Update rarity toggles
    for rarity, enabled in pairs(Options.Items.AutoSell.Rarities) do
        if Options.Controls[rarity.."Sell"] then
            Options.Controls[rarity.."Sell"]:SetValue(enabled)
        end
    end
end

-- Stats update function
function Options:UpdateStats(stats)
    if not Options._initialized then return end
    
    Options.Stats.FishCaught:SetText("Fish Caught: "..tostring(stats.fishCaught or 0))
    Options.Stats.Coins:SetText("Coins: "..tostring(stats.coins or 0))
    Options.Stats.CurrentRod:SetText("Current Rod: "..tostring(stats.currentRod or "None"))
end

return Options
