-- config.lua
-- Core configuration module for Lucid Hub
local Config = {
    Version = "1.0.1",
    Debug = true,
    
    -- Core UI Configuration
    UI = {
        Window = {
            Name = "Lucid Hub",
            Title = "Lucid Hub",
            SubTitle = "by ProbTom",
            LoadingTitle = "Lucid Hub",
            LoadingSubtitle = "by ProbTom",
            TabWidth = 160,
            Size = UDim2.fromOffset(580, 460),
            Theme = "Rose",
            MinimizeKey = Enum.KeyCode.RightControl
        },
        Tabs = {
            {Name = "Home", Icon = "rbxassetid://4483345998"},
            {Name = "Main", Icon = "rbxassetid://4483345998"},
            {Name = "Items", Icon = "rbxassetid://4483345998"},
            {Name = "Teleports", Icon = "rbxassetid://4483345998"},
            {Name = "Misc", Icon = "rbxassetid://4483345998"},
            {Name = "Trade", Icon = "rbxassetid://4483345998"},
            {Name = "Credit", Icon = "rbxassetid://4483345998"}
        }
    },

    -- Save Configuration
    Save = {
        Enabled = true,
        FolderName = "LucidHub",
        FileName = "Config"
    },

    -- Item Settings
    Items = {
        ChestSettings = {
            MinRange = 10,
            MaxRange = 100,
            Default = 50
        },
        FishRarities = {
            "Common",
            "Rare",
            "Legendary",
            "Mythical",
            "Enchant Relics",
            "Exotic",
            "Limited",
            "Gemstones"
        }
    },

    -- URLs for dynamic loading
    URLs = {
        Main = "https://raw.githubusercontent.com/ProbTom/Lucid/main/",
        Backup = "https://raw.githubusercontent.com/ProbTom/Lucid/backup/",
        FluentUI = "https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua",
        SaveManager = "https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua",
        InterfaceManager = "https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"
    }
}

-- Protect configuration from modification
if getgenv then
    getgenv().Config = Config
end

return Config
