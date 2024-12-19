-- Check for multiple executions
if getgenv().cuppink then
    warn("Lucid Hub: Already executed!")
    return
end
getgenv().cuppink = true

-- Check for required globals
if not getgenv().Tabs then
    warn("Tabs not found in global environment")
    return
end

if not getgenv().Fluent then
    warn("Fluent UI not found in global environment")
    return
end

-- Get required services with error handling
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

-- Initialize required services
local Players = getService("Players")
local RunService = getService("RunService")
local VirtualUser = getService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

if not LocalPlayer then
    warn("LocalPlayer not found")
    return
end

-- Load Functions module
local Functions = loadstring(game:HttpGet("https://raw.githubusercontent.com/ProbTom/Lucid/main/functions.lua"))()

local FishingZonesFolder = workspace:WaitForChild("zones"):WaitForChild("fishing")

-- Initialize state variables
local CastMode = "Legit"
local ShakeMode = "Navigation"
local ReelMode = "Blatant"
local Zone = nil

-- Main Section
local mainSection = Tabs.Main:AddSection("Auto Fishing")

-- Auto Cast Toggle
local autoCast = Tabs.Main:AddToggle("autoCast", {Title = "Auto Cast", Default = false})
autoCast:OnChanged(function()
    if Options.autoCast.Value then
        RunService:BindToRenderStep("AutoCast", 1, function()
            if LocalPlayer.Character then
                Functions.autoCast(CastMode, LocalPlayer.Character, LocalPlayer.Character:FindFirstChild("HumanoidRootPart"))
            end
        end)
    else
        RunService:UnbindFromRenderStep("AutoCast")
    end
end)

-- Auto Shake Toggle
local autoShake = Tabs.Main:AddToggle("autoShake", {Title = "Auto Shake", Default = false})
autoShake:OnChanged(function()
    if Options.autoShake.Value then
        RunService:BindToRenderStep("AutoShake", 1, function()
            pcall(function()
                if LocalPlayer.PlayerGui:FindFirstChild("shakeui") and 
                   LocalPlayer.PlayerGui.shakeui.Enabled then
                    -- Direct method
                    LocalPlayer.PlayerGui.shakeui.safezone.button.Size = UDim2.new(1001, 0, 1001, 0)
                    VirtualUser:Button1Down(Vector2.new(1, 1))
                    VirtualUser:Button1Up(Vector2.new(1, 1))
                    
                    -- Functions module method
                    Functions.autoShake(ShakeMode, LocalPlayer.PlayerGui)
                end
            end)
