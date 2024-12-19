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
        -- Main Features (only what's actually used in MainTab)
        autoCast = { Value = false },
        autoShake = { Value = false },
        autoReel = { Value = false },
        CastMode = { Value = "Legit" },
        ReelMode = { Value = "Blatant" }
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

    -- Reset options
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

-- Export variables and functions
getgenv().ReplicatedStorage = ReplicatedStorage
getgenv().LocalPlayer = LocalPlayer
getgenv().playerStats = playerStats
getgenv().addConnection = addConnection
getgenv().cleanup = cleanup

return true
