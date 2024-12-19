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
            Acrylic = true,
            Theme = "Dark"
        })
    end

    local window = getgenv().LucidWindow

    -- Initialize Tabs table
    if not getgenv().Tabs then
        getgenv().Tabs = {}
    end

    -- Create main tabs
    getgenv().Tabs.Main = window:AddTab({Title = "Main"})
    getgenv().Tabs.Settings = window:AddTab({Title = "Settings"})
    getgenv().Tabs.Credits = window:AddTab({Title = "Credits"})

    -- Add Settings sections
    local settingsTab = getgenv().Tabs.Settings
    if settingsTab then
        local themeSection = settingsTab:AddSection("Theme")
        
        themeSection:AddDropdown("ThemeDropdown", {
            Title = "Theme",
            Values = {"Light", "Dark", "Darker", "Discord", "Aqua"},
            Default = "Dark",
            Callback = function(value)
                window:SetTheme(value)
            end
        })

        themeSection:AddToggle("SaveWindow", {
            Title = "Save Window Position",
            Default = false,
            Callback = function(value)
                window:SaveConfig(value)
            end
        })

        themeSection:AddToggle("Acrylic", {
            Title = "Acrylic Effect",
            Default = true,
            Callback = function(value)
                window:ToggleAcrylic(value)
            end
        })
    end

    -- Add Credits sections
    local creditsTab = getgenv().Tabs.Credits
    if creditsTab then
        local creditsSection = creditsTab:AddSection("Credits")
        
        creditsSection:AddParagraph({
            Title = "Developer",
            Content = "ProbTom"
        })

        creditsSection:AddParagraph({
            Title = "UI Library",
            Content = "Fluent UI Library by dawid-scripts"
        })
    end

    -- Load saved settings
    if getgenv().CompatibilityLayer then
        local config = getgenv().CompatibilityLayer.getConfig()
        if config and config.windowState then
            if config.windowState.theme then
                window:SetTheme(config.windowState.theme)
            end
            if config.windowState.acrylic ~= nil then
                window:ToggleAcrylic(config.windowState.acrylic)
            end
        end
    end

    return true
end)

if not success then
    warn("Failed to initialize Tab.lua:", result)
    return false
end

return result
