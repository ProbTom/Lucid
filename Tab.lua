local Window = Fluent:CreateWindow({
    Title = "Lucid Hub",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Theme = "Rose",
    MinimizeKey = Enum.KeyCode.LeftControl -- Used when you press Q
})

local Tabs = {
    Home = Window:AddTab({ Title = "Home", Icon = "home" }),
    Main = Window:AddTab({ Title = "Main", Icon = "list" }),
    Items = Window:AddTab({ Title = "Items", Icon = "box" }),
    Teleports = Window:AddTab({ Title = "Teleports", Icon = "map-pin" }),
    Misc = Window:AddTab({ Title = "Misc", Icon = "file-text" }),
    Trade = Window:AddTab({ Title = "Trade", Icon = "gift" }),
    Exclusives = Window:AddTab({ Title = "Credit", Icon = "heart" })
}

getgenv().Tabs = Tabs
return true
