-- functions.lua
local Functions = {}

-- Core Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Constants
local INTERACTION_COOLDOWN = 0.1
local MAX_RETRIES = 3
local REMOTE_TIMEOUT = 5

-- Utility Functions
local function waitForChild(parent, childName, timeout)
    timeout = timeout or 5
    local child = parent:FindFirstChild(childName)
    local startTime = tick()
    
    while not child and tick() - startTime < timeout do
        child = parent:FindFirstChild(childName)
        RunService.Heartbeat:Wait()
    end
    
    return child
end

local function invokeWithRetry(remote, ...)
    local success, result
    local attempts = 0
    
    repeat
        attempts = attempts + 1
        success, result = pcall(function()
            return remote:FireServer(...)
        end)
        if not success and attempts < MAX_RETRIES then
            task.wait(INTERACTION_COOLDOWN)
        end
    until success or attempts >= MAX_RETRIES
    
    return success, result
end

-- Core Fishing Functions
Functions.autoFish = function(gui)
    pcall(function()
        if not gui then return end
        
        local fishing = gui:FindFirstChild("Fishing")
        if not fishing then return end
        
        local cast = ReplicatedStorage.events:FindFirstChild("castrod")
        if not cast then return end
        
        invokeWithRetry(cast)
    end)
end

Functions.autoReel = function(gui)
    pcall(function()
        if not gui then return end
        
        local fishing = gui:FindFirstChild("Fishing")
        if not fishing or not fishing.Visible then return end
        
        local reel = ReplicatedStorage.events:FindFirstChild("reelfinished")
        if not reel then return end
        
        invokeWithRetry(reel)
    end)
end

Functions.autoShake = function(gui)
    pcall(function()
        if not gui then return end
        
        local fishing = gui:FindFirstChild("Fishing")
        if not fishing or not fishing.Visible then return end
        
        if not LocalPlayer.Character then return end
        
        local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
        if not humanoid then return end
        
        -- Simulate shaking movement
        for i = 1, 3 do
            humanoid:MoveTo(humanoid.RootPart.Position + Vector3.new(math.random(-1, 1), 0, math.random(-1, 1)))
            task.wait(0.1)
        end
    end)
end

-- Enhanced Item Management Functions
Functions.sellFish = function(rarity)
    pcall(function()
        local backpack = LocalPlayer:WaitForChild("Backpack")
        if not backpack then return end
        
        for _, item in pairs(backpack:GetChildren()) do
            if item:FindFirstChild("values") and 
               item.values:FindFirstChild("rarity") and 
               item.values.rarity.Value == rarity then
                
                local sellRemote = ReplicatedStorage.events:FindFirstChild("sellfish")
                if sellRemote then
                    invokeWithRetry(sellRemote, item)
                end
                
                task.wait(INTERACTION_COOLDOWN)
            end
        end
    end)
end

Functions.equipBestRod = function()
    pcall(function()
        local backpack = LocalPlayer:WaitForChild("Backpack")
        if not backpack then return end
        
        local bestRod = nil
        local bestValue = 0
        
        for _, item in pairs(backpack:GetChildren()) do
            if item:FindFirstChild("values") and 
               item.values:FindFirstChild("power") then
                local power = item.values.power.Value
                if power > bestValue then
                    bestValue = power
                    bestRod = item
                end
            end
        end
        
        if bestRod then
            bestRod.Parent = LocalPlayer.Character
        end
    end)
end

-- Enhanced Chest Collection
Functions.collectChest = function(chest, range)
    pcall(function()
        if not LocalPlayer.Character then return end
        
        local humanoidRootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then return end
        
        local chestPart = chest:FindFirstChild("Part")
        if not chestPart then return end
        
        local distance = (humanoidRootPart.Position - chestPart.Position).Magnitude
        if distance <= (range or 50) then
            local collectRemote = ReplicatedStorage.events:FindFirstChild("collectchest")
            if collectRemote then
                invokeWithRetry(collectRemote, chest)
            end
        end
    end)
end

-- Notification System
Functions.ShowNotification = function(title, content, duration)
    pcall(function()
        if getgenv().Window then
            getgenv().Window:Notify({
                Title = title or "Notification",
                Content = content or "",
                Duration = duration or 3
            })
        end
    end)
end

-- Initialize Functions with error handling
local function InitializeFunctions()
    local requirements = {
        {name = "Config", value = getgenv().Config},
        {name = "State", value = getgenv().State}
    }
    
    for _, req in ipairs(requirements) do
        if not req.value then
            warn("Functions: Missing requirement -", req.name)
            return false
        end
    end
    
    return true
end

-- Run initialization with error handling
if not InitializeFunctions() then
    warn("⚠️ Failed to initialize Functions")
