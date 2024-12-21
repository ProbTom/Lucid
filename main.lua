-- main.lua
local function LoadLucid()
    -- First load and verify WindUI
    local success, WindUI = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
    end)

    if not success or not WindUI then
        warn("Failed to load WindUI:", WindUI)
        return false
    end

    -- Create base environment
    local Lucid = {
        Name = "Lucid Hub",
        Version = "1.1.0",
        WindUIVersion = "1.0.0",
        Author = "ProbTom",
        LastUpdated = "2024-12-21"
    }

    -- Set up global access
    getgenv().Lucid = Lucid
    getgenv().WindUI = WindUI

    -- Load loader with proper error handling
    local Loader = loadstring(game:HttpGet("https://raw.githubusercontent.com/ProbTom/Lucid/main/loader.lua"))()
    if not Loader then
        warn("Failed to load Lucid loader")
        return false
    end

    -- Verify WindUI is properly loaded
    if not WindUI.CreateWindow then
        warn("WindUI not properly initialized")
        return false
    end

    -- Initialize base window first
    local MainWindow = WindUI:CreateWindow({
        Title = "Lucid Hub",
        Icon = "rbxassetid://7733960981", -- Fishing icon
        Theme = "Dark",
        SaveConfig = true,
        ConfigFolder = "LucidHub"
    })

    if not MainWindow then
        warn("Failed to create main window")
        return false
    end

    -- Load core modules with proper dependency injection
    local modules = {
        Debug = Loader.load("debug"),
        Utils = Loader.load("utils"),
        Functions = Loader.load("functions"),
        Options = Loader.load("options"),
        UI = Loader.load("ui")
    }

    -- Verify all modules loaded
    for name, module in pairs(modules) do
        if not module then
            warn("Failed to load module:", name)
            return false
        end
    end

    -- Initialize modules in correct order with proper dependencies
    local initSuccess = pcall(function()
        modules.Debug.init({
            windui = WindUI,
            window = MainWindow
        })

        modules.Utils.init({
            windui = WindUI,
            window = MainWindow,
            debug = modules.Debug
        })

        modules.Functions.init({
            windui = WindUI,
            window = MainWindow,
            debug = modules.Debug,
            utils = modules.Utils
        })

        modules.Options.init({
            windui = WindUI,
            window = MainWindow,
            debug = modules.Debug,
            utils = modules.Utils,
            functions = modules.Functions
        })

        modules.UI.init({
            windui = WindUI,
            window = MainWindow,
            debug = modules.Debug,
            utils = modules.Utils,
            functions = modules.Functions
        })
    end)

    if not initSuccess then
        warn("Failed to initialize modules")
        return false
    end

    -- Merge modules into Lucid environment
    for name, module in pairs(modules) do
        Lucid[name] = module
    end

    -- Create settings system
    if not isfolder("LucidHub") then
        makefolder("LucidHub")
    end

    -- Settings management
    local function loadSettings()
        if isfile("LucidHub/settings.json") then
            local success, settings = pcall(function()
                return game:GetService("HttpService"):JSONDecode(readfile("LucidHub/settings.json"))
            end)
            if success and settings then
                return settings
            end
        end
        return modules.Options.getDefaultSettings()
    end

    getgenv().Settings = loadSettings()

    -- Auto-save settings
    spawn(function()
        while wait(30) do
            if getgenv().Settings then
                writefile("LucidHub/settings.json", game:GetService("HttpService"):JSONEncode(getgenv().Settings))
            end
        end
    end)

    -- Version checker
    spawn(function()
        local success, latestVersion = pcall(function()
            return game:HttpGet("https://raw.githubusercontent.com/ProbTom/Lucid/main/version.txt")
        end)
        
        if success and latestVersion ~= Lucid.Version then
            modules.Debug.Info("Update available: v" .. latestVersion, true)
        end
    end)

    modules.Debug.Info("Lucid Hub v" .. Lucid.Version .. " loaded successfully!", true)
    return true
end

-- Execute with error handling
local success, result = pcall(LoadLucid)
if not success then
    warn("Critical error loading Lucid:", result)
end

return getgenv().Lucid
