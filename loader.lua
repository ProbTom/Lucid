-- loader.lua
-- Core loader module for Lucid Hub
if getgenv().LucidHubLoaded then
    warn("Lucid Hub: Already executed!")
    return
end

local Loader = {
    _version = "1.0.1",
    _modules = {},
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
                -- Use Config.URLs.FluentUI once config is loaded
                return loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
            end)

            if success and result then
                return result
            end

            if i < retries then
                warn(string.format("Retry %d/%d loading Fluent UI", i, retries))
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

    return true
end

-- Module loading with retry mechanism
local function loadModule(moduleName, retries)
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
            print(string.format("✓ Successfully loaded module: %s", moduleName))
            return result
        end

        if attempt < retries then
            warn(string.format("Retry %d/%d loading module: %s", attempt, retries, moduleName))
            task.wait(1)
        else
            warn(string.format("Failed to load module: %s", moduleName))
        end
    end
    
    return false
end

-- Initialize loader
local function initialize()
    if not initializeCore() then
        warn("Failed to initialize core systems")
        return false
    end

    -- Load modules in correct order
    local moduleOrder = {
        "config",
        "compatibility",
        "functions",
        "events",
        "ui"
    }

    for _, moduleName in ipairs(moduleOrder) do
        if not loadModule(moduleName) then
            warn("Failed to load required module:", moduleName)
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
