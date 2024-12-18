local Config = {
    UI = {
        MainColor = Color3.fromRGB(38, 38, 38),
        ButtonColor = Color3.new(220, 125, 255),
        MinimizeKey = Enum.KeyCode.RightControl,
        Theme = "Rose"
    },
    URLs = {
        -- Using the latest working Fluent UI library
        Fluent = "https://raw.githubusercontent.com/dawid-scripts/Fluent/main/Fluent.lua",
        SaveManager = "https://raw.githubusercontent.com/dawid-scripts/Fluent/main/Addons/SaveManager.lua",
        InterfaceManager = "https://raw.githubusercontent.com/dawid-scripts/Fluent/main/Addons/InterfaceManager.lua"
    },
    GameID = 16732694052
}

getgenv().Config = Config
return Config
