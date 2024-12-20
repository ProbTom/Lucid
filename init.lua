-- init.lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Clean up any existing folders
if ReplicatedStorage:FindFirstChild("Lucid") then
    ReplicatedStorage.Lucid:Destroy()
end

-- Create fresh folder
local lucidFolder = Instance.new("Folder")
lucidFolder.Name = "Lucid"
lucidFolder.Parent = ReplicatedStorage

-- Simple debug function for initialization
local function init_log(msg)
    print("[LUCID INIT] " .. msg)
end

-- Create debug module first
local debugModule = Instance.new("ModuleScript")
debugModule.Name = "debug"
debugModule.Source = [[
local Debug = {_initialized = false}
function Debug.Info(msg) print("[LUCID INFO] " .. tostring(msg)) end
function Debug.Warn(msg) warn("[LUCID WARN] " .. tostring(msg)) end
function Debug.Error(msg) warn("[LUCID ERROR] " .. tostring(msg)) end
function Debug.init() Debug._initialized = true return true end
return Debug
]]
debugModule.Parent = lucidFolder

-- Create utils module
local utilsModule = Instance.new("ModuleScript")
utilsModule.Name = "utils"
utilsModule.Source = [[
local Utils = {_initialized = false}
function Utils.init(modules) Utils._initialized = true return true end
return Utils
]]
utilsModule.Parent = lucidFolder

-- Create UI module
local uiModule = Instance.new("ModuleScript")
uiModule.Name = "ui"
uiModule.Source = [[
local UI = {_initialized = false}
function UI.init(modules) UI._initialized = true return true end
function UI.CreateWindow() return {} end
function UI.CreateTab() return {} end
function UI.CreateButton() return {} end
function UI.Notify() end
function UI.CloseAll() end
return UI
]]
uiModule.Parent = lucidFolder

-- Initialize modules in order
local function InitializeLucid()
    local modules = {}
    
    -- Load debug first
    local success, debug = pcall(require, debugModule)
    if not success then
        init_log("Failed to load debug module")
        return false
    end
    modules.debug = debug
    
    -- Initialize debug
    if not debug.init() then
        init_log("Failed to initialize debug module")
        return false
    end
    
    -- Load and initialize other modules
    local moduleOrder = {
        {name = "utils", script = utilsModule},
        {name = "ui", script = uiModule}
    }
    
    for _, module in ipairs(moduleOrder) do
        local success, moduleInstance = pcall(require, module.script)
        if not success then
            debug.Error("Failed to load module: " .. module.name)
            return false
        }
        
        modules[module.name] = moduleInstance
        if not moduleInstance.init({debug = debug}) then
            debug.Error("Failed to initialize module: " .. module.name)
            return false
        }
    end
    
    -- Store in global state
    getgenv().Lucid = {
        Version = "1.0.1",
        Debug = modules.debug,
        Utils = modules.utils,
        UI = modules.ui
    }
    
    return true
end

-- Run initialization
if not InitializeLucid() then
    init_log("Failed to initialize Lucid")
    return false
end

return true
