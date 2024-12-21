-- options.lua (fix for Theme error)
local Options = {
    _VERSION = "1.1.0",
    _initialized = false,
    LastUpdated = "2024-12-21",
    
    -- Default settings
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
            Rarities = {
                Common = false,
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
        }
    },
    
    UI = {
        SaveSettings = true,
        LoadSettings = true,
        Theme = "Dark", -- Default theme
        Transparency = 0,
        MinimizeKey = Enum.KeyCode.RightControl
    }
}

-- Dependencies
local WindUI
local Debug
local Utils
local Functions

function Options.init(deps)
    if Options._initialized then return end
    
    -- Ensure dependencies are available
    WindUI = deps.windui or error("WindUI dependency missing")
    Debug = deps.debug or error("Debug dependency missing")
    Utils = deps.utils or error("Utils dependency missing")
    Functions = deps.functions or error("Functions dependency missing")
    
    -- Initialize window without theme first
    Options.Window = WindUI:CreateWindow({
        Title = "Lucid Hub",
        Icon = "fish",
        Author = "ProbTom",
        Folder = "LucidHub"
    })
    
    -- Initialize tabs after window creation
    Options:InitMainTab()
    Options:InitItemsTab()
    Options:InitSettingsTab()
    
    -- Load saved settings
    Options:LoadSettings()
    
    Options._initialized = true
    return true
end

-- Rest of your options.lua code remains the same...
