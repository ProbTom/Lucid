-- main.lua
local Lucid = {
    Name = "Lucid Hub",
    Version = "1.1.0",
    WindUIVersion = "1.0.0",
    Author = "ProbTom",
    LastUpdated = "2024-12-21"
}

-- First, ensure WindUI is loaded
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
if not WindUI then
    warn("Failed to load WindUI")
    return
end

-- Create global environment
getgenv().Lucid = Lucid
getgenv().WindUI = WindUI

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

-- Create Lucid folder in ReplicatedStorage
local lucidFolder = ReplicatedStorage:FindFirstChild("Lucid") or Instance.new("Folder")
lucidFolder.Name = "Lucid"
lucidFolder.Parent = ReplicatedStorage

-- Load core modules
local success, error = pcall(function()
    -- Load loader first
    local Loader = loadstring(game:HttpGet("https://raw.githubusercontent.com/ProbTom/Lucid/main/loader.lua"))()
    if not Loader then
        error("Failed to load Lucid loader")
        return
    end

    -- Initialize modules with dependencies
    Lucid.Debug = Loader.load("debug")
    if not Lucid.Debug then error("Failed to load Debug module") end
    Lucid.Debug.init({windui = WindUI})

    Lucid.Utils = Loader.load("utils")
    if not Lucid.Utils then error("Failed to load Utils module") end
    Lucid.Utils.init({windui = WindUI, debug = Lucid.Debug})

    Lucid.Functions = Loader.load("functions")
    if not Lucid.Functions then error("Failed to load Functions module") end
    Lucid.Functions.init({windui = WindUI, debug = Lucid.Debug, utils = Lucid.Utils})

    Lucid.Options = Loader.load("options")
    if not Lucid.Options then error("Failed to load Options module") end
    Lucid.Options.init({windui = WindUI, debug = Lucid.Debug, utils = Lucid.Utils, functions = Lucid.Functions})

    Lucid.UI = Loader.load("ui")
    if not Lucid.UI then error("Failed to load UI module") end
    Lucid.UI.init({windui = WindUI, debug = Lucid.Debug, utils = Lucid.Utils, functions = Lucid.Functions})

    -- Create default settings if they don't exist
    if not isfolder("LucidHub") then
        makefolder("LucidHub")
    end

    -- Load or create settings
    local function loadSettings()
        if isfile("LucidHub/settings.json") then
            local success, settings = pcall(function()
                return HttpService:JSONDecode(readfile("LucidHub/settings.json"))
            end)
            if success and settings then
                return settings
            end
        end
        return Lucid.Options.getDefaultSettings()
    end

    -- Initialize settings
    getgenv().Settings = loadSettings()

    -- Start auto-save loop
    spawn(function()
        while wait(30) do
            if getgenv().Settings then
                writefile("LucidHub/settings.json", HttpService:JSONEncode(getgenv().Settings))
            end
        end
    end)

    -- Log successful initialization
    Lucid.Debug.Info("Lucid Hub v" .. Lucid.Version .. " loaded successfully!", true)
end)

if not success then
    warn("Failed to initialize Lucid:", error)
    if WindUI then
        WindUI:Notify({
            Title = "Initialization Error",
            Content = tostring(error),
            Duration = 10
        })
    end
end

-- Version check
spawn(function()
    local success, latestVersion = pcall(function()
        return game:HttpGet("https://raw.githubusercontent.com/ProbTom/Lucid/main/version.txt")
    end)
    
    if success and latestVersion ~= Lucid.Version then
        if WindUI then
            WindUI:Notify({
                Title = "Update Available",
                Content = "A new version of Lucid Hub is available: " .. latestVersion,
                Duration = 10
            })
        end
    end
end)

return Lucid
