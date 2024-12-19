-- compatibility.lua
local Compatibility = {}

-- Game detection and version checking
Compatibility.GameSupported = function()
    local supportedGames = {
        [14264772720] = "Winter Fishing Simulator" -- Example game ID
    }
    
    return supportedGames[game.GameId] ~= nil, supportedGames[game.GameId]
end

Compatibility.CheckVersion = function()
    local currentVersion = getgenv().Config.Version
    local latestVersion = "1.0.0" -- This should be fetched from a remote source in production
    
    return {
        current = currentVersion,
        latest = latestVersion,
        needsUpdate = currentVersion ~= latestVersion
    }
end

-- Event system compatibility
Compatibility.ValidateEvents = function()
    local required = {
        "castrod",
        "reelfinished",
        "character"
    }
    
    local missing = {}
    for _, event in ipairs(required) do
        if not game:GetService("ReplicatedStorage"):WaitForChild("events"):FindFirstChild(event) then
            table.insert(missing, event)
        end
    end
    
    return #missing == 0, missing
end

-- Anti-cheat compatibility
Compatibility.SetupAntiCheatBypass = function()
    local success = pcall(function()
        -- Basic anti-detection measures
        local mt = getrawmetatable(game)
        local old = mt.__namecall
        setreadonly(mt, false)
        
        mt.__namecall = newcclosure(function(self, ...)
            local args = {...}
            local method = getnamecallmethod()
            
            if method == "FireServer" or method == "InvokeServer" then
                -- Add specific event handling here if needed
            end
            
            return old(self, ...)
        end)
        
        setreadonly(mt, true)
    end)
    
    return success
end

-- Script environment validation
Compatibility.ValidateEnvironment = function()
    local requirements = {
        ["getgenv"] = type(getgenv) == "function",
        ["hookfunction"] = type(hookfunction) == "function",
        ["newcclosure"] = type(newcclosure) == "function",
        ["setreadonly"] = type(setreadonly) == "function",
        ["getrawmetatable"] = type(getrawmetatable) == "function"
    }
    
    local missing = {}
    for name, available in pairs(requirements) do
        if not available then
            table.insert(missing, name)
        end
    end
    
    return #missing == 0, missing
end

-- UI compatibility checks
Compatibility.ValidateUIEnvironment = function()
    local services = {
        ["CoreGui"] = pcall(function() return game:GetService("CoreGui") end),
        ["Players"] = pcall(function() return game:GetService("Players") end),
        ["RunService"] = pcall(function() return game:GetService("RunService") end),
        ["UserInputService"] = pcall(function() return game:GetService("UserInputService") end)
    }
    
    local missing = {}
    for name, available in pairs(services) do
        if not available then
            table.insert(missing, name)
        end
    end
    
    return #missing == 0, missing
end

-- Initialize compatibility checks
local function InitializeCompatibility()
    local checks = {
        {name = "Game Support", func = Compatibility.GameSupported},
        {name = "Environment", func = Compatibility.ValidateEnvironment},
        {name = "Events", func = Compatibility.ValidateEvents},
        {name = "UI Environment", func = Compatibility.ValidateUIEnvironment}
    }
    
    local failed = {}
    for _, check in ipairs(checks) do
        local success, result = pcall(check.func)
        if not success or (type(result) == "table" and result[1] == false) then
            table.insert(failed, check.name)
        end
    end
    
    if #failed > 0 then
        warn("Compatibility checks failed:", table.concat(failed, ", "))
        return false
    end
    
    -- Setup anti-cheat bypass
    Compatibility.SetupAntiCheatBypass()
    
    return true
end

-- Set global reference
getgenv().Compatibility = Compatibility

-- Run initialization
return InitializeCompatibility()
