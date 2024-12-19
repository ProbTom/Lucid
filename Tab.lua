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
local Config = getgenv().Config  -- Changed line here
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
    Title = productInfo .. " | Lucid Hub",
    SubTitle = " ",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false,
    Theme = Config.UI.Theme,
    MinimizeKey = Config.UI.MinimizeKey
})

-- Create tabs
local Tabs = {
    Home = Window:AddTab({ Title = "Home", Icon = "home" }),
    Main = Window:AddTab({ Title = "Main", Icon = "list" }),
    Items = Window:AddTab({ Title = "Items", Icon = "box" }),
    Teleports = Window:AddTab({ Title = "Teleports", Icon = "map-pin" }),
    Misc = Window:AddTab({ Title = "Misc", Icon = "file-text" }),
    Trade = Window:AddTab({ Title = "Trade", Icon = "gift" }),
    Exclusives = Window:AddTab({ Title = "Credit", Icon = "heart" }),
}

-- Export tabs for other modules
getgenv().Tabs = Tabs

-- Add Discord button with safe clipboard operation
Tabs.Home:AddButton({
    Title = "Copy Owner Discord",
    Description = "Any problem ? Add Me",
    Callback = function()
        pcall(function()
            setclipboard("https://discord.com/users/229396464848076800")
        end)
    end
})

-- Select first tab and show notification
Window:SelectTab(1)
Fluent:Notify({
    Title = "Lucid Hub",
    Content = "Executed!",
    Duration = 8
})

return true
