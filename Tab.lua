-- Previous wait for game load code remains the same...

local function safeCallMethod(object, methodName, ...)
    if object and typeof(object[methodName]) == "function" then
        return pcall(function()
            return object[methodName](object, ...)
        end)
    end
    return false, string.format("Method %s not available", methodName)
end

local function createWindow()
    if not getgenv().Fluent then
        error("Fluent UI library not initialized")
        return
    end

    -- Check if window already exists
    if getgenv().LucidWindow then
        return {
            Success = true,
            Window = getgenv().LucidWindow,
            Tabs = getgenv().Tabs
        }
    end

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

    -- Create tabs with error handling
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

    -- Store tabs reference
    getgenv().Tabs = Tabs

    -- Initialize settings with safe method calls
    if Tabs.Settings then
        local SettingsTab = Tabs.Settings
        local ThemeSection = SettingsTab:AddSection("Theme")

        if ThemeSection then
            -- Add settings controls with safe method calls
            ThemeSection:AddDropdown("ThemeDropdown", {
                Title = "Theme",
                Values = {"Light", "Dark", "Darker", "Discord", "Aqua"},
                Multi = false,
                Default = "Dark",
                Callback = function(value)
                    safeCallMethod(Window, "SetTheme", value)
                end
            })

            -- Add other settings controls...
        end
    end

    return {
        Success = true,
        Window = Window,
        Tabs = Tabs
    }
end

return createWindow()
