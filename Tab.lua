-- Tab.lua
-- Dependency check and initialization
if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- Verify required global states
assert(type(getgenv().Fluent) == "table", "Fluent UI library not initialized")
assert(type(getgenv().Functions) == "table", "Functions module not initialized")
assert(type(getgenv().Options) == "table", "Options not initialized")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Create window with error handling
local function createWindow()
    if getgenv().LucidWindow then
        return {
            Success = true,
            Window = getgenv().LucidWindow,
            Tabs = getgenv().Tabs
        }
    end

    local success, window = pcall(function()
        return getgenv().Fluent:CreateWindow({
            Title = "Lucid Hub",
            SubTitle = "by ProbTom",
            TabWidth = 160,
            Size = UDim2.fromOffset(580, 460),
            Acrylic = true,
            Theme = "Dark"
        })
    end)

    if not success or not window then
        warn("Failed to create window:", window)
        return {
            Success = false,
            Error = window
        }
    end

    -- Store window reference
    getgenv().LucidWindow = window

    -- Initialize tabs with error handling
    local Tabs = {}
    
    local function createTab(name, config)
        local tabSuccess, tab = pcall(function()
            return window:AddTab(config)
        end)
        
        if tabSuccess and tab then
            Tabs[name] = tab
            return tab
        else
            warn("Failed to create tab:", name, tab)
            return nil
        end
    end

    -- Create main tabs
    createTab("Main", {
        Title = "Main",
        Icon = "rbxassetid://10723424505"
    })

    createTab("Settings", {
        Title = "Settings",
        Icon = "rbxassetid://10734949203"
    })

    createTab("Credits", {
        Title = "Credits",
        Icon = "rbxassetid://10723346959"
    })

    -- Store tabs reference
    getgenv().Tabs = Tabs

    -- Initialize Settings tab
    if Tabs.Settings then
        local settingsSuccess, settingsSection = pcall(function()
            return Tabs.Settings:AddSection("Theme")
        end)

        if settingsSuccess and settingsSection then
            pcall(function()
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
            end)
        end
    end

    -- Initialize Credits tab
    if Tabs.Credits then
        local creditsSuccess, creditsSection = pcall(function()
            return Tabs.Credits:AddSection("Credits")
        end)

        if creditsSuccess and creditsSection then
            pcall(function()
                creditsSection:AddParagraph({
                    Title = "Developer",
                    Content = "ProbTom"
                })

                creditsSection:AddParagraph({
                    Title = "UI Library",
                    Content = "Fluent UI Library by dawid-scripts"
                })
            end)
        end
    end

    -- Apply saved settings if available
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

    return {
        Success = true,
        Window = window,
        Tabs = Tabs
    }
end

-- Create and return window
local windowResult = createWindow()
if not windowResult.Success then
    error("Failed to create window: " .. tostring(windowResult.Error))
    return false
end

return true
