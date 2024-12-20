-- loader.lua
-- Version: 1.0.1
-- Author: ProbTom
-- Created: 2024-12-20 16:34:06 UTC

local Loader = {
    Version = "1.0.1",
    BaseURL = "https://raw.githubusercontent.com/ProbTom/Lucid/main/",
    Modules = {
        "debug",    -- Debug system must be first
        "events",   -- Event system
        "utils",    -- Utility functions
        "ui"        -- UI components if you have them
    }
}

-- Basic logging (uses debug module once loaded)
local function log(msg, type)
    print(string.format("[LUCID %s] %s", type or "INFO", tostring(msg)))
end

-- Protected HTTP fetch
local function fetchModule(name)
    local success, content = pcall(function()
        return game:HttpGet(Loader.BaseURL .. name .. ".lua")
    end)
    
    if not success then
        log("Failed to fetch " .. name .. ": " .. tostring(content), "ERROR")
        return nil
    end
    
    return content
end

-- Protected module loading
local function loadModule(content, name)
    local func, err = loadstring(content)
    if not func then
        log("Failed to parse " .. name .. ": " .. tostring(err), "ERROR")
        return nil
    end
    
    local success, module = pcall(func)
    if not success then
        log("Failed to execute " .. name .. ": " .. tostring(module), "ERROR")
        return nil
    end
    
    return module
end

-- Initialize modules
local function init()
    log("Starting module initialization")
    
    -- Load each module
    for _, moduleName in ipairs(Loader.Modules) do
        log("Loading " .. moduleName)
        
        local content = fetchModule(moduleName)
        if not content then
            return false
        end
        
        local module = loadModule(content, moduleName)
        if not module then
            return false
        end
        
        getgenv().LucidState.Modules[moduleName] = module
    end
    
    -- Initialize modules in order
    for _, moduleName in ipairs(Loader.Modules) do
        local module = getgenv().LucidState.Modules[moduleName]
        if type(module) == "table" and type(module.init) == "function" then
            local success, err = pcall(function()
                module.init(getgenv().LucidState.Modules)
            end)
            
            if not success then
                log("Failed to initialize " .. moduleName .. ": " .. tostring(err), "ERROR")
                return false
            end
        end
    end
    
    log("All modules loaded successfully")
    return true
end

return init()
