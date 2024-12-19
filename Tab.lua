-- Tab.lua
-- Ensure game is loaded
if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- Initialize local variables
local success, result = pcall(function()
    -- Service initialization
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    
    -- Verify required global states with informative errors
    if type(getgenv().Fluent) ~= "table" then
        error("Fluent UI library not initialized")
    end
    
    if type(getgenv().Functions) ~= "table" then
        error("Functions module not initialized")
    end
    
    if type(getgenv().Options) ~= "table" then
        error("Options not initialized")
    end

    -- Window creation with proper error handling
    local window = getgenv().Fluent:CreateWindow({
        Title = "Lucid Hub",
        SubTitle = "by ProbTom",
        TabWidth = 160,
        Size = UDim2.fromOffset(580, 460),
        Acrylic = true,
        Theme = "Dark",
        MinimizeConfig = {
            Side = "Left",
            Position = UDim2.new(0, 0, 0.5, 0)
        }
    })

    -- Initialize tabs table if it doesn't exist
    if not getgenv().Tabs then
        getgenv().Tabs = {}
    end

    -- Create and store main tabs
    getgenv().Tabs.Main = window:AddTab({
        Title = "Main",
        Icon = "rbxassetid://10723424505"
    })

    getgenv().Tabs.Settings = window:AddTab({
        Title = "Settings",
        Icon = "rbxassetid://10734949203"
    })

    getgenv().Tabs.Credits = window:AddTab({
        Title = "Credits",
        Icon = "rbxassetid://10723346959"
    })

    -- Store window reference
    getgenv().LucidWindow = window

    -- Initialize Settings tab
    if getgenv().Tabs.Settings then
        local settingsSection = getgenv().Tabs.Settings:AddSection("Theme")
        
        settingsSection:AddDropdown("ThemeDropdown", {
            Title = "Theme",
            Values = {"Light", "Dark", "Darker", "Discord", "Aqua"},
            Multi = false,
            Default = "Dark",
            Callback = function(value)
                pcall(function()
                    window:SetTheme(value)
                    getgenv().Functions.ShowNotification("Theme changed to " .. value)
                end)
            end
        })

        settingsSection:AddToggle("SaveWindowToggle", {
            Title = "Save Window Position",
            Default = false,
            Callback = function(value)
                pcall(function()
                    window:SaveConfig(value)
                    getgenv().Functions.ShowNotification("Window position saving " .. (value and "enabled" or "disabled"))
                end)
            end
        })

        settingsSection:AddToggle("AcrylicToggle", {
            Title = "Acrylic",
            Default = true,
            Callback = function(value)
                pcall(function()
                    window:ToggleAcrylic(value)
                    getgenv().Functions.ShowNotification("Acrylic effect " .. (value and "enabled" or "disabled"))
                end)
            end
        })

        settingsSection:AddSlider("TransparencySlider", {
            Title = "Transparency",
            Default = 0,
            Min = 0,
            Max = 100,
            Callback = function(value)
                pcall(function()
                    window:SetBackgroundTransparency(value / 100)
                    getgenv().Functions.ShowNotification("Transparency set to " .. value .. "%")
                end)
            end
        })
    end

    -- Initialize Credits tab
    if getgenv().Tabs.Credits then
        local creditsSection = getgenv().Tabs.Credits:AddSection("Credits")
        
        creditsSection:AddParagraph({
            Title = "Developer",
            Content = "ProbTom"
        })

        creditsSection:AddParagraph({
            Title = "UI Library",
            Content = "Fluent UI Library by dawid-scripts"
        })
    end

    -- Apply saved settings
    local savedConfig = getgenv().CompatibilityLayer.getConfig()
    if savedConfig and savedConfig.windowState then
        pcall(function()
            if savedConfig.windowState.theme then
                window:SetTheme(savedConfig.windowState.theme)
            end
            if savedConfig.windowState.transparency then
                window:SetBackgroundTransparency(savedConfig.windowState.transparency)
            end
            if savedConfig.windowState.acrylic ~= nil then
                window:ToggleAcrylic(savedConfig.windowState.acrylic)
            end
        end)
    end

    return true
end)

if not success then
    warn("Failed to initialize Tab.lua:", result)
    return false
end

return result
