-- MainTab.lua
-- Complete implementation with all dependencies and error handling
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

-- Wait for critical dependencies with enhanced error handling
local function initializeDependencies()
    local dependencies = {
        { name = "Tabs", path = function(t) return t.Main end },
        { name = "Functions" },
        { name = "Options" }
    }

    for _, dep in ipairs(dependencies) do
        if not waitForDependency(dep.name, dep.path) then
            warn(string.format("Failed to initialize %s dependency", dep.name))
            return false
        end
    end
    return true
end

if not initializeDependencies() then return false end

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Cache MainTab reference
local MainTab = getgenv().Tabs.Main

-- Create main section
local mainSection = MainTab:AddSection("Auto Fishing")

-- Auto Cast Toggle with enhanced error handling
local autoCast = MainTab:AddToggle("autoCast", {
    Title = "Auto Cast",
    Default = false
})

autoCast:OnChanged(function()
    pcall(function()
        if autoCast.Value then
            RunService:BindToRenderStep("AutoCast", 1, function()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    Functions.autoCast(
                        "Legit",
                        LocalPlayer.Character, 
                        LocalPlayer.Character.HumanoidRootPart
                    )
                end
            end)
        else
            if RunService:IsStudio() or game:GetService("RunService"):IsRunning() then
                RunService:UnbindFromRenderStep("AutoCast")
            end
        end
    end)
end)

-- Auto Shake Toggle with enhanced error handling
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
            if RunService:IsStudio() or game:GetService("RunService"):IsRunning() then
                RunService:UnbindFromRenderStep("AutoShake")
            end
        end
    end)
end)

-- Auto Reel Toggle with enhanced error handling
local autoReel = MainTab:AddToggle("autoReel", {
    Title = "Auto Reel",
    Default = false
})

autoReel:OnChanged(function()
    pcall(function()
        if autoReel.Value then
            RunService:BindToRenderStep("AutoReel", 1, function()
                if LocalPlayer.PlayerGui then
                    Functions.autoReel(LocalPlayer.PlayerGui, "Legit")
                end
            end)
        else
            if RunService:IsStudio() or game:GetService("RunService"):IsRunning() then
                RunService:UnbindFromRenderStep("AutoReel")
            end
        end
    end)
end)

-- Enhanced cleanup handler with error checking
local function cleanupTab()
    pcall(function()
        -- Ensure RunService is available
        if RunService:IsStudio() or game:GetService("RunService"):IsRunning() then
            RunService:UnbindFromRenderStep("AutoCast")
            RunService:UnbindFromRenderStep("AutoShake")
            RunService:UnbindFromRenderStep("AutoReel")
        end
        
        -- Reset toggles with nil checks
        if autoCast and type(autoCast.SetValue) == "function" then 
            autoCast:SetValue(false) 
        end
        if autoShake and type(autoShake.SetValue) == "function" then 
            autoShake:SetValue(false) 
        end
        if autoReel and type(autoReel.SetValue) == "function" then 
            autoReel:SetValue(false) 
        end
    end)
end

-- Add cleanup to global cleanup function with existing handler preservation
if getgenv().cleanup then
    local oldCleanup = getgenv().cleanup
    getgenv().cleanup = function()
        cleanupTab()
        oldCleanup()
    end
else
    getgenv().cleanup = cleanupTab
end

return true
