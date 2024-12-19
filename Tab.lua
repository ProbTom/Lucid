-- Tab.lua
local success, result = pcall(function()
    -- Wait for game load
    if not game:IsLoaded() then
        game.Loaded:Wait()
    end

    -- Get services
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer

    -- Check dependencies
    if not getgenv().Fluent then return "Fluent UI library not initialized" end
    if not getgenv().Functions then return "Functions module not initialized" end
    if not getgenv().Options then return "Options not initialized" end

    -- Create window if it doesn't exist
    if not getgenv().LucidWindow then
        getgenv().LucidWindow = getgenv().Fluent:CreateWindow({
            Title = "Lucid Hub",
            SubTitle = "by ProbTom",
            TabWidth = 160,
            Size = UDim2.fromOffset(580, 460),
            Theme = "Rose"
        })
    end

    local window = getgenv().LucidWindow
    if not window then return "Failed to create window" end

    -- Initialize Tabs table
    if not getgenv().Tabs then
        getgenv().Tabs = {}
    end

    -- Create all tabs
    getgenv().Tabs.Home = window:AddTab({
        Title = "Home",
        Icon = "home"
    })

    getgenv().Tabs.Main = window:AddTab({
        Title = "Main",
        Icon = "list"
    })

    getgenv().Tabs.Items = window:AddTab({
        Title = "Items",
        Icon = "box"
    })

    getgenv().Tabs.Teleports = window:AddTab({
        Title = "Teleports",
        Icon = "map-pin"
    })

    getgenv().Tabs.Misc = window:AddTab({
        Title = "Misc",
        Icon = "file-text"
    })

    getgenv().Tabs.Trade = window:AddTab({
        Title = "Trade",
        Icon = "gift"
    })

    getgenv().Tabs.Exclusives = window:AddTab({
        Title = "Credit",
        Icon = "heart"
    })

    -- Add Credits content to Exclusives tab
    if getgenv().Tabs.Exclusives then
        local creditsSection = getgenv().Tabs.Exclusives:AddSection("Credits")
        
        creditsSection:AddParagraph({
            Title = "Developer",
            Content = "ProbTom"
        })

        creditsSection:AddParagraph({
            Title = "UI Library",
            Content = "Fluent UI Library by dawid-scripts"
        })
    end

    return true
end)

if not success then
    warn("Failed to initialize Tab.lua:", result)
    return false
end

return result
