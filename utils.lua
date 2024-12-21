-- utils.lua
local Utils = {
    _VERSION = "1.1.0",
    _initialized = false,
    LastUpdated = "2024-12-21"
}

-- Dependencies
local WindUI
local Debug

-- Services
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Constants
local SAVE_FOLDER = "LucidHub"
local MAX_RETRIES = 3
local RETRY_DELAY = 1

-- Ensure save directory exists
if not isfolder(SAVE_FOLDER) then
    makefolder(SAVE_FOLDER)
end

-- Initialize Utils
function Utils.init(deps)
    if Utils._initialized then return end
    
    WindUI = deps.windui or error("WindUI dependency missing")
    Debug = deps.debug or error("Debug dependency missing")
    
    Utils._initialized = true
    return true
end

-- Deep copy function for tables
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

-- Merge two tables
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

-- Safe call with error handling
function Utils.SafeCall(func, ...)
    if type(func) ~= "function" then
        Debug.Error("Attempted to call a non-function")
        return nil
    end
    
    local success, result = pcall(func, ...)
    if not success then
        Debug.Error("Function call failed: " .. tostring(result))
        return nil
    end
    return result
end

-- File handling functions
function Utils.SaveToFile(filename, data)
    local path = SAVE_FOLDER .. "/" .. filename
    local success, result = pcall(function()
        writefile(path, HttpService:JSONEncode(data))
    end)
    
    if not success then
        Debug.Error("Failed to save file: " .. tostring(result))
        return false
    end
    return true
end

function Utils.LoadFromFile(filename)
    local path = SAVE_FOLDER .. "/" .. filename
    if not isfile(path) then return nil end
    
    local success, result = pcall(function()
        return HttpService:JSONDecode(readfile(path))
    end)
    
    if not success then
        Debug.Error("Failed to load file: " .. tostring(result))
        return nil
    end
    return result
end

-- Performance utilities
function Utils.Throttle(callback, limit)
    local lastRun = 0
    return function(...)
        local now = os.clock()
        if now - lastRun >= limit then
            lastRun = now
            return Utils.SafeCall(callback, ...)
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
            Utils.SafeCall(callback, unpack(args))
        end)
    end
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

-- Network utilities
function Utils.HttpGet(url, retries)
    retries = retries or MAX_RETRIES
    
    for i = 1, retries do
        local success, result = pcall(function()
            return game:HttpGet(url)
        end)
        
        if success then
            return result
        end
        
        Debug.Warn(string.format("HTTP GET failed (attempt %d/%d): %s", 
            i, retries, tostring(result)))
        
        if i < retries then
            task.wait(RETRY_DELAY)
        end
    end
    
    return nil
end

-- UI utilities
function Utils.CreateNotification(title, content, duration)
    if not WindUI then return end
    
    WindUI:Notify({
        Title = title,
        Content = content,
        Duration = duration or 5
    })
end

-- Version checking
function Utils.CheckVersion(current, minimum)
    local function parseVersion(ver)
        local major, minor, patch = ver:match("(%d+)%.(%d+)%.(%d+)")
        return tonumber(major), tonumber(minor), tonumber(patch)
    end
    
    local curMajor, curMinor, curPatch = parseVersion(current)
    local minMajor, minMinor, minPatch = parseVersion(minimum)
    
    if curMajor > minMajor then return true end
    if curMajor < minMajor then return false end
    if curMinor > minMinor then return true end
    if curMinor < minMinor then return false end
    return curPatch >= minPatch
end

return Utils
