local Window = getgenv().Fluent:CreateWindow({
    Title = "Lucid Hub",
    SubTitle = "by ProbTom",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeConfig = {
        Side = "Left",
        Position = UDim2.new(0, 0, 0.5, 0),
        Background = "rbxassetid://0",
        ButtonBackground = "rbxassetid://0",
        ImageColor3 = Color3.fromRGB(255, 255, 255),
    }
})

-- Create Tabs object to store all tabs
local Tabs = {
    Main = Window:AddTab({
        Title = "Main",
        Icon = "rbxassetid://10723424505"
    }),
    Settings = Window:AddTab({
        Title = "Settings",
        Icon = "rbxassetid://10734949203"
    }),
    Credits = Window:AddTab({
        Title = "Credits",
        Icon = "rbxassetid://10723346959"
    })
}

-- Add credits section
local CreditsSection = Tabs.Credits:AddSection("Credits")

CreditsSection:AddParagraph({
    Title = "Script Developer",
    Content = "ProbTom - Main Developer"
})

CreditsSection:AddParagraph({
    Title = "UI Library",
    Content = "Fluent Interface Suite by dawid"
})

-- Make Tabs accessible globally
getgenv().Tabs = Tabs

-- Set up settings tab
local SettingsTab = Tabs.Settings
local ThemeManager = getgenv().Fluent.Options

-- Add theme customization
local ThemeSection = SettingsTab:AddSection("Theme")

local ThemeDropdown = ThemeSection:AddDropdown("ThemeDropdown", {
    Title = "Theme",
    Values = {"Light", "Dark", "Darker", "Discord", "Aqua"},
    Multi = false,
    Default = "Dark",
})

ThemeDropdown:OnChanged(function(value)
    Window:SetTheme(value)
end)

-- Add window customization
local WindowSection = SettingsTab:AddSection("Window")

local WindowToggle = WindowSection:AddToggle("WindowToggle", {
    Title = "Save Window Info",
    Default = false,
})

WindowToggle:OnChanged(function(value)
    Window:SaveConfig(value)
end)

local MinimizeKeybind = WindowSection:AddKeybind("MinimizeKeybind", {
    Title = "Minimize Bind",
    Default = "LeftControl",
})

MinimizeKeybind:OnChanged(function(value)
    Window:SetMinimizeKeybind(value)
end)

-- Add UI customization
local CustomSection = SettingsTab:AddSection("Customization")

local TransparencySlider = CustomSection:AddSlider("Transparency", {
    Title = "Transparency",
    Default = 0,
    Min = 0,
    Max = 100,
    Rounding = 0,
    Callback = function(value)
        Window:SetBackgroundTransparency(value / 100)
    end
})

local AcrylicToggle = CustomSection:AddToggle("AcrylicToggle", {
    Title = "Acrylic",
    Default = true,
})

AcrylicToggle:OnChanged(function(value)
    Window:ToggleAcrylic(value)
end)

return true
