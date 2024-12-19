-- ui.lua
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- Ensure we have our dependencies
if not getgenv().Fluent then
    error("Fluent UI library not initialized")
    return false
end

if not getgenv().Config then
    error("Config not initialized")
    return false
end

-- Clean up existing window if it exists
if getgenv().Window then
    pcall(function()
        getgenv().Window:Destroy()
    end)
    getgenv().Window = nil
end

-- Initialize SaveManager if available
local SaveManager = nil
if getgenv().Config.URLs.SaveManager then
    local success, content = pcall(function()
        return game:HttpGet(getgenv().Config.URLs.SaveManager)
    end)
    
    if success then
        SaveManager = loadstring(content)()
        if SaveManager then
            SaveManager:SetLibrary(getgenv().Fluent)
            SaveManager:SetFolder("LucidHub")
            SaveManager:BuildConfigSection(getgenv().Window)
        end
    end
end

-- Create window with proper settings
local Window = getgenv().Fluent:CreateWindow({
    Title = "Lucid Hub",
    SubTitle = "by ProbTom",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = getgenv().Config.UI.Theme or "Dark",
    MinimizeKey = getgenv().Config.UI.MinimizeKey or Enum.KeyCode.RightControl
})

-- Store window reference globally
getgenv().Window = Window

-- Add tabs
local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "home" }),
    Items = Window:AddTab({ Title = "Items", Icon = "package" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

-- Initialize SaveManager for the window if available
if SaveManager then
    SaveManager:LoadAutoloadConfig()
end

-- Settings tab configuration
local SettingsTab = Tabs.Settings
if SettingsTab then
    local ThemeSection = SettingsTab:AddSection("Theme")
    if ThemeSection then
        local ColorPicker = ThemeSection:AddColorPicker("Color", {
            Title = "Main Color",
            Default = getgenv().Config.UI.MainColor,
            Callback = function(color)
                getgenv().Config.UI.MainColor = color
                Window:SetAccent(color)
            end
        })
    end
    
    -- Add UI toggle
    local ToggleUI = SettingsTab:AddButton({
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

-- Store tabs globally for other scripts
getgenv().Tabs = Tabs

-- Handle window closing
Window.OnClose(function()
    if SaveManager then
        SaveManager:SaveAutoloadConfig()
    end
end)

return true
