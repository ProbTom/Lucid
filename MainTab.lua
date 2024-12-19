local function waitForDependency(name, path)
    local startTime = tick()
    while not (getgenv()[name] and (not path or path(getgenv()[name]))) do
        if tick() - startTime > 10 then
            error(string.format("Failed to load dependency: %s after 10 seconds", name))
            return false
        end
        task.wait(0.1)
    end
    return true
end

-- Wait for critical dependencies
if not waitForDependency("Tabs", function(t) return t.Main end) then return false end
if not waitForDependency("Functions") then return false end
if not waitForDependency("Options") then return false end

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Cache MainTab reference
local MainTab = getgenv().Tabs.Main

-- Create main section
local mainSection = MainTab:AddSection("Auto Fishing")

-- Auto Cast Toggle
local autoCast = MainTab:AddToggle("autoCast", {
    Title = "Auto Cast",
    Default = false
})

autoCast:OnChanged(function()
    pcall(function()
        if autoCast.Value then
            RunService:BindToRenderStep("AutoCast", 1, function()
                if LocalPlayer.Character then
                    Functions.autoCast(LocalPlayer.Character, 
                        LocalPlayer.Character:FindFirstChild("HumanoidRootPart"))
                end
            end)
        else
            RunService:UnbindFromRenderStep("AutoCast")
        end
    end)
end)

-- Auto Shake Toggle
local autoShake = MainTab:AddToggle("autoShake", {
    Title = "Auto Shake",
    Default = false
})

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
local autoReel = MainTab:AddToggle("autoReel", {
    Title = "Auto Reel",
    Default = false
})

autoReel:OnChanged(function()
    pcall(function()
        if autoReel.Value then
            RunService:BindToRenderStep("AutoReel", 1, function()
                if LocalPlayer.PlayerGui then
                    Functions.autoReel(LocalPlayer.PlayerGui)
                end
            end)
        else
            RunService:UnbindFromRenderStep("AutoReel")
        end
    end)
end)

-- Add cleanup handler
local function cleanupTab()
    pcall(function()
        RunService:UnbindFromRenderStep("AutoCast")
        RunService:UnbindFromRenderStep("AutoShake")
        RunService:UnbindFromRenderStep("AutoReel")
        
        -- Reset toggles
        if autoCast then autoCast:SetValue(false) end
        if autoShake then autoShake:SetValue(false) end
        if autoReel then autoReel:SetValue(false) end
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
