-- Wait for game to load
if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- Wait for Fluent UI to be available and initialized
local function waitForFluent()
    local startTime = tick()
    while not (getgenv().Fluent and typeof(getgenv().Fluent.CreateWindow) == "function") do
        if tick() - startTime > 10 then
            return false
        end
        task.wait(0.1)
    end
    return true
end

-- Check if window already exists
if getgenv().LucidWindow then
    return {
        Success = true,
        Window = getgenv().LucidWindow,
        Tabs = getgenv().Tabs
    }
end

-- Wait for Fluent UI
if not waitForFluent() then
    error("Failed to load Fluent UI library")
    return false
end

-- Create window with pcall to catch any errors
local success, Window = pcall(function()
    return getgenv().Fluent:CreateWindow({
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
end)

if not success then
    warn("Failed to create window:", Window)
    return false
end

-- Store window reference
getgenv().LucidWindow = Window

-- Create tabs with pcall
local success, Tabs = pcall(function()
    return {
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
end)

if not success then
    warn("Failed to create tabs:", Tabs)
    return false
end

-- Store tabs reference
getgenv().Tabs = Tabs

-- Credits Section
pcall(function()
    local CreditsSection = Tabs.Credits:AddSection("Credits")
    CreditsSection:AddParagraph({
        Title = "Script Developer",
        Content = "ProbTom - Main Developer"
    })
    CreditsSection:AddParagraph({
        Title = "UI Library",
        Content = "Fluent Interface Suite by dawid"
    })
end)

-- Settings Tab
pcall(function()
    local SettingsTab = Tabs.Settings
    local ThemeSection = SettingsTab:AddSection("Theme")

    ThemeSection:AddDropdown("ThemeDropdown", {
        Title = "Theme",
        Values = {"Light", "Dark", "Darker", "Discord", "Aqua"},
        Multi = false,
        Default = "Dark",
        Callback = function(value)
            Window:SetTheme(value)
        end
    })

    local WindowSection = SettingsTab:AddSection("Window")
    
    WindowSection:AddToggle("WindowToggle", {
        Title = "Save Window Info",
        Default = false,
        Callback = function(value)
            Window:SaveConfig(value)
        end
    })

    WindowSection:AddKeybind("MinimizeKeybind", {
        Title = "Minimize Bind",
        Default = "LeftControl",
        Callback = function(value)
            Window:SetMinimizeKeybind(value)
        end
    })

    local CustomSection = SettingsTab:AddSection("Customization")

    CustomSection:AddSlider("Transparency", {
        Title = "Transparency",
        Default = 0,
        Min = 0,
        Max = 100,
        Rounding = 0,
        Callback = function(value)
            Window:SetBackgroundTransparency(value / 100)
        end
    })

    CustomSection:AddToggle("AcrylicToggle", {
        Title = "Acrylic",
        Default = true,
        Callback = function(value)
            Window:ToggleAcrylic(value)
        end
    })
end)

return {
    Success = true,
    Window = Window,
    Tabs = Tabs
}
