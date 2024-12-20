-- init.lua
local Debug = {
    Info = function(msg) print("[INFO]", msg) end,
    Warn = function(msg) warn("[WARN]", msg) end,
    Error = function(msg) warn("[ERROR]", msg) end
}

local function createModule(name, source)
    local moduleScript = Instance.new("ModuleScript")
    moduleScript.Name = name
    moduleScript.Source = source
    moduleScript.Parent = game:GetService("ReplicatedStorage")
    return moduleScript
end

-- Create debug module first
local debugModule = createModule("debug", [[
local Debug = {_initialized = false}
function Debug.Info(msg) print("[INFO] " .. tostring(msg)) end
function Debug.Warn(msg) warn("[WARN] " .. tostring(msg)) end
function Debug.Error(msg) warn("[ERROR] " .. tostring(msg)) end
function Debug.init() Debug._initialized = true return true end
return Debug
]])

-- Create and load the module
local success, debug = pcall(require, debugModule)
if not success then
    warn("Failed to load debug module:", debug)
    return
end

getgenv().Lucid = {
    Debug = debug,
    Version = "1.0.1"
}

debug.Info("Lucid initialized successfully")
return true
