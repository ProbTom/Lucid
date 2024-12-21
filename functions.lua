-- functions.lua
local Functions = {
    _VERSION = "1.1.0",
    _initialized = false
}

-- Dependencies
local WindUI
local Debug
local Utils

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Cooldown management
local Cooldowns = {
    Cast = 1.5,
    Reel = 0.1,
    Shake = 0.1,
    LastCast = 0,
    LastReel = 0,
    LastShake = 0
}

-- Initialize Functions
function Functions.init(deps)
    if Functions._initialized then return end
    
    WindUI = deps.windui
    Debug = deps.debug
    Utils = deps.utils

    -- Initialize state
    getgenv().State = {
        AutoCasting = false,
        AutoReeling = false,
        AutoShaking = false,
        ChestCollecting = false,
        AutoSelling = false
    }

    Functions._initialized = true
    Debug.Info("Functions module initialized")
    return true
end

-- Core fishing functions
function Functions.Cast()
    if tick() - Cooldowns.LastCast < Cooldowns.Cast then return end
    
    local events = ReplicatedStorage:WaitForChild("events")
    if events and events:FindFirstChild("castrod") then
        events.castrod:FireServer()
        Cooldowns.LastCast = tick()
        Debug.Info("Cast rod")
    end
end

function Functions.Reel()
    if tick() - Cooldowns.LastReel < Cooldowns.Reel then return end
    
    local events = ReplicatedStorage:WaitForChild("events")
    if events and events:FindFirstChild("reelfinished") then
        events.reelfinished:FireServer()
        Cooldowns.LastReel = tick()
        Debug.Info("Reeled line")
    end
end

function Functions.Shake()
    if tick() - Cooldowns.LastShake < Cooldowns.Shake then return end
    
    local events = ReplicatedStorage:WaitForChild("events")
    if events and events:FindFirstChild("character") then
        events.character:FireServer("shake")
        Cooldowns.LastShake = tick()
        Debug.Info("Performed shake")
    end
end

-- Toggle functions
function Functions.ToggleAutoFish(enabled)
    getgenv().State.AutoCasting = enabled
    Debug.Info("Auto fish " .. (enabled and "enabled" or "disabled"))
end

function Functions.ToggleAutoReel(enabled)
    getgenv().State.AutoReeling = enabled
    Debug.Info("Auto reel " .. (enabled and "enabled" or "disabled"))
end

function Functions.ToggleAutoShake(enabled)
    getgenv().State.AutoShaking = enabled
    Debug.Info("Auto shake " .. (enabled and "enabled" or "disabled"))
end

function Functions.ToggleChestCollector(enabled)
    getgenv().State.ChestCollecting = enabled
    Debug.Info("Chest collector " .. (enabled and "enabled" or "disabled"))
end

function Functions.ToggleAutoSell(enabled)
    getgenv().State.AutoSelling = enabled
    Debug.Info("Auto sell " .. (enabled and "enabled" or "disabled"))
end

-- Equipment management
function Functions.EquipBestRod()
    local inventory = LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Inventory")
    if not inventory then return end
    
    -- Rod equip logic here
    Debug.Info("Attempting to equip best rod")
end

-- Main loop handler
Functions.MainLoop = RunService.Heartbeat:Connect(function()
    if not LocalPlayer or not LocalPlayer.Character then return end
    
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    if not playerGui then return end
    
    local fishingGui = playerGui:FindFirstChild("FishingGui")
    if not fishingGui then return end
    
    -- Auto fishing logic
    if getgenv().State.AutoCasting then
        local castingBar = fishingGui:FindFirstChild("CastingBar")
        if not castingBar or not castingBar.Visible then
            Functions.Cast()
        end
    end
    
    -- Auto reel logic
    if getgenv().State.AutoReeling then
        local reelButton = fishingGui:FindFirstChild("ReelButton")
        if reelButton and reelButton.Visible then
            Functions.Reel()
        end
    end
    
    -- Auto shake logic
    if getgenv().State.AutoShaking then
        local shakeBar = fishingGui:FindFirstChild("ShakeBar")
        if shakeBar and shakeBar.Visible then
            Functions.Shake()
        end
    end
    
    -- Chest collector logic
    if getgenv().State.ChestCollecting then
        Functions.CollectNearbyChests()
    end
    
    -- Auto sell logic
    if getgenv().State.AutoSelling then
        Functions.AutoSellItems()
    end
end)

-- Chest collection
function Functions.CollectNearbyChests()
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local hrp = character.HumanoidRootPart
    
    -- Chest collection logic here
    Debug.Info("Checking for nearby chests")
end

-- Auto sell
function Functions.AutoSellItems()
    -- Auto sell logic here
    Debug.Info("Checking items for auto-sell")
end

return Functions
