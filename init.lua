-- init.lua
local Lucid = {
    _VERSION = "1.0.1",
    _AUTHOR = "ProbTom",
    _DEBUG = true
}

-- Setup global state first
getgenv().LucidState = {
    Version = Lucid._VERSION,
    StartTime = os.time(),
    Modules = {},
    Options = {},
    Config = {
        Debug = true
    }
}

-- Create folder for modules
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local lucidFolder = Instance.new("Folder")
lucidFolder.Name = "Lucid"
lucidFolder.Parent = ReplicatedStorage

-- Function to load module from URL
local function loadFromUrl(name)
    local success, content = pcall(function()
        return game:HttpGet("https://raw.githubusercontent.com/ProbTom/Lucid/main/" .. name .. ".lua")
    end)
    
    if not success then
        warn("Failed to fetch:", name, content)
        return false
    end
    
    local moduleScript = Instance.new("ModuleScript")
    moduleScript.Name = name
    moduleScript.Source = content
    moduleScript.Parent = lucidFolder
    
    return moduleScript
end

-- Load core modules in correct order
local moduleOrder = {"debug", "utils", "ui"}
local loadedModules = {}

for _, moduleName in ipairs(moduleOrder) do
    local moduleScript = loadFromUrl(moduleName)
    if moduleScript then
        local success, module = pcall(require, moduleScript)
        if success and module then
            loadedModules[moduleName] = module
            getgenv().LucidState.Modules[moduleName] = module
        else
            warn("Failed to load module:", moduleName)
            return
        end
    end
end

-- Initialize modules in order
for _, moduleName in ipairs(moduleOrder) do
    local module = loadedModules[moduleName]
    if module and module.init then
        local success = module.init(loadedModules)
        if not success then
            warn("Failed to initialize module:", moduleName)
            return
        end
    end
end

return Lucid
