-- Initialize Options table and other global variables
Options = {
    autoCast = { Value = false },
    autoShake = { Value = false },
    autoReel = { Value = false },
    FreezeCharacter = { Value = false },
}

-- Ensure required services and variables are correctly initialized
ReplicatedStorage = game:GetService("ReplicatedStorage")
Players = game:GetService("Players")
LocalPlayer = Players.LocalPlayer

-- Debugging to check if variables are correctly initialized
print("ReplicatedStorage:", ReplicatedStorage)
print("Players:", Players)
print("LocalPlayer:", LocalPlayer)

-- Check if LocalPlayer is loaded
if not LocalPlayer then
    Players.PlayerAdded:Wait()
    LocalPlayer = Players.LocalPlayer
end

-- Debugging to check if playerstats is accessible
local playerStats = ReplicatedStorage:FindFirstChild("playerstats")
if not playerStats then
    warn("playerstats not found in ReplicatedStorage")
else
    print("playerstats found in ReplicatedStorage")
end

-- Export other required variables globally if needed
getgenv().ReplicatedStorage = ReplicatedStorage
getgenv().LocalPlayer = LocalPlayer
getgenv().playerStats = playerStats
