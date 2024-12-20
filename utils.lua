-- utils.lua
-- Version: 1.0.1
-- Author: ProbTom
-- Created: 2024-12-20 19:47:58 UTC

local Utils = {
    _VERSION = "1.0.1",
    _initialized = false
}

-- Dependencies
local Debug

-- Services
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Constants
local MAX_RETRIES = 3
local RETRY_DELAY = 1

-- Table utilities
function Utils.DeepCopy(original)
    if type(original) ~= "table" then return original end
    
    local copy = {}
    for k, v in pairs(original) do
        if type(v) == "table" then
            copy[k] = Utils.DeepCopy(v)
        else
            copy[k] = v
        end
    end
    return copy
end

function Utils.Merge(t1, t2)
    for k, v in pairs(t2) do
        if type(v) == "table" and type(t1[k]) == "table" then
            Utils.Merge(t1[k], v)
        else
            t1[k] = v
        end
    end
    return t1
end

-- String utilities
function Utils.FormatString(str, ...)
    local args = {...}
    return str:gsub("{(%d+)}", function(i)
        return tostring(args[tonumber(i)])
    end)
end

-- HTTP utilities with retry
function Utils.HttpGet(url)
    for i = 1, MAX_RETRIES do
        local success, result = pcall(function()
            return HttpService:GetAsync(url)
        end)
        
        if success then
            return result
        end
        
        Debug.Warn(string.format("HTTP GET failed (attempt %d/%d): %s", 
            i, MAX_RETRIES, tostring(result)))
        
        if i < MAX_RETRIES then
            task.wait(RETRY_DELAY)
        end
    end
    
    return nil
end

-- Player utilities
function Utils.GetPlayerFromString(str)
    str = str:lower()
    local players = Players:GetPlayers()
    
    -- Exact match
    for _, player in ipairs(players) do
        if player.Name:lower() == str then
            return player
        end
    end
    
    -- Partial match
    for _, player in ipairs(players) do
        if player.Name:lower():find(str, 1, true) then
            return player
        end
    end
    
    return nil
end

-- Performance utilities
function Utils.Throttle(callback, limit)
    local lastRun = 0
    return function(...)
        local now = os.clock()
        if now - lastRun >= limit then
            lastRun = now
            return callback(...)
        end
    end
end

function Utils.Debounce(callback, delay)
    local timer
    return function(...)
        local args = {...}
        if timer then timer:Disconnect() end
        
        timer = RunService.Heartbeat:Connect(function()
            timer:Disconnect()
            callback(unpack(args))
        end)
    end
end

-- Safety utilities
function Utils.SafeCall(func, ...)
    if type(func) ~= "function" then
        Debug.Error("Attempted to call a non-function")
        return nil
    end
    
    local success, result = pcall(func, ...)
    if not success then
        Debug.Error(string.format("SafeCall failed: %s", tostring(result)))
        return nil
    end
    return result
end

-- Initialize module
function Utils.init(modules)
    if Utils._initialized then return true end
    
    Debug = modules.debug
    if not Debug then
        return false
    end
    
    Utils._initialized = true
    Debug.Info("Utils module initialized")
    return true
end

return Utils
