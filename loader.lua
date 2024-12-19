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
        Fluent = "https://raw.githubusercontent.com/dawid-scripts/Fluent/master/src/main.lua",
        FluentBackup = "https://raw.githubusercontent.com/dawid-scripts/Fluent/main/src/main.lua" -- Backup Fluent source
    },
    MaxRetries = 3,
    RetryDelay = 1
}

local function debugPrint(...)
    if getgenv().Config.Debug then
        print("[Lucid Debug]", ...)
        if type(debug) == "table" and type(debug.traceback) == "function" then
            print(debug.traceback())
        end
    end
end

local function loadScript(name)
    local success, result = pcall(function()
        local source = game:HttpGet(getgenv().Config.URLs.Main .. name)
        if not source then return false end
        
        local loaded = loadstring(source)
        if not loaded then return false end
        
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

-- Load compatibility layer first
debugPrint("Loading compatibility layer...")
if not loadScript("compatibility.lua") then
    error("Failed to load compatibility layer")
    return
end

-- Initialize Fluent UI with retries
local function initializeFluentUI()
    local function tryLoadFluent(url)
        local success, content = pcall(function()
            return game:HttpGet(url)
        end)
        
        if not success then
            debugPrint("Failed to fetch Fluent UI from:", url)
            return false
        end
        
        local loaded = loadstring(content)
        if not loaded then
            debugPrint("Failed to compile Fluent UI source")
            return false
        end
        
        local success, lib = pcall(loaded)
        if not success or type(lib) ~= "table" then
            debugPrint("Failed to execute Fluent UI:", lib)
            return false
        end
        
        return lib
    end
    
    -- Try main URL first
    local fluentLib = tryLoadFluent(getgenv().Config.URLs.Fluent)
    
    -- If main fails, try backup
    if not fluentLib then
        debugPrint("Trying backup Fluent URL...")
        fluentLib = tryLoadFluent(getgenv().Config.URLs.FluentBackup)
    end
    
    if not fluentLib then
        return false
    end
    
    -- Verify essential methods exist
    local requiredMethods = {"CreateWindow", "Notify"}
    for _, method in ipairs(requiredMethods) do
        if type(fluentLib[method]) ~= "function" then
            debugPrint("Missing required Fluent UI method:", method)
            return false
        end
    end
    
    -- Apply compatibility wrapper
    if type(getgenv().CompatibilityLayer) == "table" and 
       type(getgenv().CompatibilityLayer.wrapFluentUI) == "function" then
        local wrapped = getgenv().CompatibilityLayer.wrapFluentUI(fluentLib)
        if type(wrapped) == "table" then
            getgenv().Fluent = wrapped
            return true
        end
    end
    
    debugPrint("Failed to wrap Fluent UI with compatibility layer")
    return false
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
