-- init.lua
-- Version: 1.0.1
-- Author: ProbTom
-- Created: 2024-12-20 19:46:51 UTC

-- Create module container
local Lucid = {
    _VERSION = "1.0.1",
    _AUTHOR = "ProbTom",
    _DEBUG = true,
    modules = {}
}

-- Initialize global state first
getgenv().LucidState = {
    Version = Lucid._VERSION,
    StartTime = os.time(),
    Modules = {},
    Options = {},
    Config = {Debug = true}
}

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Clean up any existing instance
local existing = ReplicatedStorage:FindFirstChild("Lucid")
if existing then existing:Destroy() end

-- Create fresh module folder
local lucidFolder = Instance.new("Folder")
lucidFolder.Name = "Lucid"
lucidFolder.Parent = ReplicatedStorage

-- Early initialization logger
local function init_log(msg)
    print(string.format("[LUCID INIT] %s", tostring(msg)))
end

-- Module loading function
local function loadModule(name)
    local success, content = pcall(function()
        return game:HttpGet("https://raw.githubusercontent.com/ProbTom/Lucid/main/" .. name .. ".lua")
    end)
    
    if not success then
        init_log("Failed to fetch module: " .. name)
        return nil
    end
    
    local moduleScript = Instance.new("ModuleScript")
    moduleScript.Name = name
    moduleScript.Source = content
    moduleScript.Parent = lucidFolder
    
    return moduleScript
end

-- Initialize modules in correct order
local function InitializeLucid()
    -- Load modules in dependency order
    local moduleOrder = {"debug", "utils", "ui", "config", "state"}
    local loadedModules = {}
    
    for _, moduleName in ipairs(moduleOrder) do
        init_log("Loading " .. moduleName)
        
        local moduleScript = loadModule(moduleName)
        if not moduleScript then
            init_log("Failed to load " .. moduleName)
            return false
        end
        
        local success, module = pcall(require, moduleScript)
        if not success then
            init_log("Failed to require " .. moduleName)
            return false
        end
        
        loadedModules[moduleName] = module
        Lucid.modules[moduleName] = module
    end
    
    -- Initialize modules with dependencies
    for _, moduleName in ipairs(moduleOrder) do
        local module = loadedModules[moduleName]
        if module and module.init then
            local success = module.init(loadedModules)
            if not success then
                init_log("Failed to initialize " .. moduleName)
                return false
            end
        end
    end
    
    return true
end

-- Run initialization
if not InitializeLucid() then
    init_log("⚠️ Failed to initialize Lucid")
    return false
end

-- Make Lucid available globally
_G.Lucid = Lucid

return Lucid
