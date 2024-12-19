-- Check for required dependencies first
if not getgenv().Tabs or not getgenv().Tabs.Main then
    warn("Waiting for Tabs to initialize...")
    local startTime = tick()
    while not getgenv().Tabs or not getgenv().Tabs.Main do
        if tick() - startTime > 10 then
            error("Tabs failed to initialize after 10 seconds")
            return
        end
        task.wait(0.1)
    end
end

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Initialize Options table if it doesn't exist
if not getgenv().Options then
    getgenv().Options = {
        CastMode = { Value = "Legit" },
        ReelMode = { Value = "Blatant" },
        autoCast = { Value = false },
        autoShake = { Value = false },
        autoReel = { Value = false }
    }
end

-- Initialize state variables from Options
local CastMode = getgenv().Options.CastMode.Value
local ReelMode = getgenv().Options.ReelMode.Value

-- Ensure Functions table exists
if not getgenv().Functions then
    warn("Waiting for Functions to initialize...")
    local startTime = tick()
    while not getgenv().Functions do
        if tick() - startTime > 10 then
            error("Functions failed to initialize after 10 seconds")
            return
        end
        task.wait(0.1)
    end
end

-- Cache Tabs reference
local MainTab = getgenv().Tabs.Main

-- Main Section
local mainSection = MainTab:AddSection("Auto Fishing")

-- Auto Cast Toggle
local autoCast = MainTab:AddToggle("autoCast", {Title = "Auto Cast", Default = false})
autoCast:OnChanged(function()
    pcall(function()
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
end)

-- Auto Shake Toggle
local autoShake = MainTab:AddToggle("autoShake", {Title = "Auto Shake", Default = false})
autoShake:OnChanged(function()
    pcall(function()
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
end)

-- Auto Reel Toggle
local autoReel = MainTab:AddToggle("autoReel", {Title = "Auto Reel", Default = false})
autoReel:OnChanged(function()
    pcall(function()
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
end)

-- Cast Mode Dropdown
local castModeDropdown = MainTab:AddDropdown("CastMode", {
    Title = "Cast Mode",
    Values = {"Legit", "Blatant"},
    Multi = false,
    Default = CastMode
})

castModeDropdown:OnChanged(function(Value)
    CastMode = Value
    getgenv().Options.CastMode.Value = Value
end)

-- Reel Mode Dropdown
local reelModeDropdown = MainTab:AddDropdown("ReelMode", {
    Title = "Reel Mode",
    Values = {"Legit", "Blatant"},
    Multi = false,
    Default = ReelMode
})

reelModeDropdown:OnChanged(function(Value)
    ReelMode = Value
    getgenv().Options.ReelMode.Value = Value
end)

-- Cleanup handler
local function cleanupTab()
    pcall(function()
        RunService:UnbindFromRenderStep("AutoCast")
        RunService:UnbindFromRenderStep("AutoShake")
        RunService:UnbindFromRenderStep("AutoReel")
        
        -- Reset toggles
        if autoCast then autoCast:SetValue(false) end
        if autoShake then autoShake:SetValue(false) end
        if autoReel then autoReel:SetValue(false) end
        
        -- Save current modes
        if getgenv().Options then
            getgenv().Options.CastMode.Value = CastMode
            getgenv().Options.ReelMode.Value = ReelMode
        end
    end)
end

-- Add cleanup to global cleanup function
if getgenv().cleanup then
    local oldCleanup = getgenv().cleanup
    getgenv().cleanup = function()
        cleanupTab()
        oldCleanup()
    end
end

return true
