-- compatibility.lua
local Compatibility = {}

-- Core Services
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Constants
local REQUIRED_SERVICES = {
    "Players",
    "ReplicatedStorage",
    "RunService",
    "UserInputService",
    "CoreGui"
}

local REQUIRED_FUNCTIONS = {
    "getgenv",
    "hookfunction",
    "newcclosure",
    "setreadonly",
    "getrawmetatable"
}

-- Version handling and checks
Compatibility.CheckVersion = function()
    local currentVersion = getgenv().Config.Version or "1.0.0"
    local latestVersion = "1.0.0"
    
    return {
        current = currentVersion,
        latest = latestVersion,
        needsUpdate = currentVersion ~= latestVersion
    }
end

-- Required game services validation
Compatibility.ValidateServices = function()
    local missing = {}
    for _, service in ipairs(REQUIRED_SERVICES) do
        if not pcall(function() return game:GetService(service) end) then
            table.insert(missing, service)
        end
    end
    
    return #missing == 0, missing
end

-- Game event system compatibility
Compatibility.ValidateGameEvents = function()
    local events = ReplicatedStorage:FindFirstChild("events") or ReplicatedStorage:FindFirstChild("Events")
    if not events then
        -- Create events folder if it doesn't exist
        events = Instance.new("Folder")
        events.Name = "events"
        events.Parent = ReplicatedStorage
    end
    
    -- Create required remote events if they don't exist
    local requiredEvents = {
        "castrod",
        "reelfinished",
        "character"
    }
    
    for _, eventName in ipairs(requiredEvents) do
        if not events:FindFirstChild(eventName) then
            local newEvent = Instance.new("RemoteEvent")
            newEvent.Name = eventName
            newEvent.Parent = events
        end
    end
    
    return true, {}
end

-- Script environment validation
Compatibility.ValidateEnvironment = function()
    local missing = {}
    for _, funcName in ipairs(REQUIRED_FUNCTIONS) do
        if type(_G[funcName]) ~= "function" then
            table.insert(missing, funcName)
        end
    end
    
    return #missing == 0, missing
end

-- Anti-cheat bypass setup
Compatibility.SetupAntiCheatBypass = function()
    local success = pcall(function()
        local mt = getrawmetatable(game)
        if not mt then return false end
        
        local old = mt.__namecall
        setreadonly(mt, false)
        
        mt.__namecall = newcclosure(function(self, ...)
            local args = {...}
            local method = getnamecallmethod()
            
            if method == "FireServer" or method == "InvokeServer" then
                local remoteName = self.Name:lower()
                if remoteName:match("cheat") or remoteName:match("detect") or remoteName:match("violation") then
                    return
                end
            end
            
            return old(self, ...)
        end)
        
        setreadonly(mt, true)
    end)
    
    return success
end

-- Module configuration validation
Compatibility.ValidateConfig = function()
    if not getgenv().Config then
        getgenv().Config = {
            Version = "1.0.0",
            Debug = true,
            URLs = {
                Main = "https://raw.githubusercontent.com/ProbTom/Lucid/main/",
                Backup = "https://raw.githubusercontent.com/ProbTom/Lucid/backup/"
            },
            Items = {
                FishRarities = {"Common", "Rare", "Legendary"},
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
    end
    return true, {}
end

-- Global state validation
Compatibility.ValidateState = function()
    if not getgenv().State then
        getgenv().State = {
            AutoFishing = false,
            AutoSelling = false,
            SelectedRarities = {},
            LastReelTime = 0,
            LastShakeTime = 0
        }
    end
    return true, {}
end

-- Initialize all compatibility checks
local function InitializeCompatibility()
    -- Initialize config and state first
    Compatibility.ValidateConfig()
    Compatibility.ValidateState()
    
    local checks = {
        {name = "Environment", func = Compatibility.ValidateEnvironment},
        {name = "Services", func = Compatibility.ValidateServices},
        {name = "Game Events", func = Compatibility.ValidateGameEvents}
    }
    
    local failed = {}
    for _, check in ipairs(checks) do
        local success, missing = check.func()
        if not success then
            if getgenv().Config.Debug then
                warn(string.format("⚠️ %s check failed: %s", 
                    check.name, 
                    table.concat(missing, ", ")
                ))
            end
        end
    end
    
    -- Setup anti-cheat bypass
    Compatibility.SetupAntiCheatBypass()
    
    return true
end

-- Run initialization
if not InitializeCompatibility() then
    if getgenv().Config.Debug then
        warn("⚠️ Compatibility initialization completed with warnings")
    end
end

return Compatibility
