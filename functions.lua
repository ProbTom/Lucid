-- functions.lua
local Functions = {
    _VERSION = "1.1.0",
    _initialized = false,
    LastUpdated = "2024-12-21"
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

-- Constants
local COOLDOWNS = {
    Cast = 1.5,
    Reel = 0.1,
    Shake = 0.1,
    LastCast = 0,
    LastReel = 0,
    LastShake = 0
}

-- State Management
local State = {
    AutoCasting = false,
    AutoReeling = false,
    AutoShaking = false,
    ChestCollecting = false,
    AutoSelling = false
}

function Functions.init(deps)
    if Functions._initialized then return end
    
    WindUI = deps.windui or error("WindUI dependency missing")
    Debug = deps.debug or error("Debug dependency missing")
    Utils = deps.utils or error("Utils dependency missing")
    
    -- Initialize event connections
    Functions:InitializeEvents()
    
    Functions._initialized = true
    return true
end

-- Core Fishing Functions
function Functions.Cast()
    if tick() - COOLDOWNS.LastCast < COOLDOWNS.Cast then return end
    
    local events = ReplicatedStorage:WaitForChild("events")
    if events and events:FindFirstChild("castrod") then
        Utils.SafeCall(function()
            events.castrod:FireServer()
            COOLDOWNS.LastCast = tick()
            Debug.Debug("Cast rod")
        end)
    end
end

function Functions.Reel()
    if tick() - COOLDOWNS.LastReel < COOLDOWNS.Reel then return end
    
    local events = ReplicatedStorage:WaitForChild("events")
    if events and events:FindFirstChild("reelfinished") then
        Utils.SafeCall(function()
            events.reelfinished:FireServer()
            COOLDOWNS.LastReel = tick()
            Debug.Debug("Reeled line")
        end)
    end
end

function Functions.Shake()
    if tick() - COOLDOWNS.LastShake < COOLDOWNS.Shake then return end
    
    local events = ReplicatedStorage:WaitForChild("events")
    if events and events:FindFirstChild("character") then
        Utils.SafeCall(function()
            events.character:FireServer("shake")
            COOLDOWNS.LastShake = tick()
            Debug.Debug("Performed shake")
        end)
    end
end

-- Auto Functions
function Functions.ToggleAutoFish(enabled)
    State.AutoCasting = enabled
    Debug.Info(enabled and "Auto Fish enabled" or "Auto Fish disabled", true)
end

function Functions.ToggleAutoReel(enabled)
    State.AutoReeling = enabled
    Debug.Info(enabled and "Auto Reel enabled" or "Auto Reel disabled", true)
end

function Functions.ToggleAutoShake(enabled)
    State.AutoShaking = enabled
    Debug.Info(enabled and "Auto Shake enabled" or "Auto Shake disabled", true)
end

-- Item Management Functions
function Functions.ToggleChestCollector(enabled)
    State.ChestCollecting = enabled
    Debug.Info(enabled and "Chest Collector enabled" or "Chest Collector disabled", true)
end

function Functions.ToggleAutoSell(enabled)
    State.AutoSelling = enabled
    Debug.Info(enabled and "Auto Sell enabled" or "Auto Sell disabled", true)
end

function Functions.SellItems(rarities)
    local events = ReplicatedStorage:WaitForChild("events")
    if not events or not events:FindFirstChild("sellitems") then return end
    
    Utils.SafeCall(function()
        for rarity, shouldSell in pairs(rarities) do
            if shouldSell then
                events.sellitems:FireServer(rarity)
                task.wait(0.1) -- Prevent throttling
            end
        end
    end)
end

-- Rod Management
function Functions.EquipBestRod()
    local events = ReplicatedStorage:WaitForChild("events")
    if not events or not events:FindFirstChild("equiprod") then return end
    
    Utils.SafeCall(function()
        local stats = Functions.GetPlayerStats()
        if stats and stats.bestRod then
            events.equiprod:FireServer(stats.bestRod)
            Debug.Info("Equipped best rod: " .. stats.bestRod)
        end
    end)
end

-- Stats Functions
function Functions.GetPlayerStats()
    local stats = ReplicatedStorage:FindFirstChild("playerstats")
    if not stats then return nil end
    
    local playerStats = stats:FindFirstChild(LocalPlayer.Name)
    if not playerStats then return nil end
    
    return {
        fishCaught = playerStats:FindFirstChild("fishcaught") and playerStats.fishcaught.Value or 0,
        coins = playerStats:FindFirstChild("coins") and playerStats.coins.Value or 0,
        currentRod = playerStats:FindFirstChild("rod") and playerStats.rod.Value or "None",
        bestRod = playerStats:FindFirstChild("bestrod") and playerStats.bestrod.Value or nil
    }
end

-- Event Handling
function Functions:InitializeEvents()
    -- Main Game Loop
    RunService.Heartbeat:Connect(function()
        if not LocalPlayer or not LocalPlayer.Character then return end
        
        local playerGui = LocalPlayer:WaitForChild("PlayerGui")
        if not playerGui then return end
        
        local fishingGui = playerGui:FindFirstChild("FishingGui")
        if not fishingGui then return end
        
        -- Auto Cast
        if State.AutoCasting then
            local castingBar = fishingGui:FindFirstChild("CastingBar")
            if not castingBar or not castingBar.Visible then
                Functions.Cast()
            end
        end
        
        -- Auto Reel
        if State.AutoReeling then
            local reelButton = fishingGui:FindFirstChild("ReelButton")
            if reelButton and reelButton.Visible then
                Functions.Reel()
            end
        end
        
        -- Auto Shake
        if State.AutoShaking then
            local shakeBar = fishingGui:FindFirstChild("ShakeBar")
            if shakeBar and shakeBar.Visible then
                Functions.Shake()
            end
        end
    end)
    
    -- Stats Update Loop
    task.spawn(function()
        while task.wait(1) do
            local stats = Functions.GetPlayerStats()
            if stats then
                WindUI:UpdateStats(stats)
            end
        end
    end)
end

-- Chest Collection Loop
task.spawn(function()
    while task.wait(0.5) do
        if State.ChestCollecting then
            Functions.CollectNearbyChests()
        end
    end
end)

-- Auto Sell Loop
task.spawn(function()
    while task.wait(5) do
        if State.AutoSelling then
            Functions.SellItems(getgenv().Options.Items.AutoSell.Rarities)
        end
    end
end)

return Functions
