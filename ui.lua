-- ui.lua
-- Version: 1.0.1
-- Author: ProbTom
-- Created: 2024-12-20 19:34:00 UTC

local UI = {
    _VERSION = "1.0.1",
    _initialized = false,
    _windows = {}
}

-- Dependencies
local Debug
local Utils

-- Services
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

function UI.CreateWindow(config)
    local window = Instance.new("ScreenGui")
    window.Name = config.Title or "Lucid Window"
    Utils.ProtectGui(window)
    
    local main = Instance.new("Frame")
    main.Name = "Main"
    main.Size = config.Size or UDim2.new(0, 600, 0, 400)
    main.Position = config.Position or UDim2.new(0.5, -300, 0.5, -200)
    main.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    main.BorderSizePixel = 0
    main.Parent = window
    
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    title.BorderSizePixel = 0
    title.Text = config.Title
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 14
    title.Font = Enum.Font.GothamBold
    title.Parent = main
    
    -- Make window draggable
    local dragging = false
    local dragStart
    local startPos
    
    title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    table.insert(UI._windows, window)
    return window
end

function UI.CreateTab(window, config)
    local tab = Instance.new("Frame")
    tab.Name = config.Title
    tab.Size = UDim2.new(1, 0, 1, -30)
    tab.Position = UDim2.new(0, 0, 0, 30)
    tab.BackgroundTransparency = 1
    tab.Parent = window.Main
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 5)
    layout.Parent = tab
    
    return tab
end

function UI.CreateButton(tab, config)
    local button = Instance.new("TextButton")
    button.Name = config.Title
    button.Size = UDim2.new(1, -20, 0, 30)
    button.Position = UDim2.new(0, 10, 0, 0)
    button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    button.BorderSizePixel = 0
    button.Text = config.Title
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 14
    button.Font = Enum.Font.Gotham
    button.Parent = tab
    
    button.MouseButton1Click:Connect(function()
        Utils.SafeCall(config.Callback)
    end)
    
    return button
end

function UI.CreateToggle(tab, config)
    local toggle = Instance.new("Frame")
    toggle.Name = config.Title
    toggle.Size = UDim2.new(1, -20, 0, 30)
    toggle.Position = UDim2.new(0, 10, 0, 0)
    toggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    toggle.BorderSizePixel = 0
    toggle.Parent = tab
    
    local button = Instance.new("TextButton")
    button.Name = "Toggle"
    button.Size = UDim2.new(0, 30, 0, 30)
    button.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    button.BorderSizePixel = 0
    button.Text = ""
    button.Parent = toggle
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -40, 1, 0)
    label.Position = UDim2.new(0, 40, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = config.Title
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = toggle
    
    local enabled = config.Default or false
    button.BackgroundColor3 = enabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    
    button.MouseButton1Click:Connect(function()
        enabled = not enabled
        button.BackgroundColor3 = enabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        Utils.SafeCall(config.Callback, enabled)
    end)
    
    return toggle
end

function UI.Notify(config)
    local notification = Instance.new("ScreenGui")
    notification.Name = "Notification"
    Utils.ProtectGui(notification)
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 250, 0, 60)
    frame.Position = UDim2.new(1, -270, 1, -80)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    frame.BorderSizePixel = 0
    frame.Parent = notification
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 20)
    title.BackgroundTransparency = 1
    title.Text = config.Title
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 14
    title.Font = Enum.Font.GothamBold
    title.Parent = frame
    
    local content = Instance.new("TextLabel")
    content.Size = UDim2.new(1, 0, 1, -20)
    content.Position = UDim2.new(0, 0, 0, 20)
    content.BackgroundTransparency = 1
    content.Text = config.Content
    content.TextColor3 = Color3.fromRGB(200, 200, 200)
    content.TextSize = 12
    content.Font = Enum.Font.Gotham
    content.Parent = frame
    
    frame:TweenPosition(
        UDim2.new(1, -270, 1, -80),
        Enum.EasingDirection.Out,
        Enum.EasingStyle.Quad,
        0.3,
        true
    )
    
    task.delay(config.Duration or 3, function()
        frame:TweenPosition(
            UDim2.new(1, 20, 1, -80),
            Enum.EasingDirection.Out,
            Enum.EasingStyle.Quad,
            0.3,
            true,
            function()
                notification:Destroy()
            end
        )
    end)
end

function UI.CloseAll()
    for _, window in ipairs(UI._windows) do
        window:Destroy()
    end
    UI._windows = {}
end

function UI.init(modules)
    if UI._initialized then
        return true
    end
    
    Debug = modules.debug
    Utils = modules.utils
    
    UI._initialized = true
    Debug.Info("UI module initialized")
    return true
end

return UI
