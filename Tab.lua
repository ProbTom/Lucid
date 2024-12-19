-- Tab.lua
local success, result = pcall(function()
    if not game:IsLoaded() then
        game.Loaded:Wait()
    end

    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer

    if not getgenv().Fluent then return "Fluent UI library not initialized" end
    if not getgenv().Functions then return "Functions module not initialized" end
    if not getgenv().Options then return "Options not initialized" end
    if not getgenv().Config then return "Config not initialized" end

    if not getgenv().LucidWindow then
        getgenv().LucidWindow = getgenv().Fluent:CreateWindow({
            Title = "Lucid Hub",
            SubTitle = "by ProbTom",
            TabWidth = 160,
            Size = UDim2.fromOffset(580, 460),
            Theme = getgenv().Config.UI.Theme
        })
    end

    local window = getgenv().LucidWindow
    if not window then return "Failed to create window" end

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
        getgenv().Tabs[tabInfo.Name] = window:AddTab({
            Title = tabInfo.Name,
            Icon = tabInfo.Icon
        })
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
    end

    return true
end)

if not success then
    warn("Failed to initialize Tab.lua:", result)
    return false
end

return result
