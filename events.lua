-- events.lua
-- Version: 2024.12.20
-- Author: ProbTom
-- Last Updated: 2024-12-20 14:30:12

local Events = {
    _version = "1.0.1",
    _connections = {},
    _handlers = {},
    _remotes = {},
    _initialized = false,
    _lastUpdate = os.time()
}

local Debug = getgenv().LucidDebug

-- Services
local Services = {
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService")
}

local LocalPlayer = Services.Players.LocalPlayer

-- Utility Functions
local function isValidEventName(name)
    return type(name) == "string" and name:match("^[%w_]+$") ~= nil
end

local function protectedCall(func, ...)
    if type(func) ~= "function" then return false end
    return pcall(func, ...)
end

-- Event Registration
function Events.Register(eventName, callback)
    if not isValidEventName(eventName) then
        Debug.Error("Invalid event name: " .. tostring(eventName))
        return false
    end
    
    if type(callback) ~= "function" then
        Debug.Error("Invalid callback for event: " .. eventName)
        return false
    end
    
    Events._handlers[eventName] = Events._handlers[eventName] or {}
    table.insert(Events._handlers[eventName], callback)
    
    Debug.Log("Registered handler for event: " .. eventName)
    return true
end

-- Event Triggering
function Events.Trigger(eventName, ...)
    if not Events._handlers[eventName] then return false end
    
    for _, handler in ipairs(Events._handlers[eventName]) do
        task.spawn(function()
            local success, result = protectedCall(handler, ...)
            if not success then
                Debug.Error("Event handler failed for " .. eventName .. ": " .. tostring(result))
            end
        end)
    end
    
    return true
end

-- Remote Event Management
function Events.SetupRemotes()
    local config = getgenv().LucidState.Config
    
    -- Required events
    for _, eventName in ipairs(config.Events.Required) do
        local remote = Services.ReplicatedStorage:WaitForChild(eventName, 5)
        if not remote then
            Debug.Error("Required remote event not found: " .. eventName)
            return false
        end
        Events._remotes[eventName] = remote
    end
    
    -- Optional events
    for _, eventName in ipairs(config.Events.Optional) do
        local remote = Services.ReplicatedStorage:FindFirstChild(eventName)
        if remote then
            Events._remotes[eventName] = remote
        end
    end
    
    return true
end

-- Remote Event Handlers
function Events.HandleRemote(eventName, callback)
    local remote = Events._remotes[eventName]
    if not remote then
        Debug.Error("Remote event not found: " .. eventName)
        return false
    end
    
    local connection = remote.OnClientEvent:Connect(function(...)
        local success, result = protectedCall(callback, ...)
        if not success then
            Debug.Error("Remote handler failed for " .. eventName .. ": " .. tostring(result))
        end
    end)
    
    table.insert(Events._connections, connection)
    return true
end

-- Fishing Events
function Events.SetupFishing()
    -- Auto Cast
    Events.Register("AutoCast", function()
        if not getgenv().LucidState.AutoCasting then return end
        
        local castRemote = Events._remotes.castrod
        if not castRemote then return end
        
        task.spawn(function()
            while getgenv().LucidState.AutoCasting do
                castRemote:FireServer()
                task.wait(getgenv().LucidState.Config.Features.AutoCast.Delay)
            end
        end)
    end)
    
    -- Auto Reel
    Events.Register("AutoReel", function()
        if not getgenv().LucidState.AutoReeling then return end
        
        local reelRemote = Events._remotes.fishing
        if not reelRemote then return end
        
        task.spawn(function()
            while getgenv().LucidState.AutoReeling do
                reelRemote:FireServer("reel")
                task.wait(getgenv().LucidState.Config.Features.AutoReel.Delay)
            end
        end)
    end)
    
    -- Auto Shake
    Events.Register("AutoShake", function()
        if not getgenv().LucidState.AutoShaking then return end
        
        local shakeRemote = Events._remotes.fishing
        if not shakeRemote then return end
        
        task.spawn(function()
            while getgenv().LucidState.AutoShaking do
                shakeRemote:FireServer("shake")
                task.wait(getgenv().LucidState.Config.Features.AutoShake.Delay)
            end
        end)
    end)
end

-- Character Events
function Events.SetupCharacter()
    local function onCharacterAdded(character)
        Events.Trigger("CharacterAdded", character)
    end
    
    if LocalPlayer.Character then
        onCharacterAdded(LocalPlayer.Character)
    end
    
    local connection = LocalPlayer.CharacterAdded:Connect(onCharacterAdded)
    table.insert(Events._connections, connection)
end

-- Initialize Events System
function Events.Initialize()
    if Events._initialized then
        return true
    end
    
    -- Setup remote events
    if not Events.SetupRemotes() then
        Debug.Error("Failed to setup remote events")
        return false
    end
    
    -- Setup fishing events
    Events.SetupFishing()
    
    -- Setup character events
    Events.SetupCharacter()
    
    Events._initialized = true
    Debug.Log("Events system initialized")
    return true
end

-- Cleanup
function Events.Cleanup()
    for _, connection in ipairs(Events._connections) do
        if typeof(connection) == "RBXScriptConnection" then
            connection:Disconnect()
        end
    end
    
    Events._connections = {}
    Events._handlers = {}
    Events._remotes = {}
    Events._initialized = false
    
    Debug.Log("Events system cleaned up")
end

return Events
