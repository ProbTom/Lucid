-- config.lua
local success, result = pcall(function()
    -- Ensure environment is ready
    if not game:IsLoaded() then 
        game.Loaded:Wait()
    end

    -- Create Config table
    local Config = {
        Version = "1.0.0",
        Debug = true,
        UI = {
            MainColor = Color3.fromRGB(38, 38, 38),
            ButtonColor = Color3.fromRGB(220, 125, 255),
            MinimizeKey = Enum.KeyCode.RightControl,
            Theme = "Rose"
        },
        GameID = 16732694052,
        URLs = {
            Main = "https://raw.githubusercontent.com/ProbTom/Lucid/main/",
            Fluent = "https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua",
            SaveManager = "https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua",
            InterfaceManager = "https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"
        },
        Items = {
            ChestRange = {
                Default = 50,
                Min = 10,
                Max = 100
            },
            RodRanking = {
                "Rod Of The Forgotten Fang",
                "Rod Of The Eternal King",
                "Rod Of The Depth",
                "No-Life Rod",
                "Krampus's Rod",
                "Trident Rod",
                "Kings Rod",
                "Aurora Rod",
                "Mythical Rod",
                "Destiny Rod",
                "Celestial Rod",
                "Voyager Rod",
                "Riptide Rod",
                "Seasons Rod",
                "Resourceful Rod",
                "Precision Rod",
                "Steady Rod",
                "Nocturnal Rod",
                "Reinforced Rod",
                "Magnet Rod",
                "Rapid Rod",
                "Fortune Rod",
                "Phoenix Rod",
                "Scurvy Rod",
                "Midas Rod",
                "Buddy Bond Rod",
                "Haunted Rod",
                "Relic Rod",
                "Antler Rod",
                "North-Star Rod",
                "Astral Rod",
                "Event Horizon Rod",
                "Candy Cane Rod",
                "Fungal Rod",
                "Magma Rod",
                "Long Rod",
                "Lucky Rod",
                "Fast Rod",
                "Stone Rod",
                "Carbon Rod",
                "Plastic Rod",
                "Training Rod",
                "Fischer's Rod",
                "Flimsy Rod"
            },
            FishRarities = {
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
        },
        MaxRetries = 3,
        RetryDelay = 1
    }

    -- Set global config
    if getgenv then
        getgenv().Config = Config
    else
        _G.Config = Config
    end

    return Config
end)

if not success then
    warn("Failed to initialize config:", result)
    return false
end

return result
