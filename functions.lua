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

-- Initialize required services first
local Players = getService("Players")
local ReplicatedStorage = getService("ReplicatedStorage")

-- Wait for LocalPlayer to be available
local LocalPlayer = Players and Players.LocalPlayer
if not LocalPlayer then
    local success, player = pcall(function()
        return Players:WaitForChild("LocalPlayer", 10)
    end)
    if success then
        LocalPlayer = player
    end
end

-- Early validation to prevent nil errors
if not Players or not ReplicatedStorage or not LocalPlayer then
    warn("Essential services or LocalPlayer not available")
    return false
end

-- Verify global state initialization
if not getgenv or not getgenv() then
    warn("getgenv not available")
    return false
end

-- Initialize required global states if they don't exist
if not getgenv().Config then
    getgenv().Config = {
        Debug = true,
        Version = "1.0.1"
    }
end

if not getgenv().State then
    getgenv().State = {
        AutoFishing = false,
        AutoSelling = false,
        SelectedRarities = {},
        LastReelTime = 0,
        LastShakeTime = 0,
        Events = {
            Available = {}
        }
    }
end

-- Enhanced Notification System with nil checks
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
            local events = ReplicatedStorage:FindFirstChild("events")
            if events and events:FindFirstChild("character") then
                events.character:FireServer("shake")
            end
        end
    end)
end

-- Inventory Management Functions with nil checks
Functions.sellFish = function(rarity)
    if not rarity or not LocalPlayer then return end
    
    pcall(function()
        local backpack = LocalPlayer:WaitForChild("Backpack")
        local sold = 0
        
        for _, item in pairs(backpack:GetChildren()) do
            if item:FindFirstChild("values") and 
               item.values:FindFirstChild("rarity") and 
               item.values.rarity.Value == rarity then
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
    if not LocalPlayer then return end
    
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
        
        if bestRod and LocalPlayer.Character then
            bestRod.Parent = LocalPlayer.Character
            if getgenv().Config.Debug then
                Functions.ShowNotification("Equipment", "Equipped best rod: " .. bestRod.Name)
            end
        end
    end)
end

Functions.collectChest = function(chest, range)
    if not chest or not range or not LocalPlayer then return end
    
    pcall(function()
        local character = LocalPlayer.Character
        if not character then return end
        
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then return end
        
        local distance = (chest:GetPivot().Position - humanoidRootPart.Position).Magnitude
        if distance <= range then
            local events = ReplicatedStorage:FindFirstChild("events")
            if events and events:FindFirstChild("collectchest") then
                events.collectchest:FireServer(chest)
            end
        end
    end)
end

-- Initialize module
local function InitializeFunctions()
    -- Set up character added handler with error checking
    if LocalPlayer then
        pcall(function()
            LocalPlayer.CharacterAdded:Connect(function(character)
                if getgenv().Options and getgenv().Options.AutoEquipBestRod then
                    task.wait(1)
                    Functions.equipBestRod()
                end
            end)
        end)
    end
    
    if getgenv().Config and getgenv().Config.Debug then
        print("✓ Functions module initialized successfully")
    end
    
    return true
end

-- Run initialization
if InitializeFunctions() then
    return Functions
else
    warn("⚠️ Failed to initialize Functions module")
    return false
end
