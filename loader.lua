-- loader.lua
-- Version: 1.0.1
-- Author: ProbTom
-- Created: 2024-12-20 14:55:59 UTC

local Loader = {
    _VERSION = "1.0.1",
    _AUTHOR = "ProbTom",
    _initialized = false
}

-- Forward declaration of dependencies
local Debug

-- Constants
local REPO_URL = "https://raw.githubusercontent.com/ProbTom/Lucid/main/"
local MAX_RETRIES = 3
local RETRY_DELAY = 1

-- Module loading order
local MODULE_ORDER = {
    {name = "debug", required = true},
    {name = "utils", required = true},
    {name = "events", required = true},
    {name = "state", required = true},
    {name = "ui", required = false}
}

-- Storage for loaded modules
local loadedModules = {}

-- Early logging function
local function loaderLog(msg, isError)
    local prefix = isError and "ERROR" or "INFO"
    print(string.format("[LUCID LOADER %s] %s", prefix, tostring(msg)))
end

-- Safe module loading
local function safeLoadModule(moduleName)
    if loadedModules[moduleName] then
        return loadedModules[moduleName]
    end
    
    local success, result = pcall(function()
        local module = require(moduleName)
        if type(module) ~= "table" then
            error("Module must return a table")
        end
        return module
    end)
    
    if not success then
        loaderLog(string.format("Failed to load module '%s': %s", moduleName, result), true)
        return nil, result
    end
    
    return result
end

-- Module initialization
local function initializeModule(module, moduleName, modules)
    if type(module.init) ~= "function" then
        return true
    end
    
    local success, result = pcall(function()
        return module.init(modules)
    end)
    
    if not success then
        loaderLog(string.format("Failed to initialize module '%s': %s", moduleName, result), true)
        return false
    end
    
    return true
end

-- Version checking
function Loader.CheckVersion()
    local success, versionData = pcall(function()
        local url = REPO_URL .. "version.json"
        local HttpService = game:GetService("HttpService")
        return HttpService:JSONDecode(HttpService:GetAsync(url))
    end)
    
    if not success then
        if Debug then Debug.Error("Failed to check version: " .. tostring(versionData)) end
        return false
    end
    
    return versionData
end

-- Module loading
function Loader.LoadModule(moduleName, isRequired)
    if loadedModules[moduleName] then
        return loadedModules[moduleName]
    end
    
    local module, err = safeLoadModule(moduleName)
    if not module then
        if isRequired then
            loaderLog(string.format("Required module '%s' failed to load: %s", moduleName, err), true)
            return nil
        else
            loaderLog(string.format("Optional module '%s' not loaded: %s", moduleName, err))
            return nil
        end
    end
    
    loadedModules[moduleName] = module
    
    -- Initialize if debug module is available
    if Debug then
        Debug.Info(string.format("Loaded module: %s", moduleName))
    else
        loaderLog(string.format("Loaded module: %s", moduleName))
    end
    
    return module
end

-- System initialization
function Loader.Initialize()
    if Loader._initialized then
        return true
    end
    
    -- Load modules in order
    for _, moduleInfo in ipairs(MODULE_ORDER) do
        local module = Loader.LoadModule(moduleInfo.name, moduleInfo.required)
        
        if moduleInfo.required and not module then
            loaderLog(string.format("Failed to load required module: %s", moduleInfo.name), true)
            return false
        end
        
        if module and not initializeModule(module, moduleInfo.name, loadedModules) then
            if moduleInfo.required then
                return false
            end
        end
    end
    
    Loader._initialized = true
    
    if Debug then
        Debug.Info("Loader initialized successfully")
    else
        loaderLog("Loader initialized successfully")
    end
    
    return true
end

-- Module cleanup
function Loader.Cleanup()
    for name, module in pairs(loadedModules) do
        if type(module.shutdown) == "function" then
            pcall(function()
                module.shutdown()
            end)
        end
    end
    
    loadedModules = {}
    Loader._initialized = false
    
    if Debug then
        Debug.Info("Loader cleanup completed")
    else
        loaderLog("Loader cleanup completed")
    end
end

-- Initialize the loader
function Loader.init(modules)
    if type(modules) ~= "table" then
        return false, "Invalid modules parameter"
    end
    
    Debug = modules.debug
    if not Debug then
        return false, "Debug module is required"
    end
    
    return Loader.Initialize()
end

return Loader
