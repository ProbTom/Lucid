-- main.lua
local function LoadLucid()
    -- Create base environment first
    local Lucid = {
        Name = "Lucid Hub",
        Version = "1.1.0",
        WindUIVersion = "1.0.0",
        Author = "ProbTom",
        LastUpdated = "2024-12-21"
    }

    -- Set up global access early
    getgenv().Lucid = Lucid

    -- Load WindUI with proper error handling
    local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
    if not WindUI then
        warn("[Lucid] Failed to load WindUI")
        return false
    end

    -- Create window immediately after WindUI loads
    local MainWindow = WindUI:CreateWindow({
        Name = "Lucid Hub",
        LoadingTitle = "Lucid Hub",
        LoadingSubtitle = "by ProbTom",
        ConfigurationSaving = {
            Enabled = true,
            FolderName = "LucidHub",
            FileName = "LucidHub_Settings"
        },
        KeySystem = false
    })

    if not MainWindow then
        warn("[Lucid] Failed to create main window")
        return false
    end

    -- Store these in the environment
    Lucid.WindUI = WindUI
    Lucid.MainWindow = MainWindow

    -- Load loader with error handling
    local success, Loader = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/ProbTom/Lucid/main/loader.lua"))()
    end)

    if not success or not Loader then
        warn("[Lucid] Failed to load loader:", Loader)
        return false
    end

    -- Initialize core modules with proper dependency injection
    local modules = {
        Debug = {
            module = Loader.load("debug"),
            deps = {windui = WindUI, window = MainWindow}
        },
        Utils = {
            module = nil,
            deps = nil
        },
        Functions = {
            module = nil,
            deps = nil
        },
        Options = {
            module = nil,
            deps = nil
        },
        UI = {
            module = nil,
            deps = nil
        }
    }

    -- Load Debug first
    if not modules.Debug.module then
        warn("[Lucid] Failed to load Debug module")
        return false
    end

    -- Initialize Debug
    local Debug = modules.Debug.module
    Debug.init(modules.Debug.deps)

    -- Now load remaining modules in order
    modules.Utils.module = Loader.load("utils")
    modules.Utils.deps = {
        windui = WindUI,
        window = MainWindow,
        debug = Debug
    }

    modules.Functions.module = Loader.load("functions")
    modules.Functions.deps = {
        windui = WindUI,
        window = MainWindow,
        debug = Debug,
        utils = modules.Utils.module
    }

    modules.Options.module = Loader.load("options")
    modules.Options.deps = {
        windui = WindUI,
        window = MainWindow,
        debug = Debug,
        utils = modules.Utils.module,
        functions = modules.Functions.module
    }

    modules.UI.module = Loader.load("ui")
    modules.UI.deps = {
        windui = WindUI,
        window = MainWindow,
        debug = Debug,
        utils = modules.Utils.module,
        functions = modules.Functions.module,
        options = modules.Options.module
    }

    -- Initialize each module in sequence
    for name, data in pairs(modules) do
        if not data.module then
            Debug.Error("Failed to load " .. name .. " module")
            return false
        end

        local success = pcall(function()
            data.module.init(data.deps)
        end)

        if not success then
            Debug.Error("Failed to initialize " .. name .. " module")
            return false
        end

        -- Store initialized module in Lucid environment
        Lucid[name] = data.module
    end

    -- Create settings handler
    if not isfolder("LucidHub") then
        makefolder("LucidHub")
    end

    -- Load or create settings
    local function loadSettings()
        if isfile("LucidHub/settings.json") then
            local success, settings = pcall(function()
                return game:GetService("HttpService"):JSONDecode(readfile("LucidHub/settings.json"))
            end)
            if success and settings then
                return settings
            end
        end
        return Lucid.Options.getDefaultSettings()
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

    Debug.Info("Lucid Hub v" .. Lucid.Version .. " loaded successfully!")
    return true
end

-- Execute with error handling
local success = pcall(LoadLucid)
if not success then
    warn("[Lucid] Critical error during initialization")
end

return getgenv().Lucid
