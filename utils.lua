-- utils.lua
-- Version: 1.0.1
-- Author: ProbTom
-- Created: 2024-12-20 14:44:48 UTC

local Utils = {}

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

function Utils.TrimString(str)
    return str:match("^%s*(.-)%s*$")
end

-- Math utilities
function Utils.Round(num, decimals)
    local mult = 10^(decimals or 0)
    return math.floor(num * mult + 0.5) / mult
end

function Utils.Lerp(a, b, t)
    return a + (b - a) * t
end

function Utils.Clamp(value, min, max)
    return math.min(math.max(value, min), max)
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

function Utils.IsPlayerAlive(player)
    player = player or Players.LocalPlayer
    return player and player.Character and player.Character:FindFirstChild("Humanoid") 
           and player.Character.Humanoid.Health > 0
end

-- HTTP utilities
function Utils.HttpGet(url, retries)
    retries = retries or MAX_RETRIES
    
    local success, result
    for i = 1, retries do
        success, result = pcall(function()
            return HttpService:GetAsync(url)
        end)
        
        if success then
            return result
        end
        
        Debug.Warn(string.format("HTTP GET failed (attempt %d/%d): %s", i, retries, tostring(result)))
        if i < retries then
            task.wait(RETRY_DELAY)
        end
    end
    
    return nil, result
end

function Utils.JsonEncode(data)
    return HttpService:JSONEncode(data)
end

function Utils.JsonDecode(str)
    return HttpService:JSONDecode(str)
end

-- Time utilities
function Utils.FormatTime(seconds)
    local days = math.floor(seconds / 86400)
    local hours = math.floor((seconds % 86400) / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = seconds % 60
    
    if days > 0 then
        return string.format("%dd %02dh %02dm %02ds", days, hours, minutes, secs)
    elseif hours > 0 then
        return string.format("%02dh %02dm %02ds", hours, minutes, secs)
    elseif minutes > 0 then
        return string.format("%02dm %02ds", minutes, secs)
    else
        return string.format("%02ds", secs)
    end
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
        if timer then
            timer:Disconnect()
        end
        
        timer = RunService.Heartbeat:Connect(function()
            timer:Disconnect()
            callback(unpack(args))
        end)
    end
end

-- Safety utilities
function Utils.SafeCall(func, ...)
    local success, result = pcall(func, ...)
    if not success then
        Debug.Error(string.format("SafeCall failed: %s", tostring(result)))
        return nil
    end
    return result
end

function Utils.ProtectGui(gui)
    if syn and syn.protect_gui then
        syn.protect_gui(gui)
    elseif gethui then
        gui.Parent = gethui()
    else
        gui.Parent = game:GetService("CoreGui")
    end
end

-- Initialize module
function Utils.init(modules)
    Debug = modules.debug
    Debug.Info("Utils module initialized")
    return true
end

return Utils
