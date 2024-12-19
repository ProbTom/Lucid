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

    -- Load Fluent UI with error handling
    local success, Fluent = pcall(function()
        return loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
    end)

    if not success or not Fluent then
        warn("Failed to load Fluent UI:", Fluent)
        return false
    end

    -- Store UI references globally
    getgenv().Fluent = Fluent
    getgenv().Window = nil -- Will be set by UI module
    
    -- Load UI addons
    pcall(function()
        getgenv().SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
        getgenv().InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
    end)

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
            print("✓ Successfully loaded module:", moduleName)
            return result
        end

        if attempt < retries then
            warn(string.format("Retry %d/%d loading module: %s", attempt, retries, moduleName))
            task.wait(1)
        else
            warn("Failed to load module:", moduleName, result)
            return false
        end
    end
    
    return false
end

-- Initialize core first
local coreSuccess = initializeCore()
if not coreSuccess then
    warn("Failed to initialize core systems")
    return
end

-- Load modules in correct order
local moduleOrder = {
    "functions",
    "compatibility",
    "events",
    "ui"
}

for _, moduleName in ipairs(moduleOrder) do
    if not loadModule(moduleName) then
        warn("Failed to load required module:", moduleName)
        return
    end
end

getgenv().LucidHubLoaded = true
