-- ui.lua
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- Core environment check
if not getgenv then
    error("Unsupported environment")
    return false
end

-- Check required dependencies
if not getgenv().Fluent then
    error("Fluent UI library not initialized")
    return false
end

-- Check if window already exists and clean up
if getgenv().LucidWindow then
    pcall(function()
        getgenv().LucidWindow:Destroy()
    end)
    getgenv().LucidWindow = nil
end

-- Create new window instance
local Window = getgenv().Fluent:CreateWindow({
    Title = "Lucid Hub",
    SubTitle = "by ProbTom",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightControl
})

-- Store window reference safely
getgenv().LucidWindow = Window

-- Create base tabs
local MainTab = Window:AddTab({ Title = "Main", Icon = "home" })
local ItemsTab = Window:AddTab({ Title = "Items", Icon = "package" })
local SettingsTab = Window:AddTab({ Title = "Settings", Icon = "settings" })

-- Store tabs globally
getgenv().LucidTabs = {
    Main = MainTab,
    Items = ItemsTab,
    Settings = SettingsTab
}

-- Initialize Settings Tab
local ThemeSection = SettingsTab:AddSection("Theme")
ThemeSection:AddColorPicker("UIColor", {
    Title = "Main Color",
    Default = Color3.fromRGB(38, 38, 38),
    Callback = function(color)
        Window:SetAccent(color)
    end
})

-- Add UI Toggle
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

-- Setup keybind for window toggle
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightControl then
        if Window.Minimized then
            Window:Restore()
        else
            Window:Minimize()
        end
    end
end)

return true
