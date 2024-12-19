-- events.lua
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Initialize Events table
local Events = {
    Connections = {},
    Active = {}
}

-- Event handling functions
Events.StartAutoFishing = function()
    if Events.Active.Fishing then return end
    
    Events.Active.Fishing = true
    Events.Connections.Fishing = RunService.RenderStepped:Connect(function()
        if not Events.Active.Fishing then return end
        
        local gui = LocalPlayer:WaitForChild("PlayerGui")
        if not gui then return end
        
        -- Handle auto fishing sequence
        if getgenv().Functions then
            if getgenv().Options.AutoFish then
                getgenv().Functions.autoFish(gui)
            end
            
            if getgenv().Options.AutoReel then
                getgenv().Functions.autoReel(gui)
            end
            
            if getgenv().Options.AutoShake then
                getgenv().Functions.autoShake(gui)
            end
        end
    end)
end

Events.StopAutoFishing = function()
    if Events.Connections.Fishing then
        Events.Connections.Fishing:Disconnect()
        Events.Connections.Fishing = nil
    end
    Events.Active.Fishing = false
end

Events.StartAutoCollectChests = function()
    if Events.Active.ChestCollection then return end
    
    Events.Active.ChestCollection = true
    Events.Connections.ChestCollection = RunService.Heartbeat:Connect(function()
        if not Events.Active.ChestCollection then return end
        
        for _, chest in pairs(workspace:GetChildren()) do
            if chest:IsA("Model") and chest.Name:match("Chest") then
                if getgenv().Functions then
                    getgenv().Functions.collectChest(chest, getgenv().Options.ChestRange)
                end
            end
        end
    end)
end

Events.StopAutoCollectChests = function()
    if Events.Connections.ChestCollection then
        Events.Connections.ChestCollection:Disconnect()
        Events.Connections.ChestCollection = nil
    end
    Events.Active.ChestCollection = false
end

-- Auto-sell system
Events.StartAutoSell = function()
    if Events.Active.Selling then return end
    
    Events.Active.Selling = true
    Events.Connections.Selling = RunService.Heartbeat:Connect(function()
        if not Events.Active.Selling then return end
        
        for rarity, enabled in pairs(getgenv().State.SelectedRarities) do
            if enabled and getgenv().Functions then
                getgenv().Functions.sellFish(rarity)
            end
        end
    end)
end

Events.StopAutoSell = function()
    if Events.Connections.Selling then
        Events.Connections.Selling:Disconnect()
        Events.Connections.Selling = nil
    end
    Events.Active.Selling = false
end

-- Character respawn handling
Events.SetupCharacterHandler = function()
    local function onCharacterAdded(character)
        if getgenv().Options.AutoEquipBestRod and getgenv().Functions then
            task.wait(1) -- Wait for character to fully load
            getgenv().Functions.equipBestRod()
        end
    end
    
    if LocalPlayer.Character then
        onCharacterAdded(LocalPlayer.Character)
    end
    
    Events.Connections.CharacterAdded = LocalPlayer.CharacterAdded:Connect(onCharacterAdded)
end

-- Cleanup function
Events.CleanupAllConnections = function()
    for _, connection in pairs(Events.Connections) do
        if typeof(connection) == "RBXScriptConnection" and connection.Connected then
            connection:Disconnect()
        end
    end
    
    Events.Connections = {}
    Events.Active = {}
end

-- Initialize events system
local function InitializeEvents()
    Events.SetupCharacterHandler()
    
    -- Clean up on script end
    game:BindToClose(function()
        Events.CleanupAllConnections()
    end)
    
    return true
end

-- Set global reference
getgenv().Events = Events

return InitializeEvents()
