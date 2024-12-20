-- loader.lua
-- Version: 1.0.1
-- Author: ProbTom
-- Created: 2024-12-20 19:25:38 UTC

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Create or get the Lucid folder in ReplicatedStorage
local lucidFolder = ReplicatedStorage:FindFirstChild("Lucid") or Instance.new("Folder")
lucidFolder.Name = "Lucid"
lucidFolder.Parent = ReplicatedStorage

-- Module URLs
local modules = {
    debug = "https://raw.githubusercontent.com/ProbTom/Lucid/main/debug.lua",
    utils = "https://raw.githubusercontent.com/ProbTom/Lucid/main/utils.lua",
    ui = "https://raw.githubusercontent.com/ProbTom/Lucid/main/ui.lua"
}

-- Load modules
local loadedModules = {}

-- Function to load a module
local function loadModule(name, url)
    local success, content = pcall(function()
        return game:HttpGet(url)
    end)
    
    if not success then
        warn("Failed to fetch module", name, content)
        return nil
    end
    
    -- Create ModuleScript
    local moduleScript = Instance.new("ModuleScript")
    moduleScript.Name = name
    moduleScript.Source = content
    moduleScript.Parent = lucidFolder
    
    -- Require the module
    local loaded = require(moduleScript)
    loadedModules[name] = loaded
    return loaded
end

-- Load core modules in order
local debug = loadModule("debug", modules.debug)
if not debug then return false end

local utils = loadModule("utils", modules.utils)
if not utils then return false end

local ui = loadModule("ui", modules.ui)
if not ui then return false end

-- Initialize modules
if debug.init and utils.init and ui.init then
    debug.init()
    utils.init({debug = debug})
    ui.init({debug = debug, utils = utils})
end

return loadedModules
