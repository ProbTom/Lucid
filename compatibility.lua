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
        Version = "1.0.0",
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
        LastShakeTime = 0
    }
end

-- Version handling and checks
Compatibility.CheckVersion = function()
    return {
        current = getgenv().Config.Version,
        latest = "1.0.0",
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

-- Game Events Setup
Compatibility.SetupGameEvents = function()
    -- Create events folder if it doesn't exist
    local events = ReplicatedStorage:FindFirstChild("events")
    if not events then
        events = Instance.new("Folder")
        events.Name = "events"
        events.Parent = ReplicatedStorage
    end

    -- Create required events
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

-- Anti-cheat bypass setup
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

-- Initialize compatibility checks
local function InitializeCompatibility()
    -- Set up game events first
    Compatibility.SetupGameEvents()
    
    -- Run other checks
    local checks = {
        {name = "Environment", func = Compatibility.ValidateEnvironment},
        {name = "Services", func = Compatibility.ValidateServices}
    }
    
    local allPassed = true
    for _, check in ipairs(checks) do
        local success, missing = check.func()
        if not success then
            if getgenv().Config.Debug then
                warn(string.format("⚠️ %s check failed: %s", 
                    check.name, 
                    table.concat(missing, ", ")
                ))
            end
            allPassed = false
        end
    end
    
    -- Setup anti-cheat bypass
    Compatibility.SetupAntiCheatBypass()
    
    -- Return true even if some checks fail - we'll run in degraded mode
    return true
end

-- Run initialization and return module
InitializeCompatibility()
return Compatibility
