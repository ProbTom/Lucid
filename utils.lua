-- utils.lua
-- Version: 2024.12.20
-- Author: ProbTom
-- Last Updated: 2024-12-20 14:32:12

local Utils = {
    _version = "1.0.1",
    _initialized = false,
    _cache = {}
}

local Debug = getgenv().LucidDebug

-- Services
local Services = {
    HttpService = game:GetService("HttpService"),
    TweenService = game:GetService("TweenService"),
    RunService = game:GetService("RunService"),
    Players = game:GetService("Players")
}

local LocalPlayer = Services.Players.LocalPlayer

-- Time Management
function Utils.GetTimestamp()
    return os.time()
end

function Utils.FormatTime(timestamp)
    return os.date("%Y-%m-%d %H:%M:%S", timestamp or Utils.GetTimestamp())
end

function Utils.TimeSince(timestamp)
    return os.time() - timestamp
end

-- Data Management
function Utils.ToJSON(data)
    if type(data) ~= "table" then return "{}" end
    
    local success, result = pcall(function()
        return Services.HttpService:JSONEncode(data)
    end)
    
    return success and result or "{}"
end

function Utils.FromJSON(str)
    if type(str) ~= "string" then return {} end
    
    local success, result = pcall(function()
        return Services.HttpService:JSONDecode(str)
    end)
    
    return success and result or {}
end

-- File Management
function Utils.SaveToFile(filename, data)
    if not writefile then return false end
    
    local success, result = pcall(function()
        writefile(filename, Utils.ToJSON(data))
        return true
    end)
    
    return success
end

function Utils.LoadFromFile(filename)
    if not readfile then return false end
    
    local success, content = pcall(function()
        return readfile(filename)
    end)
    
    if not success then return {} end
    return Utils.FromJSON(content)
end

-- Character Management
function Utils.GetCharacter()
    return LocalPlayer.Character
end

function Utils.GetHumanoid()
    local character = Utils.GetCharacter()
    return character and character:FindFirstChild("Humanoid")
end

function Utils.GetRoot()
    local character = Utils.GetCharacter()
    return character and (character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso"))
end

-- Position Management
function Utils.GetPosition()
    local root = Utils.GetRoot()
    return root and root.Position
end

function Utils.Distance(pos1, pos2)
    if not pos1 or not pos2 then return math.huge end
    return (pos1 - pos2).Magnitude
end

function Utils.IsWithinDistance(pos1, pos2, maxDistance)
    return Utils.Distance(pos1, pos2) <= (maxDistance or math.huge)
end

-- Anti-Cheat Protection
function Utils.SafeWait(duration)
    duration = math.clamp(duration or 0, 0, 1)
    local start = tick()
    repeat 
        Services.RunService.Heartbeat:Wait()
    until tick() - start >= duration
end

function Utils.SafeTeleport(position)
    local root = Utils.GetRoot()
    if not root or not position then return false end
    
    local humanoid = Utils.GetHumanoid()
    if humanoid then
        humanoid:ChangeState(Enum.HumanoidStateType.Physics)
    end
    
    root.CFrame = CFrame.new(position)
    Utils.SafeWait(0.1)
    
    if humanoid then
        humanoid:ChangeState(Enum.HumanoidStateType.Running)
    end
    
    return true
end

-- Cache Management
function Utils.CacheSet(key, value, duration)
    Utils._cache[key] = {
        value = value,
        expires = os.time() + (duration or 60)
    }
end

function Utils.CacheGet(key)
    local cached = Utils._cache[key]
    if not cached or os.time() > cached.expires then
        Utils._cache[key] = nil
        return nil
    end
    return cached.value
end

function Utils.CacheClean()
    local now = os.time()
    for key, cached in pairs(Utils._cache) do
        if now > cached.expires then
            Utils._cache[key] = nil
        end
    end
end

-- Version Management
function Utils.CompareVersions(v1, v2)
    local function parseVersion(v)
        local major, minor, patch = v:match("(%d+)%.(%d+)%.(%d+)")
        return {
            tonumber(major) or 0,
            tonumber(minor) or 0,
            tonumber(patch) or 0
        }
    end
    
    local ver1 = parseVersion(v1)
    local ver2 = parseVersion(v2)
    
    for i = 1, 3 do
        if ver1[i] > ver2[i] then
            return 1
        elseif ver1[i] < ver2[i] then
            return -1
        end
    end
    
    return 0
end

-- Performance Monitoring
function Utils.StartPerfMonitor()
    local stats = {}
    
    local connection = Services.RunService.Heartbeat:Connect(function(deltaTime)
        table.insert(stats, deltaTime)
        if #stats > 60 then
            table.remove(stats, 1)
        end
    end)
    
    Utils._connections = Utils._connections or {}
    table.insert(Utils._connections, connection)
    
    return function()
        local avg = 0
        for _, dt in ipairs(stats) do
            avg = avg + dt
        end
        return avg / #stats
    end
end

-- Initialize Utils
function Utils.Initialize()
    if Utils._initialized then
        return true
    end
    
    -- Start cache cleanup
    task.spawn(function()
        while true do
            Utils.CacheClean()
            Utils.SafeWait(30)
        end
    end)
    
    Utils._initialized = true
    Debug.Log("Utils system initialized")
    return true
end

-- Cleanup
function Utils.Cleanup()
    Utils._cache = {}
    
    if Utils._connections then
        for _, connection in ipairs(Utils._connections) do
            if typeof(connection) == "RBXScriptConnection" then
                connection:Disconnect()
            end
        end
        Utils._connections = {}
    end
    
    Utils._initialized = false
    Debug.Log("Utils system cleaned up")
end

return Utils