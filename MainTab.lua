local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Initialize state variables
local CastMode = "Legit"
local ReelMode = "Blatant"

-- Main Section
local mainSection = Tabs.Main:AddSection("Auto Fishing")

-- Auto Cast Toggle
local autoCast = Tabs.Main:AddToggle("autoCast", {Title = "Auto Cast", Default = false})
autoCast:OnChanged(function()
    Options.autoCast.Value = autoCast.Value
    if Options.autoCast.Value then
        if LocalPlayer.Character then
            Functions.autoCast(CastMode, LocalPlayer.Character, LocalPlayer.Character:FindFirstChild("HumanoidRootPart"))
        end
    end
end)

-- Auto Shake Toggle
local autoShake = Tabs.Main:AddToggle("autoShake", {Title = "Auto Shake", Default = false})
autoShake:OnChanged(function()
    Options.autoShake.Value = autoShake.Value
    if Options.autoShake.Value then
        if LocalPlayer.PlayerGui then
            pcall(function()
                if LocalPlayer.PlayerGui:FindFirstChild("shakeui") and 
                   LocalPlayer.PlayerGui.shakeui.Enabled then
                    LocalPlayer.PlayerGui.shakeui.safezone.button.Size = UDim2.new(1001, 0, 1001, 0)
                    VirtualUser:Button1Down(Vector2.new(1, 1))
                    task.wait(0.1)
                    VirtualUser:Button1Up(Vector2.new(1, 1))
                end
            end)
        end
    end
end)

-- Auto Reel Toggle
local autoReel = Tabs.Main:AddToggle("autoReel", {Title = "Auto Reel", Default = false})
autoReel:OnChanged(function()
    Options.autoReel.Value = autoReel.Value
    if Options.autoReel.Value then
        if LocalPlayer and LocalPlayer.PlayerGui then
            Functions.autoReel(LocalPlayer.PlayerGui, ReelMode)
        end
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

-- Set up auto-update loop
RunService.RenderStepped:Connect(function()
    if Options.autoCast.Value then
        if LocalPlayer.Character then
            Functions.autoCast(CastMode, LocalPlayer.Character, LocalPlayer.Character:FindFirstChild("HumanoidRootPart"))
        end
    end
    
    if Options.autoShake.Value then
        if LocalPlayer.PlayerGui then
            Functions.autoShake(LocalPlayer.PlayerGui)
        end
    end
    
    if Options.autoReel.Value then
        if LocalPlayer.PlayerGui then
            Functions.autoReel(LocalPlayer.PlayerGui, ReelMode)
        end
    end
end)

return true
