-- config.lua
-- Version: 2024.12.20
-- Author: ProbTom

local Config = {
    Version = "1.0.1",
    Debug = true,
    
    UI = {
        Window = {
            Title = "Lucid Hub",
            SubTitle = "by ProbTom",
            TabWidth = 160,
            Size = UDim2.fromOffset(580, 460),
            Theme = "Dark",
            MinimizeKeybind = Enum.KeyCode.RightControl
        },
        
        Tabs = {
            Home = {
                Name = "Home",
                Icon = "home"
            },
            Main = {
                Name = "Main",
                Icon = "list"
            },
            Items = {
                Name = "Items",
                Icon = "package"
            },
            Teleports = {
                Name = "Teleports",
                Icon = "map-pin"
            },
            Misc = {
                Name = "Misc",
                Icon = "file-text"
            },
            Settings = {
                Name = "Settings",
                Icon = "settings"
            },
            Credits = {
                Name = "Credits",
                Icon = "heart"
            }
        }
    },
    
    URLs = {
        FluentUI = "https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua",
        Repository = "https://raw.githubusercontent.com/ProbTom/Lucid/main/"
    },
    
    Features = {
        AutoCast = {
            Enabled = false,
            Delay = 1
        },
        AutoReel = {
            Enabled = false,
            Delay = 0.1
        },
        AutoShake = {
            Enabled = false,
            Delay = 0.1
        }
    }
}

return Config
