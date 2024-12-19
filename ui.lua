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
local Config = getgenv().Config
local Fluent = getgenv().Fluent

if not Fluent then
    warn("Fluent UI library not found")
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

-- Set the flag at the end of successful loading
getgenv().LucidHubLoaded = true

return true
