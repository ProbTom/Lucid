-- init.lua
if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- Initialize global tables
if not _G.Functions then _G.Functions = {} end
if not _G.Options then _G.Options = {} end

-- Load Fluent UI Library
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

-- Initialize global state
getgenv().Fluent = Fluent
getgenv().SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
getgenv().InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- Load core modules in order
loadstring(game:HttpGet("https://raw.githubusercontent.com/ProbTom/Lucid/main/config.lua"))()
loadstring(game:HttpGet("https://raw.githubusercontent.com/ProbTom/Lucid/main/compatibility.lua"))()
loadstring(game:HttpGet("https://raw.githubusercontent.com/ProbTom/Lucid/main/functions.lua"))()
loadstring(game:HttpGet("https://raw.githubusercontent.com/ProbTom/Lucid/main/Tab.lua"))()

-- Load feature modules after core initialization
loadstring(game:HttpGet("https://raw.githubusercontent.com/ProbTom/Lucid/main/MainTab.lua"))()
loadstring(game:HttpGet("https://raw.githubusercontent.com/ProbTom/Lucid/main/ItemsTab.lua"))()

-- Initialize SaveManager
getgenv().SaveManager:SetLibrary(Fluent)
getgenv().SaveManager:SetFolder("LucidHub")
getgenv().SaveManager:Load("LucidHub")

return true
