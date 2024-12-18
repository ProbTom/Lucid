local function notify(title, content)
    if game:GetService("StarterGui") then
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title,
            Text = content,
            Duration = 5
        })
    end
end

-- Check for multiple executions
if getgenv().LucidHubLoaded then
    notify("Lucid Hub", "Already loaded!")
    return
end

-- Initialize loading
local function fetchURL(url)
    local success, result = pcall(function()
        return game:HttpGet(url)
    end)
    
    if not success then
        notify("Error", "Failed to fetch: " .. url)
        return nil
    end
    
    if type(result) ~= "string" or #result == 0 then
        notify("Error", "Invalid response from: " .. url)
        return nil
    end
    
    if result:match("404: Not Found") then
        notify("Error", "File not found: " .. url)
        return nil
    end
    
    return result
end

local function loadScript(source, name)
    if not source then
        notify("Error", "No source for: " .. name)
        return false
    end
    
    local func, err = loadstring(source)
    if not func then
        notify("Error", "Failed to parse " .. name .. ": " .. tostring(err))
        return false
    end
    
    local success, result = pcall(func)
    if not success then
        notify("Error", "Failed to run " .. name .. ": " .. tostring(result))
        return false
    end
    
    return true
end

-- Base URL for scripts
local baseUrl = "https://raw.githubusercontent.com/ProbTom/Lucid/main/"

-- Try to load config first
local configSource = fetchURL(baseUrl .. "config.lua")
if not configSource then
    notify("Error", "Failed to load config")
    return
end

local success = loadScript(configSource, "config")
if not success then
    notify("Error", "Failed to execute config")
    return
end

-- Load required external libraries
if getgenv().Config and getgenv().Config.URLs then
    for name, url in pairs(getgenv().Config.URLs) do
        local source = fetchURL(url)
        if not source then
            notify("Error", "Failed to load " .. name)
            return
        end
        if not loadScript(source, name) then
            notify("Error", "Failed to execute " .. name)
            return
        end
        task.wait(0.1)
    end
end

-- Load main scripts
local files = {
    "init.lua",
    "ui.lua",
    "Tab.lua",
    "MainTab.lua"
}

for _, file in ipairs(files) do
    local source = fetchURL(baseUrl .. file)
    if not source then
        notify("Error", "Failed to fetch " .. file)
        return
    end
    
    if not loadScript(source, file) then
        notify("Error", "Failed to load " .. file)
        return
    end
    
    task.wait(0.1)
end

-- Set loaded flag
getgenv().LucidHubLoaded = true

notify("Success", "Lucid Hub loaded!")

if getgenv().Fluent then
    getgenv().Fluent:Notify({
        Title = "Lucid Hub",
        Content = "Successfully loaded!",
        Duration = 5
    })
end
