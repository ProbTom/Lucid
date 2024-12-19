-- compatibility.lua
local Compatibility = {
    _version = "1.0.1",
    _initialized = false,
    _connections = {},
    _eventChecks = {},
    _eventRetries = {}
}

-- Core services
local Services = {
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService")
}

-- Event retry configuration
local RETRY_DELAY = 1
local MAX_RETRIES = 10

-- Silent event check
function Compatibility.CheckEvent(eventName)
    if not Compatibility._eventChecks[eventName] then
        Compatibility._eventChecks[eventName] = {
            exists = false,
            lastCheck = 0
        }
    end

    local currentTime = tick()
    if currentTime - Compatibility._eventChecks[eventName].lastCheck < RETRY_DELAY then
        return Compatibility._eventChecks[eventName].exists
    end

    local events = Services.ReplicatedStorage:FindFirstChild("events")
    if events then
        local eventExists = events:FindFirstChild(eventName) ~= nil
        Compatibility._eventChecks[eventName] = {
            exists = eventExists,
            lastCheck = currentTime
        }
        return eventExists
    end

    Compatibility._eventChecks[eventName] = {
        exists = false,
        lastCheck = currentTime
    }
    return false
end

-- Setup event monitoring
function Compatibility.MonitorEvents()
    local events = Services.ReplicatedStorage:FindFirstChild("events")
    if not events then
        events = Instance.new("Folder")
        events.Name = "events"
        events.Parent = Services.ReplicatedStorage
    end

    -- Monitor event creation
    Compatibility._connections.eventAdded = events.ChildAdded:Connect(function(child)
        Compatibility._eventChecks[child.Name] = {
            exists = true,
            lastCheck = tick()
        }
        
        if getgenv().State and getgenv().State.Events then
            getgenv().State.Events.Available[child.Name] = true
        end
    end)

    -- Monitor event removal
    Compatibility._connections.eventRemoved = events.ChildRemoved:Connect(function(child)
        Compatibility._eventChecks[child.Name] = {
            exists = false,
            lastCheck = tick()
        }
        
        if getgenv().State and getgenv().State.Events then
            getgenv().State.Events.Available[child.Name] = false
        end
    end)
end

-- Setup periodic event checking
function Compatibility.StartEventRetrySystem()
    Compatibility._connections.eventRetry = Services.RunService.Heartbeat:Connect(function()
        for eventName, retries in pairs(Compatibility._eventRetries) do
            if retries < MAX_RETRIES then
                if Compatibility.CheckEvent(eventName) then
                    Compatibility._eventRetries[eventName] = nil
                else
                    Compatibility._eventRetries[eventName] = retries + 1
                end
            end
        end
    end)
end

-- Initialize compatibility layer
function Compatibility.Initialize()
    if Compatibility._initialized then
        return true
    end

    -- Setup event monitoring
    Compatibility.MonitorEvents()

    -- Initialize event retry system
    Compatibility._eventRetries = {
        castrod = 0,
        character = 0
    }
    
    -- Start event retry system
    Compatibility.StartEventRetrySystem()

    Compatibility._initialized = true
    
    if getgenv().Config and getgenv().Config.Debug then
        print("✓ Compatibility layer initialized successfully")
    end

    return true
end

-- Cleanup function
function Compatibility.Cleanup()
    for _, connection in pairs(Compatibility._connections) do
        if typeof(connection) == "RBXScriptConnection" then
            connection:Disconnect()
        end
    end
    Compatibility._connections = {}
    Compatibility._eventChecks = {}
    Compatibility._eventRetries = {}
end

-- Run initialization
local success = Compatibility.Initialize()

if not success and getgenv().Config and getgenv().Config.Debug then
    warn("⚠️ Failed to initialize Compatibility layer")
end

-- Setup cleanup on teleport
game:GetService("Players").LocalPlayer.OnTeleport:Connect(function()
    Compatibility.Cleanup()
end)

return Compatibility
