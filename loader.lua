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
    if success and type(result) == "string" and #result > 0 then
        return result
    end
    warn("Failed to fetch:", url)
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
            warn("Failed to execute:", name, result)
            return false
        end
        return true
    end
    warn("Failed to load script:", name, err)
    return false
end

-- Base URL for your scripts
local baseUrl = "https://raw.githubusercontent.com/ProbTom/Lucid/main/"

-- Files to load in order
local files = {
    "config.lua",
    "init.lua",
    "ui.lua",
    "Tab.lua",
    "MainTab.lua"
}

-- Load each file
for _, file in ipairs(files) do
    print("Fetching:", file) -- Debug print
    local source = fetchURL(baseUrl .. file)
    if not source then
        warn("Failed to fetch:", file)
        return
    end
    print("Loading:", file) -- Debug print
    local success = loadScript(source, file)
    if not success then
        warn("Failed to load:", file)
        return
    end
    task.wait(0.1) -- Small delay between loads
end

-- Set loaded flag
getgenv().LucidHubLoaded = true

print("Lucid Hub loaded successfully!")

-- Show success notification if Fluent is loaded
if getgenv().Fluent then
    getgenv().Fluent:Notify({
        Title = "Lucid Hub",
        Content = "Successfully loaded!",
        Duration = 5
    })
end
