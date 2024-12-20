-- init.lua
local Lucid = {
    _VERSION = "1.0.1",
    _AUTHOR = "ProbTom",
    _DEBUG = true,
    modules = {}
}

-- Create folder for modules
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Clean up any existing instance
local existing = ReplicatedStorage:FindFirstChild("Lucid")
if existing then existing:Destroy() end

local lucidFolder = Instance.new("Folder")
lucidFolder.Name = "Lucid"
lucidFolder.Parent = ReplicatedStorage

-- Early initialization logger
local function init_log(msg)
    if Lucid._DEBUG then
        print(string.format("[LUCID INIT] %s", tostring(msg)))
    end
end

-- Create debug module directly
local debugModule = Instance.new("ModuleScript")
debugModule.Name = "debug"
debugModule.Source = [[
local Debug = {_initialized = false}

function Debug.log(level, msg)
    print(string.format("[LUCID %s] %s", level, tostring(msg)))
    return true
end

function Debug.Info(msg) return Debug.log("INFO", msg) end
function Debug.Error(msg) return Debug.log("ERROR", msg) end
function Debug.Debug(msg) return Debug.log("DEBUG", msg) end
function Debug.Warn(msg) return Debug.log("WARN", msg) end
function Debug.Fatal(msg) return Debug.log("FATAL", msg) end

function Debug.init()
    Debug._initialized = true
    Debug.log("INFO", "Debug module initialized")
    return true
end

return Debug
]]
debugModule.Parent = lucidFolder

-- Initialize core system
function Lucid.Initialize()
    init_log("Starting initialization sequence")
    
    -- Load debug module first
    local success, debug = pcall(function()
        return require(debugModule)
    end)
    
    if not success then
        init_log("Failed to load debug module: " .. tostring(debug))
        return false
    end
    
    -- Store and initialize debug module
    Lucid.modules.debug = debug
    debug.init()
    
    init_log("Initialization sequence completed")
    return true
end

-- Initialize the system
local success, err = pcall(Lucid.Initialize)
if not success then
    warn("[LUCID] Initialization failed:", err)
end

-- Make Lucid available globally
_G.Lucid = Lucid

return Lucid
