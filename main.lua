-- main.lua
-- Version: 1.0.1
-- Author: ProbTom
-- Created: 2024-12-20 14:40:15 UTC

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
    StartTime = "2024-12-20 14:40:15",
    Debug = true,
    Loaded = false
}

-- Configuration
local Config = {
    BaseURL = "https://raw.githubusercontent.com/ProbTom/Lucid/main/",
    ModuleOrder = {
        "debug",
        "config",
        "utils",
        "state",
        "events",
        "ui",
        "loader"
    }
}

-- Module loader
local function loadModule(name)
    local success, module = pcall(function()
        return loadstring(game:HttpGet(Config.BaseURL .. name .. ".lua"))()
    end)
    
    if not success then
        warn(string.format("[LUCID] Failed to load %s module: %s", name, tostring(module)))
        return false
    end
    
    return module
end

-- Initialize system
local function init()
    -- Wait for game load
    if not game:IsLoaded() then
        game.Loaded:Wait()
    end
    
    -- Load modules in sequence
    local modules = {}
    for _, moduleName in ipairs(Config.ModuleOrder) do
        local module = loadModule(moduleName)
        if not module then
            return false
        end
        modules[moduleName] = module
    end
    
    -- Initialize modules
    for _, moduleName in ipairs(Config.ModuleOrder) do
        if modules[moduleName].init then
            local success, err = pcall(modules[moduleName].init, modules)
            if not success then
                warn(string.format("[LUCID] Failed to initialize %s: %s", moduleName, tostring(err)))
                return false
            end
        end
    end
    
    getgenv().LucidState.Loaded = true
    if modules.debug then
        modules.debug.Log("Lucid system fully loaded!")
    end
    
    return true
end

-- Start initialization
return init()
