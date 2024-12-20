-- functions.lua
local Functions = {
    _version = "1.0.1",
    _initialized = false,
    _connections = {},
    _cooldowns = {
        cast = 0,
        reel = 0
    }
}

-- Core services
local Services = {
    Players = game:GetService("Players"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    RunService = game:GetService("RunService")
}

local Player = Services.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

-- Core fishing functions
function Functions.Cast()
    local events = Services.ReplicatedStorage:WaitForChild("events")
    local castEvent = events:WaitForChild("castrod")
    
    if tick() - Functions._cooldowns.cast < 1 then return end
    Functions._cooldowns.cast = tick()
    
    castEvent:FireServer()
end

function Functions.Reel()
    local events = Services.ReplicatedStorage:WaitForChild("events")
    local reelEvent = events:WaitForChild("reelfinished")
    
    if tick() - Functions._cooldowns.reel < 1 then return end
    Functions._cooldowns.reel = tick()
    
    reelEvent:FireServer()
end

function Functions.StartAutoFishing()
    if Functions._connections.fishing then return end
    
    Functions._connections.fishing = Services.RunService.Heartbeat:Connect(function()
        if not getgenv().State.AutoFishing then
            Functions._connections.fishing:Disconnect()
            Functions._connections.fishing = nil
            return
        end
        
        -- Auto fishing logic
        Functions.Cast()
        task.wait(2)
        Functions.Reel()
    end)
end

function Functions.StopAutoFishing()
    if Functions._connections.fishing then
        Functions._connections.fishing:Disconnect()
        Functions._connections.fishing = nil
    end
end

-- Initialize functions system
function Functions.Initialize()
    if Functions._initialized then return true end
    
    -- Set up character handling
    Player.CharacterAdded:Connect(function(char)
        Character = char
    end)
    
    Functions._initialized = true
    
    if getgenv().Config and getgenv().Config.Debug then
        print("✓ Functions module initialized successfully")
    end
    
    return true
end

-- Cleanup function
function Functions.Cleanup()
    for _, connection in pairs(Functions._connections) do
        if typeof(connection) == "RBXScriptConnection" then
            connection:Disconnect()
        end
    end
    Functions._connections = {}
end

-- Run initialization
local success = Functions.Initialize()

if not success and getgenv().Config and getgenv().Config.Debug then
    warn("⚠️ Failed to initialize Functions module")
end

-- Setup cleanup on teleport
game:GetService("Players").LocalPlayer.OnTeleport:Connect(function()
    Functions.Cleanup()
end)

return Functions
