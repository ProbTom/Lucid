-- main tab
local Fluent = getgenv().Fluent

local Window = Fluent:CreateWindow({
    Title = game:GetService("MarketplaceService"):GetProductInfo(16732694052).Name .." | Lucid Hub",
    SubTitle = "Lucid Hub",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false, -- The blur may be detectable, setting this to false disables blur entirely
    Theme = "Rose",
    MinimizeKey = Enum.KeyCode.RightControl -- Used when theres no MinimizeKeybind
})

local Tabs = {
    Home = Window:AddTab({ Title = "Home", Icon = "home" }),
    Main = Window:AddTab({ Title = "Main", Icon = "list" }),
    Items = Window:AddTab({ Title = "Items", Icon = "box" }),
    Teleports = Window:AddTab({ Title = "Teleports", Icon = "map-pin" }),
    Misc = Window:AddTab({ Title = "Misc", Icon = "file-text" }),
    Trade = Window:AddTab({ Title = "Trade", Icon = "gift" }),
    Exclusives = Window:AddTab({ Title = "Credit", Icon = "heart" }),
}

getgenv().Tabs = Tabs

Tabs.Home:AddButton({
    Title = "Copy Owner Discord",
    Description = "Any problem ? Add Me",
    Callback = function()
        setclipboard("https://discord.com/users/229396464848076800")
    end
})

Window:SelectTab(1)
Fluent:Notify({
    Title = "Lucid Hub",
    Content = "Executed!",
    Duration = 8
})