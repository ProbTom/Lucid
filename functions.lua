-- functions.lua
if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Functions = {}

-- Get required services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Existing functions
Functions.ShowNotification = function(String)
    if getgenv().Fluent then
        getgenv().Fluent:Notify({
            Title = "Lucid Hub",
            Content = String,
            Duration = 5
        })
    end
end

Functions.autoCast = function(CastMode, LocalCharacter, HumanoidRootPart)
    -- Existing autoCast implementation
end

Functions.autoShake = function(gui)
    -- Existing autoShake implementation
end

Functions.autoReel = function(PlayerGui, ReelMode)
    -- Existing autoReel implementation
end

Functions.handleZoneCast = function(ZoneCast, Zone, FishingZonesFolder, HumanoidRootPart)
    -- Existing handleZoneCast implementation
end

-- New Item Management Functions
Functions.sellFish = function(rarity)
    pcall(function()
        local backpack = LocalPlayer:WaitForChild("Backpack")
        for _, item in pairs(backpack:GetChildren()) do
            if item:FindFirstChild("values") and 
               item.values:FindFirstChild("rarity") and 
               item.values.rarity.Value == rarity then
                ReplicatedStorage:WaitForChild("events"):WaitForChild("character"):FireServer("sell", item.Name)
                task.wait(0.1) -- Small delay between sells
            end
        end
    end)
end

Functions.collectChest = function(chest, range)
    pcall(function()
        local character = LocalPlayer.Character
        if character and chest then
            local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
            local chestPart = chest:FindFirstChild("Hitbox") or chest:FindFirstChild("HumanoidRootPart")
            
            if humanoidRootPart and chestPart then
                local distance = (humanoidRootPart.Position - chestPart.Position).Magnitude
                if distance <= (range or 50) then
                    ReplicatedStorage:WaitForChild("events"):WaitForChild("character"):FireServer("collect", chest)
                end
            end
        end
    end)
end

Functions.equipBestRod = function()
    pcall(function()
        local character = LocalPlayer.Character
        if not character then return end
        
        -- Use rod ranking from config
        for _, rodName in ipairs(getgenv().Config.Items.RodRanking) do
            if character:FindFirstChild(rodName) then
                ReplicatedStorage:WaitForChild("events"):WaitForChild("character"):FireServer("equip", rodName)
                break
            end
        end
    end)
end

-- Set global Functions table
getgenv().Functions = Functions

return true
