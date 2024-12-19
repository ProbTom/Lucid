-- Check if already executed
if getgenv().LucidHubLoaded then
    warn("Lucid Hub: Already executed!")
    return
end

-- Function to clean up existing instances
local function cleanupExisting()
    local CoreGui = game:GetService("CoreGui")
    if CoreGui:FindFirstChild("ClickButton") then
        CoreGui:FindFirstChild("ClickButton"):Destroy()
    end
end

-- Clean up any existing instances
cleanupExisting()

-- Wait for game load
if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- Define config globally
getgenv().Config = {
    Version = "1.0.0",
    URLs = {
        Fluent = "https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"
    }
}

-- Load Fluent UI
local function loadFluent()
    local success, result = pcall(function()
        return loadstring(game:HttpGet(getgenv().Config.URLs.Fluent))()
    end)
    
    if success then
        getgenv().Fluent = result
        return true
    else
        warn("Failed to load Fluent UI library:", result)
        return false
    end
end

-- Load Fluent
if not loadFluent() then
    warn("Failed to initialize Fluent UI")
    return
end

-- Function to load scripts
local function loadScript(name, maxRetries)
    maxRetries = maxRetries or 3
    local retryCount = 0
    
    while retryCount < maxRetries do
        local success, result = pcall(function()
            local source = game:HttpGet("https://raw.githubusercontent.com/ProbTom/Lucid/main/" .. name)
            return loadstring(source)()
        end)
        
        if success then
            return true
        else
            warn(string.format("Failed to load %s (Attempt %d/%d): %s", name, retryCount, maxRetries, tostring(result)))
            task.wait(1)
        end
        retryCount = retryCount + 1
    end
    return false
end

-- Load required scripts
local loadOrder = {
    {name = "init.lua", required = true},
    {name = "Tab.lua", required = true},
    {name = "functions.lua", required = true},
    {name = "MainTab.lua", required = true}
}

for _, script in ipairs(loadOrder) do
    if not loadScript(script.name) and script.required then
        return
    end
    task.wait(0.1)
end

-- Mark as loaded
getgenv().LucidHubLoaded = true

return true
