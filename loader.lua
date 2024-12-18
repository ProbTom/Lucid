-- Check for multiple executions
if getgenv().LucidHubLoaded then
    warn("Lucid Hub: Already executed!")
    return
end

-- Initialize loading
local function fetchURL(url)
    local success, result = pcall(function()
        return game:HttpGet(url)
    end)
    if success then
        return result
    end
    warn("Failed to fetch:", url, "Error:", result)
    return nil
end

local function loadScript(source, name)
    if not source then
        warn("No source provided for:", name)
        return false
    end
    
    local func, err = loadstring(source)
    if func then
        local success, result = pcall(func)
        if not success then
            warn("Failed to execute:", name, "Error:", result)
            return false
        end
        return true
    end
    warn("Failed to load:", name, "Error:", err)
    return false
end

-- Base URL for your scripts
local baseUrl = "https://raw.githubusercontent.com/ProbTom/Lucid/main/"

-- Load config first
print("Loading config...")
local configSource = fetchURL(baseUrl .. "config.lua")
if not loadScript(configSource, "config.lua") then return end

-- Load Fluent UI and its addons
print("Loading UI libraries...")
local fluentSource = fetchURL(getgenv().Config.URLs.Fluent)
if not loadScript(fluentSource, "Fluent") then return end

local saveManagerSource = fetchURL(getgenv().Config.URLs.SaveManager)
if not loadScript(saveManagerSource, "SaveManager") then return end

local interfaceManagerSource = fetchURL(getgenv().Config.URLs.InterfaceManager)
if not loadScript(interfaceManagerSource, "InterfaceManager") then return end

-- Load the rest of your scripts in order
local files = {
    "init.lua",
    "ui.lua",
    "Tab.lua",
    "MainTab.lua"
}

for _, file in ipairs(files) do
    print("Loading", file, "...")
    local source = fetchURL(baseUrl .. file)
    if not loadScript(source, file) then return end
    task.wait(0.1) -- Small delay between loads
end

-- Set loaded flag
getgenv().LucidHubLoaded = true

-- Show success notification
if getgenv().Fluent then
    getgenv().Fluent:Notify({
        Title = "Lucid Hub",
        Content = "Successfully loaded!",
        Duration = 5
    })
end
