if getgenv().LucidHubLoaded then
    warn("Lucid Hub: Already executed!")
    return
end

if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- Define config globally to be used by other scripts
getgenv().Config = {
    UI = {
        MainColor = Color3.fromRGB(38, 38, 38),
        ButtonColor = Color3.new(220, 125, 255),
        MinimizeKey = Enum.KeyCode.RightControl,
        Theme = "Rose"
    },
    GameID = 16732694052,
    URLs = {
        Fluent = "https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua",
        SaveManager = "https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua",
        InterfaceManager = "https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"
    }
}

-- Load Fluent UI directly
getgenv().Fluent = loadstring(game:HttpGet(getgenv().Config.URLs.Fluent))()
if not getgenv().Fluent then
    warn("Failed to load Fluent UI library")
    return
end

-- Load managers after Fluent is loaded
getgenv().SaveManager = loadstring(game:HttpGet(getgenv().Config.URLs.SaveManager))()
getgenv().InterfaceManager = loadstring(game:HttpGet(getgenv().Config.URLs.InterfaceManager))()

-- Load the rest of your scripts
local files = {
    "init.lua",
    "ui.lua",
    "Tab.lua",
    "MainTab.lua"
}

for _, file in ipairs(files) do
    local source = game:HttpGet("https://raw.githubusercontent.com/ProbTom/Lucid/main/" .. file)
    local success, result = pcall(loadstring(source))
    if not success then
        warn("Failed to load " .. file .. ": " .. tostring(result))
        return
    end
    task.wait(0.1)
end

getgenv().LucidHubLoaded = true

if getgenv().Fluent then
    getgenv().Fluent:Notify({
        Title = "Lucid Hub",
        Content = "Successfully loaded!",
        Duration = 5
    })
end
