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
local VirtualUser = getService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

-- Check critical services
if not RunService or not VirtualUser then
    warn("Critical services not found")
    return
end

-- Initialize Options table
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

-- Safe check for playerstats
local playerStats = ReplicatedStorage and ReplicatedStorage:FindFirstChild("playerstats")
if not playerStats then
    warn("playerstats not found in ReplicatedStorage")
end

-- Cleanup function
local function cleanup()
    pcall(function()
        RunService:UnbindFromRenderStep("AutoShake")
        RunService:UnbindFromRenderStep("AutoCast")
        RunService:UnbindFromRenderStep("AutoReel")
    end)
end

-- Export variables and functions safely
getgenv().ReplicatedStorage = ReplicatedStorage
getgenv().LocalPlayer = LocalPlayer
getgenv().playerStats = playerStats
getgenv().cleanup = cleanup

return true
