-- loader.lua
local Loader = {
    _initialized = false
}

-- Wait for game to load
if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Load Debug Module
local Debug = {
    Log = function(msg) print("[LOG]:", msg) end,
    Error = function(msg) warn("[ERROR]:", msg) end,
    Warning = function(msg) warn("[WARNING]:", msg) end
}

-- Initialize global state
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

-- Load Fluent UI Library
local function loadFluentUI()
    if getgenv().Fluent then
        return true
    end

    local success, result = pcall(function()
        return loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
    end)

    if success and result then
        getgenv().Fluent = result
        Debug.Log("Fluent UI library loaded successfully")
        return true
    end
    
    Debug.Error("Failed to load Fluent UI library")
    return false
end

-- Create Window
local function createWindow()
    if not getgenv().Fluent then
        Debug.Error("Fluent UI library not loaded")
        return false
    end

    if getgenv().LucidWindow then
        return true
    end

    local success, window = pcall(function()
        return getgenv().Fluent:CreateWindow({
            Title = "Lucid Hub",
            SubTitle = "by ProbTom",
            TabWidth = 160,
            Size = UDim2.fromOffset(580, 460),
            Theme = "Dark"
        })
    end)

    if success and window then
        getgenv().LucidWindow = window
        Debug.Log("Window created successfully")
        return true
    end

    Debug.Error("Failed to create window")
    return false
end

-- Create Tabs
local function createTabs()
    if not getgenv().LucidWindow then
        Debug.Error("Window not created")
        return false
    end

    if not getgenv().Tabs then
        getgenv().Tabs = {}
    end

    -- Main Tab
    local success, mainTab = pcall(function()
        return getgenv().LucidWindow:AddTab({
            Title = "Main",
            Icon = "rbxassetid://10723424505"
        })
    end)

    if success and mainTab then
        getgenv().Tabs.Main = mainTab
        Debug.Log("Main tab created")
    else
        Debug.Error("Failed to create Main tab")
        return false
    end

    return true
end

-- Create Features
local function createFeatures()
    if not getgenv().Tabs.Main then
        Debug.Error("Main tab not created")
        return false
    end

    local success, section = pcall(function()
        return getgenv().Tabs.Main:AddSection("Fishing Controls")
    end)

    if not success or not section then
        Debug.Error("Failed to create section")
        return false
    end

    -- Auto Cast Toggle
    section:AddToggle({
        Title = "Auto Cast",
        Default = false,
        Callback = function(value)
            if getgenv().State then
                getgenv().State.AutoCasting = value
                Debug.Log("Auto Cast: " .. tostring(value))
            end
        end
    })

    -- Auto Reel Toggle
    section:AddToggle({
        Title = "Auto Reel",
        Default = false,
        Callback = function(value)
            if getgenv().State then
                getgenv().State.AutoReeling = value
                Debug.Log("Auto Reel: " .. tostring(value))
            end
        end
    })

    -- Auto Shake Toggle
    section:AddToggle({
        Title = "Auto Shake",
        Default = false,
        Callback = function(value)
            if getgenv().State then
                getgenv().State.AutoShaking = value
                Debug.Log("Auto Shake: " .. tostring(value))
            end
        end
    })

    return true
end

-- Initialize
function Loader.Initialize()
    if Loader._initialized then
        return true
    end

    Debug.Log("Starting initialization...")

    -- Step 1: Load UI Library
    if not loadFluentUI() then
        Debug.Error("Failed to load UI library")
        return false
    end

    -- Step 2: Create Window
    if not createWindow() then
        Debug.Error("Failed to create window")
        return false
    end

    -- Step 3: Create Tabs
    if not createTabs() then
        Debug.Error("Failed to create tabs")
        return false
    end

    -- Step 4: Create Features
    if not createFeatures() then
        Debug.Error("Failed to create features")
        return false
    end

    -- Setup cleanup
    LocalPlayer.OnTeleport:Connect(function()
        if getgenv().State then
            getgenv().State = nil
        end
        if getgenv().LucidWindow then
            pcall(function()
                getgenv().LucidWindow:Destroy()
            end)
            getgenv().LucidWindow = nil
        end
    end)

    Loader._initialized = true
    Debug.Log("Initialization complete")
    return true
end

return Loader
