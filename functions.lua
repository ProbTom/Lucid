-- functions.lua
local Functions = {}

-- Core Services with error handling
local function getService(serviceName)
    local success, service = pcall(function()
        return game:GetService(serviceName)
    end)
    
    if not success then
        warn("Failed to get service:", serviceName)
        return nil
    end
    
    return service
end

local Players = getService("Players")
local ReplicatedStorage = getService("ReplicatedStorage")
local LocalPlayer = Players and Players.LocalPlayer

-- Utility Functions
local function validateEnvironment()
    if not getgenv or not getgenv() then
        warn("Missing getgenv environment")
        return false
    end
    
    if not getgenv().Config then
        warn("Missing Config in global environment")
        return false
    end
    
    if not getgenv().State then
        warn("Missing State in global environment")
        return false
    end
    
    return true
end

-- Enhanced Notification System
Functions.ShowNotification = function(title, message)
    if not getgenv().Fluent then return end
    
    pcall(function()
        getgenv().Fluent:Notify({
            Title = title or "Notification",
            Content = message or "",
            Duration = 3
        })
    end)
end

-- Fishing Functions with improved error handling
Functions.autoFish = function(playerGui)
    if not playerGui then return end
    
    pcall(function()
        local fishingGui = playerGui:WaitForChild("FishingGui", 1)
        if not fishingGui then return end
        
        local castingBar = fishingGui:FindFirstChild("CastingBar")
        if not castingBar or not castingBar.Visible then
            -- Trigger cast event
            local events = ReplicatedStorage:FindFirstChild("events")
            if events and events:FindFirstChild("castrod") then
                events.castrod:FireServer()
            end
        end
    end)
end

Functions.autoReel = function(playerGui)
    if not playerGui then return end
    
    pcall(function()
        local fishingGui = playerGui:WaitForChild("FishingGui", 1)
        if not fishingGui then return end
        
        local reelButton = fishingGui:FindFirstChild("ReelButton")
        if reelButton and reelButton.Visible then
            -- Trigger reel event
            local events = ReplicatedStorage:FindFirstChild("events")
            if events and events:FindFirstChild("reelfinished") then
                events.reelfinished:FireServer()
            end
        end
    end)
end

Functions.autoShake = function(playerGui)
    if not playerGui then return end
    
    pcall(function()
        local fishingGui = playerGui:WaitForChild("FishingGui", 1)
        if not fishingGui then return end
        
        local shakeBar = fishingGui:FindFirstChild("ShakeBar")
        if shakeBar and shakeBar.Visible then
            -- Trigger shake event
            local events = ReplicatedStorage:FindFirstChild("events")
            if events and events:FindFirstChild("character") then
                events.character:FireServer("shake")
            end
        end
    end)
end

-- Inventory Management Functions
Functions.sellFish = function(rarity)
    if not rarity then return end
    
    pcall(function()
        local backpack = LocalPlayer:WaitForChild("Backpack")
        local sold = 0
        
        for _, item in pairs(backpack:GetChildren()) do
            if item:FindFirstChild("values") and 
               item.values:FindFirstChild("rarity") and 
               item.values.rarity.Value == rarity then
                -- Trigger sell event
                local events = ReplicatedStorage:FindFirstChild("events")
                if events and events:FindFirstChild("sellfish") then
                    events.sellfish:FireServer(item)
                    sold = sold + 1
                end
            end
        end
        
        if getgenv().Config.Debug and sold > 0 then
            Functions.ShowNotification("Sold Items", string.format("Sold %d %s items", sold, rarity))
        end
    end)
end

Functions.equipBestRod = function()
    pcall(function()
        local backpack = LocalPlayer:WaitForChild("Backpack")
        local bestRod = nil
        local bestPower = 0
        
        for _, item in pairs(backpack:GetChildren()) do
            if item:FindFirstChild("values") and 
               item.values:FindFirstChild("power") and 
               item.values:FindFirstChild("type") and 
               item.values.type.Value == "Rod" then
                local power = item.values.power.Value
                if power > bestPower then
                    bestPower = power
                    bestRod = item
                end
            end
        end
        
        if bestRod then
            bestRod.Parent = LocalPlayer.Character
            if getgenv().Config.Debug then
                Functions.ShowNotification("Equipment", "Equipped best rod: " .. bestRod.Name)
            end
        end
    end)
end

-- Chest Collection Function
Functions.collectChest = function(chest, range)
    if not chest or not range then return end
    
    pcall(function()
        local character = LocalPlayer.Character
        if not character then return end
        
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then return end
        
        local distance = (chest:GetPivot().Position - humanoidRootPart.Position).Magnitude
        if distance <= range then
            -- Trigger chest collection event
            local events = ReplicatedStorage:FindFirstChild("events")
            if events and events:FindFirstChild("collectchest") then
                events.collectchest:FireServer(chest)
            end
        end
    end)
end

-- Enhanced initialization with dependency checking
local function InitializeFunctions()
    -- Validate core requirements
    if not validateEnvironment() then
        return false
    end
    
    -- Validate services
    if not Players or not ReplicatedStorage or not LocalPlayer then
        warn("Failed to initialize required services")
        return false
    end
    
    -- Set up event handlers
    pcall(function()
        LocalPlayer.CharacterAdded:Connect(function(character)
            if getgenv().Options.AutoEquipBestRod then
                task.wait(1) -- Wait for backpack to load
                Functions.equipBestRod()
            end
        end)
    end)
    
    -- Initialize successful
    if getgenv().Config.Debug then
        Functions.ShowNotification("Initialization", "Functions module loaded successfully")
    end
    
    return true
end

-- Run initialization with error handling
if not InitializeFunctions() then
    warn("⚠️ Failed to initialize Functions module")
    return false
end

return Functions
