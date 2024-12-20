-- loader.lua (continued)
    -- Load UI
    local Fluent = loadFluentUI()
    if not Fluent then
        Debug.Error("Failed to load Fluent UI")
        return false
    end
    
    -- Create window
    local window = createWindow(Config)
    if not window then
        Debug.Error("Failed to create window")
        return false
    end
    
    -- Create tabs
    local function createTabs()
        if not getgenv().Tabs then
            getgenv().Tabs = {}
        end
        
        for tabName, tabConfig in pairs(Config.UI.Tabs) do
            local success, tab = pcall(function()
                return window:AddTab({
                    Title = tabConfig.Name,
                    Icon = tabConfig.Icon
                })
            end)
            
            if success and tab then
                getgenv().Tabs[tabName] = tab
                Debug.Log("Created tab: " .. tabName)
            else
                Debug.Error("Failed to create tab: " .. tabName)
                return false
            end
        end
        return true
    end
    
    if not createTabs() then
        Debug.Error("Failed to create tabs")
        return false
    end
    
    -- Create features
    local function createFeatures()
        local mainTab = getgenv().Tabs.Main
        if not mainTab then
            Debug.Error("Main tab not found")
            return false
        end
        
        local section = mainTab:AddSection("Fishing Controls")
        
        -- Auto Cast
        section:AddToggle({
            Title = "Auto Cast",
            Default = State.Get("AutoCasting") or false,
            Callback = function(value)
                State.Set("AutoCasting", value)
                Debug.Log("Auto Cast: " .. tostring(value))
            end
        })
        
        -- Auto Reel
        section:AddToggle({
            Title = "Auto Reel",
            Default = State.Get("AutoReeling") or false,
            Callback = function(value)
                State.Set("AutoReeling", value)
                Debug.Log("Auto Reel: " .. tostring(value))
            end
        })
        
        -- Auto Shake
        section:AddToggle({
            Title = "Auto Shake",
            Default = State.Get("AutoShaking") or false,
            Callback = function(value)
                State.Set("AutoShaking", value)
                Debug.Log("Auto Shake: " .. tostring(value))
            end
        })
        
        return true
    end
    
    if not createFeatures() then
        Debug.Error("Failed to create features")
        return false
    end
    
    -- Setup cleanup
    local function cleanup()
        for _, connection in pairs(Loader._connections) do
            if typeof(connection) == "RBXScriptConnection" then
                connection:Disconnect()
            end
        end
        
        if getgenv().LucidWindow then
            pcall(function()
                getgenv().LucidWindow:Destroy()
            end)
            getgenv().LucidWindow = nil
        end
        
        State.Set("_initialized", false)
        Loader._initialized = false
    end
    
    -- Register cleanup on teleport
    Loader._connections.teleport = game:GetService("Players").LocalPlayer.OnTeleport:Connect(cleanup)
    
    Loader._initialized = true
    Debug.Log("Initialization complete")
    return true
end

-- Main execution
local function start()
    if not Loader.Initialize() then
        Debug.Error("Initialization failed")
        return false
    end
    return true
end

if not start() then
    Debug.Error("Failed to start Lucid Hub")
end

return Loader
