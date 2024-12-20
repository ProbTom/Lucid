-- main.lua
if not game:IsLoaded() then
    game.Loaded:Wait()
end

local function start()
    -- Load loader
    local success, loader = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/ProbTom/Lucid/main/loader.lua"))()
    end)

    if not success then
        warn("[ERROR]: Failed to load loader:", loader)
        return false
    end

    -- Initialize
    if loader and type(loader.Initialize) == "function" then
        success = pcall(function()
            return loader.Initialize()
        end)

        if not success then
            warn("[ERROR]: Failed to initialize")
            return false
        end
    else
        warn("[ERROR]: Invalid loader")
        return false
    end

    return true
end

local success = start()
if not success then
    warn("[ERROR]: Script failed to start")
end

return success
