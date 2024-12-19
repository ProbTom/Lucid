getgenv().Config = {
    URLs = {
        Main = "https://raw.githubusercontent.com/ProbTom/Lucid/main/",
        Backup = "https://raw.githubusercontent.com/ProbTom/Lucid/backup/"
    },
    
    Game = {
        SupportedGames = {
            [14264772720] = "Winter Fishing Simulator"
        },
        MinimumDelay = 0.1,
        MaximumDelay = 2.0
    },
    
    UI = {
        Title = "Lucid Hub",
        Subtitle = "Winter Fishing Simulator",
        Theme = "Dark",
        MainColor = Color3.fromRGB(46, 148, 255),
        MinimizeKey = Enum.KeyCode.RightShift
    },
    
    Items = {
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
        
        ChestSettings = {
            MinRange = 10,
            MaxRange = 100,
            DefaultRange = 50
        }
    },
    
    Options = {
        AutoFish = false,
        AutoReel = false,
        AutoShake = false,
        AutoSell = false,
        AutoEquipBestRod = false,
        AutoCollectChests = false,
        ChestRange = 50
    }
}
