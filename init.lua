-- init.lua
-- Version: 1.0.1
-- Author: ProbTom
-- Created: 2024-12-20 15:08:06 UTC

local Lucid = {
    _VERSION = "1.0.1",
    _AUTHOR = "ProbTom",
    _DEBUG = true
}

-- Create folder for modules
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local lucidFolder = Instance.new("Folder")
lucidFolder.Name = "Lucid"
lucidFolder.Parent = ReplicatedStorage

-- Function to create a ModuleScript
local function createModule(name, source)
    local module = Instance.new("ModuleScript")
    module.Name = name
    module.Source = game:HttpGet("https://raw.githubusercontent.com/ProbTom/Lucid/main/" .. name .. ".lua")
    module.Parent = lucidFolder
    return module
end

-- Early initialization logger
local function init_log(msg)
    if Lucid._DEBUG then
        print(string.format("[LUCID INIT] %s", tostring(msg)))
    end
end

-- Safe require function modified for Roblox
local function safe_require(moduleName)
    init_log("Loading " .. moduleName)
    
    -- Create module if it doesn't exist
    if not lucidFolder:FindFirstChild(moduleName) then
        local success, err = pcall(function()
            return createModule(moduleName)
        end)
        if not success then
            init_log("Failed to create module " .. moduleName .. ": " .. tostring(err))
            return nil
        end
    end
    
    -- Require the module
    local success, result = pcall(function()
        return require(lucidFolder:WaitForChild(moduleName))
    end)
    
    if not success then
        init_log("Failed to load " .. moduleName .. ": " .. tostring(result))
        return nil
    end
    
    return result
end

-- Module initialization sequence
local MODULES = {
    {name = "debug", critical = true},
    {name = "utils", critical = true},
    {name = "events", critical = true},
    {name = "state", critical = true},
    {name = "ui", critical = false}
}

-- Module container
Lucid.modules = {}

-- Initialize core system
function Lucid.Initialize()
    init_log("Starting initialization sequence")
    
    -- Load each module in sequence
    for _, moduleInfo in ipairs(MODULES) do
        local module = safe_require(moduleInfo.name)
        
        if not module then
            if moduleInfo.critical then
                init_log("Critical module failed to load: " .. moduleInfo.name)
                return false
            else
                init_log("Non-critical module failed to load: " .. moduleInfo.name)
            end
        else
            -- Store loaded module
            Lucid.modules[moduleInfo.name] = module
            
            -- Initialize module if it has init function
            if type(module.init) == "function" then
                local success, err = pcall(function()
                    return module.init(Lucid.modules)
                end)
                
                if not success then
                    init_log("Module initialization failed: " .. moduleInfo.name .. " - " .. tostring(err))
                    if moduleInfo.critical then
                        return false
                    end
                end
            end
        end
    end
    
    init_log("Initialization sequence completed")
    return true
end

-- System shutdown
function Lucid.Shutdown()
    init_log("Beginning shutdown sequence")
    
    -- Shutdown modules in reverse order
    for i = #MODULES, 1, -1 do
        local moduleName = MODULES[i].name
        local module = Lucid.modules[moduleName]
        
        if module and type(module.shutdown) == "function" then
            pcall(function()
                module.shutdown()
            end)
        end
    end
    
    -- Clean up modules
    Lucid.modules = {}
    lucidFolder:Destroy()
    init_log("Shutdown complete")
end

-- Error handler
function Lucid.HandleError(err)
    init_log("ERROR: " .. tostring(err))
    
    if Lucid.modules.debug then
        Lucid.modules.debug.Error(err)
    end
end

-- Initialize the system
local success, err = pcall(Lucid.Initialize)
if not success then
    Lucid.HandleError(err)
end

return Lucid
