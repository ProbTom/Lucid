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

-- Initialize required services with error handling
local ReplicatedStorage = getService("ReplicatedStorage")
local Players = getService("Players")
local RunService = getService("RunService")
local VirtualUser = getService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

-- Initialize Options table if it doesn't exist
if not getgenv().Options then
    getgenv().Options = {
        -- Main Features
        autoCast = { Value = false },
        autoShake = { Value = false },
        autoReel = { Value = false },
        CastMode = { Value = "Legit" },
        ReelMode = { Value = "Blatant" },
        
        -- Character Features
        FreezeCharacter = { Value = false },
        ZoneCast = { Value = false },
        WalkOnWater = { Value = false },
        ToggleNoclip = { Value = false },
        
        -- Game Features
        CountShadows = { Value = false },
        RodDupe = { Value = false },
        BypassRadar = { Value = false },
        BypassGPS = { Value = false },
        RemoveFog = { Value = false },
        DayOnly = { Value = false },
        
        -- Other Settings
        HoldDuration = { Value = false },
        DisableOxygen = { Value = true },
        JustUI = { Value = true },
        IdentityHiderUI = { Value = false }
    }
end

-- Wait for game load
if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- Wait for LocalPlayer if not loaded
if not LocalPlayer then
    Players.PlayerAdded:Wait()
    LocalPlayer = Players.LocalPlayer
end

-- Safe check for playerstats
local playerStats = ReplicatedStorage and ReplicatedStorage:FindFirstChild("playerstats")
if not playerStats then
    warn("playerstats not found in ReplicatedStorage")
end

-- Connection handling
local connections = {}
local function addConnection(connection)
    if typeof(connection) == "RBXScriptConnection" then
        table.insert(connections, connection)
        return connection
    end
    return nil
end

-- Cleanup function
local function cleanup()
    -- Disconnect all connections
    for _, connection in ipairs(connections) do
        if typeof(connection) == "RBXScriptConnection" and connection.Connected then
            connection:Disconnect()
        end
    end
    table.clear(connections)

    -- Unbind from RunService
    pcall(function()
        RunService:UnbindFromRenderStep("AutoCast")
        RunService:UnbindFromRenderStep("AutoShake")
        RunService:UnbindFromRenderStep("AutoReel")
    end)

    -- Reset character state
    if LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = 16
            humanoid.JumpPower = 50
        end
        
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.Anchored = false
        end
    end

    -- Clear global variables
    for _, option in pairs(getgenv().Options) do
        option.Value = false
    end
end

-- Add cleanup connection for player removal
addConnection(Players.PlayerRemoving:Connect(function(player)
    if player == LocalPlayer then
        cleanup()
    end
end))

-- Add cleanup connection for script termination
addConnection(game:GetService("ScriptContext").Error:Connect(function(message, trace, script)
    if script and script:IsDescendantOf(game:GetService("CoreGui")) then
        warn("Lucid Hub Runtime Error:", message, "\nStack:", trace)
    end
end))

-- Export variables and functions
getgenv().ReplicatedStorage = ReplicatedStorage
getgenv().LocalPlayer = LocalPlayer
getgenv().playerStats = playerStats
getgenv().addConnection = addConnection
getgenv().cleanup = cleanup

-- Initialize anti-cheat protection
local function setupAntiCheat()
    pcall(function()
        -- Disable error reporting
        for _, connection in pairs(getconnections(game:GetService("ScriptContext").Error)) do
            connection:Disable()
        end

        -- Protect against remote detection
        local oldNamecall
        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            local args = {...}
            
            if method == "FireServer" or method == "InvokeServer" then
                if typeof(args[1]) == "string" and args[1]:match("exploit") then
                    return
                end
            end
            
            return oldNamecall(self, ...)
        end)
        
        -- Hook index metamethod for additional protection
        local oldIndex
        oldIndex = hookmetamethod(game, "__index", function(self, key)
            if checkcaller() then return oldIndex(self, key) end
            
            if key == "Name" and self:IsA("RemoteEvent") then
                return "Event"
            end
            
            return oldIndex(self, key)
        end)
    end)
end

setupAntiCheat()
return true
