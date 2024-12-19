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
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")

-- Cache MainTab reference
local MainTab = getgenv().Tabs.Main

-- Create main section
local mainSection = MainTab:AddSection("Auto Fishing")

-- Auto Reel Toggle (First)
local autoReel = MainTab:AddToggle("autoReel", {
    Title = "Auto Reel",
    Default = false
})

local lastReelTime = 0
local REEL_COOLDOWN = 0.05  -- Reduced cooldown for faster response
local reelEvent = ReplicatedStorage:WaitForChild("events"):WaitForChild("reelfinished")

autoReel:OnChanged(function()
    pcall(function()
        if autoReel.Value then
            RunService:BindToRenderStep("AutoReel", Enum.RenderPriority.First.Value, function()
                if LocalPlayer.PlayerGui and tick() - lastReelTime > REEL_COOLDOWN then
                    -- Check if we have a rod equipped
                    local rodName = ReplicatedStorage.playerstats[LocalPlayer.Name].Stats.rod.Value
                    local rod = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild(rodName)
                    
                    if rod and rod.values and not rod.values.casting.Value then
                        -- Original auto reel function
                        Functions.autoReel(LocalPlayer.PlayerGui)
                        
                        -- Fire reel finish event
                        task.spawn(function()
                            pcall(function()
                                reelEvent:FireServer(100, true)
                            end)
                        end)
                        
                        lastReelTime = tick()
                    end
                end
            end)
        else
            RunService:UnbindFromRenderStep("AutoReel")
        end
    end)
end)

-- Auto Shake Toggle (Second)
local autoShake = MainTab:AddToggle("autoShake", {
    Title = "Auto Shake",
    Default = false
})

local lastShakeClick = 0
local lureGui = nil
local SHAKE_COOLDOWN = 0.05

local function ExportValue(arg1, arg2)
    return tonumber(string.format("%."..(arg2 or 1)..'f', arg1))
end

autoShake:OnChanged(function()
    pcall(function()
        if autoShake.Value then
            -- Create lure percentage GUI
            if not lureGui then
                lureGui = ReplicatedStorage.resources.items.items.GPS.GPS.gpsMain.xyz:Clone()
                lureGui.Parent = LocalPlayer.PlayerGui:WaitForChild("hud"):WaitForChild("safezone"):WaitForChild("backpack")
                lureGui.Name = "Lure"
                lureGui.Text = "<font color='#ff4949'>Lure </font>: 0%"
            end

            RunService:BindToRenderStep("AutoShake", Enum.RenderPriority.First.Value, function()
                if LocalPlayer.PlayerGui and tick() - lastShakeClick > SHAKE_COOLDOWN then
                    -- Update lure percentage
                    local rodName = ReplicatedStorage.playerstats[LocalPlayer.Name].Stats.rod.Value
                    local rod = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild(rodName)
                    if rod and rod.values.lure then
                        lureGui.Text = "<font color='#ff4949'>Lure </font>: "..tostring(ExportValue(tostring(rod.values.lure.Value), 2)).."%"
                    end

                    local shakeui = LocalPlayer.PlayerGui:FindFirstChild("shakeui")
                    if shakeui and shakeui.Enabled then
                        local button = shakeui.safezone:FindFirstChild("button")
                        if button and button.Visible then
                            button.Size = UDim2.new(1001, 0, 1001, 0)
                            lastShakeClick = tick()
                            VirtualUser:Button1Down(Vector2.new(1, 1))
                            task.spawn(function()
                                task.wait(0.01)
                                VirtualUser:Button1Up(Vector2.new(1, 1))
                            end)
                        end
                    end
                end
            end)
        else
            RunService:UnbindFromRenderStep("AutoShake")
            if lureGui then
                lureGui:Destroy()
                lureGui = nil
            end
        end
    end)
end)

-- Auto Cast Toggle (Last)
local autoCast = MainTab:AddToggle("autoCast", {
    Title = "Auto Cast",
    Default = false
})

autoCast:OnChanged(function()
    pcall(function()
        if autoCast.Value then
            RunService:BindToRenderStep("AutoCast", 1, function()
                if LocalPlayer.Character then
                    Functions.autoCast(
                        LocalPlayer.Character, 
                        LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    )
                end
            end)
        else
            RunService:UnbindFromRenderStep("AutoCast")
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

        if lureGui then
            lureGui:Destroy()
            lureGui = nil
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
