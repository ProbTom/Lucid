if getgenv().LucidHubLoaded then
    warn("Lucid Hub: Already executed!")
    return
end

local function cleanupExisting()
    local CoreGui = game:GetService("CoreGui")
    if CoreGui:FindFirstChild("ClickButton") then
        CoreGui:FindFirstChild("ClickButton"):Destroy()
    end
end

cleanupExisting()

if not game:IsLoaded() then
    game.Loaded:Wait()
end

getgenv().Config = {
    Version = "1.0.0",
    Debug = true,
    URLs = {
        Main = "https://raw.githubusercontent.com/ProbTom/Lucid/main/",
        Fluent = "https://github.com/dawid-scripts/Fluent/releases/download/1.1.0/main.lua"
    },
    MaxRetries = 3,
    RetryDelay = 1
}

local function debugPrint(...)
    if getgenv().Config.Debug then
        print("[Lucid Debug]", table.concat({...}, " "))
    end
end

local function loadScript(name)
    local success, result = pcall(function()
        debugPrint("Fetching:", name)
        local source = game:HttpGet(getgenv().Config.URLs.Main .. name)
        if not source then 
            debugPrint("No source found for:", name)
            return false 
        end
        
        debugPrint("Compiling:", name)
        local loaded = loadstring(source)
        if not loaded then 
            debugPrint("Failed to compile:", name)
            return false 
        end
        
        debugPrint("Executing:", name)
        return loaded()
    end)
    
    if success and result then
        debugPrint("Successfully loaded:", name)
        return true
    else
        warn(string.format("Failed to load %s: %s", name, tostring(result)))
        return false
    end
end

-- Initialize Fluent UI with enhanced error handling
local function initializeFluentUI()
    debugPrint("Fetching Fluent UI source...")
    local success, content = pcall(function()
        return game:HttpGet(getgenv().Config.URLs.Fluent)
    end)
    
    if not success or not content then
        debugPrint("Failed to fetch Fluent UI source:", tostring(content))
        return false
    end
    
    debugPrint("Compiling Fluent UI...")
    local loaded, compileError = loadstring(content)
    if not loaded then
        debugPrint("Compile error:", compileError)
        return false
    end
    
    debugPrint("Executing Fluent UI...")
    local success, lib = pcall(loaded)
    if not success then
        debugPrint("Execution error:", lib)
        return false
    end
    
    getgenv().Fluent = lib
    debugPrint("Fluent UI initialized successfully")
    return true
end

-- Load scripts in correct order with dependencies
local loadOrder = {
    {name = "config.lua", required = true},
    {name = "compatibility.lua", required = true},
    {name = "options.lua", required = true},
    {name = "events.lua", required = true},
    {name = "functions.lua", required = true},
    {name = "Tab.lua", required = true},
    {name = "MainTab.lua", required = true},
    {name = "ItemsTab.lua", required = true},
    {name = "ui.lua", required = false}
}

-- Initialize Fluent UI first
debugPrint("Initializing Fluent UI...")
if not initializeFluentUI() then
    error("Failed to initialize Fluent UI")
    return
end

-- Load all scripts in order
for _, script in ipairs(loadOrder) do
    if not loadScript(script.name) and script.required then
        error(string.format("Failed to load required script: %s", script.name))
        return
    end
    task.wait(0.1)
end

-- Initialize SaveManager after all scripts are loaded
if getgenv().Fluent then
    getgenv().SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
    if getgenv().SaveManager then
        getgenv().SaveManager:SetLibrary(getgenv().Fluent)
        getgenv().SaveManager:SetFolder("LucidHub")
        getgenv().SaveManager:Load("LucidHub")
    end
end

getgenv().LucidHubLoaded = true
debugPrint("Lucid Hub loaded successfully")
return true
