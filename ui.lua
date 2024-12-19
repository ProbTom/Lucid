-- ui.lua
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

-- Ensure required globals
if not getgenv().Fluent then
    error("Fluent UI library not initialized")
    return false
end

if not getgenv().Config then
    error("Configuration not initialized")
    return false
end

-- Clean up existing window
if getgenv().Window then
    pcall(function()
        getgenv().Window:Destroy()
    end)
    getgenv().Window = nil
end

-- Create new window
local Window = getgenv().Fluent:CreateWindow({
    Title = "Lucid Hub v" .. getgenv().Config.Version,
    SubTitle = "by ProbTom",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = getgenv().Config.UI.Theme
})

-- Initialize tabs
local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "fish" }),
    Items = Window:AddTab({ Title = "Items", Icon = "package" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

-- Settings Tab Configuration
do
    local SettingsTab = Tabs.Settings
    local ThemeSection = SettingsTab:AddSection("Theme")
    
    -- Theme Color Picker
    ThemeSection:AddColorPicker("UIColor", {
        Title = "Main Color",
        Default = getgenv().Config.UI.MainColor,
        Callback = function(color)
            getgenv().Config.UI.MainColor = color
            Window:SetAccent(color)
        end
    })
    
    -- Theme Dropdown
    ThemeSection:AddDropdown("Theme", {
        Title = "Theme",
        Values = {"Light", "Dark", "Discord", "Rose"},
        Default = getgenv().Config.UI.Theme,
        Callback = function(theme)
            Window:ChangeTheme(theme)
            getgenv().Config.UI.Theme = theme
        end
    })
    
    -- Info Section
    local InfoSection = SettingsTab:AddSection("Information")
    InfoSection:AddLabel("Version: " .. getgenv().Config.Version)
    InfoSection:AddLabel("Created by: ProbTom")
end

-- Mobile Support
if UserInputService.TouchEnabled then
    local function createMobileButton()
        local ClickButton = Instance.new("ScreenGui")
        ClickButton.Name = "ClickButton"
        ClickButton.ResetOnSpawn = false
        
        -- Parent to CoreGui safely
        pcall(function()
            ClickButton.Parent = CoreGui
        end)
        
        local MainFrame = Instance.new("Frame")
        MainFrame.Name = "MainFrame"
        MainFrame.Parent = ClickButton
        MainFrame.AnchorPoint = Vector2.new(1, 0)
        MainFrame.BackgroundColor3 = getgenv().Config.UI.MainColor
        MainFrame.BackgroundTransparency = 0.8
        MainFrame.BorderSizePixel = 0
        MainFrame.Position = UDim2.new(1, -60, 0, 10)
        MainFrame.Size = UDim2.new(0, 45, 0, 45)
        
        local UICorner = Instance.new("UICorner")
        UICorner.CornerRadius = UDim.new(1, 0)
        UICorner.Parent = MainFrame
        
        -- Make draggable
        local dragging = false
        local dragStart = nil
        local startPos = nil
        
        MainFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = MainFrame.Position
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.Touch then
                local delta = input.Position - dragStart
                MainFrame.Position = UDim2.new(
                    startPos.X.Scale,
                    startPos.X.Offset + delta.X,
                    startPos.Y.Scale,
                    startPos.Y.Offset + delta.Y
                )
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
        
        -- Toggle button
        local ToggleButton = Instance.new("TextButton")
        ToggleButton.Parent = MainFrame
        ToggleButton.BackgroundTransparency = 1
        ToggleButton.Size = UDim2.fromScale(1, 1)
        ToggleButton.Text = ""
        ToggleButton.MouseButton1Click:Connect(function()
            if Window.Minimized then
                Window:Restore()
            else
                Window:Minimize()
            end
        end)
    end
    
    createMobileButton()
end

-- Store references globally
getgenv().Window = Window
getgenv().Tabs = Tabs

-- Initialize keybinds
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
