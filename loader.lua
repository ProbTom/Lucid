if getgenv().LucidHubLoaded then
    warn("Lucid Hub: Already executed!")
    return
end

if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- Load config first
local configSource = game:HttpGet("https://raw.githubusercontent.com/ProbTom/Lucid/main/config.lua")
local config = loadstring(configSource)()

-- Load UI Libraries using the same method as your working script
local Fluent = loadstring(game:HttpGet(config.URLs.Fluent))()
local SaveManager = loadstring(game:HttpGet(config.URLs.SaveManager))()
local InterfaceManager = loadstring(game:HttpGet(config.URLs.InterfaceManager))()

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
