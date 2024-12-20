-- ui.lua
local UI = {
    _version = "1.0.2",
    _initialized = false,
    _tabs = {},
    _connections = {},
    _icons = {
        main = "rbxassetid://10723424505",
        settings = "rbxassetid://10734931430"
    }
}

local Debug = loadstring(game:HttpGet("https://raw.githubusercontent.com/ProbTom/Lucid/main/debug.lua"))()

function UI.IsInitialized()
    return UI._initialized
end

function UI.CreateMainSections()
    if not getgenv().Tabs or not getgenv().Tabs.Main then
        Debug.Error("Main tab not created. Cannot create sections.")
        return false
    end

    local sections = {}
    
    -- Fishing Controls Section
    sections.Fishing = getgenv().Tabs.Main:AddSection("Fishing Controls")
    Debug.Log("Fishing Controls section created.")
    
    -- Auto Cast Toggle
    sections.Fishing:AddToggle("AutoCast", {
        Title = "Auto Cast",
        Default = false,
        Callback = function(value)
            if getgenv().State then
                getgenv().State.AutoCasting = value
                Debug.Log("Auto Cast set to " .. tostring(value))
            end
        end
    })

    -- Auto Reel Toggle
    sections.Fishing:AddToggle("AutoReel", {
        Title = "Auto Reel",
        Default = false,
        Callback = function(value)
            if getgenv().State then
                getgenv().State.AutoReeling = value
                Debug.Log("Auto Reel set to " .. tostring(value))
            end
        end
    })

    -- Auto Shake Toggle
    sections.Fishing:AddToggle("AutoShake", {
        Title = "Auto Shake",
        Default = false,
        Callback = function(value)
            if getgenv().State then
                getgenv().State.AutoShaking = value
                Debug.Log("Auto Shake set to " .. tostring(value))
            end
        end
    })

    return true
end

function UI.Initialize()
    if UI._initialized then
        Debug.Log("UI already initialized")
        return true
    end

    if not getgenv().LucidWindow then
        Debug.Error("Window not initialized")
        return false
    end

    local success = UI.CreateMainSections()
    if not success then
        Debug.Error("Failed to create main sections")
        return false
    }

    UI._initialized = true
    Debug.Log("UI module initialized successfully")
    return true
end

function UI.Cleanup()
    for _, connection in pairs(UI._connections) do
        if typeof(connection) == "RBXScriptConnection" then
            connection:Disconnect()
        end
    end
    UI._connections = {}
    Debug.Log("UI cleanup completed")
end

return UI
