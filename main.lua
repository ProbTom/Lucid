-- main.lua
-- First, let's wrap everything in a protected load
local function StartLucid()
    -- Ensure we can access global environment
    assert(getgenv, "getgenv not found")

    -- Initialize core services
    local Players = game:GetService("Players")
    local HttpService = game:GetService("HttpService")

    -- Load the UI Library with error handling
    local Library
    local success, result = pcall(function()
        return loadstring(game:HttpGet('https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/wind'))()
    end)

    if not success then
        warn("[Lucid] Failed to load UI Library:", result)
        return false
    end
    Library = result

    -- Verify Library loaded correctly
    if not Library or type(Library.CreateLib) ~= "function" then
        warn("[Lucid] Invalid UI Library")
        return false
    end

    -- Create base environment
    local Lucid = {
        Name = "Lucid Hub",
        Version = "1.1.0",
        Author = "ProbTom",
        LastUpdated = "2024-12-21",
        Library = Library,
        Initialized = false
    }

    -- Set up global access
    getgenv().Lucid = Lucid

    -- Create Window with error handling
    local MainWindow
    success, result = pcall(function()
        return Library.CreateLib("Lucid Hub", "Ocean")
    end)

    if not success then
        warn("[Lucid] Failed to create window:", result)
        return false
    end
    MainWindow = result
    Lucid.MainWindow = MainWindow

    -- Initialize Tabs
    local function CreateTab(name)
        local success, tab = pcall(function()
            return MainWindow:NewTab(name)
        end)
        if not success then
            warn("[Lucid] Failed to create tab:", name)
            return nil
        end
        return tab
    end

    -- Create tabs with error handling
    local MainTab = CreateTab("Main")
    if not MainTab then return false end

    local ItemsTab = CreateTab("Items")
    if not ItemsTab then return false end

    local SettingsTab = CreateTab("Settings")
    if not SettingsTab then return false end

    -- Create sections
    local function CreateSection(tab, name)
        local success, section = pcall(function()
            return tab:NewSection(name)
        end)
        if not success then
            warn("[Lucid] Failed to create section:", name)
            return nil
        end
        return section
    end

    -- Initialize sections with error handling
    local MainSection = CreateSection(MainTab, "Fishing")
    if not MainSection then return false end

    -- Create settings structure
    getgenv().Settings = {
        AutoFish = false,
        AutoReel = false,
        AutoShake = false,
        CastMode = "Legit",
        Items = {
            ChestCollector = {
                Enabled = false,
                Range = 50
            },
            AutoSell = {
                Enabled = false,
                Rarities = {}
            }
        }
    }

    -- Add elements with error handling
    pcall(function()
        MainSection:NewToggle("Auto Fish", "Toggles auto fishing", function(state)
            getgenv().Settings.AutoFish = state
        end)

        MainSection:NewToggle("Auto Reel", "Toggles auto reeling", function(state)
            getgenv().Settings.AutoReel = state
        end)

        MainSection:NewToggle("Auto Shake", "Toggles auto shaking", function(state)
            getgenv().Settings.AutoShake = state
        end)

        MainSection:NewDropdown("Cast Mode", "Select casting mode", 
            {"Legit", "Semi-Legit", "Instant"}, 
            function(currentOption)
                getgenv().Settings.CastMode = currentOption
            end
        )
    end)

    -- Initialize settings system
    if not isfolder("LucidHub") then
        pcall(function()
            makefolder("LucidHub")
        end)
    end

    -- Load settings
    pcall(function()
        if isfile("LucidHub/settings.json") then
            local data = readfile("LucidHub/settings.json")
            local decoded = HttpService:JSONDecode(data)
            if type(decoded) == "table" then
                getgenv().Settings = decoded
            end
        end
    end)

    -- Auto-save settings
    spawn(function()
        while true do
            wait(30)
            pcall(function()
                if getgenv().Settings then
                    writefile("LucidHub/settings.json", 
                        HttpService:JSONEncode(getgenv().Settings)
                    )
                end
            end)
        end
    end)

    Lucid.Initialized = true
    return true
end

-- Execute the loader with full error handling
local success, result = pcall(function()
    -- Ensure the script can run
    assert(game, "Expected 'game' to be available")
    assert(game:GetService("Players"), "Players service not available")
    
    return StartLucid()
end)

if not success then
    warn("[Lucid] Failed to start:", result)
    return false
end

if type(getgenv().Lucid) ~= "table" then
    warn("[Lucid] Failed to initialize properly")
    return false
end

return getgenv().Lucid
