-- events.lua
local Events = {
    Connections = {},
    Active = {},
    LastTick = {}
}

-- Core Services
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Basic validation
if not getgenv or not getgenv().Functions then
    warn("Required environment not available")
    return false
end

-- Initialize State if needed
if not getgenv().State then
    getgenv().State = {
        Events = {
            Available = {}
        }
    }
end

-- Cooldown management
local function isOnCooldown(action)
    if not Events.LastTick[action] then
        Events.LastTick[action] = 0
        return false
    end
    return (tick() - Events.LastTick[action]) < 0.1
end

local function updateCooldown(action)
    Events.LastTick[action] = tick()
end

-- Basic event handlers
Events.StartAutoFishing = function()
    if Events.Active.Fishing then return end
    Events.Active.Fishing = true
    
    pcall(function()
        Events.Connections.Fishing = RunService.RenderStepped:Connect(function()
            if not Events.Active.Fishing then return end
            
            local player = Players.LocalPlayer
            if not player then return end
            
            local gui = player:FindFirstChild("PlayerGui")
            if not gui then return end
            
            if getgenv().Options.AutoFish and not isOnCooldown("fishing") then
                pcall(function() getgenv().Functions.autoFish(gui) end)
                updateCooldown("fishing")
            end
            
            if getgenv().Options.AutoReel and not isOnCooldown("reeling") then
                pcall(function() getgenv().Functions.autoReel(gui) end)
                updateCooldown("reeling")
            end
            
            if getgenv().Options.AutoShake and not isOnCooldown("shaking") then
                pcall(function() getgenv().Functions.autoShake(gui) end)
                updateCooldown("shaking")
            end
        end)
    end)
end

Events.StopAutoFishing = function()
    if Events.Connections.Fishing then
        pcall(function()
            Events.Connections.Fishing:Disconnect()
            Events.Connections.Fishing = nil
        end)
    end
    Events.Active.Fishing = false
end

Events.StartAutoCollectChests = function()
    if Events.Active.ChestCollection then return end
    Events.Active.ChestCollection = true
    
    pcall(function()
        Events.Connections.ChestCollection = RunService.Heartbeat:Connect(function()
            if not Events.Active.ChestCollection or isOnCooldown("chestCheck") then return end
            
            pcall(function()
                for _, chest in pairs(workspace:GetChildren()) do
                    if chest:IsA("Model") and chest.Name:match("Chest") then
                        getgenv().Functions.collectChest(chest, getgenv().Options.ChestRange)
                    end
                end
            end)
            
            updateCooldown("chestCheck")
        end)
    end)
end

Events.StopAutoCollectChests = function()
    if Events.Connections.ChestCollection then
        pcall(function()
            Events.Connections.ChestCollection:Disconnect()
            Events.Connections.ChestCollection = nil
        end)
    end
    Events.Active.ChestCollection = false
end

Events.StartAutoSell = function()
    if Events.Active.Selling then return end
    Events.Active.Selling = true
    
    pcall(function()
        Events.Connections.Selling = RunService.Heartbeat:Connect(function()
            if not Events.Active.Selling or isOnCooldown("selling") then return end
            
            pcall(function()
                if getgenv().State.SelectedRarities then
                    for rarity, enabled in pairs(getgenv().State.SelectedRarities) do
                        if enabled then
                            getgenv().Functions.sellFish(rarity)
                        end
                    end
                end
            end)
            
            updateCooldown("selling")
        end)
    end)
end

Events.StopAutoSell = function()
    if Events.Connections.Selling then
        pcall(function()
            Events.Connections.Selling:Disconnect()
            Events.Connections.Selling = nil
        end)
    end
    Events.Active.Selling = false
end

-- Simple initialization
local function Initialize()
    -- Check available events
    local events = ReplicatedStorage:FindFirstChild("events")
    if events then
        for _, event in ipairs(events:GetChildren()) do
            getgenv().State.Events.Available[event.Name] = true
        end
    end
    
    -- Basic cleanup
    game:GetService("Players").PlayerRemoving:Connect(function(player)
        if player == Players.LocalPlayer then
            for _, connection in pairs(Events.Connections) do
                pcall(function()
                    if connection.Connected then
                        connection:Disconnect()
                    end
                end)
            end
        end
    end)
    
    return true
end

-- Run initialization
local success = pcall(Initialize)
if success then
    return Events
end

return false
