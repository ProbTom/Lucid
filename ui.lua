-- ui.lua
-- Version: 1.0.1
-- Author: ProbTom
-- Created: 2024-12-20 19:32:24 UTC

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

-- Constants
local COLORS = {
    BACKGROUND = Color3.fromRGB(30, 30, 30),
    HEADER = Color3.fromRGB(40, 40, 40),
    BUTTON = Color3.fromRGB(50, 50, 50),
    TEXT = Color3.fromRGB(255, 255, 255),
    TOGGLE_ON = Color3.fromRGB(0, 255, 0),
    TOGGLE_OFF = Color3.fromRGB(255, 0, 0)
}

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

function UI.CreateWindow(config)
    assert(type(config) == "table", "Config must be a table")
    
    local window = Instance.new("ScreenGui")
    window.Name = config.Title or "Lucid"
    Utils.ProtectGui(window)
    
    local main = Instance.new("Frame")
    main.Name = "Main"
    main.Size = config.Size or UDim2.new(0, 600, 0, 400)
    main.Position = config.Position or UDim2.new(0.5, -300, 0.5, -200)
    main.BackgroundColor3 = COLORS.BACKGROUND
    main.BorderSizePixel = 0
    main.Parent = window
    
    -- Make corners rounded
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = main
    
    -- Add header
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 30)
    header.BackgroundColor3 = COLORS.HEADER
    header.BorderSizePixel = 0
    header.Parent = main
    
    -- Round header corners
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 8)
    headerCorner.Parent = header
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Text = config.Title
    title.Size = UDim2.new(1, -10, 1, 0)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.BackgroundTransparency = 1
    title.TextColor3 = COLORS.TEXT
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.Parent = header
    
    -- Make window draggable
    local dragging = false
    local dragStart
    local startPos
    
    header.InputBegan:Connect(function(input)
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
    
    -- Content container
    local container = Instance.new("Frame")
    container.Name = "Container"
    container.Size = UDim2.new(1, 0, 1, -30)
    container.Position = UDim2.new(0, 0, 0, 30)
    container.BackgroundTransparency = 1
    container.Parent = main
    
    -- Store window
    table.insert(UI._windows, window)
    
    return container
end

function UI.CreateTab(parent, config)
    assert(parent, "Parent is required")
    assert(type(config) == "table", "Config must be a table")
    
    local tab = Instance.new("ScrollingFrame")
    tab.Name = config.Title or "Tab"
    tab.Size = UDim2.new(1, -20, 1, -10)
    tab.Position = UDim2.new(0, 10, 0, 5)
    tab.BackgroundTransparency = 1
    tab.BorderSizePixel = 0
    tab.ScrollBarThickness = 4
    tab.ScrollingDirection = Enum.ScrollingDirection.Y
    tab.AutomaticCanvasSize = Enum.AutomaticSize.Y
    tab.Parent = parent
    
    -- Layout
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 5)
    layout.Parent = tab
    
    return tab
end

function UI.CreateButton(parent, config)
    assert(parent, "Parent is required")
    assert(type(config) == "table", "Config must be a table")
    
    local button = Instance.new("TextButton")
    button.Name = config.Title or "Button"
    button.Size = UDim2.new(1, 0, 0, 35)
    button.BackgroundColor3 = COLORS.BUTTON
    button.BorderSizePixel = 0
    button.Text = config.Title or "Button"
    button.TextColor3 = COLORS.TEXT
    button.Font = Enum.Font.Gotham
    button.TextSize = 14
    button.Parent = parent
    
    -- Round corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = button
    
    -- Hover effect
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        }):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = COLORS.BUTTON
        }):Play()
    end)
    
    -- Click callback
    if config.Callback then
        button.MouseButton1Click:Connect(function()
            Utils.SafeCall(config.Callback)
        end)
    end
    
    return button
end

function UI.CreateToggle(parent, config)
    assert(parent, "Parent is required")
    assert(type(config) == "table", "Config must be a table")
    
    local container = Instance.new("Frame")
    container.Name = config.Title or "Toggle"
    container.Size = UDim2.new(1, 0, 0, 35)
    container.BackgroundColor3 = COLORS.BUTTON
    container.BorderSizePixel = 0
    container.Parent = parent
    
    -- Round corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = container
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Text = config.Title or "Toggle"
    title.Size = UDim2.new(1, -60, 1, 0)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.BackgroundTransparency = 1
    title.TextColor3 = COLORS.TEXT
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Font = Enum.Font.Gotham
    title.TextSize = 14
    title.Parent = container
    
    -- Toggle button
    local toggle = Instance.new("TextButton")
    toggle.Name = "Toggle"
    toggle.Size = UDim2.new(0, 40, 0, 20)
    toggle.Position = UDim2.new(1, -50, 0.5, -10)
    toggle.BackgroundColor3 = config.Default and COLORS.TOGGLE_ON or COLORS.TOGGLE_OFF
    toggle.BorderSizePixel = 0
    toggle.Text = ""
    toggle.Parent = container
    
    -- Round toggle corners
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 10)
    toggleCorner.Parent = toggle
    
    -- State
    local enabled = config.Default or false
    
    -- Click handler
    toggle.MouseButton1Click:Connect(function()
        enabled = not enabled
        TweenService:Create(toggle, TweenInfo.new(0.2), {
            BackgroundColor3 = enabled and COLORS.TOGGLE_ON or COLORS.TOGGLE_OFF
        }):Play()
        
        if config.Callback then
            Utils.SafeCall(config.Callback, enabled)
        end
    end)
    
    return container
end

function UI.Notify(config)
    assert(type(config) == "table", "Config must be a table")
    
    local notification = Instance.new("ScreenGui")
    notification.Name = "Notification"
    Utils.ProtectGui(notification)
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 250, 0, 60)
    frame.Position = UDim2.new(1, 20, 1, -70)
    frame.BackgroundColor3 = COLORS.BACKGROUND
    frame.BorderSizePixel = 0
    frame.Parent = notification
    
    -- Round corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Text = config.Title or "Notification"
    title.Size = UDim2.new(1, -20, 0, 25)
    title.Position = UDim2.new(0, 10, 0, 5)
    title.BackgroundTransparency = 1
    title.TextColor3 = COLORS.TEXT
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.Parent = frame
    
    -- Content
    local content = Instance.new("TextLabel")
    content.Name = "Content"
    content.Text = config.Content or ""
    content.Size = UDim2.new(1, -20, 0, 20)
    content.Position = UDim2.new(0, 10, 0, 30)
    content.BackgroundTransparency = 1
    content.TextColor3 = COLORS.TEXT
    content.TextXAlignment = Enum.TextXAlignment.Left
    content.Font = Enum.Font.Gotham
    content.TextSize = 12
    content.Parent = frame
    
    -- Animation
    frame:TweenPosition(
        UDim2.new(1, -270, 1, -70),
        Enum.EasingDirection.Out,
        Enum.EasingStyle.Quart,
        0.4,
        true
    )
    
    -- Auto-remove
    task.delay(config.Duration or 3, function()
        frame:TweenPosition(
            UDim2.new(1, 20, 1, -70),
            Enum.EasingDirection.In,
            Enum.EasingStyle.Quart,
            0.4,
            true,
            function()
                notification:Destroy()
            end
        )
    end)
end

function UI.CloseAll()
    for _, window in ipairs(UI._windows) do
        pcall(function()
            window:Destroy()
        end)
    end
    UI._windows = {}
end

return UI
