local Config = {
    UI = {
        MainColor = Color3.fromRGB(38, 38, 38),
        ButtonColor = Color3.new(220, 125, 255),
        MinimizeKey = Enum.KeyCode.RightControl,
        Theme = "Rose"
    },
    URLs = {
        -- Correct URLs for Fluent UI
        Fluent = "https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Main.lua",
        SaveManager = "https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua",
        InterfaceManager = "https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"
    },
    GameID = 16732694052
}

getgenv().Config = Config
return Config
