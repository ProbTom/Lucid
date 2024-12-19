if getgenv().LucidHubLoaded then
    warn("Lucid Hub: Already executed!")
    return
end

local function cleanupExisting()
    local CoreGui = game:GetService("CoreGui")
    if CoreGui:FindFirstChild("ClickButton") then
        CoreGui:FindFirstChild("ClickButton"):Destroy()
    end
end

cleanupExisting()

if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- Initialize Config first, before any HTTP requests
getgenv().Config = {
    Version = "1.0.0",
    Debug = true,
    UI = {
        MainColor = Color3.fromRGB(38, 38, 38),
        ButtonColor = Color3.new(220, 125, 255),
        MinimizeKey = Enum.KeyCode.RightControl,
        Theme = "Rose"
    },
    URLs = {
        Main = "https://raw.githubusercontent.com/ProbTom/Lucid/main/",
        Fluent = "https://github.com/dawid-scripts/Fluent/releases/download/1.1.0/main.lua",
        SaveManager = "https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua",
        InterfaceManager = "https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"
    },
    GameID = 16732694052,
    Items = {
        ChestRange = {
            Default = 50,
            Min = 10,
            Max = 100
        },
        RodRanking = {
            "Rod Of The Forgotten Fang",
            "Rod Of The Eternal King",
            "Rod Of The Depth",
            "No-Life Rod",
            "Krampus's Rod",
            "Trident Rod",
            "Kings Rod",
            "Aurora Rod",
            "Mythical Rod",
            "Destiny Rod",
            "Celestial Rod",
            "Voyager Rod",
            "Riptide Rod",
            "Seasons Rod",
            "Resourceful Rod",
            "Precision Rod",
            "Steady Rod",
            "Nocturnal Rod",
            "Reinforced Rod",
            "Magnet Rod",
            "Rapid Rod",
            "Fortune Rod",
            "Phoenix Rod",
            "Scurvy Rod",
            "Midas Rod",
            "Buddy Bond Rod",
            "Haunted Rod",
            "Relic Rod",
            "Antler Rod",
            "North-Star Rod",
            "Astral Rod",
            "Event Horizon Rod",
            "Candy Cane Rod",
            "Fungal Rod",
            "Magma Rod",
            "Long Rod",
            "Lucky Rod",
            "Fast Rod",
            "Stone Rod",
            "Carbon Rod",
            "Plastic Rod",
            "Training Rod",
            "Fischer's Rod",
            "Flimsy Rod"
        },
        FishRarities = {
            "Common",
            "Uncommon",
            "Rare",
            "Epic",
            "Legendary",
            "Mythical",
            "Enchant Relics",
            "Exotic",
            "Limited",
            "Gemstones"
        }
    },
    MaxRetries = 3,
    RetryDelay = 1,
    Debug = true
}

local function debugPrint(...)
    if getgenv().Config.Debug then
        print("[Lucid Debug]", table.concat({...}, " "))
    end
end

local function loadScript(name)
    local success, result = pcall(function()
        debugPrint("Fetching:", name)
        local source = game:HttpGet(getgenv().Config.URLs.Main .. name)
        if not source then 
            debugPrint("No source found for:", name)
            return false 
        end
        
        debugPrint("Compiling:", name)
        local loaded = loadstring(source)
        if not loaded then 
            debugPrint("Failed to compile:", name)
            return false 
        end
        
        debugPrint("Executing:", name)
        return loaded()
    end)
    
    if success and result then
        debugPrint("Successfully loaded:", name)
        return true
    else
        warn(string.format("Failed to load %s: %s", name, tostring(result)))
        return false
    end
end

-- Initialize Fluent UI with enhanced error handling
local function initializeFluentUI()
    debugPrint("Fetching Fluent UI source...")
    local success, content = pcall(function()
        return game:HttpGet(getgenv().Config.URLs.Fluent)
    end)
    
    if not success or not content then
        debugPrint("Failed to fetch Fluent UI source:", tostring(content))
        return false
    end
    
    debugPrint("Compiling Fluent UI...")
    local loaded, compileError = loadstring(content)
    if not loaded then
        debugPrint("Compile error:", compileError)
        return false
    end
    
    debugPrint("Executing Fluent UI...")
    local success, lib = pcall(loaded)
    if not success then
        debugPrint("Execution error:", lib)
        return false
    end
    
    getgenv().Fluent = lib
    debugPrint("Fluent UI initialized successfully")
    return true
end

-- Load scripts in correct order with dependencies
local loadOrder = {
    {name = "compatibility.lua", required = true},
    {name = "options.lua", required = true},
    {name = "events.lua", required = true},
    {name = "functions.lua", required = true},
    {name = "Tab.lua", required = true},
    {name = "MainTab.lua", required = true},
    {name = "ItemsTab.lua", required = true},
    {name = "ui.lua", required = false}
}

-- Initialize Fluent UI first
debugPrint("Initializing Fluent UI...")
if not initializeFluentUI() then
    error("Failed to initialize Fluent UI")
    return
end

-- Load all scripts in order
for _, script in ipairs(loadOrder) do
    if not loadScript(script.name) and script.required then
        error(string.format("Failed to load required script: %s", script.name))
        return
    end
    task.wait(0.1)
end

-- Initialize SaveManager after all scripts are loaded
if getgenv().Fluent then
    getgenv().SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
    if getgenv().SaveManager then
        getgenv().SaveManager:SetLibrary(getgenv().Fluent)
        getgenv().SaveManager:SetFolder("LucidHub")
        getgenv().SaveManager:Load("LucidHub")
    end
end

getgenv().LucidHubLoaded = true
debugPrint("Lucid Hub loaded successfully")
return true
