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

getgenv().Config = {
    Version = "1.0.0",
    Debug = true,
    URLs = {
        Main = "https://raw.githubusercontent.com/ProbTom/Lucid/main/",
        Fluent = "https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"
    },
    MaxRetries = 3,
    RetryDelay = 1
}

local function debugPrint(...)
    if getgenv().Config.Debug then
        print("[Lucid Debug]", ...)
    end
end

local function loadScript(name)
    local success, result = pcall(function()
        local source = game:HttpGet(getgenv().Config.URLs.Main .. name)
        if not source then 
            debugPrint("No source found for:", name)
            return false 
        end
        
        local loaded = loadstring(source)
        if not loaded then 
            debugPrint("Failed to compile:", name)
            return false 
        end
        
        local result = loaded()
        if not result then
            debugPrint("Script execution returned nil:", name)
        end
        return result
    end)
    
    if success and result then
        debugPrint("Successfully loaded:", name)
        return true
    else
        warn(string.format("Failed to load %s: %s", name, tostring(result)))
        return false
    end
end

-- Load compatibility layer first
debugPrint("Loading compatibility layer...")
if not loadScript("compatibility.lua") then
    error("Failed to load compatibility layer")
    return
end

-- Initialize Fluent UI with step-by-step debugging
local function initializeFluentUI()
    debugPrint("Step 1: Fetching Fluent UI source...")
    local success, content = pcall(function()
        return game:HttpGet(getgenv().Config.URLs.Fluent)
    end)
    
    if not success then
        debugPrint("Failed to fetch Fluent UI source:", content)
        return false
    end
    
    debugPrint("Step 2: Compiling Fluent UI source...")
    local loaded, loadError = loadstring(content)
    if not loaded then
        debugPrint("Failed to compile Fluent UI:", loadError)
        return false
    end
    
    debugPrint("Step 3: Executing Fluent UI...")
    local success, lib = pcall(loaded)
    if not success then
        debugPrint("Failed to execute Fluent UI:", lib)
        return false
    end
    
    if type(lib) ~= "table" then
        debugPrint("Fluent UI did not return a table, got:", type(lib))
        return false
    end
    
    debugPrint("Step 4: Verifying Fluent UI methods...")
    local requiredMethods = {"CreateWindow", "Notify"}
    for _, method in ipairs(requiredMethods) do
        if type(lib[method]) ~= "function" then
            debugPrint("Missing required Fluent UI method:", method)
            return false
        end
    end
    
    debugPrint("Step 5: Checking compatibility layer...")
    if type(getgenv().CompatibilityLayer) ~= "table" then
        debugPrint("CompatibilityLayer is not a table")
        return false
    end
    
    if type(getgenv().CompatibilityLayer.wrapFluentUI) ~= "function" then
        debugPrint("CompatibilityLayer.wrapFluentUI is not a function")
        return false
    end
    
    debugPrint("Step 6: Wrapping Fluent UI...")
    local wrapped = getgenv().CompatibilityLayer.wrapFluentUI(lib)
    if type(wrapped) ~= "table" then
        debugPrint("Wrapped Fluent UI is not a table, got:", type(wrapped))
        return false
    end
    
    debugPrint("Step 7: Setting global Fluent...")
    getgenv().Fluent = wrapped
    
    debugPrint("Fluent UI initialization complete!")
    return true
end

debugPrint("Initializing Fluent UI...")
if not initializeFluentUI() then
    error("Failed to initialize Fluent UI")
    return
end

-- Load remaining scripts in order
local loadOrder = {
    {name = "init.lua", required = true},
    {name = "functions.lua", required = true},
    {name = "Tab.lua", required = true},
    {name = "MainTab.lua", required = true}
}

for _, script in ipairs(loadOrder) do
    if not loadScript(script.name) and script.required then
        error(string.format("Failed to load required script: %s", script.name))
        return
    end
    task.wait(0.1)
end

getgenv().LucidHubLoaded = true
debugPrint("Lucid Hub loaded successfully")
return true
