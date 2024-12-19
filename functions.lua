local Functions = {}

-- Get required services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")
local GuiService = game:GetService("GuiService")

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

Functions.autoShake = function(ShakeMode, PlayerGui)
    if ShakeMode == "Navigation" then
        pcall(function()
            local shakeui = PlayerGui:FindFirstChild("shakeui")
            if shakeui then
                local safezone = shakeui:FindFirstChild("safezone")
                local button = safezone and safezone:FindFirstChild("button")
                if button and GuiService then
                    task.wait(0.2)
                    GuiService.SelectedObject = button
                    if GuiService.SelectedObject == button then
                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
                    end
                    task.wait(0.1)
                    GuiService.SelectedObject = nil
                end
            end
        end)
    elseif ShakeMode == "Mouse" then
        pcall(function()
            local shakeui = PlayerGui:FindFirstChild("shakeui")
            if shakeui then
                local safezone = shakeui:FindFirstChild("safezone")
                local button = safezone and safezone:FindFirstChild("button")
                if button then
                    local pos = button.AbsolutePosition
                    local size = button.AbsoluteSize
                    VirtualInputManager:SendMouseButtonEvent(
                        pos.X + size.X / 2,
                        pos.Y + size.Y / 2,
                        0, true, game, 0
                    )
                    VirtualInputManager:SendMouseButtonEvent(
                        pos.X + size.X / 2,
                        pos.Y + size.Y / 2,
                        0, false, game, 0
                    )
                end
            end
        end)
    end
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

return Functions
