-- compatibility.lua
local Compatibility = {
    _version = "1.0.1",
    _initialized = false
}

-- Core services
local Services = {
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    Players = game:GetService("Players")
}

-- Service validation
Compatibility.ValidateServices = function()
    for name, service in pairs(Services) do
        if not service then
            return false
        end
    end
    return true
end

-- Game Events Setup with centralized event handling
Compatibility.SetupGameEvents = function()
    -- Initialize state if needed
    if not getgenv().State then
        getgenv().State = {}
    end
    
    if not getgenv().State.Events then
        getgenv().State.Events = {
            Available = {}
        }
    end

    -- Check for events container
    local events = Services.ReplicatedStorage:FindFirstChild("events")
    if not events then
        if getgenv().Config and getgenv().Config.Debug then
            warn("Events container not found")
        end
        -- Set all events as unavailable
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
        
        if not eventExists and getgenv().Config and getgenv().Config.Debug then
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
    if not getgenv().State or not getgenv().State.Events or not getgenv().State.Events.Available then
        return false
    end

    if featureName:match("auto") then
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

-- Memory cleanup function
Compatibility.Cleanup = function()
    pcall(function()
        -- Clear metatable modifications
        local mt = getrawmetatable(game)
        if mt and mt.__namecall then
            setreadonly(mt, false)
            mt.__namecall = nil
            setreadonly(mt, true)
        end
        
        -- Clear event handlers
        if getgenv().State and getgenv().State.Events then
            getgenv().State.Events = {
                Available = {}
            }
        end
    end)
end

-- Initialize compatibility checks
local function InitializeCompatibility()
    if Compatibility._initialized then
        return true
    end

    local status = {
        services = Compatibility.ValidateServices(),
        environment = Compatibility.ValidateEnvironment(),
        anticheat = Compatibility.SetupAntiCheatBypass(),
        events = Compatibility.SetupGameEvents()
    }
    
    -- Log initialization results if debug is enabled
    if getgenv().Config and getgenv().Config.Debug then
        for check, result in pairs(status) do
            if not result then
                warn(string.format("⚠️ Compatibility initialization failed for: %s", check))
            end
        end
    end
    
    Compatibility._initialized = true
    return true
end

-- Setup cleanup on script end
game:GetService("Players").LocalPlayer.OnTeleport:Connect(function()
    Compatibility.Cleanup()
end)

-- Run initialization
local success = InitializeCompatibility()

if success and getgenv().Config and getgenv().Config.Debug then
    print("✓ Compatibility layer initialized successfully")
end

return Compatibility
