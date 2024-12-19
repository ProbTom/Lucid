-- Safe service getter
local function getService(serviceName)
    local success, service = pcall(function()
        return game:GetService(serviceName)
    end)
    if success then
        return service
    else
        warn("Failed to get service: " .. serviceName)
        return nil
    end
end

-- Get required services and configurations
local MarketplaceService = getService("MarketplaceService")
local Config = getgenv().Config
local Fluent = getgenv().Fluent

if not Fluent then
    warn("Fluent UI library not found")
    return
end

-- Create window with safe product info fetch
local productInfo = ""
pcall(function()
    productInfo = MarketplaceService:GetProductInfo(Config.GameID).Name
end)

local Window = Fluent:CreateWindow({
    Title = productInfo .. " | Lucid Hub v" .. Config.Version,
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true, -- Enable acrylic effect
    Theme = Config.UI.Theme,
    MinimizeKey = Config.UI.MinimizeKey
})

-- Create tabs with enhanced organization
local Tabs = {
    Home = Window:AddTab({ 
        Title = "Home", 
        Icon = "home" 
    }),
    Main = Window:AddTab({ 
        Title = "Main", 
        Icon = "fishing-rod" -- More appropriate icon for fishing
    }),
    Items = Window:AddTab({ 
        Title = "Items", 
        Icon = "box" 
    }),
    Teleports = Window:AddTab({ 
        Title = "Teleports", 
        Icon = "map-pin" 
    }),
    Misc = Window:AddTab({ 
        Title = "Misc", 
        Icon = "settings" -- Changed to settings icon
    }),
    Trade = Window:AddTab({ 
        Title = "Trade", 
        Icon = "gift" 
    }),
    Credits = Window:AddTab({ 
        Title = "Credits", 
        Icon = "heart" 
    })
}

-- Export tabs for other modules
getgenv().Tabs = Tabs

-- Initialize SaveManager integration
if getgenv().SaveManager then
    -- Set up SaveManager UI
    SaveManager:SetLibrary(Fluent)
    SaveManager:IgnoreThemeSettings()
    SaveManager:SetIgnoreIndexes({})
    
    -- Add SaveManager to window
    SaveManager:BuildConfigSection(Tabs.Misc)
end

-- Initialize InterfaceManager
if getgenv().InterfaceManager then
    -- Set up InterfaceManager
    InterfaceManager:SetLibrary(Fluent)
    InterfaceManager:SetFolder("LucidHub")
    
    -- Add theme manager to window
    InterfaceManager:BuildInterfaceSection(Tabs.Misc)
end

-- Add Home tab content
Tabs.Home:AddParagraph({
    Title = "Welcome to Lucid Hub",
    Content = "Version: " .. Config.Version .. "\nGame: " .. productInfo
})

-- Add Discord button with safe clipboard operation
Tabs.Home:AddButton({
    Title = "Join Discord",
    Description = "Get support and updates",
    Callback = function()
        pcall(function()
            setclipboard("https://discord.com/users/229396464848076800")
            Fluent:Notify({
                Title = "Discord",
                Content = "Discord link copied to clipboard!",
                Duration = 3
            })
        end)
    end
})

-- Add Credits tab content
Tabs.Credits:AddParagraph({
    Title = "Credits",
    Content = "Developer: ProbTom\nUI Library: Fluent"
})

-- Add report bug button
Tabs.Credits:AddButton({
    Title = "Report Bug",
    Description = "Report any issues or bugs",
    Callback = function()
        pcall(function()
            setclipboard("https://github.com/ProbTom/Lucid/issues")
            Fluent:Notify({
                Title = "Bug Report",
                Content = "GitHub issues page copied to clipboard!",
                Duration = 3
            })
        end)
    end
})

-- Select first tab and show notification
Window:SelectTab(1)

-- Initialize notification
Fluent:Notify({
    Title = "Lucid Hub",
    Content = "Interface loaded successfully!",
    Duration = 5
})

return true
