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

-- Initialize with debug support
local function start()
    -- Step 1: Load Debug
    if not loadDebug() then
        return false
    end
    
    -- Step 2: Load Loader
    local success, loader = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/ProbTom/Lucid/main/loader.lua"))()
    end)
    
    if not success or not loader then
        Debug.Error("Failed to load loader: " .. tostring(success))
        return false
    end
    
    -- Step 3: Initialize
    if type(loader.Initialize) == "function" then
        success = pcall(loader.Initialize)
        if not success then
            Debug.Error("Failed to initialize loader")
            return false
        end
    else
        Debug.Error("Invalid loader: Initialize function missing")
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
