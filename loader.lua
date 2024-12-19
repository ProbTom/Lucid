-- loader.lua
local function initializeEnvironment()
    if getgenv().LucidHubLoaded then
        warn("Lucid Hub: Already executed!")
        return false
    end

    if not game:IsLoaded() then
        game.Loaded:Wait()
    end

    -- Cleanup existing UI elements
    local CoreGui = game:GetService("CoreGui")
    if CoreGui:FindFirstChild("ClickButton") then
        CoreGui:FindFirstChild("ClickButton"):Destroy()
    end

    return true
end

local function debugPrint(...)
    if getgenv().Config and getgenv().Config.Debug then
        print("[Lucid Debug]", table.concat({...}, " "))
    end
end

local function fetchAndExecute(url)
    local success, content = pcall(function()
        return game:HttpGet(url)
    end)

    if not success then
        return false, "Failed to fetch content: " .. tostring(content)
    end

    local func, err = loadstring(content)
    if not func then
        return false, "Failed to compile: " .. tostring(err)
    end

    local success, result = pcall(func)
    if not success then
        return false, "Failed to execute: " .. tostring(result)
    end

    return true, result
end

local function loadScript(name)
    if not getgenv().Config then
        return false, "Config not initialized"
    end

    local url = getgenv().Config.URLs.Main .. name
    debugPrint("Loading:", name)
    
    local success, result = fetchAndExecute(url)
    if not success then
        warn(string.format("Failed to load %s: %s", name, tostring(result)))
        return false
    end

    debugPrint("Successfully loaded:", name)
    return true
end

-- Main initialization sequence
if not initializeEnvironment() then
    return
end

-- Load configuration first
local configSuccess, configResult = fetchAndExecute("https://raw.githubusercontent.com/ProbTom/Lucid/main/config.lua")
if not configSuccess then
    error("Failed to load configuration: " .. tostring(configResult))
    return
end

-- Initialize Fluent UI
local fluentSuccess, fluentUI = fetchAndExecute(getgenv().Config.URLs.Fluent)
if not fluentSuccess then
    error("Failed to initialize Fluent UI: " .. tostring(fluentUI))
    return
end
getgenv().Fluent = fluentUI

-- Define loading sequence
local loadOrder = {
    {name = "compatibility.lua", required = true},
    {name = "options.lua", required = true},
    {name = "events.lua", required = true},
    {name = "functions.lua", required = true},
    {name = "Tab.lua", required = true},
    {name = "MainTab.lua", required = true},
    {name = "ItemsTab.lua", required = true},
    {name = "ui.lua", required = false}
}

-- Load all scripts in sequence
for _, script in ipairs(loadOrder) do
    if not loadScript(script.name) and script.required then
        error(string.format("Failed to load required script: %s", script.name))
        return
    end
    task.wait(0.1)
end

-- Initialize SaveManager
if getgenv().Fluent then
    local saveManagerSuccess, saveManager = fetchAndExecute(getgenv().Config.URLs.SaveManager)
    if saveManagerSuccess then
        getgenv().SaveManager = saveManager
        getgenv().SaveManager:SetLibrary(getgenv().Fluent)
        getgenv().SaveManager:SetFolder("LucidHub")
        getgenv().SaveManager:Load("LucidHub")
    end
end

getgenv().LucidHubLoaded = true
debugPrint("Lucid Hub loaded successfully")
return true
