-- loader.lua
if getgenv().LucidHubLoaded then
    warn("Lucid Hub: Already executed!")
    return
end

local Loader = {
    _version = "1.0.1",
    _modules = {},
    _loaded = {},
    _initialized = false
}

-- Core initialization
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

    -- Load Fluent UI with retry mechanism
    local function loadFluentUI(retries)
        for i = 1, retries do
            local success, result = pcall(function()
                return loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
            end)

            if success and result then
                return result
            end
            task.wait(1)
        end
        return nil
    end

    -- Initialize Fluent UI
    local Fluent = loadFluentUI(3)
    if not Fluent then
        warn("Failed to load Fluent UI")
        return false
    end

    -- Store UI references globally
    getgenv().Fluent = Fluent

    -- Load UI addons
    pcall(function()
        getgenv().SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
        getgenv().InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
    end)

    return true
end

-- Module loading with retry mechanism
local function loadModule(moduleName, retries)
    if Loader._loaded[moduleName] then
        return Loader._modules[moduleName]
    end

    retries = retries or 3
    
    for attempt = 1, retries do
        local success, result = pcall(function()
            return loadstring(game:HttpGet(string.format(
                "https://raw.githubusercontent.com/ProbTom/Lucid/main/%s.lua",
                moduleName
            )))()
        end)

        if success and result then
            Loader._modules[moduleName] = result
            Loader._loaded[moduleName] = true
            
            -- Store in global state for cross-module access
            getgenv()[moduleName:gsub("^%l", string.upper)] = result
            
            if getgenv().Config and getgenv().Config.Debug then
                print(string.format("✓ Successfully loaded module: %s", moduleName))
            end
            return result
        end

        if attempt < retries then
            task.wait(1)
        end
    end
    
    warn(string.format("Failed to load module: %s", moduleName))
    return false
end

-- Initialize loader with correct dependency order
local function initialize()
    if not initializeCore() then
        warn("Failed to initialize core systems")
        return false
    end

    -- Define module loading order with dependencies
    local moduleOrder = {
        {name = "config", required = true},      -- Load config first
        {name = "events", required = true},      -- Load events before compatibility
        {name = "compatibility", required = true}, -- Now compatibility can use events
        {name = "functions", required = true},
        {name = "ui", required = true}
    }

    -- Load modules in order
    for _, module in ipairs(moduleOrder) do
        if not loadModule(module.name) and module.required then
            warn(string.format("Failed to load required module: %s", module.name))
            return false
        end
    end

    Loader._initialized = true
    getgenv().LucidHubLoaded = true
    return true
end

-- Run initialization
local success = initialize()

if not success then
    warn("⚠️ Lucid Hub failed to initialize completely")
    return false
end

return Loader
