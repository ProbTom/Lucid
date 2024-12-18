if getgenv().LucidHubLoaded then
    warn("Lucid Hub: Already executed!")
    return
end

if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- Load UI Libraries directly
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- Store in global
getgenv().Fluent = Fluent
getgenv().SaveManager = SaveManager
getgenv().InterfaceManager = InterfaceManager

-- Load the rest of your scripts
local files = {
    "init.lua",
    "ui.lua",
    "Tab.lua",
    "MainTab.lua"
}

for _, file in ipairs(files) do
    local source = game:HttpGet("https://raw.githubusercontent.com/ProbTom/Lucid/main/" .. file)
    local success, result = pcall(loadstring(source))
    if not success then
        warn("Failed to load " .. file .. ": " .. tostring(result))
        return
    end
    task.wait(0.1)
end

getgenv().LucidHubLoaded = true

if Fluent then
    Fluent:Notify({
        Title = "Lucid Hub",
        Content = "Successfully loaded!",
        Duration = 5
    })
end
