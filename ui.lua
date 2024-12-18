-- In ui.lua
local function safeLoadString(url)
    print("Attempting to load: " .. url) -- Debug print
    local success, content = pcall(function()
        return game:HttpGet(url)
    end)
    
    if not success then
        warn("Failed to get content from URL: " .. url)
        return nil
    end
    
    local func, err = loadstring(content)
    if not func then
        warn("Failed to parse content from: " .. url)
        warn("Error: " .. tostring(err))
        return nil
    end
    
    success, result = pcall(func)
    if not success then
        warn("Failed to execute content from: " .. url)
        warn("Error: " .. tostring(result))
        return nil
    end
    
    return result
end

-- Load UI libraries with better error handling
local Fluent = safeLoadString(Config.URLs.Fluent)
if not Fluent then
    warn("Failed to load Fluent UI library")
    return
end

local SaveManager = safeLoadString(Config.URLs.SaveManager)
if not SaveManager then
    warn("Failed to load SaveManager")
    -- Continue anyway as this is optional
end

local InterfaceManager = safeLoadString(Config.URLs.InterfaceManager)
if not InterfaceManager then
    warn("Failed to load InterfaceManager")
    -- Continue anyway as this is optional
end
