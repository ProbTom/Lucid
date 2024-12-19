local Window = Fluent:CreateWindow({
    Title = "Lucid Hub",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460)
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "rod" }),
    Items = Window:AddTab({ Title = "Items", Icon = "box" }),
    Teleports = Window:AddTab({ Title = "Teleports", Icon = "map" }),
    Fishing = Window:AddTab({ Title = "Fishing", Icon = "fish" }),
    Pets = Window:AddTab({ Title = "Pets", Icon = "paw-print" }),
    Eggs = Window:AddTab({ Title = "Eggs", Icon = "egg" }),
    Misc = Window:AddTab({ Title = "Misc", Icon = "settings" })
}

getgenv().Tabs = Tabs
return true
