-- Tab.lua
-- Version: 2024.12.20
-- Author: ProbTom

local Tabs = {
    _initialized = false,
    _tabs = {},
    _sections = {}
}

-- Debug Module (local version)
local Debug = {
    Log = function(msg) print("[Lucid Tabs] " .. tostring(msg)) end,
    Error = function(msg) warn("[Lucid Tabs Error] " .. tostring(msg)) end
}

-- Protected function call wrapper
local function protectedCall(func, ...)
    if type(func) ~= "function" then
        Debug.Error("Attempted to call a nil value or non-function")
        return false
    end
    
    local success, result = pcall(func, ...)
    if not success then
        Debug.Error(result)
        return false
    end
    return true, result
end

-- Tab Configuration
local TabConfig = {
    {Name = "Home", Icon = "home"},
    {Name = "Main", Icon = "list"},
    {Name = "Items", Icon = "package"},
    {Name = "Teleports", Icon = "map-pin"},
    {Name = "Misc", Icon = "file-text"},
    {Name = "Trade", Icon = "gift"},
    {Name = "Credit", Icon = "heart"}
}

-- Initialize tabs
function Tabs.Initialize()
    if Tabs._initialized then
        return true
    end

    if not getgenv or not getgenv().LucidWindow then
        Debug.Error("Window not initialized")
        return false
    end

    local window = getgenv().LucidWindow

    -- Create tabs
    for _, tabInfo in ipairs(TabConfig) do
        local success, tab = protectedCall(function()
            return window:AddTab({
                Title = tabInfo.Name,
                Icon = tabInfo.Icon
            })
        end)

        if success and tab then
            Tabs._tabs[tabInfo.Name] = tab
            Debug.Log(tabInfo.Name .. " tab created")
        else
            Debug.Error("Failed to create " .. tabInfo.Name .. " tab")
        end
    end

    -- Add credits content
    if Tabs._tabs.Credit then
        local creditsSection = Tabs._tabs.Credit:AddSection("Credits")
        
        creditsSection:AddParagraph({
            Title = "Developer",
            Content = "ProbTom"
        })

        creditsSection:AddParagraph({
            Title = "UI Library",
            Content = "Fluent UI Library by dawid-scripts"
        })
    end

    Tabs._initialized = true
    Debug.Log("Tabs initialized successfully")
    return true
end

-- Get a specific tab
function Tabs.GetTab(name)
    if not Tabs._tabs[name] then
        Debug.Error("Tab not found: " .. tostring(name))
        return nil
    end
