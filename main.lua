-- main.lua
-- Version: 1.0.1
-- Author: ProbTom
-- Created: 2024-12-20 16:13:11 UTC

-- Global namespace protection
if getgenv().LucidLoaded then
    warn("[LUCID] System already loaded!")
    return false
end

-- Core system state
getgenv().LucidLoaded = true
getgenv().LucidState = {
    Version = "1.0.1",
    User = "ProbTom",
    StartTime = os.date("!%Y-%m-%d %H:%M:%S"),
    Debug = true,
    Loaded = false,
    Modules = {} -- Store loaded modules globally
}

-- Configuration
local Config = {
    BaseURL = "https://raw.githubusercontent.com/ProbTom/Lucid/main/",
    ModuleOrder = {
        "debug",    -- Must be first
        "utils",    -- Basic utilities
        "state",    -- State management
        "events",   -- Event system
        "ui",       -- UI components
        "loader"    -- Module loader
    }
}

-- Basic logging before debug module
local function earlyLog(msg, type)
    print(string.format("[LUCID %s] %s", type or "INFO", tostring(msg)))
end

-- Module loader
local function loadModule(name)
    local success, content = pcall(function()
        return game:HttpGet(Config.BaseURL .. name .. ".lua")
    end)
    
    if not success then
        earlyLog("Failed to fetch " .. name .. ": " .. tostring(content), "ERROR")
        return false
    end
    
    local success, module = pcall(loadstring, content)
    if not success then
        earlyLog("Failed to parse " .. name .. ": " .. tostring(module), "ERROR")
        return false
    end
    
    success, module = pcall(module)
    if not success then
        earlyLog("Failed to execute " .. name .. ": " .. tostring(module), "ERROR")
        return false
    end
    
    -- Store module globally
    getgenv().LucidState.Modules[name] = module
    return module
end

-- Initialize system
local function init()
    -- Wait for game load
    if not game:IsLoaded() then
        game.Loaded:Wait()
    end
    
    earlyLog("Starting initialization sequence")
    
    -- Load modules in sequence
    for _, moduleName in ipairs(Config.ModuleOrder) do
        earlyLog("Loading " .. moduleName)
        local module = loadModule(moduleName)
        if not module then
            return false
        end
    end
    
    -- Initialize modules with access to all loaded modules
    for _, moduleName in ipairs(Config.ModuleOrder) do
        local module = getgenv().LucidState.Modules[moduleName]
        if module and type(module.init) == "function" then
            local success, err = pcall(function()
                return module.init(getgenv().LucidState.Modules)
            end)
            if not success then
                earlyLog("Failed to initialize " .. moduleName .. ": " .. tostring(err), "ERROR")
                return false
            end
        end
    end
    
    getgenv().LucidState.Loaded = true
    earlyLog("System fully loaded!")
    
    return true
end

-- Start initialization
return init()
