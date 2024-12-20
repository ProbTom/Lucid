-- main.lua
if not game:IsLoaded() then
    game.Loaded:Wait()
end

local success, result = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/ProbTom/Lucid/main/loader.lua"))()
end)

if not success then
    warn("Failed to load Lucid Hub:", result)
    return
end

return true