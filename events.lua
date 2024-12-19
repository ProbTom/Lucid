-- events.lua
local Events = {
    _version = "1.0.1",
    _initialized = false,
    _connections = {},
    _events = {
        required = {
            castrod = false,
            reelfinished = false,
            character = false
        }
    }
}

-- Core services
local Services = {
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService")
}

local Player = Services.Players.LocalPlayer

-- Initialize state if not exists
if not getgenv().State then
    getgenv().State = {
        Events = {
            Available = {}
        }
    }
end

-- Silent event verification
function Events.VerifyEvents()
    local events = Services.ReplicatedStorage:WaitForChild("events", 1)
    if not events then return false end
    
    for eventName, _ in pairs(Events._events.required) do
        local event = events:FindFirstChild(eventName)
        Events._events.required[eventName] = event ~= nil
        getgenv().State.Events.Available[eventName] = event ~= nil
    end
    
    return true
end

-- Event monitoring system
function Events.StartEventMonitoring()
    if Events._connections.monitor then return end
    
    local events = Services.ReplicatedStorage:WaitForChild("events", 1)
    if not events then return end
    
    Events._connections.monitor = events.ChildAdded:Connect(function(child)
        if Events._events.required[child.Name] ~= nil then
            Events._events.required[child.Name] = true
            getgenv().State.Events.Available[child.Name] = true
        end
    end)
    
    Events._connections.removed = events.ChildRemoved:Connect(function(child)
        if Events._events.required[child.Name] ~= nil then
            Events._events.required[child.Name] = false
            getgenv().State.Events.Available[child.Name] = false
        end
    end)
end

-- Event handling system
function Events.HandleFishingEvents()
    if Events._connections.fishing then return end
    
    local events = Services.ReplicatedStorage:WaitForChild("events", 1)
    if not events then return end
    
    -- Handle rod cast events
    local castEvent = events:FindFirstChild("castrod")
    if castEvent then
        Events._connections.cast = castEvent.OnClientEvent:Connect(function()
            if getgenv().Functions then
                task.spawn(function()
                    task.wait(0.1) -- Small delay for game state update
                    if getgenv().State.AutoReeling then
                        getgenv().Functions.Reel()
                    end
                end)
            end
        end)
    end
    
    -- Handle character events (shake)
    local characterEvent = events:FindFirstChild("character")
    if characterEvent then
        Events._connections.character = characterEvent.OnClientEvent:Connect(function(action)
            if action == "shake" and getgenv().Functions then
                task.spawn(function()
                    task.wait(0.1) -- Small delay for game state update
                    if getgenv().State.AutoShaking then
                        getgenv().Functions.Shake()
                    end
                end)
            end
        end)
    end
end

-- Initialize events system
function Events.Initialize()
    if Events._initialized then return true end
    
    -- Verify events existence
    Events.VerifyEvents()
    
    -- Start monitoring
    Events.StartEventMonitoring()
    
    -- Setup event handlers
    Events.HandleFishingEvents()
    
    Events._initialized = true
    
    if getgenv().Config and getgenv().Config.Debug then
        print("✓ Events module initialized successfully")
    end
    
    return true
end

-- Cleanup function
function Events.Cleanup()
    for _, connection in pairs(Events._connections) do
        if typeof(connection) == "RBXScriptConnection" then
            connection:Disconnect()
        end
    end
    Events._connections = {}
end

-- Run initialization
local success = Events.Initialize()

if not success and getgenv().Config and getgenv().Config.Debug then
    warn("⚠️ Failed to initialize Events module")
end

-- Setup cleanup on teleport
game:GetService("Players").LocalPlayer.OnTeleport:Connect(function()
    Events.Cleanup()
end)

return Events
