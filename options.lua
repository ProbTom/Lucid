-- options.lua
local Options = {
    -- Main Tab Options
    AutoFish = false,
    AutoCast = false,
    AutoReel = false,
    AutoShake = false,
    CastMode = "Legit",
    ReelMode = "Legit",
    ZoneCast = false,
    SelectedZone = "None",

    -- Items Tab Options
    Items = {
        ChestCollector = {
            Enabled = false,
            Range = 50
        },
        AutoSell = {
            Enabled = false,
            Rarities = {
                Common = true,
                Uncommon = false,
                Rare = false,
                Epic = false,
                Legendary = false,
                Mythical = false,
                ["Enchant Relics"] = false,
                Exotic = false,
                Limited = false,
                Gemstones = false
            }
        },
        RodManager = {
            AutoEquipBest = false,
            LastEquipped = nil
        }
    },

    -- UI Settings
    UI = {
        SaveSettings = true,
        LoadSettings = true,
        Theme = "Rose",
        Transparency = 0,
        MinimizeKey = Enum.KeyCode.RightControl
    }
}

-- Initialize settings handler
local function initializeSettings()
    -- Set global options reference
    getgenv().Options = Options

    -- Initialize SaveManager if available
    if getgenv().SaveManager then
        getgenv().SaveManager:SetIgnoreIndexes({
            "LastEquipped" -- Don't save temporary states
        })

        -- Load saved settings
        if Options.UI.LoadSettings then
            pcall(function()
                getgenv().SaveManager:Load("LucidHub")
            end)
        end
    end
end

-- Auto-save settings on changes
local function createSettingsWatcher()
    local RunService = game:GetService("RunService")
    
    RunService.Heartbeat:Connect(function()
        if Options.UI.SaveSettings and getgenv().SaveManager then
            pcall(function()
                getgenv().SaveManager:Save("LucidHub")
            end)
        end
    end)
end

-- Initialize
initializeSettings()
createSettingsWatcher()

return Options