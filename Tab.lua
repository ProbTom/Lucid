local Window = Fluent:CreateWindow({
    Title = "Lucid Hub",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false -- Removed blur effect
})

-- Create basic tabs
local Tabs = {
    Main = Window:AddTab({ 
        Title = "Main", 
        Icon = "fishing-rod"
    }),
    Items = Window:AddTab({ 
        Title = "Items", 
        Icon = "box" 
    }),
    Teleports = Window:AddTab({ 
        Title = "Teleports", 
        Icon = "map-pin" 
    })
}

-- Export tabs for other modules
getgenv().Tabs = Tabs

return true
