-- loader.lua
-- Version: 1.0.1
-- Author: ProbTom
-- Last Updated: 2024-12-20 14:49:17 UTC

local Loader = {}

-- Add early debug function for loader
local function loaderDebug(msg)
    print("[LUCID LOADER]", msg)
end

-- Module loading with detailed error reporting
function Loader.LoadModule(name)
    loaderDebug("Attempting to load module: " .. name)
    
    if not name then
        loaderDebug("Error: Module name is nil")
        return nil
    end

    -- Check if module is already loaded
    if loadedModules and loadedModules[name] then
        loaderDebug("Module already loaded: " .. name)
        return loadedModules[name]
    end

    -- Initialize loadedModules if it doesn't exist
    if not loadedModules then
        loaderDebug("Initializing loadedModules table")
        loadedModules = {}
    end

    -- Try to load the module
    local success, result = pcall(function()
        local moduleCode = [[
            -- Your module code here for ]] .. name .. [[.lua
        ]]
        
        loaderDebug("Parsing module: " .. name)
        local moduleFunc = loadstring(moduleCode)
        
        if not moduleFunc then
            error("Failed to parse module code")
        end
        
        loaderDebug("Executing module: " .. name)
        local module = moduleFunc()
        
        if not module then
            error("Module returned nil")
        end
        
        return module
    end)

    if not success then
        loaderDebug("Failed to load module " .. name .. ": " .. tostring(result))
        return nil
    end

    -- Store the loaded module
    loadedModules[name] = result
    loaderDebug("Successfully loaded module: " .. name)

    -- Initialize the module if it has an init function
    if type(result.init) == "function" then
        loaderDebug("Initializing module: " .. name)
        success, err = pcall(function()
            result.init(loadedModules)
        end)
        
        if not success then
            loaderDebug("Failed to initialize module " .. name .. ": " .. tostring(err))
            return nil
        end
    end

    return result
end

-- Initialize loader with proper order
function Loader.Initialize()
    loaderDebug("Starting initialization sequence")
    
    -- Define loading order
    local loadOrder = {
        "debug",    -- Load debug first
        "config",   -- Then configuration
        "utils",    -- Utilities next
        "events",   -- Events system
        "state",    -- State management
        "ui"        -- UI last
    }

    -- Load each module in order
    for _, moduleName in ipairs(loadOrder) do
        loaderDebug("Loading module in sequence: " .. moduleName)
        local module = Loader.LoadModule(moduleName)
        
        if not module then
            loaderDebug("Critical error loading " .. moduleName)
            return false
        end
    end

    loaderDebug("Initialization sequence completed")
    return true
end

return Loader
