-- main.lua
if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- Load Debug module first
local Debug
local function loadDebug()
    local success, result = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/ProbTom/Lucid/main/debug.lua"))()
    end)
    
    if not success then
        warn("[CRITICAL ERROR]: Failed to load Debug module:", result)
        return false
    end
    
    Debug = result
    return true
end

-- Load modules with detailed error reporting
local function loadModule(name, url)
    local success, content = pcall(function()
        return game:HttpGet(url)
    end)
    
    if not success then
        Debug.Error("Failed to fetch " .. name .. ": " .. tostring(content))
        return false
    end
    
    local success2, module = pcall(loadstring, content)
    if not success2 then
        Debug.Error("Failed to compile " .. name .. ": " .. tostring(module))
        return false
    end
    
    local success3, result = pcall(module)
    if not success3 then
        Debug.Error("Failed to execute " .. name .. ": " .. tostring(result))
        return false
    end
    
    return result
end

-- Initialize with debug support
local function start()
    -- Step 1: Load Debug
    if not loadDebug() then
        return false
    end
    Debug.Log("Debug module loaded successfully")
    
    -- Step 2: Load Config
    local Config = loadModule("config", "https://raw.githubusercontent.com/ProbTom/Lucid/main/config.lua")
    if not Config then
        return false
    end
    Debug.Log("Config loaded successfully")
    
    -- Step 3: Load State
    local State = loadModule("state", "https://raw.githubusercontent.com/ProbTom/Lucid/main/state.lua")
    if not State then
        return false
    end
    Debug.Log("State loaded successfully")
    
    -- Step 4: Load Loader
    local Loader = loadModule("loader", "https://raw.githubusercontent.com/ProbTom/Lucid/main/loader.lua")
    if not Loader then
        return false
    end
    Debug.Log("Loader loaded successfully")
    
    -- Initialize global state
    if not getgenv then
        Debug.Error("getgenv is not available")
        return false
    end
    
    getgenv().LucidState = {
        Debug = Debug,
        Config = Config,
        State = State,
        Loader = Loader
    }
    
    -- Initialize loader
    if type(Loader.Initialize) ~= "function" then
        Debug.Error("Loader.Initialize is not a function")
        return false
    end
    
    local success, result = pcall(Loader.Initialize)
    if not success then
        Debug.Error("Loader initialization failed: " .. tostring(result))
        return false
    end
    
    Debug.Log("Lucid Hub started successfully")
    return true
end

local success = start()
if not success then
    warn("[LUCID ERROR]: Failed to start Lucid Hub")
end

return success
