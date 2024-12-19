if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Functions = {}

-- Get required services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")

Functions.ShowNotification = function(String)
    if getgenv().Fluent then
        getgenv().Fluent:Notify({
            Title = "Lucid Hub",
            Content = String,
            Duration = 5
        })
    end
end

Functions.autoCast = function(CastMode, LocalCharacter, HumanoidRootPart)
    pcall(function()
        if LocalCharacter then
            local tool = LocalCharacter:FindFirstChildOfClass("Tool")
            if tool then
                local hasBobber = tool:FindFirstChild("bobber")
                if not hasBobber then
                    if CastMode == "Legit" then
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, LocalPlayer, 0)
                        
                        local powerBarConnection
                        powerBarConnection = HumanoidRootPart.ChildAdded:Connect(function()
                            if HumanoidRootPart:FindFirstChild("power") then
                                local powerBar = HumanoidRootPart.power:FindFirstChild("powerbar")
                                if powerBar and powerBar:FindFirstChild("bar") then
                                    powerBar.bar.Changed:Connect(function(property)
                                        if property == "Size" and 
                                           powerBar.bar.Size == UDim2.new(1, 0, 1, 0) then
                                            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, LocalPlayer, 0)
                                            if powerBarConnection then
                                                powerBarConnection:Disconnect()
                                            end
                                        end
                                    end)
                                end
                            end
                        end)
                    elseif CastMode == "Blatant" then
                        local rod = LocalCharacter:FindFirstChildOfClass("Tool")
                        if rod and rod:FindFirstChild("values") and string.find(rod.Name, "Rod") then
                            task.wait(0.5)
                            local Random = math.random(90, 99)
                            pcall(function()
                                rod.events.cast:FireServer(Random)
                            end)
                        end
                    end
                end
            end
        end
    end)
end

Functions.autoShake = function(gui)
    pcall(function()
        if gui:FindFirstChild("shakeui") and gui.shakeui.Enabled then
            gui.shakeui.safezone.button.Size = UDim2.new(1001, 0, 1001, 0)
            VirtualInputManager:Button1Down(Vector2.new(1, 1))
            task.wait(0.1)
            VirtualInputManager:Button1Up(Vector2.new(1, 1))
        end
    end)
end

Functions.autoReel = function(PlayerGui, ReelMode)
    pcall(function()
        local reel = PlayerGui:FindFirstChild("reel")
        if reel then
            local bar = reel:FindFirstChild("bar")
            if bar then
                local playerbar = bar:FindFirstChild("playerbar")
                local fish = bar:FindFirstChild("fish")
                if playerbar and fish then
                    if ReelMode == "Legit" then
                        playerbar.Position = fish.Position
                    elseif ReelMode == "Blatant" then
                        game:GetService("ReplicatedStorage").events.reelfinished:FireServer(100, false)
                    end
                end
            end
        end
    end)
end

Functions.handleZoneCast = function(ZoneCast, Zone, FishingZonesFolder, HumanoidRootPart)
    if ZoneCast and Zone then
        local fishingSpot = FishingZonesFolder and FishingZonesFolder:FindFirstChild(Zone)
        if fishingSpot then
            local spotCFrame = fishingSpot.CFrame
            local targetPosition = spotCFrame.Position + Vector3.new(0, 2, 0)
            if HumanoidRootPart then
                HumanoidRootPart.CFrame = CFrame.new(HumanoidRootPart.Position, targetPosition)
            end
        end
    end
end

-- Initialize notifications if they don't exist
if not getgenv().Notifications then
    getgenv().Notifications = {
        Actions = true
    }
end

return Functions
