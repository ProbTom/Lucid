-- loader.lua
if getgenv().LucidHubLoaded then
    warn("Lucid Hub: Already executed!")
    return
end

-- Core initialization with error handling
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

    -- Load Fluent UI with error handling
    local success, Fluent = pcall(function()
        return loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
    end)

    if not success then
        warn("Failed to load Fluent UI:", Fluent)
        return false
    end

    -- Initialize global references
    getgenv().Fluent = Fluent
    getgenv().SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
    getgenv().InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

    return true
end

-- Module loading with error handling
local function loadModule(moduleName)
    local success, result = pcall(function()
        return loadstring(game:HttpGet(string.format(
            "https://raw.githubusercontent.com/ProbTom/Lucid/main/%s.lua",
            moduleName
        )))()
    end)

    if not success then
        warn("Failed to load module:", moduleName, result)
        return false
    end

    return true
end

-- Main initialization sequence
local function initialize()
    if not initializeCore() then
        warn("Failed to initialize core components")
        return false
    end

    -- Load modules in order with dependency checking
    local modules = {
        {name = "config", required = true},
        {name = "compatibility", required = true},
        {name = "functions", required = true},
        {name = "events", required = true},
        {name = "Tab", required = true},
        {name = "MainTab", required = false},
        {name = "ItemsTab", required = false},
        {name = "ui", required = false}
    }

    for _, module in ipairs(modules) do
        local success = loadModule(module.name)
        if not success and module.required then
            warn("Failed to load required module:", module.name)
            return false
        end
    end

    -- Initialize SaveManager
    if getgenv().SaveManager then
        getgenv().SaveManager:SetLibrary(getgenv().Fluent)
        getgenv().SaveManager:SetFolder("LucidHub")
        getgenv().SaveManager:Load("LucidHub")
    end

    -- Set initialization flag
    getgenv().State.Initialized = true
    getgenv().LucidHubLoaded = true

    if getgenv().Config and getgenv().Config.Debug then
        print("✓ Lucid Hub loaded successfully!")
    end

    return true
end

-- Execute initialization
if not initialize() then
    warn("⚠️ Lucid Hub failed to initialize completely")
    -- Attempt to clean up if initialization failed
    if getgenv().State then
        getgenv().State.Initialized = false
    end
    return false
end

return true
