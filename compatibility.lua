-- compatibility.lua
local Compatibility = {}

-- Core Services
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Initialize Config if not exists
if not getgenv().Config then
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
end

-- Initialize State if not exists
if not getgenv().State then
    getgenv().State = {
        AutoFishing = false,
        AutoSelling = false,
        SelectedRarities = {},
        LastReelTime = 0,
        LastShakeTime = 0,
        Events = {
            Available = {}
        }
    }
end

-- Version handling and checks
Compatibility.CheckVersion = function()
    return {
        current = getgenv().Config.Version,
        latest = "1.0.1",
        needsUpdate = false
    }
end

-- Required game services validation
Compatibility.ValidateServices = function()
    local required = {
        "Players",
        "ReplicatedStorage",
        "RunService",
        "UserInputService",
        "CoreGui"
    }
    
    local missing = {}
    for _, service in ipairs(required) do
        if not pcall(function() return game:GetService(service) end) then
            table.insert(missing, service)
        end
    end
    
    return #missing == 0, missing
end

-- Game Events Setup with improved error handling
Compatibility.SetupGameEvents = function()
    local events = ReplicatedStorage:FindFirstChild("events")
    if not events then
        if getgenv().Config.Debug then
            warn("⚠️ Events folder not found in ReplicatedStorage, creating fallback handlers")
        end
        -- Create a fallback events table
        getgenv().State.Events.Available = {
            castrod = false,
            reelfinished = false,
            character = false
        }
        return true
    end

    -- Check required events
    local requiredEvents = {
        "castrod",
        "reelfinished",
        "character"
    }

    -- Check each event and store availability
    for _, eventName in ipairs(requiredEvents) do
        local eventExists = events:FindFirstChild(eventName) ~= nil
        getgenv().State.Events.Available[eventName] = eventExists
        
        if not eventExists and getgenv().Config.Debug then
            warn("⚠️ Event not found:", eventName)
        end
    end

    return true
end

-- Script environment validation
Compatibility.ValidateEnvironment = function()
    local required = {
        ["getgenv"] = type(getgenv) == "function",
        ["hookfunction"] = type(hookfunction) == "function",
        ["newcclosure"] = type(newcclosure) == "function",
        ["setreadonly"] = type(setreadonly) == "function",
        ["getrawmetatable"] = type(getrawmetatable) == "function"
    }
    
    local missing = {}
    for name, available in pairs(required) do
        if not available then
            table.insert(missing, name)
        end
    end
    
    return #missing == 0, missing
end

-- Enhanced Anti-cheat bypass
Compatibility.SetupAntiCheatBypass = function()
    pcall(function()
        local mt = getrawmetatable(game)
        if not mt then return end
        
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
    
    return true
end

-- Feature availability check
Compatibility.IsFeatureAvailable = function(featureName)
    if featureName:match("auto") and getgenv().State.Events.Available then
        local requiredEvents = {
            autofish = {"castrod"},
            autoreel = {"reelfinished"},
            autoshake = {"character"}
        }
        
        local events = requiredEvents[featureName:lower()]
        if events then
            for _, event in ipairs(events) do
                if not getgenv().State.Events.Available[event] then
                    return false
                end
            end
        end
    end
    return true
end

-- Initialize compatibility checks
local function InitializeCompatibility()
    local status = {
        events = Compatibility.SetupGameEvents(),
        environment = Compatibility.ValidateEnvironment(),
        services = Compatibility.ValidateServices(),
        anticheat = Compatibility.SetupAntiCheatBypass()
    }
    
    -- Log initialization results if debug is enabled
    if getgenv().Config.Debug then
        for check, result in pairs(status) do
            if not result then
                warn(string.format("⚠️ Compatibility initialization failed for: %s", check))
            end
        end
    end
    
    -- Return true to allow script to continue with reduced functionality
    return true
end

-- Run initialization and return module
if InitializeCompatibility() then
    if getgenv().Config.Debug then
        print("✓ Compatibility layer initialized successfully")
    end
else
    warn("⚠️ Compatibility layer initialization failed")
end

return Compatibility
