getgenv().Config = {
    UI = {
        MainColor = Color3.fromRGB(38, 38, 38),
        ButtonColor = Color3.new(220, 125, 255),
        MinimizeKey = Enum.KeyCode.RightControl,
        Theme = "Rose"
    },
    GameID = 16732694052,
    URLs = {
        -- Updated URLs to ensure compatibility
        Fluent = "https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua",
        SaveManager = "https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua",
        InterfaceManager = "https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"
    },
    Debug = true -- Add debug flag for better error handling
}

return true
