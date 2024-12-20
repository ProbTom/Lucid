-- Tab.lua
local Debug = loadstring(game:HttpGet("https://raw.githubusercontent.com/ProbTom/Lucid/main/debug.lua"))()

local function initializeTabs()
    if not game:IsLoaded() then
        game.Loaded:Wait()
    end

    -- Verify required globals
    local required = {
        "Fluent",
        "Functions",
        "Options",
        "Config",
        "LucidWindow"
    }

    for _, name in ipairs(required) do
        if not getgenv()[name] then
            Debug.Error(name .. " not initialized")
            return false
        end
    end

    -- Use existing window
    local window = getgenv().LucidWindow
    if not window then 
        Debug.Error("Window not initialized")
        return false
    end

    if not getgenv().Tabs then
        getgenv().Tabs = {}
    end

    -- Initialize Options
    getgenv().Options.ChestRange = getgenv().Config.Items.ChestSettings.Default
    getgenv().Options.SelectedRarities = {Common = true}
    getgenv().Options.AutoCollectEnabled = false
    getgenv().Options.AutoSellEnabled = false
    getgenv().Options.AutoEquipBestRod = false

    -- Create tabs using configuration
    for _, tabInfo in ipairs(getgenv().Config.UI.Tabs) do
        if not getgenv().Tabs[tabInfo.Name] then
            getgenv().Tabs[tabInfo.Name] = window:AddTab({
                Title = tabInfo.Name,
                Icon = tabInfo.Icon
            })
            Debug.Log(tabInfo.Name .. " tab created.")
        end
    end

    -- Add Credits content
    if getgenv().Tabs.Credit then
        local creditsSection = getgenv().Tabs.Credit:AddSection("Credits")
        
        creditsSection:AddParagraph({
            Title = "Developer",
            Content = "ProbTom"
        })

        creditsSection:AddParagraph({
            Title = "UI Library",
            Content = "Fluent UI Library by dawid-scripts"
        })
        Debug.Log("Credits section created.")
    end

    return true
end

return initializeTabs()
