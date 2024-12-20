-- loader.lua
-- Version: 1.0.1
-- Author: ProbTom
-- Created: 2024-12-20 14:45:42 UTC

local Loader = {}

-- Dependencies
local Debug
local Config
local Events
local Utils

-- Services
local HttpService = game:GetService("HttpService")

-- Constants
local REPO_URL = "https://raw.githubusercontent.com/ProbTom/Lucid/main/"
local MODULE_LOAD_ORDER = {
    "debug",
    "config",
    "state",
    "events",
    "ui",
    "utils"
}

-- Module cache
local loadedModules = {}

-- Version checking
function Loader.CheckVersion()
    local success, versionData = pcall(function()
        return Utils.JsonDecode(Utils.HttpGet(REPO_URL .. "version.json"))
    end)
    
    if not success then
        Debug.Error("Failed to check version: " .. tostring(versionData))
        return false
    end
    
    local currentVersion = Config.Get("Version")
    if currentVersion ~= versionData.version then
        Debug.Info(string.format("New version available: %s (current: %s)", versionData.version, currentVersion))
        return versionData
    end
    
    return true
end

-- Module loading
function Loader.LoadModule(name)
    if loadedModules[name] then
        return loadedModules[name]
    end
    
    local moduleUrl = REPO_URL .. name .. ".lua"
    local success, moduleContent = pcall(function()
        return Utils.HttpGet(moduleUrl)
    end)
    
    if not success then
        Debug.Error(string.format("Failed to load module '%s': %s", name, tostring(moduleContent)))
        return nil
    end
    
    local moduleFunc, err = loadstring(moduleContent)
    if not moduleFunc then
        Debug.Error(string.format("Failed to parse module '%s': %s", name, tostring(err)))
        return nil
    end
    
    local module = moduleFunc()
    loadedModules[name] = module
    
    -- Initialize module if it has an init function
    if type(module.init) == "function" then
        success, err = pcall(module.init, loadedModules)
        if not success then
            Debug.Error(string.format("Failed to initialize module '%s': %s", name, tostring(err)))
            return nil
        end
    end
    
    Debug.Info(string.format("Loaded module: %s", name))
    return module
end

-- Auto-update functionality
function Loader.AutoUpdate()
    local versionData = Loader.CheckVersion()
    if type(versionData) == "table" then
        Debug.Info("Starting auto-update process...")
        
        -- Backup current configuration
        local currentConfig = Config.GetAll()
        
        -- Reload all modules
        for _, moduleName in ipairs(MODULE_LOAD_ORDER) do
            local success = Loader.LoadModule(moduleName)
            if not success then
                Debug.Error(string.format("Auto-update failed at module: %s", moduleName))
                return false
            end
        end
        
        -- Restore configuration with new defaults
        Config.Reset()
        Config.Set("Version", versionData.version)
        Utils.Merge(Config.GetAll(), currentConfig)
        
        Events.Fire("UpdateComplete", versionData)
        Debug.Info(string.format("Auto-update completed. New version: %s", versionData.version))
        return true
    end
    
    return false
end

-- Module dependency check
function Loader.CheckDependencies()
    local missing = {}
    
    -- Check for required Roblox services
    local requiredServices = {
        "HttpService",
        "Players",
        "RunService",
        "TweenService",
        "UserInputService"
    }
    
    for _, service in ipairs(requiredServices) do
        local success = pcall(function()
            return game:GetService(service)
        end)
        if not success then
            table.insert(missing, "Service: " .. service)
        end
    end
    
    -- Check for required functions
    local requiredFunctions = {
        "loadstring",
        "pcall",
        "typeof"
    }
    
    for _, func in ipairs(requiredFunctions) do
        if not _G[func] then
            table.insert(missing, "Function: " .. func)
        end
    end
    
    return #missing == 0, missing
end

-- Initialize loader
function Loader.Initialize()
    -- Check dependencies first
    local dependenciesOk, missing = Loader.CheckDependencies()
    if not dependenciesOk then
        warn("[LUCID] Missing dependencies:")
        for _, item in ipairs(missing) do
            warn("  - " .. item)
        end
        return false
    end
    
    -- Load modules in order
    for _, moduleName in ipairs(MODULE_LOAD_ORDER) do
        local success = Loader.LoadModule(moduleName)
        if not success then
            return false
        end
    end
    
    -- Set up auto-update check interval
    task.spawn(function()
        while true do
            task.wait(3600) -- Check every hour
            if Config.Get("AutoUpdate") then
                Loader.AutoUpdate()
            end
        end
    end)
    
    Debug.Info("Loader initialized successfully")
    return true
end

return Loader
