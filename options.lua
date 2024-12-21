-- options.lua
local Options = {
    _VERSION = "1.1.0",
    _initialized = false,
    LastUpdated = "2024-12-21"
}

local WindUI, MainWindow, Debug, Utils, Functions

function Options.init(deps)
    if Options._initialized then return end
    
    WindUI = deps.windui or error("WindUI dependency missing")
    MainWindow = deps.window or error("MainWindow dependency missing")
    Debug = deps.debug or error("Debug dependency missing")
    Utils = deps.utils or error("Utils dependency missing")
    Functions = deps.functions or error("Functions dependency missing")
    
    -- Initialize default settings
    Options.DefaultSettings = {
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
            Theme = "Dark",
            Transparency = 0,
            MinimizeKey = Enum.KeyCode.RightControl
        }
    }
    
    Options._initialized = true
    return true
end

function Options.getDefaultSettings()
    return Utils.DeepCopy(Options.DefaultSettings)
end

return Options
