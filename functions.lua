-- functions.lua
local Functions = {
    _version = "1.0.1",
    _initialized = false,
    _connections = {},
    _timers = {
        lastCast = 0,
        lastReel = 0,
        lastShake = 0
    },
    _cooldowns = {
        cast = 1,
        reel = 0.5,
        shake = 0.5
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

-- Initialize state if not exists
if not getgenv().State then
    getgenv().State = {
        AutoCasting = false,
        AutoReeling = false,
        AutoShaking = false,
        LastReelTime = 0,
        LastShakeTime = 0,
        Events = {
            Available = {}
        }
    }
end

-- Core fishing functions with cooldown management
function Functions.Cast()
    if tick() - Functions._timers.lastCast < Functions._cooldowns.cast then return end
    
    local events = Services.ReplicatedStorage:WaitForChild("events", 1)
    if not events then return end
    
    local castEvent = events:FindFirstChild("castrod")
    if not castEvent then return end

    Functions._timers.lastCast = tick()
    castEvent:FireServer()
end

function Functions.Reel()
    if tick() - Functions._timers.lastReel < Functions._cooldowns.reel then return end
    
    local events = Services.ReplicatedStorage:WaitForChild("events", 1)
    if not events then return end
    
    local reelEvent = events:FindFirstChild("reelfinished")
    if not reelEvent then return end

    Functions._timers.lastReel = tick()
    reelEvent:FireServer()
end

function Functions.Shake()
    if tick() - Functions._timers.lastShake < Functions._cooldowns.shake then return end
    
    local events = Services.ReplicatedStorage:WaitForChild("events", 1)
    if not events then return end
    
    local characterEvent = events:FindFirstChild("character")
    if not characterEvent then return end

    Functions._timers.lastShake = tick()
    characterEvent:FireServer("shake")
end

-- Auto fishing system
function Functions.StartAutoFishing()
    if Functions._connections.fishing then return end
    
    Functions._connections.fishing = Services.RunService.Heartbeat:Connect(function()
        if not Player or not Player.Character then return end
        
        local playerGui = Player:FindFirstChild("PlayerGui")
        if not playerGui then return end
        
        local fishingGui = playerGui:FindFirstChild("FishingGui")
        if not fishingGui then return end

        -- Auto Cast Logic
        if getgenv().State.AutoCasting then
            local castingBar = fishingGui:FindFirstChild("CastingBar")
            if not castingBar or not castingBar.Visible then
                Functions.Cast()
            end
        end

        -- Auto Reel Logic
        if getgenv().State.AutoReeling then
            local reelButton = fishingGui:FindFirstChild("ReelButton")
            if reelButton and reelButton.Visible then
                Functions.Reel()
            end
        end

        -- Auto Shake Logic
        if getgenv().State.AutoShaking then
            local shakeBar = fishingGui:FindFirstChild("ShakeBar")
            if shakeBar and shakeBar.Visible then
                Functions.Shake()
            end
        end
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
    
    -- Start auto fishing if enabled
    Functions.StartAutoFishing()
    
    Functions._initialized = true
    
    if getgenv().Config and getgenv().Config.Debug then
        print("✓ Functions module initialized successfully")
    end
    
    return true
end

-- Cleanup function
function Functions.Cleanup()
    Functions.StopAutoFishing()
    
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
