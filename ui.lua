-- ui.lua
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- Verify environment
if not getgenv then
    error("Unsupported environment")
    return false
end

-- Initialize default configuration if missing
if not getgenv().Config then
    getgenv().Config = {
        UI = {
            MainColor = Color3.fromRGB(38, 38, 38),
            ButtonColor = Color3.fromRGB(220, 125, 255),
            MinimizeKey = Enum.KeyCode.RightControl,
            Theme = "Dark"
        }
    }
end

-- Clean up existing window
if getgenv().Window then
    pcall(function()
        getgenv().Window:Destroy()
    end)
    getgenv().Window = nil
end

-- Verify Fluent UI library
if not getgenv().Fluent then
    error("Fluent UI library not initialized")
    return false
end

-- Create window
local Window = getgenv().Fluent:CreateWindow({
    Title = "Lucid Hub",
    SubTitle = "by ProbTom",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = getgenv().Config.UI.Theme,
    MinimizeKey = getgenv().Config.UI.MinimizeKey
})

-- Store window reference
getgenv().Window = Window

-- Create tabs
local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "home" }),
    Items = Window:AddTab({ Title = "Items", Icon = "package" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

-- Configure settings tab
local SettingsTab = Tabs.Settings
if SettingsTab then
    local ThemeSection = SettingsTab:AddSection("Theme")
    if ThemeSection then
        ThemeSection:AddColorPicker("UIColor", {
            Title = "Main Color",
            Default = getgenv().Config.UI.MainColor,
            Callback = function(color)
                getgenv().Config.UI.MainColor = color
                Window:SetAccent(color)
            end
        })
    end

    SettingsTab:AddButton({
        Title = "Toggle UI",
        Callback = function()
            if Window.Minimized then
                Window:Restore()
            else
                Window:Minimize()
            end
        end
    })
end

-- Store tabs globally
getgenv().Tabs = Tabs

-- Setup minimize keybind
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == getgenv().Config.UI.MinimizeKey then
        if Window.Minimized then
            Window:Restore()
        else
            Window:Minimize()
        end
    end
end)

return true
