-- loader.lua
if getgenv().LucidHubLoaded then
    warn("Lucid Hub: Already executed!")
    return
end

local Loader = {
    _version = "1.0.1",
    _modules = {},
    _loaded = {},  -- Track loaded modules
    _initialized = false
}

-- Core initialization
local function initializeCore()
    if not game:IsLoaded() then
        game.Loaded:Wait()
    end

    -- Initialize global state first
    if not getgenv().State then
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
    end

    -- Load Fluent UI with retry mechanism
    if not getgenv().Fluent then
        local function loadFluentUI(retries)
            for i = 1, retries do
                local success, result = pcall(function()
                    return loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
                end)

                if success and result then
                    return result
                end

                if i < retries then
                    task.wait(1)
                end
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
    end

    return true
end

-- Module loading with duplicate prevention
local function loadModule(moduleName, retries)
    -- Check if module is already loaded
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
            print(string.format("✓ Successfully loaded module: %s", moduleName))
            return result
        end

        if attempt < retries then
            task.wait(1)
        end
    end
    
    warn(string.format("Failed to load module: %s", moduleName))
    return false
end

-- Initialize loader
local function initialize()
    if Loader._initialized then
        return true
    end

    if not initializeCore() then
        warn("Failed to initialize core systems")
        return false
    end

    -- Load modules in correct order with dependency checks
    local moduleOrder = {
        {name = "config", required = true},
        {name = "compatibility", required = true},
        {name = "functions", required = true},
        {name = "events", required = true},
        {name = "ui", required = true}
    }

    for _, module in ipairs(moduleOrder) do
        if not loadModule(module.name) and module.required then
            warn("Failed to load required module:", module.name)
            return false
        end
    end

    Loader._initialized = true
    getgenv().LucidHubLoaded = true
    return true
end

-- Run initialization with cleanup on failure
local success = initialize()

if not success then
    warn("⚠️ Lucid Hub failed to initialize completely")
    -- Cleanup any partial initialization
    if getgenv().LucidUI and getgenv().LucidUI._components then
        pcall(function()
            if getgenv().LucidUI._components.Window then
                getgenv().LucidUI._components.Window:Destroy()
            end
        end)
    end
    return false
end

return Loader
