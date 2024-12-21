-- loader.lua
local Lucid = {
    Name = "Lucid Hub",
    Version = "1.1.0",
    WindUIVersion = "1.0.0",
    Author = "ProbTom",
    LastUpdated = "2024-12-21"
}

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")

-- Create Lucid folder in ReplicatedStorage
local lucidFolder = ReplicatedStorage:FindFirstChild("Lucid") or Instance.new("Folder")
lucidFolder.Name = "Lucid"
lucidFolder.Parent = ReplicatedStorage

-- Module URLs
local modules = {
    windui = "https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua",
    debug = "https://raw.githubusercontent.com/ProbTom/Lucid/main/debug.lua",
    utils = "https://raw.githubusercontent.com/ProbTom/Lucid/main/utils.lua",
    functions = "https://raw.githubusercontent.com/ProbTom/Lucid/main/functions.lua",
    options = "https://raw.githubusercontent.com/ProbTom/Lucid/main/options.lua"
}

-- Load modules
local loadedModules = {}

-- Function to load a module
local function loadModule(name, url)
    -- Special case for WindUI
    if name == "windui" then
        local success, windui = pcall(function()
            return loadstring(game:HttpGet(url))()
        end)
        if success then
            loadedModules[name] = windui
            return windui
        end
        warn("Failed to load WindUI:", windui)
        return nil
    end

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
local WindUI = loadModule("windui", modules.windui)
if not WindUI then return false end

local Debug = loadModule("debug", modules.debug)
if not Debug then return false end

local Utils = loadModule("utils", modules.utils)
if not Utils then return false end

local Functions = loadModule("functions", modules.functions)
if not Functions then return false end

local Options = loadModule("options", modules.options)
if not Options then return false end

-- Initialize modules
Debug.init()
Utils.init({debug = Debug, windui = WindUI})
Functions.init({debug = Debug, utils = Utils, windui = WindUI})
Options.init({debug = Debug, utils = Utils, functions = Functions, windui = WindUI})

return loadedModules
