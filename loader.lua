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
    URLs = {
        Main = "https://raw.githubusercontent.com/ProbTom/Lucid/main/",
        Backup = "https://raw.githubusercontent.com/ProbTom/Lucid/backup/",
        Fluent = {
            Primary = "https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua",
            Fallback = "https://raw.githubusercontent.com/dawid-scripts/Fluent/main/src/main.lua"
        }
    },
    MaxRetries = 3,
    RetryDelay = 1
}

local function loadFluent()
    local success, result
    
    -- Try primary URL
    success, result = pcall(function()
        return loadstring(game:HttpGet(getgenv().Config.URLs.Fluent.Primary))()
    end)
    
    -- If primary fails, try fallback
    if not success then
        warn("Primary Fluent URL failed, trying fallback...")
        success, result = pcall(function()
            return loadstring(game:HttpGet(getgenv().Config.URLs.Fluent.Fallback))()
        end)
    end
    
    if success then
        getgenv().Fluent = result
        return true
    else
        warn("Failed to load Fluent UI library:", result)
        return false
    end
end

if not loadFluent() then
    warn("Failed to initialize Fluent UI")
    return
end

local function loadScript(name, maxRetries)
    maxRetries = maxRetries or getgenv().Config.MaxRetries
    local retryCount = 0
    local lastError
    
    while retryCount < maxRetries do
        -- Try main URL first
        local success, result = pcall(function()
            local source = game:HttpGet(getgenv().Config.URLs.Main .. name)
            return loadstring(source)()
        end)
        
        if success then
            return true
        end
        
        -- If main fails, try backup URL
        success, result = pcall(function()
            local source = game:HttpGet(getgenv().Config.URLs.Backup .. name)
            return loadstring(source)()
        end)
        
        if success then
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

local loadOrder = {
    {name = "init.lua", required = true},
    {name = "Tab.lua", required = true},
    {name = "functions.lua", required = true},
    {name = "MainTab.lua", required = true}
}

-- Version check
pcall(function()
    local versionInfo = game:HttpGet(getgenv().Config.URLs.Main .. "version.txt")
    if versionInfo ~= getgenv().Config.Version then
        warn("New version available: " .. versionInfo)
    end
end)

for _, script in ipairs(loadOrder) do
    if not loadScript(script.name) and script.required then
        return
    end
    task.wait(0.1)
end

getgenv().LucidHubLoaded = true
return true
