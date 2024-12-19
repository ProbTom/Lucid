-- Check if already executed first
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
    
    -- Clean up any existing Fluent windows
    if getgenv().Fluent then
        pcall(function()
            for _, window in pairs(getgenv().Fluent.Windows) do
                window:Destroy()
            end
        end)
    end
    
    -- Clear all states
    getgenv().Fluent = nil
    getgenv().SaveManager = nil
    getgenv().InterfaceManager = nil
    getgenv().Config = nil
    getgenv().Tabs = nil
    getgenv().Options = nil
end

-- Clean up any existing instances
cleanupExisting()

-- Wait for game load
if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- Define config globally
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

-- Function to load scripts
local function loadScript(name)
    local success, result = pcall(function()
        local source = game:HttpGet("https://raw.githubusercontent.com/ProbTom/Lucid/main/" .. name)
        return loadstring(source)()
    end)
    
    if not success then
        warn("Failed to load " .. name .. ": " .. tostring(result))
        return false
    end
    
    return true
end

-- Load scripts in order
local loadOrder = {
    "init.lua",      -- First to initialize variables
    "Tab.lua",       -- Second to create the window and tabs
    "functions.lua", -- Third to load functions
    "MainTab.lua"    -- Last to use everything
}

for _, scriptName in ipairs(loadOrder) do
    if not loadScript(scriptName) then
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
