-- Check if already executed first, before doing anything else
if getgenv().LucidHubLoaded then
    warn("Lucid Hub: Already executed!")
    return
end

-- Function to clean up existing instances
local function cleanupExisting()
    local CoreGui = game:GetService("CoreGui")
    
    -- Remove existing GUI elements
    if CoreGui:FindFirstChild("ClickButton") then
        CoreGui:FindFirstChild("ClickButton"):Destroy()
    end
    
    -- Clear all states
    getgenv().Fluent = nil
    getgenv().SaveManager = nil
    getgenv().InterfaceManager = nil
    getgenv().Config = nil
    getgenv().Tabs = nil
end

-- Clean up any existing instances
cleanupExisting()

-- Wait for game load
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
local success, result = pcall(function()
    return loadstring(game:HttpGet(getgenv().Config.URLs.Fluent))()
end)

if success then
    getgenv().Fluent = result
else
    warn("Failed to load Fluent UI library")
    return
end

-- Load managers after Fluent is loaded
pcall(function()
    getgenv().SaveManager = loadstring(game:HttpGet(getgenv().Config.URLs.SaveManager))()
    getgenv().InterfaceManager = loadstring(game:HttpGet(getgenv().Config.URLs.InterfaceManager))()
end)

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

-- Mark as loaded
getgenv().LucidHubLoaded = true

if getgenv().Fluent then
    getgenv().Fluent:Notify({
        Title = "Lucid Hub",
        Content = "Successfully loaded!",
        Duration = 5
    })
end
