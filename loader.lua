-- loader.lua
local Loader = {
    _VERSION = "1.1.0",
    LastUpdated = "2024-12-21",
    Debug = false
}

-- Core Services
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Constants
local BASE_URL = "https://raw.githubusercontent.com/ProbTom/Lucid/main/"
local MODULES = {
    debug = "debug.lua",
    utils = "utils.lua",
    functions = "functions.lua",
    options = "options.lua",
    ui = "ui.lua"
}

-- Dependencies
local WindUI

-- Module cache
local loadedModules = {}

-- Local storage for loaded content
local moduleSource = {}

-- Initialize environment
function Loader.init()
    -- Create Lucid folder in ReplicatedStorage if it doesn't exist
    local lucidFolder = ReplicatedStorage:FindFirstChild("Lucid") or Instance.new("Folder")
    lucidFolder.Name = "Lucid"
    lucidFolder.Parent = ReplicatedStorage

    -- Load WindUI first
    local success, windui = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
    end)

    if success then
        WindUI = windui
        if Loader.Debug then
            print("[Lucid Loader] WindUI loaded successfully")
        end
    else
        warn("[Lucid Loader] Failed to load WindUI:", windui)
    end

    return true
end

-- Fetch module content
function Loader.fetch(moduleName)
    if moduleSource[moduleName] then
        return moduleSource[moduleName]
    end

    local moduleUrl = BASE_URL .. MODULES[moduleName]
    
    local success, content = pcall(function()
        return game:HttpGet(moduleUrl)
    end)

    if success then
        moduleSource[moduleName] = content
        if Loader.Debug then
            print("[Lucid Loader] Successfully fetched:", moduleName)
        end
        return content
    else
        warn("[Lucid Loader] Failed to fetch", moduleName, ":", content)
        return nil
    end
end

-- Load a module
function Loader.load(moduleName)
    if loadedModules[moduleName] then
        return loadedModules[moduleName]
    end

    if not MODULES[moduleName] then
        warn("[Lucid Loader] Invalid module name:", moduleName)
        return nil
    end

    local moduleContent = Loader.fetch(moduleName)
    if not moduleContent then
        return nil
    end

    local success, module = pcall(function()
        return loadstring(moduleContent)()
    end)

    if success then
        loadedModules[moduleName] = module
        if Loader.Debug then
            print("[Lucid Loader] Successfully loaded:", moduleName)
        end
        return module
    else
        warn("[Lucid Loader] Failed to load", moduleName, ":", module)
        return nil
    end
end

-- Get WindUI instance
function Loader.getWindUI()
    return WindUI
end

-- Load all modules
function Loader.loadAll()
    local modules = {}
    
    -- Load core modules in specific order
    local loadOrder = {"debug", "utils", "functions", "options", "ui"}
    
    for _, moduleName in ipairs(loadOrder) do
        modules[moduleName] = Loader.load(moduleName)
        if not modules[moduleName] then
            warn("[Lucid Loader] Failed to load core module:", moduleName)
            return nil
        end
    end

    return modules
end

-- Check for updates
function Loader.checkUpdate()
    local success, latestVersion = pcall(function()
        local versionUrl = BASE_URL .. "version.txt"
        return game:HttpGet(versionUrl)
    end)

    if success and latestVersion ~= Loader._VERSION then
        if WindUI then
            WindUI:Notify({
                Title = "Update Available",
                Content = "A new version of Lucid Hub is available: " .. latestVersion,
                Duration = 10
            })
        end
        return latestVersion
    end
    
    return nil
end

-- Set debug mode
function Loader.setDebug(enabled)
    Loader.Debug = enabled
end

-- Initialize the loader
Loader.init()

return Loader
