-- loader.lua
local Loader = {
    _version = "1.0.1",
    _initialized = false,
    _modules = {},
    _config = {
        Debug = true,
        LoadOrder = {
            "events",
            "functions",
            "ui"
        }
    }
}

-- Core services
local Services = {
    Players = game:GetService("Players"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    HttpService = game:GetService("HttpService")
}

-- Initialize global state
if not getgenv().Config then
    getgenv().Config = {
        Debug = true,
        Version = "1.0.1"
    }
end

if not getgenv().State then
    getgenv().State = {
        AutoCasting = false,
        AutoReeling = false,
        AutoShaking = false,
        LastReelTime = 0,
        LastShakeTime = 0,
        Events = {
            Available = {}
        }
    }
end

-- Module loading system with error handling
function Loader.LoadModule(moduleName)
    if Loader._modules[moduleName] then
        return Loader._modules[moduleName]
    end

    local success, module = pcall(function()
        local moduleScript = loadstring(game:HttpGet(string.format(
            "https://raw.githubusercontent.com/ProbTom/Lucid/main/%s.lua",
            moduleName
        )))()
        
        if moduleScript then
            Loader._modules[moduleName] = moduleScript
            if getgenv().Config.Debug then
                print(string.format("✓ Successfully loaded module: %s", moduleName))
            end
        end
        
        return moduleScript
    end)

    if not success or not module then
        warn(string.format("⚠️ Failed to load module: %s", moduleName))
        return nil
    end

    return module
end

-- System initialization
function Loader.Initialize()
    if Loader._initialized then return true end

    -- Load UI library first
    if not getgenv().Fluent then
        local success, result = pcall(function()
            return loadstring(game:HttpGet(
                "https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"
            ))()
        end)
        
        if not success or not result then
            warn("⚠️ Failed to load UI library")
            return false
        end
        
        getgenv().Fluent = result
    end

    -- Load all required modules in order
    for _, moduleName in ipairs(Loader._config.LoadOrder) do
        local module = Loader.LoadModule(moduleName)
        if not module then
            warn(string.format("⚠️ Critical module failed to load: %s", moduleName))
            return false
        end
        
        -- Initialize module if it has an initialize function
        if type(module.Initialize) == "function" then
            local success = module.Initialize()
            if not success then
                warn(string.format("⚠️ Failed to initialize module: %s", moduleName))
                return false
            end
        end
    end

    -- Create window reference
    if not getgenv().Window then
        getgenv().Window = getgenv().Fluent:CreateWindow({
            Title = "Lucid Hub",
            SubTitle = "v1.0.1",
            TabWidth = 160,
            Size = UDim2.fromOffset(600, 400),
            Theme = "Dark",
            MinimizeKeybind = Enum.KeyCode.LeftControl
        })
    end

    Loader._initialized = true
    
    if getgenv().Config.Debug then
        print("✓ Lucid Hub initialized successfully (v1.0.1)")
    end
    
    return true
end

-- Cleanup system
function Loader.Cleanup()
    -- Cleanup all modules
    for moduleName, module in pairs(Loader._modules) do
        if type(module.Cleanup) == "function" then
            pcall(function()
                module.Cleanup()
            end)
        end
    end
    
    -- Clear module cache
    Loader._modules = {}
    Loader._initialized = false
end

-- Error handling for script execution
local success = pcall(function()
    Loader.Initialize()
end)

if not success then
    warn("⚠️ Failed to initialize Lucid Hub")
end

-- Setup cleanup on teleport
game:GetService("Players").LocalPlayer.OnTeleport:Connect(function()
    Loader.Cleanup()
end)

return Loader
