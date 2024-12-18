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
