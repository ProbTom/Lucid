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

-- Define configuration
getgenv().Config = {
    Version = "1.0.0",
    URLs = {
        Main = "https://raw.githubusercontent.com/ProbTom/Lucid/main/",
        Backup = "https://raw.githubusercontent.com/ProbTom/Lucid/backup/",
        Fluent = {
            -- Changed order and updated URLs
            Primary = "https://raw.githubusercontent.com/dawid-scripts/Fluent/master/src/main.lua",
            SaveManager = "https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua",
            InterfaceManager = "https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"
        }
    },
    MaxRetries = 3,
    RetryDelay = 1
}

local function debugPrint(...)
    if getgenv().Config.Debug then
        print(...)
    end
end

local function loadFluent()
    local function tryLoadUrl(url)
        local success, content = pcall(game.HttpGet, game, url)
        if not success then
            debugPrint("Failed to fetch from URL:", url, "Error:", content)
            return false, content
        end

        local loadSuccess, result = pcall(loadstring, content)
        if not loadSuccess then
            debugPrint("Failed to loadstring content from:", url, "Error:", result)
            return false, result
        end

        local execSuccess, lib = pcall(result)
        if not execSuccess then
            debugPrint("Failed to execute Fluent library from:", url, "Error:", lib)
            return false, lib
        end

        return true, lib
    end

    -- Try loading from primary URL
    debugPrint("Attempting to load Fluent from primary URL...")
    local success, result = tryLoadUrl(getgenv().Config.URLs.Fluent.Primary)
    
    if success then
        getgenv().Fluent = result
        return true
    end
    
    -- If primary fails, wait a bit and try again
    task.wait(1)
    
    debugPrint("Primary URL failed, attempting backup...")
    -- Try loading SaveManager
    success, result = tryLoadUrl(getgenv().Config.URLs.Fluent.SaveManager)
    if not success then
        debugPrint("Failed to load SaveManager")
        return false
    end

    -- Try loading InterfaceManager
    success, result = tryLoadUrl(getgenv().Config.URLs.Fluent.InterfaceManager)
    if not success then
        debugPrint("Failed to load InterfaceManager")
        return false
    end

    -- Set debug mode for better error reporting
    getgenv().Config.Debug = true

    return success
end

debugPrint("Starting Fluent UI initialization...")
if not loadFluent() then
    error("Failed to initialize Fluent UI - Check debug prints for details")
    return
end
debugPrint("Fluent UI initialized successfully")

local function loadScript(name, maxRetries)
    maxRetries = maxRetries or getgenv().Config.MaxRetries
    local retryCount = 0
    local lastError
    
    while retryCount < maxRetries do
        -- Try main URL first
        local success, result = pcall(function()
            local source = game:HttpGet(getgenv().Config.URLs.Main .. name)
            debugPrint("Loading script:", name)
            return loadstring(source)()
        end)
        
        if success then
            debugPrint("Successfully loaded:", name)
            return true
        end
        
        -- If main fails, try backup URL
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
