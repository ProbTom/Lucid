local function loadModule(url)
    local success, content = pcall(function()
        return game:HttpGet(url) -- Use HttpGet instead of HttpService:GetAsync
    end)
    
    if success then
        local func, err = loadstring(content)
        if func then
            return pcall(func)
        else
            warn("Failed to loadstring: " .. tostring(err))
        end
    else
        warn("Failed to load module: " .. url)
    end
    return false
end

-- Set up global environment
if not getgenv().Config then
    getgenv().Config = {}
end

-- Load modules in correct order
local baseUrl = "https://raw.githubusercontent.com/ProbTom/Lucid/main/"
local modules = {
    {name = "config", url = baseUrl .. "config.lua"},
    {name = "init", url = baseUrl .. "init.lua"},
    {name = "ui", url = baseUrl .. "ui.lua"},
    {name = "Tab", url = baseUrl .. "Tab.lua"},
    {name = "MainTab", url = baseUrl .. "MainTab.lua"}
}

for _, module in ipairs(modules) do
    local success = loadModule(module.url)
    if not success then
        warn("Failed to load " .. module.name)
        return
    end
    task.wait(0.1) -- Small delay between loads
end
