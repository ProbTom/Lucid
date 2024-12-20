-- init.lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Clear any existing
if ReplicatedStorage:FindFirstChild("Lucid") then
    ReplicatedStorage:FindFirstChild("Lucid"):Destroy()
end

-- Create container
local Lucid = Instance.new("Folder")
Lucid.Name = "Lucid"
Lucid.Parent = ReplicatedStorage

-- Create debug module
local Debug = Instance.new("ModuleScript")
Debug.Name = "Debug"
Debug.Parent = Lucid
Debug.Source = [[
local Debug = {
    _initialized = false
}

function Debug.Info(msg)
    print("[LUCID INFO]", tostring(msg))
end

function Debug.Warn(msg)
    warn("[LUCID WARN]", tostring(msg))
end

function Debug.Error(msg)
    warn("[LUCID ERROR]", tostring(msg))
end

function Debug.init()
    if Debug._initialized then return true end
    Debug._initialized = true
    Debug.Info("Debug module initialized")
    return true
end

return Debug
]]

-- Set global state
getgenv().LucidState = {
    Version = "1.0.1",
    StartTime = os.time(),
    Debug = require(Debug)
}

LucidState.Debug.Info("Lucid initialized successfully!")
return true
