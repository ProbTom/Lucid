-- init.lua
-- Version: 1.0.1
-- Author: ProbTom
-- Created: 2024-12-20 14:52:47 UTC

local Lucid = {
    _VERSION = "1.0.1",
    _AUTHOR = "ProbTom",
    _DEBUG = true
}

-- Early initialization logger (independent of debug module)
local function init_log(msg)
    if Lucid._DEBUG then
        print(string.format("[LUCID INIT] %s", tostring(msg)))
    end
end

-- Safe require function
local function safe_require(moduleName)
    init_log("Loading " .. moduleName)
    local success, result = pcall(function()
        return require(moduleName)
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
    
    Lucid.modules = {}
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
