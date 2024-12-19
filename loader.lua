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
        Backup = "https://raw.githubusercontent.com/ProbTom/Lucid/backup/",
        Fluent = "https://raw.githubusercontent.com/dawid-scripts/Fluent/main/src/main.lua"
    },
    MaxRetries = 3,
    RetryDelay = 1
}

local function debugPrint(...)
    if getgenv().Config.Debug then
        print("[Lucid Debug]", ...)
    end
end

local function loadScript(name, maxRetries)
    maxRetries = maxRetries or getgenv().Config.MaxRetries
    local retryCount = 0
    local lastError
    
    while retryCount < maxRetries do
        local success, result = pcall(function()
            local source = game:HttpGet(getgenv().Config.URLs.Main .. name)
            return loadstring(source)()
        end)
        
        if success then
            debugPrint("Successfully loaded:", name)
            return true
        end
        
        -- If main fails, try backup
        success, result = pcall(function()
            local source = game:HttpGet(getgenv().Config.URLs.Backup .. name)
            return loadstring(source)()
        end)
        
        if success then
            debugPrint("Successfully loaded from backup:", name)
            return true
        else
            lastError = result
            warn(string.format("Failed to load %s (Attempt %d/%d): %s", 
                name, retryCount + 1, maxRetries, tostring(result)))
            task.wait(getgenv().Config.RetryDelay)
        end
        retryCount = retryCount + 1
    end
    
    error(string.format("Failed to load %s after %d attempts. Last error: %s", 
        name, maxRetries, tostring(lastError)))
    return false
end

-- Load compatibility layer first
debugPrint("Loading compatibility layer...")
if not loadScript("compatibility.lua") then
    error("Failed to load compatibility layer")
    return
end

-- Load Fluent UI with compatibility wrapper
local function loadFluentUI()
    local success, content = pcall(function()
        return game:HttpGet(getgenv().Config.URLs.Fluent)
    end)

    if not success then
        warn("Failed to fetch Fluent UI:", content)
        return false
    end

    local success, fluentLib = pcall(function()
        return loadstring(content)()
    end)

    if not success then
        warn("Failed to initialize Fluent UI:", fluentLib)
        return false
    end

    -- Apply compatibility wrapper
    if getgenv().CompatibilityLayer then
        debugPrint("Applying compatibility wrapper to Fluent UI")
        getgenv().Fluent = getgenv().CompatibilityLayer.wrapFluentUI(fluentLib)
        return true
    else
        warn("Compatibility layer not found")
        return false
    end
end

debugPrint("Initializing Fluent UI...")
if not loadFluentUI() then
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
