-- loader.lua
-- Version: 1.0.1
-- Author: ProbTom
-- Created: 2024-12-20 17:00:58 UTC

local Loader = {
    Version = "1.0.1",
    BaseURL = "https://raw.githubusercontent.com/ProbTom/Lucid/main/"
}

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Create or get the Lucid folder in ReplicatedStorage
local lucidFolder = ReplicatedStorage:FindFirstChild("Lucid") or Instance.new("Folder")
lucidFolder.Name = "Lucid"
lucidFolder.Parent = ReplicatedStorage

-- Basic logging (uses debug module once loaded)
local function log(msg, type)
    print(string.format("[LUCID %s] %s", type or "INFO", tostring(msg)))
end

-- Protected HTTP fetch and module creation
local function loadModule(name)
    log("Loading " .. name)
    
    local success, content = pcall(function()
        return game:HttpGet(Loader.BaseURL .. name .. ".lua")
    end)
    
    if not success then
        log("Failed to fetch " .. name .. ": " .. tostring(content), "ERROR")
        return nil
    end
    
    -- Create ModuleScript
    local moduleScript = Instance.new("ModuleScript")
    moduleScript.Name = name
    moduleScript.Source = content
    moduleScript.Parent = lucidFolder
    
    -- Require the module
    local success, module = pcall(require, moduleScript)
    if not success then
        log("Failed to require " .. name .. ": " .. tostring(module), "ERROR")
        return nil
    end
    
    return module
end

-- Initialize modules
local function init()
    log("Starting module initialization")
    
    -- Load core modules in order
    local debug = loadModule("debug")
    if not debug then return false end
    
    local utils = loadModule("utils")
    if not utils then return false end
    
    local ui = loadModule("ui")
    if not ui then return false end
    
    -- Initialize modules
    if debug.init and utils.init and ui.init then
        debug.init()
        utils.init({debug = debug})
        ui.init({debug = debug, utils = utils})
    end
    
    log("All modules loaded successfully")
    return true
end

return init()
