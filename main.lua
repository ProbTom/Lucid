-- main.lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Create Lucid folder
local lucidFolder = ReplicatedStorage:FindFirstChild("Lucid") or Instance.new("Folder")
lucidFolder.Name = "Lucid"
lucidFolder.Parent = ReplicatedStorage

-- Load module from URL
local function loadModule(name)
    local url = "https://raw.githubusercontent.com/ProbTom/Lucid/main/" .. name .. ".lua"
    
    local success, content = pcall(function()
        return game:HttpGet(url)
    end)
    
    if not success then
        warn("Failed to fetch module:", name)
        return nil
    end
    
    -- Create or update ModuleScript
    local moduleScript = lucidFolder:FindFirstChild(name) or Instance.new("ModuleScript")
    moduleScript.Name = name
    moduleScript.Source = content
    moduleScript.Parent = lucidFolder
    
    -- Require the module
    local success, module = pcall(require, moduleScript)
    if not success then
        warn("Failed to load module:", name, module)
        return nil
    end
    
    return module
end

-- Initialize Lucid
local function initLucid()
    -- Load modules in order
    local Debug = loadModule("debug")
    if not Debug then return false end
    
    local Utils = loadModule("utils")
    if not Utils then return false end
    
    local UI = loadModule("ui")
    if not UI then return false end
    
    -- Initialize modules
    if not Debug.init() then return false end
    if not Utils.init({debug = Debug}) then return false end
    if not UI.init({debug = Debug, utils = Utils}) then return false end
    
    -- Create basic UI
    local window = UI.CreateWindow({
        Title = "Lucid",
        Size = UDim2.new(0, 600, 0, 400)
    })
    
    local mainTab = UI.CreateTab(window, {
        Title = "Main"
    })
    
    UI.CreateButton(mainTab, {
        Title = "Test",
        Callback = function()
            Debug.Info("Button clicked!")
        end
    })
    
    return true
end

-- Start when player is ready
if Players.LocalPlayer then
    if not initLucid() then
        warn("Failed to initialize Lucid")
    end
else
    Players.PlayerAdded:Connect(function()
        if not initLucid() then
            warn("Failed to initialize Lucid")
        end
    end)
end
