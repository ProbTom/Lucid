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

    -- Cleanup existing UI
    local CoreGui = game:GetService("CoreGui")
    if CoreGui:FindFirstChild("ClickButton") then
        CoreGui:FindFirstChild("ClickButton"):Destroy()
    end
end

-- Initialize debug functionality
local function createDebugger()
    return function(...)
        if getgenv().Config and getgenv().Config.Debug then
            print("[Lucid Debug]", table.concat({...}, " "))
        end
    end
end

-- Create HTTP request handler
local function createHttpHandler()
    return function(url)
        local success, result = pcall(function()
            return game:HttpGet(url)
        end)
        
        if not success then
            return false, "HTTP Request failed: " .. tostring(result)
        end
        
        return true, result
    end
end

-- Create script loader
local function createScriptLoader(debugPrint, httpGet)
    return function(scriptName)
        if not getgenv().Config then
            return false, "Config not initialized"
        end

        debugPrint("Loading script:", scriptName)
        
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
        
        debugPrint("Successfully loaded:", scriptName)
        return true, result
    end
end

-- Main execution
initializeEnvironment()
local debugPrint = createDebugger()
local httpGet = createHttpHandler()
local loadScript = createScriptLoader(debugPrint, httpGet)

-- Load configuration
debugPrint("Loading configuration...")
local configSuccess, configContent = httpGet("https://raw.githubusercontent.com/ProbTom/Lucid/main/config.lua")
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
debugPrint("Configuration loaded successfully")

-- Initialize Fluent UI
debugPrint("Initializing Fluent UI...")
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
debugPrint("Fluent UI initialized successfully")

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

-- Execute loading sequence
for _, script in ipairs(loadOrder) do
    local success, result = loadScript(script.name)
    if not success and script.required then
        error(string.format("Failed to load required script %s: %s", script.name, tostring(result)))
        return
    end
    task.wait(0.1)
end

-- Initialize SaveManager
if getgenv().Fluent then
    local saveManagerSuccess, saveManagerContent = httpGet(config.URLs.SaveManager)
    if saveManagerSuccess then
        local saveManager = loadstring(saveManagerContent)()
        if saveManager then
            getgenv().SaveManager = saveManager
            getgenv().SaveManager:SetLibrary(getgenv().Fluent)
            getgenv().SaveManager:SetFolder("LucidHub")
            getgenv().SaveManager:Load("LucidHub")
            debugPrint("SaveManager initialized successfully")
        end
    end
end

getgenv().LucidHubLoaded = true
debugPrint("Lucid Hub loaded successfully")
return true
