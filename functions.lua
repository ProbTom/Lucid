-- functions.lua
local Functions = {}

-- Core Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")

-- Constants
local MINIMUM_WAIT = 0.05
local DEFAULT_STRENGTH = 100

-- Utility Functions
Functions.ShowNotification = function(title, message)
    if getgenv().Fluent then
        getgenv().Fluent:Notify({
            Title = title or "Notification",
            Content = message or "",
            Duration = 3
        })
    end
end

-- Core Fishing Functions
Functions.autoFish = function(gui)
    pcall(function()
        if not gui then return end
        
        local rodName = ReplicatedStorage.playerstats[LocalPlayer.Name].Stats.rod.Value
        local rod = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild(rodName)
        
        if not rod then return end
        
        -- Only cast if we're not in a minigame
        if not gui:FindFirstChild("minigame") then
            local castEvent = ReplicatedStorage.events:WaitForChild("castrod")
            castEvent:FireServer()
            
            if getgenv().Config.Debug then
                Functions.ShowNotification("Auto Fish", "Casting rod...")
            end
        end
    end)
end

Functions.autoReel = function(gui)
    pcall(function()
        if not gui then return end
        
        local minigame = gui:FindFirstChild("minigame")
        if not minigame then return end
        
        local reelEvent = ReplicatedStorage.events:WaitForChild("reelfinished")
        
        -- Ensure we don't spam the server
        if tick() - (getgenv().State.LastReelTime or 0) >= MINIMUM_WAIT then
            reelEvent:FireServer(DEFAULT_STRENGTH, true)
            getgenv().State.LastReelTime = tick()
            
            if getgenv().Config.Debug then
                Functions.ShowNotification("Auto Reel", "Reeling fish...")
            end
        end
    end)
end

Functions.autoShake = function(gui)
    pcall(function()
        if not gui then return end
        
        local minigame = gui:FindFirstChild("minigame")
        if not minigame then return end
        
        if tick() - (getgenv().State.LastShakeTime or 0) >= MINIMUM_WAIT then
            VirtualUser:CaptureController()
            VirtualUser:ClickButton1(Vector2.new())
            getgenv().State.LastShakeTime = tick()
            
            if getgenv().Config.Debug then
                Functions.ShowNotification("Auto Shake", "Shaking...")
            end
        end
    end)
end

-- Inventory Management Functions
Functions.sellFish = function(rarity)
    pcall(function()
        if not getgenv().State.AutoSelling then return end
        
        local backpack = LocalPlayer:WaitForChild("Backpack")
        for _, item in pairs(backpack:GetChildren()) do
            if item:FindFirstChild("values") and 
               item.values:FindFirstChild("rarity") and 
               item.values.rarity.Value == rarity then
                
                local sellEvent = ReplicatedStorage.events:WaitForChild("character")
                sellEvent:FireServer("sell", item.Name)
                task.wait(0.1) -- Prevent server overload
                
                if getgenv().Config.Debug then
                    Functions.ShowNotification("Auto Sell", "Selling " .. item.Name)
                end
            end
        end
    end)
end

Functions.collectChest = function(chest, range)
    pcall(function()
        local character = LocalPlayer.Character
        if not character or not chest then return end
        
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        local chestPart = chest:FindFirstChild("Hitbox") or chest:FindFirstChild("HumanoidRootPart")
        
        if humanoidRootPart and chestPart then
            local distance = (humanoidRootPart.Position - chestPart.Position).Magnitude
            if distance <= (range or getgenv().Options.ChestRange) then
                local collectEvent = ReplicatedStorage.events:WaitForChild("character")
                collectEvent:FireServer("collect", chest)
                
                if getgenv().Config.Debug then
                    Functions.ShowNotification("Auto Collect", "Collecting chest...")
                end
            end
        end
    end)
end

Functions.equipBestRod = function()
    pcall(function()
        local character = LocalPlayer.Character
        if not character then return end
        
        -- Iterate through rod ranking to find the best available rod
        for _, rodName in ipairs(getgenv().Config.Items.RodRanking) do
            if character:FindFirstChild(rodName) then
                local equipEvent = ReplicatedStorage.events:WaitForChild("character")
                equipEvent:FireServer("equip", rodName)
                
                if getgenv().Config.Debug then
                    Functions.ShowNotification("Auto Equip", "Equipped " .. rodName)
                end
                break
            end
        end
    end)
end

-- Error Handling Functions
Functions.HandleError = function(context, error)
    if getgenv().Config.Debug then
        warn(string.format("[%s] Error: %s", context, error))
        Functions.ShowNotification("Error", context .. ": " .. error)
    end
end

-- Initialize function module
local function InitializeFunctions()
    if not getgenv().Config then
        error("Functions: Config not initialized")
        return false
    end
    
    if not getgenv().State then
        error("Functions: State not initialized")
        return false
    end
    
    return true
end

-- Run initialization
if not InitializeFunctions() then
    return false
end

return Functions
