-- loader.lua
local Loader = {
    _VERSION = "1.1.0",
    LastUpdated = "2024-12-21"
}

-- Core dependency URLs
local Dependencies = {
    UI = "https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/wind",
    Modules = {
        Debug = "https://raw.githubusercontent.com/ProbTom/Lucid/main/modules/debug.lua",
        Utils = "https://raw.githubusercontent.com/ProbTom/Lucid/main/modules/utils.lua",
        Functions = "https://raw.githubusercontent.com/ProbTom/Lucid/main/modules/functions.lua",
        UI = "https://raw.githubusercontent.com/ProbTom/Lucid/main/modules/ui.lua"
    }
}

-- Core services
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

-- Environment verification
local function verifyEnvironment()
    assert(getgenv, "getgenv not available")
    assert(game, "game not available")
    assert(HttpService, "HttpService not available")
    assert(Players, "Players not available")
    return true
end

-- Safe HTTP get
local function safeGet(url)
    local success, result = pcall(function()
        return game:HttpGet(url)
    end)
    
    if not success then
        warn("[Loader] Failed to fetch:", url)
        return nil
    end
    return result
end

-- Safe loadstring
local function safeLoad(source)
    local success, result = pcall(function()
        return loadstring(source)()
    end)
    
    if not success then
        warn("[Loader] Failed to load source")
        return nil
    end
    return result
end

-- Initialize UI Library
local function initializeUI()
    local uiSource = safeGet(Dependencies.UI)
    if not uiSource then return nil end
    
    local UI = safeLoad(uiSource)
    if not UI or type(UI.CreateLib) ~= "function" then
        warn("[Loader] Invalid UI library")
        return nil
    end
    
    return UI
end

-- Load module
local function loadModule(name, url, dependencies)
    local source = safeGet(url)
    if not source then return nil end
    
    local module = safeLoad(source)
    if not module then return nil end
    
    if type(module.init) == "function" then
        local success = pcall(function()
            module.init(dependencies)
        end)
        
        if not success then
            warn("[Loader] Failed to initialize module:", name)
            return nil
        end
    end
    
    return module
end

-- Initialize settings
local function initializeSettings()
    local defaultSettings = {
        AutoFish = false,
        AutoReel = false,
        AutoShake = false,
        CastMode = "Legit",
        Items = {
            ChestCollector = {
                Enabled = false,
                Range = 50
            },
            AutoSell = {
                Enabled = false,
                Rarities = {}
            }
        },
        UI = {
            Theme = "Ocean",
            MinimizeKey = Enum.KeyCode.RightControl
        }
    }
    
    -- Create settings directory
    if not isfolder("LucidHub") then
        pcall(function()
            makefolder("LucidHub")
        end)
    end
    
    -- Load existing settings or use defaults
    local settings = defaultSettings
    if isfile("LucidHub/settings.json") then
        pcall(function()
            local data = readfile("LucidHub/settings.json")
            local decoded = HttpService:JSONDecode(data)
            if type(decoded) == "table" then
                settings = decoded
            end
        end)
    end
    
    return settings
end

function Loader.start()
    -- Verify environment
    if not verifyEnvironment() then
        return false
    end
    
    -- Initialize core components
    local UI = initializeUI()
    if not UI then
        warn("[Loader] Failed to initialize UI")
        return false
    end
    
    -- Create window
    local MainWindow = UI.CreateLib("Lucid Hub", "Ocean")
    if not MainWindow then
        warn("[Loader] Failed to create main window")
        return false
    end
    
    -- Initialize settings
    local Settings = initializeSettings()
    getgenv().Settings = Settings
    
    -- Initialize modules with dependencies
    local modules = {}
    local dependencies = {
        ui = UI,
        window = MainWindow,
        settings = Settings
    }
    
    -- Load modules in order
    for name, url in pairs(Dependencies.Modules) do
        modules[name] = loadModule(name, url, dependencies)
        if not modules[name] then
            warn("[Loader] Failed to load module:", name)
            return false
        end
        dependencies[string.lower(name)] = modules[name]
    end
    
    -- Create global access
    getgenv().Lucid = {
        Name = "Lucid Hub",
        Version = "1.1.0",
        Author = "ProbTom",
        LastUpdated = "2024-12-21",
        UI = UI,
        Window = MainWindow,
        Modules = modules,
        Settings = Settings
    }
    
    return true
end

return Loader
