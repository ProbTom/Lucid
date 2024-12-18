-- At the start of ui.lua
if getgenv().LucidHubLoaded then
    warn("Lucid Hub: Already executed!")
    return
end

-- Safe service getter
local function getService(serviceName)
    local success, service = pcall(function()
        return game:GetService(serviceName)
    end)
    if success then
        return service
    else
        warn("Failed to get service: " .. serviceName)
        return nil
    end
end

-- Check for multiple executions
if getgenv().cuppink and getService("CoreGui"):FindFirstChild("ClickButton") then
    warn("Lucid Hub: Already executed!")
    return
end

getgenv().cuppink = true

-- Wait for game load
if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- Get required services
local HttpService = getService("HttpService")
local UserInputService = getService("UserInputService")
local CoreGui = getService("CoreGui")
local Config = getgenv().Config or require(script.Parent.config)

-- Safe loading function
local function safeLoadString(url)
    print("Attempting to load: " .. url) -- Debug print
    local success, content = pcall(function()
        return game:HttpGet(url)
    end)
    
    if not success then
        warn("Failed to get content from URL: " .. url)
        return nil
    end
    
    local func, err = loadstring(content)
    if not func then
        warn("Failed to parse content from: " .. url)
        warn("Error: " .. tostring(err))
        return nil
    end
    
    success, result = pcall(func)
    if not success then
        warn("Failed to execute content from: " .. url)
        warn("Error: " .. tostring(result))
        return nil
    end
    
    return result
end

-- Load UI libraries
local Fluent = safeLoadString(Config.URLs.Fluent)
local SaveManager = safeLoadString(Config.URLs.SaveManager)
local InterfaceManager = safeLoadString(Config.URLs.InterfaceManager)

if not (Fluent and SaveManager and InterfaceManager) then
    warn("Failed to load required libraries")
    return
end

-- Create mobile interface if needed
local DeviceType = UserInputService.TouchEnabled and "Mobile" or "PC"
if DeviceType == "Mobile" then
    local ClickButton = Instance.new("ScreenGui")
    ClickButton.Name = "ClickButton"
    ClickButton.Parent = CoreGui
    ClickButton.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ClickButton
    MainFrame.AnchorPoint = Vector2.new(1, 0)
    MainFrame.BackgroundTransparency = 0.8
    MainFrame.BackgroundColor3 = Config.UI.MainColor
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(1, -60, 0, 10)
    MainFrame.Size = UDim2.new(0, 45, 0, 45)

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(1, 0)
    UICorner.Parent = MainFrame

    local TextButton = Instance.new("TextButton")
    TextButton.Parent = MainFrame
    TextButton.BackgroundTransparency = 1
    TextButton.Size = UDim2.new(1, 0, 1, 0)
    TextButton.Font = Enum.Font.SourceSans
    TextButton.Text = "Open"
    TextButton.TextColor3 = Config.UI.ButtonColor
    TextButton.TextSize = 20

    -- Safe click handler
    TextButton.MouseButton1Click:Connect(function()
        local VirtualInputManager = getService("VirtualInputManager")
        if VirtualInputManager then
            VirtualInputManager:SendKeyEvent(true, Config.UI.MinimizeKey, false, game)
            VirtualInputManager:SendKeyEvent(false, Config.UI.MinimizeKey, false, game)
        end
    end)
end

-- Export UI components
getgenv().Fluent = Fluent
getgenv().SaveManager = SaveManager
getgenv().InterfaceManager = InterfaceManager

-- Set the flag at the end of successful loading
getgenv().LucidHubLoaded = true

return true
