local RunService = game:GetService("RunService")
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
    if autoCast.Value then
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
    if autoShake.Value then
        RunService:BindToRenderStep("AutoShake", 1, function()
            if LocalPlayer.PlayerGui then
                Functions.autoShake(LocalPlayer.PlayerGui)
            end
        end)
    else
        RunService:UnbindFromRenderStep("AutoShake")
    end
end)

-- Auto Reel Toggle
local autoReel = Tabs.Main:AddToggle("autoReel", {Title = "Auto Reel", Default = false})
autoReel:OnChanged(function()
    if autoReel.Value then
        RunService:BindToRenderStep("AutoReel", 1, function()
            if LocalPlayer.PlayerGui then
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
