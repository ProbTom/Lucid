-- main.lua
-- Version: 1.0.1
-- Author: ProbTom
-- Created: 2024-12-20 16:34:06 UTC

-- Global namespace protection
if getgenv().LucidLoaded then
    warn("[LUCID] System already loaded!")
    return false
end

-- Basic early logging
local function log(msg, type)
    print(string.format("[LUCID %s] %s", type or "INFO", tostring(msg)))
end

-- Set up initial state
getgenv().LucidState = {
    Version = "1.0.1",
    StartTime = os.date("!%Y-%m-%d %H:%M:%S"),
    User = "ProbTom",
    Debug = true,
    Modules = {}
}

-- Load the loader
local function initializeLucid()
    local baseUrl = "https://raw.githubusercontent.com/ProbTom/Lucid/main/"
    
    local success, content = pcall(function()
        return game:HttpGet(baseUrl .. "loader.lua")
    end)
    
    if not success then
        log("Failed to fetch loader: " .. tostring(content), "ERROR")
        return false
    end
    
    local loader, err = loadstring(content)
    if not loader then
        log("Failed to parse loader: " .. tostring(err), "ERROR")
        return false
    end
    
    success, content = pcall(loader)
    if not success then
        log("Failed to execute loader: " .. tostring(content), "ERROR")
        return false
    end
    
    getgenv().LucidLoaded = true
    return true
end

-- Start the system
return initializeLucid()
