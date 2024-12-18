-- Ensure required services and variables are correctly initialized
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Debugging to check if variables are correctly initialized
print("ReplicatedStorage:", ReplicatedStorage)
print("Players:", Players)
print("LocalPlayer:", LocalPlayer)

-- Check if LocalPlayer is loaded
if not LocalPlayer then
    Players.PlayerAdded:Wait()
    LocalPlayer = Players.LocalPlayer
end

-- Debugging to check if playerstats is accessible
local playerStats = ReplicatedStorage:FindFirstChild("playerstats")
if not playerStats then
    warn("playerstats not found in ReplicatedStorage")
else
    print("playerstats found in ReplicatedStorage")
end

-- // Main Tab // --
local section = Tabs.Main:AddSection("Auto Fishing")
local autoCast = Tabs.Main:AddToggle("autoCast", {Title = "Auto Cast", Default = false })
autoCast:OnChanged(function()
    local playerStats = ReplicatedStorage:FindFirstChild("playerstats")
    if playerStats and playerStats:FindFirstChild(LocalPlayer.Name) then
        local RodName = playerStats[LocalPlayer.Name].Stats.rod.Value
        if Options.autoCast.Value == true then
            autoCastEnabled = true
            if LocalPlayer.Backpack:FindFirstChild(RodName) then
                LocalPlayer.Character.Humanoid:EquipTool(LocalPlayer.Backpack:FindFirstChild(RodName))
            end
            if LocalPlayer.Character then
                local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
                if tool then
                    local hasBobber = tool:FindFirstChild("bobber")
                    if not hasBobber then
                        if CastMode == "Legit" then
                            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, LocalPlayer, 0)
                            LocalPlayer.Character.HumanoidRootPart.ChildAdded:Connect(function()
                                if LocalPlayer.Character.HumanoidRootPart:FindFirstChild("power") ~= nil and LocalPlayer.Character.HumanoidRootPart.power.powerbar.bar ~= nil then
                                    LocalPlayer.Character.HumanoidRootPart.power.powerbar.bar.Changed:Connect(function(property)
                                        if property == "Size" then
                                            if LocalPlayer.Character.HumanoidRootPart.power.powerbar.bar.Size == UDim2.new(1, 0, 1, 0) then
                                                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, LocalPlayer, 0)
                                            end
                                        end
                                    end)
                                end
                            end)
                        elseif CastMode == "Blatant" then
                            local rod = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
                            if rod and rod:FindFirstChild("values") and string.find(rod.Name, "Rod") then
                                task.wait(0.5)
                                local Random = math.random(90, 99)
                                rod.events.cast:FireServer(Random)
                            end
                        end
                    end
                end
                task.wait(1)
            end
        else
            autoCastEnabled = false
        end
    else
        warn("playerStats or player name not found")
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
    local oldpos = LocalPlayer.Character.HumanoidRootPart.CFrame
    FreezeChar = Options.FreezeCharacter.Value
    task.wait()
    while WaitForSomeone(RenderStepped) do
        if FreezeChar and LocalPlayer.Character.HumanoidRootPart ~= nil then
            task.wait()
            LocalPlayer.Character.HumanoidRootPart.CFrame = oldpos
        else
            break
        end
    end
end)

-- // Mode Tab // --
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
