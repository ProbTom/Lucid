-- Safe service getter
local function getService(serviceName)
    local success, service = pcall(function()
        return game:GetService(serviceName)
    end)
    if success then
        return service
    else
        warn("Failed to get service: " .. serviceName)
        return nil
    end
end

-- Initialize required services
local ReplicatedStorage = getService("ReplicatedStorage")
local Players = getService("Players")
local RunService = getService("RunService")
local UserInputService = getService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Initialize Options table with enhanced settings
if not getgenv().Options then
    getgenv().Options = {
        autoCast = { Value = false },
        autoShake = { Value = false },
        autoReel = { Value = false },
        FreezeCharacter = { Value = false },
        ZoneCast = { Value = false },
        CountShadows = { Value = false },
        RodDupe = { Value = false },
        WalkOnWater = { Value = false },
        ToggleNoclip = { Value = false },
        BypassRadar = { Value = false },
        BypassGPS = { Value = false },
        RemoveFog = { Value = false },
        DayOnly = { Value = false },
        HoldDuration = { Value = false },
        DisableOxygen = { Value = true },
        JustUI = { Value = true },
        IdentityHiderUI = { Value = false }
    }
end

-- Wait for LocalPlayer if not loaded
if not LocalPlayer then
    Players.PlayerAdded:Wait()
    LocalPlayer = Players.LocalPlayer
end

-- Safe check for playerstats with enhanced error handling
local playerStats
pcall(function()
    playerStats = ReplicatedStorage and ReplicatedStorage:WaitForChild("playerstats", 5)
end)
if not playerStats then
    warn("playerstats not found in ReplicatedStorage")
end

-- Add anti-cheat protection
local function setupAntiCheat()
    pcall(function()
        -- Hide from basic detection
        if getgenv().hideGui then
            getgenv().hideGui()
        end
        
        -- Basic memory cleanup
        for _, connection in pairs(getconnections(game:GetService("ScriptContext").Error)) do
            connection:Disable()
        end
        
        -- Protect against remote spy detection
        local oldNamecall
        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            if method == "FireServer" or method == "InvokeServer" then
                local args = {...}
                if typeof(args[1]) == "string" and args[1]:match("exploit") then
                    return
                end
            end
            return oldNamecall(self, ...)
        end)
    end)
end

-- Add enhanced error handling
local function safeRequire(module)
    local success, result = pcall(require, module)
    if not success then
        warn("Failed to require module:", module, result)
        return nil
    end
    return result
end

-- Setup connections cleanup
local connections = {}
local function addConnection(connection)
    table.insert(connections, connection)
end

-- Cleanup function
local function cleanup()
    for _, connection in ipairs(connections) do
        if typeof(connection) == "RBXScriptConnection" and connection.Connected then
            connection:Disconnect()
        end
    end
    table.clear(connections)
    
    -- Unbind any RunService bindings
    pcall(function()
        RunService:UnbindFromRenderStep("AutoCast")
        RunService:UnbindFromRenderStep("AutoShake")
        RunService:UnbindFromRenderStep("AutoReel")
    end)
end

-- Add connection for player removal
game:GetService("Players").PlayerRemoving:Connect(function(player)
    if player == LocalPlayer then
        cleanup()
    end
end)

-- Setup game-specific variables
local gameVariables = {
    lastCastTime = 0,
    lastShakeTime = 0,
    lastReelTime = 0,
    isProcessing = false
}

-- Export variables and functions safely
getgenv().ReplicatedStorage = ReplicatedStorage
getgenv().LocalPlayer = LocalPlayer
getgenv().playerStats = playerStats
getgenv().gameVars = gameVariables
getgenv().addConnection = addConnection
getgenv().cleanup = cleanup

-- Initialize anti-cheat protection
setupAntiCheat()

return true
