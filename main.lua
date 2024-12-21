-- main.lua
local function LoadLucid()
    local HttpService = game:GetService("HttpService")

    -- Initialize base structure
    local Lucid = {
        Name = "Lucid Hub",
        Version = "1.1.0",
        WindUIVersion = "1.0.0",
        Author = "ProbTom",
        LastUpdated = "2024-12-21",
        Initialized = false
    }

    -- Set up global environment
    if not getgenv then
        warn("[Lucid] getgenv not available")
        return false
    end
    
    getgenv().Lucid = Lucid

    -- Initialize WindUI first with explicit error handling
    local success, WindUI = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
    end)

    if not success or not WindUI then
        warn("[Lucid] Failed to load WindUI")
        return false
    end

    -- Create main window with safe indexing
    local success, MainWindow = pcall(function()
        return WindUI:CreateWindow({
            Name = "Lucid Hub",
            LoadingTitle = "Loading...",
            LoadingSubtitle = "by ProbTom",
            ConfigurationSaving = {
                Enabled = true,
                FolderName = "LucidHub",
                FileName = "Settings"
            }
        })
    end)

    if not success or not MainWindow then
        warn("[Lucid] Failed to create main window")
        return false
    end

    -- Store core components
    Lucid.WindUI = WindUI
    Lucid.MainWindow = MainWindow

    -- Load and initialize modules safely
    local moduleOrder = {"debug", "utils", "functions", "options", "ui"}
    local modules = {}

    -- Safe module loading function
    local function loadModule(name)
        local success, content = pcall(function()
            return game:HttpGet(string.format(
                "https://raw.githubusercontent.com/ProbTom/Lucid/main/%s.lua",
                name
            ))
        end)

        if not success or not content then
            warn("[Lucid] Failed to fetch module:", name)
            return nil
        end

        local success, module = pcall(function()
            return loadstring(content)()
        end)

        if not success or not module then
            warn("[Lucid] Failed to load module:", name)
            return nil
        end

        return module
    end

    -- Load modules in sequence
    for i, moduleName in ipairs(moduleOrder) do
        local module = loadModule(moduleName)
        if not module then
            warn("[Lucid] Critical module failed to load:", moduleName)
            return false
        end
        modules[moduleName] = module
    end

    -- Initialize modules with dependencies
    if modules.debug and type(modules.debug.init) == "function" then
        modules.debug.init({
            windui = WindUI,
            window = MainWindow
        })
    end

    if modules.utils and type(modules.utils.init) == "function" then
        modules.utils.init({
            windui = WindUI,
            window = MainWindow,
            debug = modules.debug
        })
    end

    if modules.functions and type(modules.functions.init) == "function" then
        modules.functions.init({
            windui = WindUI,
            window = MainWindow,
            debug = modules.debug,
            utils = modules.utils
        })
    end

    if modules.options and type(modules.options.init) == "function" then
        modules.options.init({
            windui = WindUI,
            window = MainWindow,
            debug = modules.debug,
            utils = modules.utils,
            functions = modules.functions
        })
    end

    if modules.ui and type(modules.ui.init) == "function" then
        modules.ui.init({
            windui = WindUI,
            window = MainWindow,
            debug = modules.debug,
            utils = modules.utils,
            functions = modules.functions,
            options = modules.options
        })
    end

    -- Merge modules into Lucid environment
    for name, module in pairs(modules) do
        Lucid[name] = module
    end

    -- Initialize settings
    if not isfolder("LucidHub") then
        makefolder("LucidHub")
    end

    -- Default settings
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
            Theme = "Dark",
            Transparency = 0
        }
    }

    -- Load or create settings
    local settings = defaultSettings
    if isfile("LucidHub/settings.json") then
        local success, loadedSettings = pcall(function()
            return HttpService:JSONDecode(readfile("LucidHub/settings.json"))
        end)
        if success and loadedSettings then
            settings = loadedSettings
        end
    end

    getgenv().Settings = settings

    -- Auto-save settings
    spawn(function()
        while wait(30) do
            if getgenv().Settings then
                pcall(function()
                    writefile("LucidHub/settings.json", 
                        HttpService:JSONEncode(getgenv().Settings)
                    )
                end)
            end
        end
    end)

    Lucid.Initialized = true
    if modules.debug then
        modules.debug.Info("Lucid Hub loaded successfully!")
    end

    return true
end

-- Execute with protected call
local success, result = pcall(LoadLucid)
if not success then
    warn("[Lucid] Critical error during initialization:", result)
end

return getgenv().Lucid
