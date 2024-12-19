-- Wait for game load
if not game:IsLoaded() then
    game.Loaded:Wait()
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

-- Get required services
local HttpService = getService("HttpService")
local UserInputService = getService("UserInputService")
local CoreGui = getService("CoreGui")

-- Clean up any existing UI
pcall(function()
    if CoreGui:FindFirstChild("ClickButton") then
        CoreGui:FindFirstChild("ClickButton"):Destroy()
    end
end)

-- Initialize globals with safe defaults
local Config = getgenv().Config or {
    UI = {
        MainColor = Color3.fromRGB(50, 50, 50),
        ButtonColor = Color3.fromRGB(255, 255, 255),
        MinimizeKey = Enum.KeyCode.LeftControl
    }
}
local Fluent = getgenv().Fluent

if not Fluent then
    warn("Fluent UI library not found")
    return
end

-- Create Fluent window
local Window = Fluent:CreateWindow({
    Title = "Lucid Hub",
    SubTitle = "by ProbTom",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark"
})

-- Initialize tabs
getgenv().Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "fish" })
}

-- Create mobile interface if needed
local DeviceType = UserInputService.TouchEnabled and "Mobile" or "PC"
if DeviceType == "Mobile" then
    pcall(function()
        local ClickButton = Instance.new("ScreenGui")
        ClickButton.Name = "ClickButton"
        ClickButton.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        
        -- Handle ResetOnSpawn
        ClickButton.ResetOnSpawn = false
        
        -- Parent the GUI safely
        pcall(function()
            ClickButton.Parent = CoreGui
        end)

        local MainFrame = Instance.new("Frame")
        MainFrame.Name = "MainFrame"
        MainFrame.Parent = ClickButton
        MainFrame.AnchorPoint = Vector2.new(1, 0)
        MainFrame.BackgroundTransparency = 0.8
        MainFrame.BackgroundColor3 = Config.UI.MainColor
        MainFrame.BorderSizePixel = 0
        MainFrame.Position = UDim2.new(1, -60, 0, 10)
        MainFrame.Size = UDim2.new(0, 45, 0, 45)
        
        -- Make the frame draggable
        local isDragging = false
        local dragStart = nil
        local startPos = nil

        MainFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                isDragging = true
                dragStart = input.Position
                startPos = MainFrame.Position
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if isDragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
                local delta = input.Position - dragStart
                MainFrame.Position = UDim2.new(
                    startPos.X.Scale,
                    startPos.X.Offset + delta.X,
                    startPos.Y.Scale,
                    startPos.Y.Offset + delta.Y
                )
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                isDragging = false
            end
        end)

        local UICorner = Instance.new("UICorner")
        UICorner.CornerRadius = UDim.new(1, 0)
        UICorner.Parent = MainFrame

        local TextButton = Instance.new("TextButton")
        TextButton.Parent = MainFrame
        TextButton.BackgroundTransparency = 1
        TextButton.Size = UDim2.new(1, 0, 1, 0)
        TextButton.Font = Enum.Font.SourceSansBold
        TextButton.Text = "Open"
        TextButton.TextColor3 = Config.UI.ButtonColor
        TextButton.TextSize = 20

        TextButton.MouseButton1Click:Connect(function()
            local VirtualInputManager = getService("VirtualInputManager")
            if VirtualInputManager then
                VirtualInputManager:SendKeyEvent(true, Config.UI.MinimizeKey, false, game)
                task.wait(0.1)
                VirtualInputManager:SendKeyEvent(false, Config.UI.MinimizeKey, false, game)
            end
        end)
    end)
end

-- Set minimize keybind
Window:SetValue("MinimizeKeybind", Config.UI.MinimizeKey)

-- Save window state
Window:OnClose(function()
    pcall(function()
        if getgenv().cleanup then
            getgenv().cleanup()
        end
    end)
end)

return true
