-- compatibility.lua
local Compatibility = {}

-- Core Services
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Version handling and checks
Compatibility.CheckVersion = function()
    -- Setup version info
    if not getgenv().Config.Version then
        getgenv().Config.Version = "1.0.0"
    end
    
    -- In production, this should fetch from a remote source
    local currentVersion = getgenv().Config.Version
    local latestVersion = "1.0.0"
    
    return {
        current = currentVersion,
        latest = latestVersion,
        needsUpdate = currentVersion ~= latestVersion
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

-- Fishing game event system compatibility
Compatibility.ValidateGameEvents = function()
    local required = {
        "castrod",
        "reelfinished",
        "character"
    }
    
    local missing = {}
    local events = ReplicatedStorage:WaitForChild("events", 5)
    
    if not events then
        return false, required
    end
    
    for _, event in ipairs(required) do
        if not events:FindFirstChild(event) then
            table.insert(missing, event)
        end
    end
    
    return #missing == 0, missing
end

-- Script environment validation
Compatibility.ValidateEnvironment = function()
    local required = {
        ["getgenv"] = type(getgenv) == "function",
        ["hookfunction"] = type(hookfunction) == "function",
        ["newcclosure"] = type(newcclosure) == "function",
        ["setreadonly"] = type(setreadonly) == "function",
        ["getrawmetatable"] = type(getrawmetatable) == "function",
        ["isfile"] = type(isfile) == "function",
        ["writefile"] = type(writefile) == "function",
        ["readfile"] = type(readfile) == "function"
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
    local success = pcall(function()
        local mt = getrawmetatable(game)
        if not mt then return false end
        
        local old = mt.__namecall
        setreadonly(mt, false)
        
        mt.__namecall = newcclosure(function(self, ...)
            local args = {...}
            local method = getnamecallmethod()
            
            -- Block potential anti-cheat remote calls
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
    local required = {
        "Version",
        "URLs",
        "Items",
        "Options"
    }
    
    local missing = {}
    for _, key in ipairs(required) do
        if not getgenv().Config or not getgenv().Config[key] then
            table.insert(missing, key)
        end
    end
    
    return #missing == 0, missing
end

-- Global state validation
Compatibility.ValidateState = function()
    local required = {
        "AutoFishing",
        "AutoSelling",
        "SelectedRarities",
        "LastReelTime",
        "LastShakeTime"
    }
    
    local missing = {}
    for _, key in ipairs(required) do
        if not getgenv().State or getgenv().State[key] == nil then
            table.insert(missing, key)
        end
    end
    
    return #missing == 0, missing
end

-- Initialize all compatibility checks
local function InitializeCompatibility()
    local checks = {
        {name = "Configuration", func = Compatibility.ValidateConfig},
        {name = "Global State", func = Compatibility.ValidateState},
        {name = "Environment", func = Compatibility.ValidateEnvironment},
        {name = "Services", func = Compatibility.ValidateServices},
        {name = "Game Events", func = Compatibility.ValidateGameEvents}
    }
    
    local failed = {}
    
    for _, check in ipairs(checks) do
        local success, missing = check.func()
        if not success then
            table.insert(failed, {
                name = check.name,
                missing = missing
            })
        end
    end
    
    if #failed > 0 then
        warn("⚠️ Compatibility Check Failed:")
        for _, failure in ipairs(failed) do
            warn(string.format("- %s missing: %s", 
                failure.name, 
                table.concat(failure.missing, ", ")
            ))
        end
        return false
    end
    
    -- Setup anti-cheat bypass
    if not Compatibility.SetupAntiCheatBypass() then
        warn("⚠️ Failed to setup anti-cheat bypass")
        return false
    end
    
    return true
end

-- Run initialization
if not InitializeCompatibility() then
    error("Failed to initialize compatibility layer")
    return false
end

return Compatibility
