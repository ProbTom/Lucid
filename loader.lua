-- loader.lua
if getgenv().LucidHubLoaded then
    warn("Lucid Hub: Already executed!")
    return
end

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
if not getgenv().State then
    getgenv().State = {
        AutoFishing = false,
        AutoSelling = false,
        SelectedRarities = {},
        LastReelTime = 0,
        LastShakeTime = 0
    }
end

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
        getgenv().Options = {
            AutoFish = false,
            AutoReel = false,
            AutoShake = false,
            AutoSell = false,
            ChestRange = 50
        }
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
            return loadstring(game:HttpGet(getgenv().Config.URLs.Main .. module .. ".lua"))()
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
    if getgenv().Config.Debug then
        print("Lucid Hub loaded successfully!")
    end
else
    warn("Failed to initialize Lucid Hub")
end

return true
