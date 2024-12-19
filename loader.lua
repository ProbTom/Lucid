-- Check if already executed
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
    Version = "1.0.0",
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

-- Function to load scripts with retry mechanism
local function loadScript(name, maxRetries)
    maxRetries = maxRetries or 3
    local retryCount = 0
    
    while retryCount < maxRetries do
        local success, result = pcall(function()
            local source = game:HttpGet("https://raw.githubusercontent.com/ProbTom/Lucid/main/" .. name)
            return loadstring(source)()
        end)
        
        if success then
            return true
        else
            retryCount = retryCount + 1
            warn(string.format("Failed to load %s (Attempt %d/%d): %s", name, retryCount, maxRetries, tostring(result)))
            task.wait(1)
        end
    end
    
    return false
end

-- Load Fluent UI with retry
local function loadFluent()
    local success, result = pcall(function()
        return loadstring(game:HttpGet(getgenv().Config.URLs.Fluent))()
    end)
    
    if success then
        getgenv().Fluent = result
        
        -- Load additional managers
        pcall(function()
            getgenv().SaveManager = loadstring(game:HttpGet(getgenv().Config.URLs.SaveManager))()
            getgenv().InterfaceManager = loadstring(game:HttpGet(getgenv().Config.URLs.InterfaceManager))()
        end)
        
        return true
    else
        warn("Failed to load Fluent UI library:", result)
        return false
    end
end

-- Initialize Fluent UI
if not loadFluent() then
    warn("Failed to initialize Fluent UI")
    return
end

-- Load scripts in order with dependencies
local loadOrder = {
    {name = "init.lua", required = true},
    {name = "Tab.lua", required = true},
    {name = "functions.lua", required = true},
    {name = "MainTab.lua", required = true}
}

-- Load all scripts
for _, script in ipairs(loadOrder) do
    if not loadScript(script.name) and script.required then
        getgenv().Fluent:Notify({
            Title = "Lucid Hub Error",
            Content = "Failed to load " .. script.name,
            Duration = 5
        })
        return
    end
    task.wait(0.1)
end

-- Set up auto-save functionality
if getgenv().SaveManager then
    getgenv().SaveManager:SetFolder("LucidHub")
    getgenv().SaveManager:SetGame(tostring(game.GameId))
    
    -- Load saved settings
    getgenv().SaveManager:Load("AutoSave")
    
    -- Auto-save settings periodically
    spawn(function()
        while true do
            task.wait(30)
            pcall(function()
                getgenv().SaveManager:Save("AutoSave")
            end)
        end
    end)
end

-- Mark as loaded
getgenv().LucidHubLoaded = true

-- Show success notification
if getgenv().Fluent then
    getgenv().Fluent:Notify({
        Title = "Lucid Hub",
        Content = string.format("Successfully loaded v%s!", getgenv().Config.Version),
        Duration = 5
    })
end

-- Add error handling for runtime errors
game:GetService("ScriptContext").Error:Connect(function(message, stack, script)
    if script and script:IsDescendantOf(game:GetService("CoreGui")) then
        warn("Lucid Hub Runtime Error:", message, "\nStack:", stack)
    end
end)

-- Setup clean disconnect
game:GetService("Players").PlayerRemoving:Connect(function(player)
    if player == game:GetService("Players").LocalPlayer then
        if getgenv().SaveManager then
            getgenv().SaveManager:Save("AutoSave")
        end
        if getgenv().cleanup then
            getgenv().cleanup()
        end
        cleanupExisting()
    end
end)

return true
