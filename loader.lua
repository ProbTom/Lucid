-- loader.lua
if getgenv().LucidHubLoaded then
    warn("Lucid Hub: Already executed!")
    return
end

-- Core initialization with improved error handling
local function initializeCore()
    if not game:IsLoaded() then
        game.Loaded:Wait()
    end

    -- Initialize global state first
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

    -- Initialize config before loading modules
    getgenv().Config = {
        Version = "1.0.1",
        Debug = true,
        URLs = {
            Main = "https://raw.githubusercontent.com/ProbTom/Lucid/main/",
            Backup = "https://raw.githubusercontent.com/ProbTom/Lucid/backup/"
        },
        Items = {
            FishRarities = {"Common", "Rare", "Legendary", "Mythical", "Enchant Relics", "Exotic", "Limited", "Gemstones"},
            RodRanking = {},
            ChestSettings = {
                MinRange = 10,
                MaxRange = 100,
                DefaultRange = 50
            }
        },
        Options = {
            AutoFish = false,
            AutoReel = false,
            AutoShake = false,
            AutoSell = false,
            ChestRange = 50
        }
    }

    -- Initialize options
    getgenv().Options = {
        AutoFish = false,
        AutoReel = false,
        AutoShake = false,
        AutoSell = false,
        ChestRange = getgenv().Config.Items.ChestSettings.DefaultRange,
        AutoCollectChests = false
    }

    -- Load Fluent UI with error handling
    local success, Fluent = pcall(function()
        return loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
    end)

    if not success then
        warn("Failed to load Fluent UI:", Fluent)
        return false
    end

    -- Store UI references globally
    getgenv().Fluent = Fluent
    
    -- Load UI addons
    getgenv().SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
    getgenv().InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

    return true
end

-- Enhanced module loading with retry mechanism
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
            if getgenv().Config.Debug then
                print("✓ Successfully loaded module:", moduleName)
            end
            return result
        end

        if attempt < retries then
            task.wait(1) -- Wait before retry
            if getgenv().Config.Debug then
                warn(string.format("Retry %d/%d loading module: %s", attempt, retries, moduleName))
            end
        else
            warn("Failed to load module:", moduleName, result)
        end
    end

    return false
end

-- Main initialization sequence with dependency management
local function initialize()
    if not initializeCore() then
        warn("Failed to initialize core components")
        return false
    end

    -- Define module loading order with dependencies
    local moduleSequence = {
        {name = "functions", required = true},    -- Load functions first
        {name = "compatibility", required = true}, -- Load compatibility checks
        {name = "events", required = true},        -- Load event handlers
        {name = "ui", required = true},            -- Load UI system
        {name = "MainTab", required = false},      -- Load tabs
        {name = "ItemsTab", required = false}
    }

    -- Load modules in sequence
    local loadedModules = {}
    for _, module in ipairs(moduleSequence) do
        local moduleResult = loadModule(module.name)
        
        if not moduleResult and module.required then
            warn("Failed to load required module:", module.name)
            return false
        end
        
        loadedModules[module.name] = moduleResult
        
        -- Store important modules globally
        if module.name == "functions" then
            getgenv().Functions = moduleResult
        elseif module.name == "events" then
            getgenv().Events = moduleResult
        end
        
        -- Small delay between module loads
        task.wait(0.1)
    end

    -- Initialize SaveManager
    if getgenv().SaveManager then
        pcall(function()
            getgenv().SaveManager:SetLibrary(getgenv().Fluent)
            getgenv().SaveManager:SetFolder("LucidHub")
            getgenv().SaveManager:Load("LucidHub")
        end)
    end

    -- Set initialization flags
    getgenv().State.Initialized = true
    getgenv().LucidHubLoaded = true

    if getgenv().Config.Debug then
        print("✓ Lucid Hub loaded successfully!")
    end

    return true
end

-- Execute initialization with error handling
local success, result = pcall(initialize)

if not success or not result then
    warn("⚠️ Lucid Hub failed to initialize completely")
    -- Cleanup on failure
    if getgenv().State then
        getgenv().State.Initialized = false
    end
    return false
end

return true
