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
local LocalPlayer = Players.LocalPlayer

-- Initialize Options table and other global variables
getgenv().Options = {
    autoCast = { Value = false },
    autoShake = { Value = false },
    autoReel = { Value = false },
    FreezeCharacter = { Value = false },
}

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

-- Export variables safely
getgenv().ReplicatedStorage = ReplicatedStorage
getgenv().LocalPlayer = LocalPlayer
getgenv().playerStats = playerStats

-- Return success
return true
