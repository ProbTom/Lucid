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

    -- Safe method caller
    local function safeCall(object, methodName, ...)
        if object and typeof(object[methodName]) == "function" then
            return pcall(object[methodName], object, ...)
        end
        return false, "Method not available"
    end

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
    if not window then return "Failed to create window" end

    -- Initialize Tabs table
    if not getgenv().Tabs then
        getgenv().Tabs = {}
    end

    -- Create main tabs
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

    -- Add Settings sections
    local settingsTab = getgenv().Tabs.Settings
    if settingsTab then
        local themeSection = settingsTab:AddSection("Theme")
        
        -- Theme Dropdown
        themeSection:AddDropdown("ThemeDropdown", {
            Title = "Theme",
            Values = {"Light", "Dark", "Darker", "Discord", "Aqua"},
            Default = "Dark",
            Callback = function(value)
                -- Safe theme setting
                if typeof(window.SetTheme) == "function" then
                    window:SetTheme(value)
                elseif typeof(window.Theme) == "string" then
                    window.Theme = value
                end
            end
        })

        -- Save Window Toggle
        themeSection:AddToggle("SaveWindow", {
            Title = "Save Window Position",
            Default = false,
            Callback = function(value)
                if typeof(window.SaveConfig) == "function" then
                    window:SaveConfig(value)
                end
            end
        })

        -- Acrylic Toggle
        themeSection:AddToggle("Acrylic", {
            Title = "Acrylic Effect",
            Default = true,
            Callback = function(value)
                if typeof(window.ToggleAcrylic) == "function" then
                    window:ToggleAcrylic(value)
                elseif typeof(window.Acrylic) == "boolean" then
                    window.Acrylic = value
                end
            end
        })

        -- Transparency Slider
        themeSection:AddSlider("Transparency", {
            Title = "Transparency",
            Default = 0,
            Min = 0,
            Max = 100,
            Callback = function(value)
                if typeof(window.SetBackgroundTransparency) == "function" then
                    window:SetBackgroundTransparency(value / 100)
                elseif typeof(window.BackgroundTransparency) == "number" then
                    window.BackgroundTransparency = value / 100
                end
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

    -- Load saved settings with safe calls
    if getgenv().CompatibilityLayer then
        local config = getgenv().CompatibilityLayer.getConfig()
        if config and config.windowState then
            pcall(function()
                if config.windowState.theme and typeof(window.SetTheme) == "function" then
                    window:SetTheme(config.windowState.theme)
                end
                if config.windowState.acrylic ~= nil and typeof(window.ToggleAcrylic) == "function" then
                    window:ToggleAcrylic(config.windowState.acrylic)
                end
                if config.windowState.transparency ~= nil and typeof(window.SetBackgroundTransparency) == "function" then
                    window:SetBackgroundTransparency(config.windowState.transparency)
                end
            end)
        end
    end

    return true
end)

if not success then
    warn("Failed to initialize Tab.lua:", result)
    return false
end

return result
