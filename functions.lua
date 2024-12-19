-- functions.lua
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")

-- Initialize Functions table
local Functions = {}

-- Core fishing functions
Functions.autoFish = function(gui)
    pcall(function()
        if not gui then return end
        
        local rodName = ReplicatedStorage.playerstats[LocalPlayer.Name].Stats.rod.Value
        local rod = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild(rodName)
        
        if not rod then return end
        
        -- Handle casting
        if not gui:FindFirstChild("minigame") then
            local castEvent = ReplicatedStorage.events:WaitForChild("castrod")
            castEvent:FireServer()
            return
        end
    end)
end

Functions.autoReel = function(gui)
    pcall(function()
        if not gui then return end
        
        local minigame = gui:FindFirstChild("minigame")
        if not minigame then return end
        
        local reelEvent = ReplicatedStorage.events:WaitForChild("reelfinished")
        local strength = 100 -- Maximum strength
        
        if tick() - (getgenv().State.LastReelTime or 0) >= 0.05 then
            reelEvent:FireServer(strength, true)
            getgenv().State.LastReelTime = tick()
        end
    end)
end

Functions.autoShake = function(gui)
    pcall(function()
        if not gui then return end
        
        local minigame = gui:FindFirstChild("minigame")
        if not minigame then return end
        
        if tick() - (getgenv().State.LastShakeTime or 0) >= 0.05 then
            VirtualUser:CaptureController()
            VirtualUser:ClickButton1(Vector2.new())
            getgenv().State.LastShakeTime = tick()
        end
    end)
end

-- Inventory management functions
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
                task.wait(0.1)
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
            end
        end
    end)
end

Functions.equipBestRod = function()
    pcall(function()
        local character = LocalPlayer.Character
        if not character then return end
        
        for _, rodName in ipairs(getgenv().Config.Items.RodRanking) do
            if character:FindFirstChild(rodName) then
                local equipEvent = ReplicatedStorage.events:WaitForChild("character")
                equipEvent:FireServer("equip", rodName)
                break
            end
        end
    end)
end

-- Utility functions
Functions.ShowNotification = function(title, content, duration)
    if getgenv().Fluent then
        getgenv().Fluent:Notify({
            Title = title or "Lucid Hub",
            Content = content,
            Duration = duration or 5
        })
    end
end

Functions.CalculateDistance = function(position1, position2)
    return (position1 - position2).Magnitude
end

-- Set global Functions reference
getgenv().Functions = Functions

return true
