-- loader.lua
if getgenv().LucidHubLoaded then
    warn("Lucid Hub: Already executed!")
    return
end

local Loader = {
    _version = "1.0.1",
    _modules = {},
    _loaded = {},
    _initialized = false,
    _baseUrl = "https://raw.githubusercontent.com/ProbTom/Lucid/main/%s.lua",
    _dependencies = {
        Fluent = {
            url = "https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua",
            required = true
        },
        SaveManager = {
            url = "https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua",
            required = false
        },
        InterfaceManager = {
            url = "https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua",
            required = false
        }
    }
}

-- Initialize core systems
local function initializeCore()
    if not game:IsLoaded() then
        game.Loaded:Wait()
    end

    -- Initialize global state
    getgenv().State = {
        AutoFishing = false,
        AutoSelling = false,
        SelectedRarities = {},
        LastReelTime = 0,
        LastShakeTime = 0,
        Events = {
            Available = {}
        },
        Initialized = false
    }

    -- Initialize global config
    getgenv().Config = {
        Debug = true,
        Version = Loader._version
    }

    -- Load UI dependencies
    for name, dep in pairs(Loader._dependencies) do
        if not getgenv()[name] then
            local success, result = pcall(function()
                return loadstring(game:HttpGet(dep.url))()
            end)
            
            if success and result then
                getgenv()[name] = result
            elseif dep.required then
                warn(string.format("Failed to load required dependency: %s", name))
                return false
            end
        end
    end

    return true
end

-- Enhanced module loading with retry mechanism
local function loadModule(moduleName, retries)
    if Loader._loaded[moduleName] then
        return Loader._modules[moduleName]
    end

    retries = retries or 3
    
    for attempt = 1, retries do
        local success, result = pcall(function()
            return loadstring(game:HttpGet(string.format(Loader._baseUrl, moduleName)))()
        end)

        if success and result then
            Loader._modules[moduleName] = result
            Loader._loaded[moduleName] = true
            
            -- Store in global state for cross-module access
            getgenv()[moduleName:gsub("^%l", string.upper)] = result
            
            if getgenv().Config and getgenv().Config.Debug then
                print(string.format("✓ Successfully loaded module: %s", moduleName))
            end
            
            -- Wait for module initialization if needed
            local initAttempts = 0
            while result._initialized ~= nil and not result._initialized and initAttempts < 10 do
                task.wait(0.1)
                initAttempts = initAttempts + 1
            end
            
            return result
        end

        if attempt < retries then
            task.wait(1)
            if getgenv().Config and getgenv().Config.Debug then
                warn(string.format("Retrying module load: %s (Attempt %d/%d)", moduleName, attempt, retries))
            end
        end
    end
    
    warn(string.format("Failed to load module: %s after %d attempts", moduleName, retries))
    return false
end

-- Module dependency order
local moduleOrder = {
    {name = "events", required = true},
    {name = "compatibility", required = true},
    {name = "functions", required = true},
    {name = "ui", required = true}
}

-- Main initialization
local function initialize()
    if not initializeCore() then
        warn("Failed to initialize core systems")
        return false
    end

    -- Load modules in order
    for _, module in ipairs(moduleOrder) do
        if not loadModule(module.name) and module.required then
            warn(string.format("Failed to load required module: %s", module.name))
            return false
        end
        task.wait(0.2)
    end

    Loader._initialized = true
    getgenv().LucidHubLoaded = true
    
    if getgenv().Config and getgenv().Config.Debug then
        print(string.format("✓ Lucid Hub initialized successfully (v%s)", Loader._version))
    end
    
    return true
end

-- Cleanup function
local function cleanup()
    -- Clean up modules
    for name, module in pairs(Loader._modules) do
        if type(module.Cleanup) == "function" then
            pcall(module.Cleanup)
        end
    end

    -- Clear global states
    getgenv().LucidHubLoaded = nil
    
    -- Clear module cache
    Loader._modules = {}
    Loader._loaded = {}
    Loader._initialized = false
end

-- Error handler
local function errorHandler(err)
    warn("⚠️ Lucid Hub encountered an error:")
    warn(debug.traceback(err))
    cleanup()
    return false
end

-- Run initialization with error handling
local success = xpcall(initialize, errorHandler)

if not success then
    warn("⚠️ Lucid Hub failed to initialize completely")
    cleanup()
    return false
end

-- Setup cleanup on teleport
game:GetService("Players").LocalPlayer.OnTeleport:Connect(cleanup)

return Loader
