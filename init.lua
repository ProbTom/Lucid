-- init.lua
if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- Debug Module
local Debug = loadstring(game:HttpGet("https://raw.githubusercontent.com/ProbTom/Lucid/main/debug.lua"))()

-- Initialize global state handler
local function initializeGlobalState()
    if not getgenv().State then
        getgenv().State = {
            AutoCasting = false,
            AutoReeling = false,
            AutoShaking = false,
            Events = {
                Available = {}
            }
        }
    end
    if not getgenv().Options then getgenv().Options = {} end
    if not getgenv().Functions then getgenv().Functions = {} end
end

-- Load configuration first
local Config = loadstring(game:HttpGet("https://raw.githubusercontent.com/ProbTom/Lucid/main/config.lua"))()
getgenv().Config = Config

-- Single point of UI initialization
local function initializeUI()
    if getgenv().Fluent then
        return getgenv().Fluent
    end
    
    local success, Fluent = pcall(function()
        return loadstring(game:HttpGet(Config.URLs.FluentUI))()
    end)
    
    if success and Fluent then
        getgenv().Fluent = Fluent
        Debug.Log("Fluent UI library loaded successfully.")
        return Fluent
    end
    Debug.Error("Failed to load Fluent UI library")
    return nil
end

-- Initialize in order
initializeGlobalState()
local Fluent = initializeUI()

if not Fluent then
    Debug.Error("Failed to initialize UI system")
    return
end

-- Load core modules after UI is ready
getgenv().SaveManager = loadstring(game:HttpGet(Config.URLs.SaveManager))()
getgenv().InterfaceManager = loadstring(game:HttpGet(Config.URLs.InterfaceManager))()

-- Create single window instance
if not getgenv().LucidWindow then
    getgenv().LucidWindow = Fluent:CreateWindow(Config.UI.Window)
    Debug.Log("Main window created successfully")
end

-- Load feature modules after window is created
local function loadModule(moduleName)
    local success, result = pcall(function()
        return loadstring(game:HttpGet(Config.URLs.Main .. moduleName .. ".lua"))()
    end)
    if not success then
        Debug.Error("Failed to load " .. moduleName .. " module")
        return false
    end
    Debug.Log(moduleName .. " module loaded successfully")
    return true
end

-- Load modules in order
local moduleOrder = {
    "functions",
    "Tab",
    "MainTab",
    "ItemsTab"
}

for _, moduleName in ipairs(moduleOrder) do
    loadModule(moduleName)
end

-- Initialize SaveManager
getgenv().SaveManager:SetLibrary(Fluent)
getgenv().SaveManager:SetFolder(Config.Save.FolderName)
getgenv().SaveManager:Load(Config.Save.FileName)

-- Setup cleanup
game:GetService("Players").LocalPlayer.OnTeleport:Connect(function()
    Debug.Log("Cleaning up before teleport")
    if getgenv().SaveManager then
        getgenv().SaveManager:Save(Config.Save.FileName)
    end
end)

return true
