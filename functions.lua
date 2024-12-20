-- functions.lua
local Functions = {}

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Cooldowns
local Cooldowns = {
    Cast = 1.5,
    Reel = 0.1,
    Shake = 0.1,
    LastCast = 0,
    LastReel = 0,
    LastShake = 0
}

-- Initialize State
if not getgenv().State then
    getgenv().State = {
        AutoCasting = false,
        AutoReeling = false,
        AutoShaking = false
    }
end

-- Main Functions
function Functions.Cast()
    if tick() - Cooldowns.LastCast < Cooldowns.Cast then return end
    local events = ReplicatedStorage:WaitForChild("events")
    if events and events:FindFirstChild("castrod") then
        events.castrod:FireServer()
        Cooldowns.LastCast = tick()
    end
end

function Functions.Reel()
    if tick() - Cooldowns.LastReel < Cooldowns.Reel then return end
    local events = ReplicatedStorage:WaitForChild("events")
    if events and events:FindFirstChild("reelfinished") then
        events.reelfinished:FireServer()
        Cooldowns.LastReel = tick()
    end
end

function Functions.Shake()
    if tick() - Cooldowns.LastShake < Cooldowns.Shake then return end
    local events = ReplicatedStorage:WaitForChild("events")
    if events and events:FindFirstChild("character") then
        events.character:FireServer("shake")
        Cooldowns.LastShake = tick()
    end
end

-- Main Loop
Functions.Connection = RunService.Heartbeat:Connect(function()
    if not LocalPlayer or not LocalPlayer.Character then return end
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    if not playerGui then return end
    
    local fishingGui = playerGui:FindFirstChild("FishingGui")
    if not fishingGui then return end
    
    -- Auto Cast
    if getgenv().State.AutoCasting then
        local castingBar = fishingGui:FindFirstChild("CastingBar")
        if not castingBar or not castingBar.Visible then
            Functions.Cast()
        end
    end
    
    -- Auto Reel
    if getgenv().State.AutoReeling then
        local reelButton = fishingGui:FindFirstChild("ReelButton")
        if reelButton and reelButton.Visible then
            Functions.Reel()
        end
    end
    
    -- Auto Shake
    if getgenv().State.AutoShaking then
        local shakeBar = fishingGui:FindFirstChild("ShakeBar")
        if shakeBar and shakeBar.Visible then
            Functions.Shake()
        end
    end
end)

return Functions
