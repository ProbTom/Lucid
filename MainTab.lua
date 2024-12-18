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
if getgenv().cuppink then
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
local VirtualInputManager = getService("VirtualInputManager")
local ReplicatedStorage = getService("ReplicatedStorage")
local VirtualUser = getService("VirtualUser")
local GuiService = getService("GuiService")
local RunService = getService("RunService")
local Workspace = getService("Workspace")
local Players = getService("Players")
local CoreGui = getService("StarterGui")
local UserInputService = getService("UserInputService")

-- Safe local variables
local LocalPlayer = Players.LocalPlayer
local LocalCharacter = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = LocalCharacter:FindFirstChild("HumanoidRootPart")
local Config = getgenv().Config or require(script.Parent.config)

-- Safe wait for child function
local function safeWaitForChild(parent, childName, timeout)
    local child = parent:WaitForChild(childName, timeout or 5)
    if not child then
        warn("Failed to find child: " .. childName)
        return nil
    end
    return child
end

-- Initialize workspace folders safely
local UserPlayer = HumanoidRootPart and safeWaitForChild(HumanoidRootPart, "user")
local ActiveFolder = Workspace:FindFirstChild("active")
local FishingZonesFolder = Workspace:FindFirstChild("zones") and safeWaitForChild(Workspace.zones, "fishing")
local TpSpotsFolder = Workspace:FindFirstChild("world") and 
                      safeWaitForChild(Workspace.world, "spawns") and 
                      safeWaitForChild(Workspace.world.spawns, "TpSpots")
local NpcFolder = Workspace:FindFirstChild("world") and safeWaitForChild(Workspace.world, "npcs")

-- Initialize PlayerGui elements safely
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local screenGui = Instance.new("ScreenGui", PlayerGui)
local shadowCountLabel = Instance.new("TextLabel", screenGui)

-- Initialize variables
local CastMode = "Legit"
local ShakeMode = "Navigation"
local ReelMode = "Blatant"
local CollectMode = "Teleports"
local teleportSpots = {}
local FreezeChar = false
local AutoFreeze = false
local ZoneCast = false
local Zone = nil

-- Get available fishing zones
local function getAvailableZones()
    local zones = {}
    if FishingZonesFolder then
        for _, zone in ipairs(FishingZonesFolder:GetChildren()) do
            table.insert(zones, zone.Name)
        end
    end
    return zones
end

-- Safe notification function
function ShowNotification(String)
    pcall(function()
        Fluent:Notify({
            Title = "Lucid Hub",
            Content = String,
            Duration = 5
        })
    end)
end

-- Anti-AFK
LocalPlayer.Idled:Connect(function()
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end)

-- Safe AFK event firing
spawn(function()
    while true do
        pcall(function()
            local afkEvent = ReplicatedStorage:WaitForChild("events"):WaitForChild("afk")
            if afkEvent then
                afkEvent:FireServer(false)
            end
        end)
        task.wait(0.01)
    end
end)

-- Auto Shake Control Functions
function startAutoShake()
    if not autoShakeConnection then
        autoShakeConnection = RunService.RenderStepped:Connect(function()
            if autoShakeEnabled then
                autoShake()
            end
        end)
    end
end

function stopAutoShake()
    if autoShakeConnection then
        autoShakeConnection:Disconnect()
        autoShakeConnection = nil
    end
end

-- Auto Reel Control Functions
function startAutoReel()
    if not autoReelConnection then
        autoReelConnection = RunService.RenderStepped:Connect(function()
            if autoReelEnabled then
                autoReel()
            end
        end)
    end
end

function stopAutoReel()
    if autoReelConnection then
        autoReelConnection:Disconnect()
        autoReelConnection = nil
    end
end

-- Zone Cast Functionality
function handleZoneCast()
    if ZoneCast and Zone then
        local fishingSpot = FishingZonesFolder and FishingZonesFolder:FindFirstChild(Zone)
        if fishingSpot then
            local spotCFrame = fishingSpot.CFrame
            local targetPosition = spotCFrame.Position + Vector3.new(0, 2, 0)
            if HumanoidRootPart then
                HumanoidRootPart.CFrame = CFrame.new(HumanoidRootPart.Position, targetPosition)
            end
        end
    end
end

-- Auto Cast Function with ZoneCast support
local function autoCast()
    pcall(function()
        if ZoneCast then
            handleZoneCast()
        end
        
        if LocalCharacter then
            local tool = LocalCharacter:FindFirstChildOfClass("Tool")
            if tool then
                local hasBobber = tool:FindFirstChild("bobber")
                if not hasBobber then
                    if CastMode == "Legit" then
                        if VirtualInputManager then
                            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, LocalPlayer, 0)
                            
                            local powerBarConnection
                            powerBarConnection = HumanoidRootPart.ChildAdded:Connect(function()
                                if HumanoidRootPart:FindFirstChild("power") and 
                                   HumanoidRootPart.power:FindFirstChild("powerbar") and 
                                   HumanoidRootPart.power.powerbar:FindFirstChild("bar") then
                                    HumanoidRootPart.power.powerbar.bar.Changed:Connect(function(property)
                                        if property == "Size" and 
                                           HumanoidRootPart.power.powerbar.bar.Size == UDim2.new(1, 0, 1, 0) then
                                            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, LocalPlayer, 0)
                                            if powerBarConnection then
                                                powerBarConnection:Disconnect()
                                            end
                                        end
                                    end)
                                end
                            end)
                        end
                    elseif CastMode == "Blatant" then
                        local rod = LocalCharacter:FindFirstChildOfClass("Tool")
                        if rod and rod:FindFirstChild("values") and string.find(rod.Name, "Rod") then
                            task.wait(0.5)
                            local Random = math.random(90, 99)
                            pcall(function()
                                rod.events.cast:FireServer(Random)
                            end)
                        end
                    end
                end
            end
        end
    end)
    task.wait(0.5)
end

-- Auto Shake Function
function autoShake()
    if ShakeMode == "Navigation" then
        pcall(function()
            local shakeui = PlayerGui:FindFirstChild("shakeui")
            if shakeui then
                local safezone = shakeui:FindFirstChild("safezone")
                local button = safezone and safezone:FindFirstChild("button")
                if button and GuiService then
                    task.wait(0.2)
                    GuiService.SelectedObject = button
                    if GuiService.SelectedObject == button then
                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
                    end
                    task.wait(0.1)
                    GuiService.SelectedObject = nil
                end
            end
        end)
    elseif ShakeMode == "Mouse" then
        pcall(function()
            local shakeui = PlayerGui:FindFirstChild("shakeui")
            if shakeui then
                local safezone = shakeui:FindFirstChild("safezone")
                local button = safezone and safezone:FindFirstChild("button")
                if button then
                    local pos = button.AbsolutePosition
                    local size = button.AbsoluteSize
                    VirtualInputManager:SendMouseButtonEvent(
                        pos.X + size.X / 2,
                        pos.Y + size.Y / 2,
                        0, true, game, 0
                    )
                    VirtualInputManager:SendMouseButtonEvent(
                        pos.X + size.X / 2,
                        pos.Y + size.Y / 2,
                        0, false, game, 0
                    )
                end
            end
        end)
    end
end

-- Auto Reel Function
function autoReel()
    pcall(function()
        local reel = PlayerGui:FindFirstChild("reel")
        if reel then
            local bar = reel:FindFirstChild("bar")
            local playerbar = bar and bar:FindFirstChild("playerbar")
            local fish = bar and bar:FindFirstChild("fish")
            if playerbar and fish then
                playerbar.Position = fish.Position
            end
        end
    end)
end

function WaitForSomeone(signal)
    if typeof(signal) == "RBXScriptSignal" then
        signal:Wait()
        return true
    end
    return false
end

-- UI Setup
local section = Tabs.Main:AddSection("Auto Fishing")

local autoCast = Tabs.Main:AddToggle("autoCast", {Title = "Auto Cast", Default = false })
autoCast:OnChanged(function()
    local RodName = ReplicatedStorage.playerstats[LocalPlayer.Name].Stats.rod.Value
    if Options.autoCast.Value == true then
        autoCastEnabled = true
        if LocalPlayer.Backpack:FindFirstChild(RodName) then
            LocalPlayer.Character.Humanoid:EquipTool(LocalPlayer.Backpack:FindFirstChild(RodName))
        end
        if LocalCharacter then
            autoCast()
        end
    else
        autoCastEnabled = false
    end
end)

local autoShake = Tabs.Main:AddToggle("autoShake", {Title = "Auto Shake", Default = false })
autoShake:OnChanged(function()
    if Options.autoShake.Value == true then
        autoShakeEnabled = true
        startAutoShake()
    else
        autoShakeEnabled = false
        stopAutoShake()
    end
end)

local autoReel = Tabs.Main:AddToggle("autoReel", {Title = "Auto Reel", Default = false })
autoReel:OnChanged(function()
    if Options.autoReel.Value == true then
        autoReelEnabled = true
        startAutoReel()
    else
        autoReelEnabled = false
        stopAutoReel()
    end
end)

local FreezeCharacter = Tabs.Main:AddToggle("FreezeCharacter", {Title = "Freeze Character", Default = false })
FreezeCharacter:OnChanged(function()
    local oldpos = HumanoidRootPart.CFrame
    FreezeChar = Options.FreezeCharacter.Value
    task.wait()
    while WaitForSomeone(RunService.RenderStepped) do
        if FreezeChar and HumanoidRootPart ~= nil then
            task.wait()
            HumanoidRootPart.CFrame = oldpos
        else
            break
        end
    end
end)

-- Mode Tab
local section = Tabs.Main:AddSection("Mode Fishing")
local autoCastMode = Tabs.Main:AddDropdown("autoCastMode", {
    Title = "Auto Cast Mode",
    Values = {"Legit", "Blatant"},
    Multi = false,
    Default = CastMode,
})
autoCastMode:OnChanged(function(Value)
    CastMode = Value
end)

local autoShakeMode = Tabs.Main:AddDropdown("autoShakeMode", {
    Title = "Auto Shake Mode",
    Values = {"Navigation", "Mouse"},
    Multi = false,
    Default = ShakeMode,
})
autoShakeMode:OnChanged(function(Value)
    ShakeMode = Value
end)

local autoReelMode = Tabs.Main:AddDropdown("autoReelMode", {
    Title = "Auto Reel Mode",
    Values = {"Legit", "Blatant"},
    Multi = false,
    Default = ReelMode,
})
autoReelMode:OnChanged(function(Value)
    ReelMode = Value
end)

-- Zone Settings
local section = Tabs.Main:AddSection("Zone Settings")
local zoneToggle = Tabs.Main:AddToggle("ZoneCast", {
    Title = "Zone Cast",
    Default = false
})

zoneToggle:OnChanged(function(Value)
    ZoneCast = Value
end)

local availableZones = getAvailableZones()
local zoneDropdown = Tabs.Main:AddDropdown("ZoneSelect", {
    Title = "Select Zone",
    Values = availableZones,
    Multi = false,
    Default = availableZones[1]
})

zoneDropdown:OnChanged(function(Value)
    Zone = Value
end)

-- Setup Connections
local function setupConnections()
    pcall(function()
        PlayerGui.DescendantAdded:Connect(function(descendant)
            if autoShakeEnabled and descendant.Name == "button" 
            and descendant.Parent and descendant.Parent.Name == "safezone" then
                startAutoShake()
            end
            
            if autoReelEnabled and descendant.Name == "playerbar" 
            and descendant.Parent and descendant.Parent.Name == "bar" then
                startAutoReel()
            end
        end)
        
        PlayerGui.DescendantRemoving:Connect(function(descendant)
            if descendant.Name == "playerbar" and descendant.Parent 
            and descendant.Parent.Name == "bar" then
                stopAutoReel()
                if autoCastEnabled then
                    task.wait(1)
                    autoCast()
                end
            end
        end)
    end)
end

setupConnections()

return true
