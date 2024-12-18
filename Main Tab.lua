-- main_tab.lua
local Fluent = getgenv().Fluent

local Window = Fluent:CreateWindow({
    Title = game:GetService("MarketplaceService"):GetProductInfo(16732694052).Name .." | Fisch - Premium",
    SubTitle = "Skibidi Tom ?)",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false, -- The blur may be detectable, setting this to false disables blur entirely
    Theme = "Rose",
    MinimizeKey = Enum.KeyCode.LeftControl -- Used when theres no MinimizeKeybind
})

local Tabs = {
    Home = Window:AddTab({ Title = "Home", Icon = "home" }),
    Exclusives = Window:AddTab({ Title = "Exclusives", Icon = "heart" }),
    Main = Window:AddTab({ Title = "Main", Icon = "list" }),
    Items = Window:AddTab({ Title = "Items", Icon = "box" }),
    Teleports = Window:AddTab({ Title = "Teleports", Icon = "map-pin" }),
    Misc = Window:AddTab({ Title = "Misc", Icon = "file-text" }),
    Trade = Window:AddTab({ Title = "Trade", Icon = "gift" })
}

-- Example of adding a button to the "Home" tab
Tabs.Home:AddButton({
    Title = "Copy Owner Discord",
    Description = "Any problem ? Add Me",
    Callback = function()
        setclipboard("https://discord.com/users/229396464848076800")
    end
})

Window:SelectTab(1)
Fluent:Notify({
    Title = "Fisch",
    Content = "Executed!",
    Duration = 8
})