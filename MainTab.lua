-- Ensure required services and variables are correctly initialized
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")
local LocalCharacter = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = LocalCharacter:WaitForChild("HumanoidRootPart")
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local GuiService = game:GetService("GuiService")

-- Define the Options table if not already defined
if not Options then
    Options = {
        autoCast = { Value = false },
        autoShake = { Value = false },
        autoReel = { Value = false },
        FreezeCharacter = { Value = false },
    }
end

-- Define additional variables
local CastMode = "Legit"
local ShakeMode = "Navigation"
local ReelMode = "Legit"
local autoCastEnabled = false
local autoShakeEnabled = false
local autoReelEnabled = false
local FreezeChar = false

-- Define functions from CupPink.lua
local function autoCast()
    if LocalCharacter then
        local tool = LocalCharacter:FindFirstChildOfClass("Tool")
        if tool then
            local hasBobber = tool:FindFirstChild("bobber")
            if not hasBobber then
                if CastMode == "Legit" then
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, LocalPlayer, 0)
                    HumanoidRootPart.ChildAdded:Connect(function()
                        if HumanoidRootPart:FindFirstChild("power") ~= nil and HumanoidRootPart.power.powerbar.bar ~= nil then
                            HumanoidRootPart.power.powerbar.bar.Changed:Connect(function(property)
                                if property == "Size" then
                                    if HumanoidRootPart.power.powerbar.bar.Size == UDim2.new(1, 0, 1, 0) then
                                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, LocalPlayer, 0)
                                    end
                                end
                            end)
                        end
                    end)
                elseif CastMode == "Blatant" then
                    local rod = LocalCharacter and LocalCharacter:FindFirstChildOfClass("Tool")
                    if rod and rod:FindFirstChild("values") and string.find(rod.Name, "Rod") then
                        task.wait(0.5)
                        local Random = math.random(90, 99)
                        rod.events.cast:FireServer(Random)
                    end
                end
            end
        end
        task.wait(0.5)
    end
end

local function autoShake()
    if ShakeMode == "Navigation" then
        task.wait()
        xpcall(function()
            local shakeui = PlayerGui:FindFirstChild("shakeui")
            if not shakeui then return end
            local safezone = shakeui:FindFirstChild("safezone")
            local button = safezone and safezone:FindFirstChild("button")
            task.wait(0.2)
            GuiService.SelectedObject = button
            if GuiService.SelectedObject == button then
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
            end
            task.wait(0.1)
            GuiService.SelectedObject = nil
        end,function (err)
        end)
    elseif ShakeMode == "Mouse" then
        task.wait()
        xpcall(function()
            local shakeui = PlayerGui:FindFirstChild("shakeui")
            if not shakeui then return end
            local safezone = shakeui:FindFirstChild("safezone")
            local button = safezone and safezone:FindFirstChild("button")
            local pos = button.AbsolutePosition
            local size = button.AbsoluteSize
            VirtualInputManager:SendMouseButtonEvent(pos.X + size.X / 2, pos.Y + size.Y / 2, 0, true, LocalPlayer, 0)
            VirtualInputManager:SendMouseButtonEvent(pos.X + size.X / 2, pos.Y + size.Y / 2, 0, false, LocalPlayer, 0)
        end,function (err)
        end)
    end
end

local function startAutoShake()
    if autoShakeConnection or not autoShakeEnabled then return end
    autoShakeConnection = RunService.RenderStepped:Connect(autoShake)
end

local function stopAutoShake()
    if autoShakeConnection then
        autoShakeConnection:Disconnect()
        autoShakeConnection = nil
    end
end

local function autoReel()
    local reel = PlayerGui:FindFirstChild("reel")
    if not reel then return end
    local bar = reel:FindFirstChild("bar")
    local playerbar = bar and bar:FindFirstChild("playerbar")
    local fish = bar and bar:FindFirstChild("fish")
    if playerbar and fish then
        playerbar.Position = fish.Position
    end
end

local function noperfect()
    local reel = PlayerGui:FindFirstChild("reel")
    if not reel then return end
    local bar = reel:FindFirstChild("bar")
    local playerbar = bar and bar:FindFirstChild("playerbar")
    if playerbar then
        playerbar.Position = UDim2.new(0, 0, -35, 0)
        wait(0.2)
    end
end

local function startAutoReel()
    if ReelMode == "Legit" then
        if autoReelConnection or not autoReelEnabled then return end
        noperfect()
        task.wait(2)
        autoReelConnection = RunService.RenderStepped:Connect(autoReel)
    elseif ReelMode == "Blatant" then
        local reel = PlayerGui:FindFirstChild("reel")
        if not reel then return end
        local bar = reel:FindFirstChild("bar")
        local playerbar = bar and bar:FindFirstChild("playerbar")
        playerbar:GetPropertyChangedSignal('Position'):Wait()
        game.ReplicatedStorage:WaitForChild("events"):WaitForChild("reelfinished"):FireServer(100, false)
    end
end

local function stopAutoReel()
    if autoReelConnection then
        autoReelConnection:Disconnect()
        autoReelConnection = nil
    end
end

local function WaitForSomeone(event)
    return true -- Placeholder return value
end

-- // Main Tab // --
local section = Tabs.Main:AddSection("Auto Fishing")
local autoCastToggle = Tabs.Main:AddToggle("autoCast", {Title = "Auto Cast", Default = false })
autoCastToggle:OnChanged(function()
    local RodName = ReplicatedStorage.playerstats[LocalPlayer.Name].Stats.rod.Value
    if Options.autoCast.Value == true then
        autoCastEnabled = true
        if LocalPlayer.Backpack:FindFirstChild(RodName) then
            LocalPlayer.Character.Humanoid:EquipTool(LocalPlayer.Backpack:FindFirstChild(RodName))
        end
        autoCast()
    else
        autoCastEnabled = false
    end
end)

local autoShakeToggle = Tabs.Main:AddToggle("autoShake", {Title = "Auto Shake", Default = false })
autoShakeToggle:OnChanged(function()
    if Options.autoShake.Value == true then
        autoShakeEnabled = true
        startAutoShake()
    else
        autoShakeEnabled = false
        stopAutoShake()
    end
end)

local autoReelToggle = Tabs.Main:AddToggle("autoReel", {Title = "Auto Reel", Default = false })
autoReelToggle:OnChanged(function()
    if Options.autoReel.Value == true then
        autoReelEnabled = true
        startAutoReel()
    else
        autoReelEnabled = false
        stopAutoReel()
    end
end)

local FreezeCharacterToggle = Tabs.Main:AddToggle("FreezeCharacter", {Title = "Freeze Character", Default = false })
FreezeCharacterToggle:OnChanged(function()
    local oldpos = HumanoidRootPart.CFrame
    FreezeChar = Options.FreezeCharacter.Value
    task.wait()
    while WaitForSomeone(RunService.RenderStepped) do
        if FreezeChar and HumanoidRootPart ~= nil then
            task.wait()
            HumanoidRootPart.CFrame = oldpos
        else
            break
        end
    end
end)

-- // Mode Tab // --
local section = Tabs.Main:AddSection("Mode Fishing")
local autoCastModeDropdown = Tabs.Main:AddDropdown("autoCastMode", {
    Title = "Auto Cast Mode",
    Values = {"Legit", "Blatant"},
    Multi = false,
    Default = CastMode,
})
autoCastModeDropdown:OnChanged(function(Value)
    CastMode = Value
end)

local autoShakeModeDropdown = Tabs.Main:AddDropdown("autoShakeMode", {
    Title = "Auto Shake Mode",
    Values = {"Navigation", "Mouse"},
    Multi = false,
    Default = ShakeMode,
})
autoShakeModeDropdown:OnChanged(function(Value)
    ShakeMode = Value
end)

local autoReelModeDropdown = Tabs.Main:AddDropdown("autoReelMode", {
    Title = "Auto Reel Mode",
    Values = {"Legit", "Blatant"},
    Multi = false,
    Default = ReelMode,
})
autoReelModeDropdown:OnChanged(function(Value)
    ReelMode = Value
end)
