-- Check for multiple executions
if getgenv().LucidHubLoaded then
    warn("Lucid Hub: Already executed!")
    return
end

-- Initialize loading
local function fetchURL(url)
    local success, result = pcall(function()
        return game:HttpGet(url)
    end)
    if success then
        return result
    end
    warn("Failed to fetch:", url)
    return nil
end

local function loadScript(source)
    local func, err = loadstring(source)
    if func then
        return pcall(func)
    end
    warn("Failed to load script:", err)
    return false
end

-- Base URL for your scripts
local baseUrl = "https://raw.githubusercontent.com/ProbTom/Lucid/main/"

-- Load config first
local configSource = fetchURL(baseUrl .. "config.lua")
if not configSource then return end
local success = loadScript(configSource)
if not success then return end

-- Load Fluent UI and its addons
local fluentSource = fetchURL(getgenv().Config.URLs.Fluent)
if not fluentSource then return end
success = loadScript(fluentSource)
if not success then return end

local saveManagerSource = fetchURL(getgenv().Config.URLs.SaveManager)
if not saveManagerSource then return end
success = loadScript(saveManagerSource)
if not success then return end

local interfaceManagerSource = fetchURL(getgenv().Config.URLs.InterfaceManager)
if not interfaceManagerSource then return end
success = loadScript(interfaceManagerSource)
if not success then return end

-- Load the rest of your scripts in order
local files = {
    "init.lua",
    "ui.lua",
    "Tab.lua",
    "MainTab.lua"
}

for _, file in ipairs(files) do
    local source = fetchURL(baseUrl .. file)
    if not source then return end
    success = loadScript(source)
    if not success then return end
    task.wait(0.1) -- Small delay between loads
end

-- Set loaded flag
getgenv().LucidHubLoaded = true

-- Show success notification
if getgenv().Fluent then
    getgenv().Fluent:Notify({
        Title = "Lucid Hub",
        Content = "Successfully loaded!",
        Duration = 5
    })
end
