-- events.lua
local Events = {
    _version = "1.0.1",
    _initialized = false,
    _eventStatus = {},
    _requiredEvents = {
        "castrod",
        "reelfinished",
        "character"
    },
    _connections = {},
    _pendingEvents = {}
}

-- Core services
local Services = {
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    RunService = game:GetService("RunService")
}

-- Silent event check without warnings
function Events.CheckEvent(eventName)
    if Events._eventStatus[eventName] ~= nil then
        return Events._eventStatus[eventName]
    end
    
    local events = Services.ReplicatedStorage:FindFirstChild("events")
    if not events then
        Events._eventStatus[eventName] = false
        Events._pendingEvents[eventName] = true
        return false
    end

    local exists = events:FindFirstChild(eventName) ~= nil
    Events._eventStatus[eventName] = exists
    
    if not exists then
        Events._pendingEvents[eventName] = true
    end
    
    return exists
end

-- Watch for event creation/removal
function Events.WatchEvents()
    local events = Services.ReplicatedStorage:FindFirstChild("events")
    if not events then
        events = Instance.new("Folder")
        events.Name = "events"
        events.Parent = Services.ReplicatedStorage
    end
    
    -- Watch for changes in the events folder
    Events._connections.added = events.ChildAdded:Connect(function(child)
        Events._eventStatus[child.Name] = true
        Events._pendingEvents[child.Name] = nil
        if getgenv().State and getgenv().State.Events then
            getgenv().State.Events.Available[child.Name] = true
        end
        
        if getgenv().Config and getgenv().Config.Debug then
            print(string.format("✓ Event became available: %s", child.Name))
        end
    end)
    
    Events._connections.removed = events.ChildRemoved:Connect(function(child)
        Events._eventStatus[child.Name] = false
        Events._pendingEvents[child.Name] = true
        if getgenv().State and getgenv().State.Events then
            getgenv().State.Events.Available[child.Name] = false
        end
    end)
end

-- Initialize events system
function Events.Initialize()
    if Events._initialized then
        return true
    end

    -- Ensure state exists
    if not getgenv().State then
        getgenv().State = {}
    end
    
    if not getgenv().State.Events then
        getgenv().State.Events = {
            Available = {}
        }
    end

    -- Check all required events silently
    for _, eventName in ipairs(Events._requiredEvents) do
        getgenv().State.Events.Available[eventName] = Events.CheckEvent(eventName)
    end

    -- Set up event watching
    Events.WatchEvents()
    
    -- Set up periodic event availability checker
    Events._connections.checker = Services.RunService.Heartbeat:Connect(function()
        for eventName in pairs(Events._pendingEvents) do
            if Events.CheckEvent(eventName) then
                Events._pendingEvents[eventName] = nil
            end
        end
    end)

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
    Events._pendingEvents = {}
    Events._eventStatus = {}
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
