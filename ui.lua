getgenv().LucidLoaded = false
    getgenv().LucidState = nil
    
    return false
end

-- Version Check
local function checkForUpdates()
    local success, latestVersion = pcall(function()
        return game:HttpGet("https://raw.githubusercontent.com/ProbTom/Lucid/main/version.json")
    end)
    
    if success then
        local versionData = Services.HttpService:JSONDecode(latestVersion)
        if versionData.version ~= Lucid._version then
            if Lucid._modules.Debug then
                Lucid._modules.Debug.Log("New version available: " .. versionData.version)
            end
            
            if Lucid._modules.UI then
                Lucid._modules.UI.Notify({
                    Title = "Update Available",
                    Content = "Version " .. versionData.version .. " is available!",
                    Duration = 10,
                    Type = "Info"
                })
            end
        end
    end
end

-- Performance Monitoring
local function setupPerformanceMonitoring()
    if not Lucid._modules.Utils then return end
    
    local getPerformance = Lucid._modules.Utils.StartPerfMonitor()
    
    task.spawn(function()
        while Lucid._initialized do
            local avgFrameTime = getPerformance()
            if avgFrameTime > 1/30 and Lucid._modules.Debug then
                Lucid._modules.Debug.Warn("Performance warning: " .. math.floor(1/avgFrameTime) .. " FPS")
            end
            task.wait(5)
        end
    end)
end

-- Main Initialization
local function initialize()
    if Lucid._initialized then
        return true
    end
    
    -- Initialize global state
    if not initializeGlobalState() then
        return errorHandler("Failed to initialize global state")
    end
    
    -- Load all modules
    if not loadModules() then
        return errorHandler("Failed to load modules")
    end
    
    -- Initialize modules
    if not initializeModules() then
        return errorHandler("Failed to initialize modules")
    end
    
    -- Setup cleanup handler
    setupCleanup()
    
    -- Setup performance monitoring
    setupPerformanceMonitoring()
    
    -- Check for updates
    task.spawn(checkForUpdates)
    
    -- Mark as initialized
    Lucid._initialized = true
    getgenv().LucidLoaded = true
    getgenv().LucidState.Loaded = true
    
    -- Final initialization message
    if Lucid._modules.Debug then
        Lucid._modules.Debug.Log("Lucid Hub initialized successfully")
    end
    
    -- Show welcome notification
    if Lucid._modules.UI then
        Lucid._modules.UI.Notify({
            Title = "Lucid Hub",
            Content = "Welcome, " .. LocalPlayer.Name .. "!",
            Duration = 5,
            Type = "Success"
        })
    end
    
    return true
end

-- Public API
Lucid.GetModule = function(name)
    return Lucid._modules[name]
end

Lucid.GetVersion = function()
    return Lucid._version
end

Lucid.GetUptime = function()
    return os.time() - Lucid._startTime
end

Lucid.Reload = function()
    -- Cleanup current instance
    if Lucid._initialized then
        for _, module in pairs(Lucid._modules) do
            if type(module.Cleanup) == "function" then
                pcall(function()
                    module.Cleanup()
                end)
            end
        end
    end
    
    -- Reset state
    Lucid._initialized = false
    Lucid._modules = {}
    getgenv().LucidLoaded = false
    getgenv().LucidState = nil
    
    -- Reinitialize
    return initialize()
end

-- Execute initialization
local success = pcall(initialize)
if not success then
    errorHandler("Failed to initialize Lucid Hub")
    return false
end

return Lucid
