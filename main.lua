-- main.lua
if not game:IsLoaded() then
    game.Loaded:Wait()
end

local function executeWithDebug(fn)
    local success, result = pcall(fn)
    if not success then
        warn("[LUCID ERROR]:", result)
        return false
    end
    return result
end

local function start()
    -- Load loader
    local success, loader = executeWithDebug(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/ProbTom/Lucid/main/loader.lua"))()
    end)
    
    if not success or not loader then
        warn("[LUCID ERROR]: Failed to load loader")
        return false
    end
    
    return true
end

return start()
