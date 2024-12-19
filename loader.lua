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

-- Load configuration first
local function loadConfig()
    local success, result = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/ProbTom/Lucid/main/config.lua"))()
    end)
    
    if not success then
        warn("Failed to load config:", result)
        return false
    end
    return true
end

if not loadConfig() then
    error("Failed to load configuration")
    return
end

-- Initialize Fluent UI with error handling
local function initializeFluentUI()
    local success, FluentLib = pcall(function()
        return loadstring(game:HttpGet(getgenv().Config.URLs.Fluent))()
    end)

    if not success then
        warn("Failed to initialize Fluent UI:", FluentLib)
        return false
    end

    -- Verify required methods exist
    local requiredMethods = {
        "CreateWindow",
        "Notify",
        "SetTheme",
        "SaveConfig",
        "SetBackgroundTransparency",
        "ToggleAcrylic"
    }

    for _, method in ipairs(requiredMethods) do
        if not FluentLib[method] then
            warn("Missing required Fluent UI method:", method)
            return false
        end
    end

    getgenv().Fluent = FluentLib
    return true
end

if not initializeFluentUI() then
    error("Failed to initialize Fluent UI")
    return
end

local function loadScript(name, maxRetries)
    maxRetries = maxRetries or 3
    local retryCount = 0
    
    while retryCount < maxRetries do
        local success, result = pcall(function()
            local source = game:HttpGet(getgenv().Config.URLs.Main .. name)
            return loadstring(source)()
        end)
        
        if success then
            return true
        end
        
        warn(string.format("Failed to load %s (Attempt %d/%d): %s", 
            name, retryCount + 1, maxRetries, tostring(result)))
        task.wait(1)
        retryCount = retryCount + 1
    end
    
    return false
end

-- Updated load order with dependencies
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
return true
