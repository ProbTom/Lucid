-- loader.lua
local Loader = {}

-- Load Core Modules
local success, UI = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/ProbTom/Lucid/main/ui.lua"))()
end)

if not success then
    warn("Failed to load UI module")
    return
end

local success, Functions = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/ProbTom/Lucid/main/functions.lua"))()
end)

if not success then
    warn("Failed to load Functions module")
    return
end

return Loader
