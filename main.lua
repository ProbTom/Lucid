-- main.lua
local Lucid = {}

-- Load core modules through your existing loader
local Loader = loadstring(game:HttpGet("https://raw.githubusercontent.com/ProbTom/Lucid/main/loader.lua"))()
if not Loader then
    warn("Failed to load Lucid loader")
    return
end

-- Initialize WindUI
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
if not WindUI then
    warn("Failed to load WindUI")
    return
end

-- Load modules with WindUI integration
Lucid.Debug = Loader.load("debug")
Lucid.Utils = Loader.load("utils")
Lucid.Functions = Loader.load("functions")
Lucid.Options = Loader.load("options")
Lucid.UI = Loader.load("ui")

-- Initialize modules with dependencies
if Lucid.Debug then
    Lucid.Debug.init({windui = WindUI})
end

if Lucid.Utils then
    Lucid.Utils.init({windui = WindUI, debug = Lucid.Debug})
end

if Lucid.Functions then
    Lucid.Functions.init({windui = WindUI, debug = Lucid.Debug, utils = Lucid.Utils})
end

if Lucid.Options then
    Lucid.Options.init({windui = WindUI, debug = Lucid.Debug, utils = Lucid.Utils, functions = Lucid.Functions})
end

if Lucid.UI then
    Lucid.UI.init({windui = WindUI, debug = Lucid.Debug, utils = Lucid.Utils, functions = Lucid.Functions})
end

-- Make Lucid accessible globally
getgenv().Lucid = Lucid

-- Start the script
if Lucid.UI and Lucid.UI._initialized then
    Lucid.Debug.Info("Lucid Hub successfully loaded!", true)
else
    warn("Failed to initialize Lucid Hub UI")
end

return Lucid
