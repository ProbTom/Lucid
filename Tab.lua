-- Tab.lua
local Debug = loadstring(game:HttpGet("https://raw.githubusercontent.com/ProbTom/Lucid/main/debug.lua"))()

local success, result = pcall(function()
    if not game:IsLoaded() then
        game.Loaded:Wait()
    end

    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer

    if not getgenv().Fluent then 
        Debug.Error("Fluent UI library not initialized")
        return "Fluent UI library not initialized" 
    end
    if not getgenv().Functions then 
        Debug.Error("Functions module not initialized")
        return "Functions module not initialized" 
    end
    if not getgenv().Options then 
        Debug.Error("Options not initialized")
        return "Options not initialized" 
    end
    if not getgenv().Config then 
        Debug.Error("Config not initialized")
        return "Config not initialized" 
    end

    -- Ensure window is created only once
    if not getgenv().LucidWindow then
        getgenv().LucidWindow = getgenv().Fluent:CreateWindow({
            Title = "Lucid Hub",
            SubTitle = "by ProbTom",
            TabWidth = 160,
            Size = UDim2.fromOffset(580, 460),
            Theme = getgenv().Config.UI.Theme
        })
        Debug.Log("LucidWindow created successfully.")
    else
        Debug.Error("LucidWindow already exists.")
    end

    local window = getgenv().LucidWindow
    if not window then 
        Debug.Error("Failed to create window")
        return "Failed to create window" 
    end

    if not getgenv().Tabs then
        getgenv().Tabs = {}
    end

    -- Initialize Options for Items tab
    getgenv().Options.ChestRange = getgenv().Config.Items.ChestRange.Default
    getgenv().Options.SelectedRarities = {Common = true}
    getgenv().Options.AutoCollectEnabled = false
    getgenv().Options.AutoSellEnabled = false
    getgenv().Options.AutoEquipBestRod = false

    -- Create all tabs with consistent order
    local TabOrder = {
        {Name = "Home", Icon = "home"},
        {Name = "Main", Icon = "list"},
        {Name = "Items", Icon = "package"},
        {Name = "Teleports", Icon = "map-pin"},
        {Name = "Misc", Icon = "file-text"},
        {Name = "Trade", Icon = "gift"},
        {Name = "Credit", Icon = "heart"}
    }

    for _, tabInfo in ipairs(TabOrder) do
        if not getgenv().Tabs[tabInfo.Name] then
            getgenv().Tabs[tabInfo.Name] = window:AddTab({
                Title = tabInfo.Name,
                Icon = tabInfo.Icon
            })
            Debug.Log(tabInfo.Name .. " tab created.")
        else
            Debug.Error(tabInfo.Name .. " tab already exists.")
        end
    end

    -- Add Credits content
    if getgenv().Tabs.Credit then
        local creditsSection = getgenv().Tabs.Credit:AddSection("Credits")
        
        creditsSection:AddParagraph({
            Title = "Developer",
            Content = "ProbTom"
        })

        creditsSection:AddParagraph({
            Title = "UI Library",
            Content = "Fluent UI Library by dawid-scripts"
        })
        Debug.Log("Credits section created.")
    end

    -- Setup save manager integration for Items tab
    if getgenv().SaveManager then
        getgenv().SaveManager:SetIgnoreIndexes({
            "ChestRange",
            "SelectedRarities",
            "AutoCollectEnabled",
            "AutoSellEnabled",
            "AutoEquipBestRod"
        })
        Debug.Log("Save manager integration setup.")
    end

    return true
end)

if not success then
    Debug.Error("Failed to initialize Tab.lua: " .. result)
    return false
end

Debug.Log("Tab.lua initialized successfully.")
return result
