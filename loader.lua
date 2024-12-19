-- loader.lua
if getgenv().LucidHubLoaded then
    warn("Lucid Hub: Already executed!")
    return
end

-- Initialize Config first
getgenv().Config = {
    Version = "1.0.0",
    Debug = false,
    URLs = {
        Main = "https://raw.githubusercontent.com/ProbTom/Lucid/main/",
        Backup = "https://raw.githubusercontent.com/ProbTom/Lucid/backup/"
    },
    
    Items = {
        FishRarities = {
            "Common",
            "Uncommon",
            "Rare",
            "Epic",
            "Legendary",
            "Mythical",
            "Enchant Relics",
            "Exotic",
            "Limited",
            "Gemstones"
        },
        
        RodRanking = {
            "Rod Of The Forgotten Fang",
            "Rod Of The Eternal King",
            "Rod Of The Depth",
            "No-Life Rod",
            "Krampus's Rod",
            "Trident Rod",
            "Kings Rod",
            "Aurora Rod",
            "Mythical Rod",
            "Destiny Rod",
            "Celestial Rod",
            "Voyager Rod",
            "Riptide Rod",
            "Seasons Rod",
            "Resourceful Rod",
            "Precision Rod",
            "Steady Rod",
            "Nocturnal Rod",
            "Reinforced Rod",
            "Magnet Rod",
            "Rapid Rod",
            "Fortune Rod",
            "Phoenix Rod",
            "Scurvy Rod",
            "Midas Rod",
            "Buddy Bond Rod",
            "Haunted Rod",
            "Relic Rod",
            "Antler Rod",
            "North-Star Rod",
            "Astral Rod",
            "Event Horizon Rod",
            "Candy Cane Rod",
            "Fungal Rod",
            "Magma Rod",
            "Long Rod",
            "Lucky Rod",
            "Fast Rod",
            "Stone Rod",
            "Carbon Rod",
            "Plastic Rod",
            "Training Rod",
            "Fischer's Rod",
            "Flimsy Rod"
        },
        
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
        AutoEquipBestRod = false,
        AutoCollectChests = false,
        ChestRange = 50
    }
}

-- Core Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Initialize environment
local function initializeEnvironment()
    if not game:IsLoaded() then
        game.Loaded:Wait()
    end
    
    -- Clean up existing UI elements
    pcall(function()
        if CoreGui:FindFirstChild("ClickButton") then
            CoreGui:FindFirstChild("ClickButton"):Destroy()
        end
    end)
end

-- Initialize global state
getgenv().State = {
    AutoFishing = false,
    AutoSelling = false,
    SelectedRarities = {},
    LastReelTime = 0,
    LastShakeTime = 0
}

-- Initialize Fluent UI
local function initializeFluentUI()
    if not getgenv().Fluent then
        local success, fluentLib = pcall(function()
            return loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
        end)
        
        if not success or not fluentLib then
            error("Failed to initialize Fluent UI")
            return false
        end
        
        getgenv().Fluent = fluentLib
    end
    return true
end

-- Initialize tabs structure
local function initializeTabs()
    if not getgenv().Tabs then
        getgenv().Tabs = {
            Main = nil,
            Items = nil,
            Settings = nil
        }
    end
end

-- Initialize options
local function initializeOptions()
    if not getgenv().Options then
        getgenv().Options = Config.Options
    end
end

-- Main initialization
local function initialize()
    initializeEnvironment()
    
    if not initializeFluentUI() then
        return false
    end
    
    initializeTabs()
    initializeOptions()
    
    -- Load core modules
    local modules = {
        "compatibility",
        "functions",
        "events",
        "ui",
        "MainTab",
        "ItemsTab"
    }
    
    for _, module in ipairs(modules) do
        local success, result = pcall(function()
            return loadstring(game:HttpGet(Config.URLs.Main .. module .. ".lua"))()
        end)
        
        if not success then
            warn("Failed to load module:", module, result)
            return false
        end
        
        task.wait(0.1) -- Small delay between module loads
    end
    
    return true
end

-- Execute initialization
if initialize() then
    getgenv().LucidHubLoaded = true
    if Config.Debug then
        print("Lucid Hub loaded successfully!")
    end
else
    warn("Failed to initialize Lucid Hub")
end

return true
