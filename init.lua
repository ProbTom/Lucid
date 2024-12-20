-- init.lua
-- Version: 2024.12.20
-- Author: ProbTom
-- Purpose: Single entry point for Lucid Hub

-- Wait for game load
if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- Global namespace protection
if getgenv().LucidLoaded then
    return warn("[LUCID] Already loaded!")
end

-- Core system state
getgenv().LucidLoaded = true
getgenv().LucidState = {
    Version = "1.0.1",
    Loaded = false,
    Debug = true
}

-- Load core debug module
local function loadDebug()
    local success, Debug = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/ProbTom/Lucid/main/debug.lua"))()
    end)
    
    if not success then
        warn("[LUCID CRITICAL] Failed to load Debug module")
        return false
    end
    
    getgenv().LucidDebug = Debug
    return Debug
end

-- Protected module loader
local function loadModule(name, path)
    if not getgenv().LucidDebug then return false end
    local Debug = getgenv().LucidDebug
    
    local success, result = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/ProbTom/Lucid/main/" .. path))()
    end)
    
    if not success then
        Debug.Error("Failed to load " .. name)
        return false
    end
    
    Debug.Log(name .. " loaded successfully")
    return result
end

-- Initialize system
local function initialize()
    -- Load debug first
    local Debug = loadDebug()
    if not Debug then return false end
    Debug.Log("System initialization started")
    
    -- Load core modules in order
    local moduleSequence = {
        {name = "Config", path = "config.lua"},
        {name = "State", path = "state.lua"},
        {name = "UI", path = "ui.lua"},
        {name = "Loader", path = "loader.lua"}
    }
    
    -- Load all modules
    for _, module in ipairs(moduleSequence) do
        local result = loadModule(module.name, module.path)
        if not result then
            Debug.Error("Failed to load " .. module.name)
            return false
        end
        getgenv().LucidState[module.name] = result
    end
    
    -- Initialize loader
    if type(getgenv().LucidState.Loader.Initialize) == "function" then
        local success = getgenv().LucidState.Loader.Initialize()
        if not success then
            Debug.Error("Loader initialization failed")
            return false
        end
    end
    
    getgenv().LucidState.Loaded = true
    Debug.Log("System initialization complete")
    return true
end

-- Execute initialization
local success = initialize()
if not success then
    getgenv().LucidLoaded = false
    warn("[LUCID] Failed to initialize system")
end

return success
