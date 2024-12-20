-- config.lua
local Config = {
    Version = "1.0.0",
    UI = {
        Window = {
            Title = "Lucid Hub",
            SubTitle = "by ProbTom",
            TabWidth = 160,
            Size = UDim2.fromOffset(580, 460),
            Theme = "Dark"
        },
        Tabs = {
            Main = {
                Name = "Main",
                Icon = "rbxassetid://10723424505"
            },
            Settings = {
                Name = "Settings",
                Icon = "rbxassetid://10734931430"
            }
        }
    },
    Features = {
        AutoCast = {
            Enabled = false,
            Delay = 1.0
        },
        AutoReel = {
            Enabled = false,
            Delay = 0.5
        },
        AutoShake = {
            Enabled = false,
            Delay = 0.2
        }
    }
}

return Config
