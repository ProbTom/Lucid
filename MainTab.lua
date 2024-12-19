-- Check for multiple executions
if getgenv().cuppink then
    warn("Lucid Hub: Already executed!")
    return
end
getgenv().cuppink = true

-- Initialize state variables
local CastMode = "Legit"
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

-- Auto Shake Toggle with fixed functionality
local autoShake = Tabs.Main:AddToggle("autoShake", {Title = "Auto Shake", Default = false})
autoShake:OnChanged(function()
    if Options.autoShake.Value then
        RunService:BindToRenderStep("AutoShake", 1, function()
            pcall(function()
                if LocalPlayer.PlayerGui:FindFirstChild("shakeui") and 
                   LocalPlayer.PlayerGui.shakeui.Enabled then
                    LocalPlayer.PlayerGui.shakeui.safezone.button.Size = UDim2.new(1001, 0, 1001, 0)
                    VirtualUser:Button1Down(Vector2.new(1, 1))
                    task.wait(0.1)
                    VirtualUser:Button1Up(Vector2.new(1, 1))
                end
            end)
        end)
    else
        RunService:UnbindFromRenderStep("AutoShake")
    end
end)

-- Auto Reel Toggle
local autoReel = Tabs.Main:AddToggle("autoReel", {Title = "Auto Reel", Default = false})
autoReel:OnChanged(function()
    if Options.autoReel.Value then
        RunService:BindToRenderStep("AutoReel", 1, function()
            if LocalPlayer and LocalPlayer.PlayerGui then
                Functions.autoReel(LocalPlayer.PlayerGui, ReelMode)
            end
        end)
    else
        RunService:UnbindFromRenderStep("AutoReel")
    end
end)

-- Cast Mode Dropdown
local castModeDropdown = Tabs.Main:AddDropdown("CastMode", {
    Title = "Cast Mode",
    Values = {"Legit", "Blatant"},
    Multi = false,
    Default = CastMode
})
castModeDropdown:OnChanged(function(Value)
    CastMode = Value
end)

-- Reel Mode Dropdown
local reelModeDropdown = Tabs.Main:AddDropdown("ReelMode", {
    Title = "Reel Mode",
    Values = {"Legit", "Blatant"},
    Multi = false,
    Default = ReelMode
})
reelModeDropdown:OnChanged(function(Value)
    ReelMode = Value
end)

return true
