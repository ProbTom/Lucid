-- loader.lua
if getgenv().LucidHubLoaded then
    warn("Lucid Hub: Already executed!")
    return
end

-- Initialize core environment
local function initializeEnvironment()
    if not game:IsLoaded() then
        game.Loaded:Wait()
    end
    
    local CoreGui = game:GetService("CoreGui")
    if CoreGui:FindFirstChild("ClickButton") then
        CoreGui:FindFirstChild("ClickButton"):Destroy()
    end
end

-- Initialize debug functionality
local function debug(...)
    if getgenv().Config and getgenv().Config.Debug then
        print("[Lucid Debug]", table.concat({select(1, ...)}, " "))
    end
end

-- Create HTTP request handler
local function httpGet(url)
    local success, result = pcall(function()
        return game:HttpGet(url)
    end)
    
    if not success then
        return false, "HTTP Request failed: " .. tostring(result)
    end
    
    return true, result
end

-- Create script loader
local function loadScript(scriptName)
    if not getgenv().Config then
        return false, "Config not initialized"
    end
    
    debug("Loading script:", scriptName)
    local url = getgenv().Config.URLs.Main .. scriptName
    local success, content = httpGet(url)
    
    if not success then
        return false, content
    end
    
    local func, err = loadstring(content)
    if not func then
        return false, "Compilation failed: " .. tostring(err)
    end
    
    local success, result = pcall(func)
    if not success then
        return false, "Execution failed: " .. tostring(result)
    end
    
    debug("Successfully loaded:", scriptName)
    return true, result
end

-- Main execution
initializeEnvironment()

-- Load configuration
debug("Loading configuration...")
local configSuccess, configContent = httpGet(getgenv().Config.URLs.Main .. "config.lua")
if not configSuccess then
    error("Failed to fetch configuration: " .. tostring(configContent))
    return
end

local configFunc, compileErr = loadstring(configContent)
if not configFunc then
    error("Failed to compile configuration: " .. tostring(compileErr))
    return
end

local success, config = pcall(configFunc)
if not success or type(config) ~= "table" then
    error("Failed to execute configuration: " .. tostring(config))
    return
end

getgenv().Config = config
debug("Configuration loaded successfully")

-- Initialize Fluent UI
debug("Initializing Fluent UI...")
local fluentSuccess, fluentContent = httpGet(config.URLs.Fluent)
if not fluentSuccess then
    error("Failed to fetch Fluent UI: " .. tostring(fluentContent))
    return
end

local fluentLib = loadstring(fluentContent)()
if not fluentLib then
    error("Failed to initialize Fluent UI")
    return
end

getgenv().Fluent = fluentLib
debug("Fluent UI initialized successfully")

-- Load core scripts
local scriptLoadOrder = {
    "compatibility.lua",
    "options.lua",
    "events.lua",
    "functions.lua",
    "Tab.lua",
    "MainTab.lua",
    "ItemsTab.lua",
    "ui.lua"
}

for _, script in ipairs(scriptLoadOrder) do
    local success, result = loadScript(script)
    if not success then
        error(string.format("Failed to load script %s: %s", script, tostring(result)))
        return
    end
    task.wait(0.1)
end

getgenv().LucidHubLoaded = true
debug("Lucid Hub loaded successfully")
