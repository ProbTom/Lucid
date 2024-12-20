-- init.lua
local Lucid = {
    _VERSION = "1.0.1",
    _AUTHOR = "ProbTom",
    _DEBUG = true
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
    
    function Debug.Info(msg) print("[LUCID INFO]", tostring(msg)) return true end
    function Debug.Error(msg) warn("[LUCID ERROR]", tostring(msg)) return true end
    function Debug.Debug(msg) print("[LUCID DEBUG]", tostring(msg)) return true end
    function Debug.Warn(msg) warn("[LUCID WARN]", tostring(msg)) return true end
    function Debug.Fatal(msg) warn("[LUCID FATAL]", tostring(msg)) return true end
    
    function Debug.init()
        Debug._initialized = true
        Debug.Info("Debug module initialized")
        return true
    end
    
    return Debug
]]
debugModule.Parent = lucidFolder

-- Safe require function
local function safe_require(moduleName)
    init_log("Loading " .. moduleName)
    
    local moduleScript = lucidFolder:FindFirstChild(moduleName)
    if not moduleScript then
        init_log("Module not found: " .. moduleName)
        return nil
    end
    
    local success, result = pcall(function()
        return require(moduleScript)
    end)
    
    if not success then
        init_log("Failed to load " .. moduleName .. ": " .. tostring(result))
        return nil
    end
    
    return result
end

-- Module initialization sequence
local MODULES = {
    {name = "debug", critical = true}
}

-- Module container
Lucid.modules = {}

-- Initialize core system
function Lucid.Initialize()
    init_log("Starting initialization sequence")
    
    -- Load each module in sequence
    for _, moduleInfo in ipairs(MODULES) do
        local module = safe_require(moduleInfo.name)
        
        if not module then
            if moduleInfo.critical then
                init_log("Critical module failed to load: " .. moduleInfo.name)
                return false
            else
                init_log("Non-critical module failed to load: " .. moduleInfo.name)
            end
        else
            -- Store loaded module
            Lucid.modules[moduleInfo.name] = module
            
            -- Initialize module if it has init function
            if type(module.init) == "function" then
                local success = pcall(function()
                    module.init()
                end)
                
                if not success and moduleInfo.critical then
                    return false
                end
            end
        end
    end
    
    init_log("Initialization sequence completed")
    return true
end

-- Initialize the system
local success = pcall(Lucid.Initialize)
if not success then
    warn("[LUCID] Initialization failed")
end

return Lucid
