local VirtualUser = game:GetService("VirtualUser")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

getgenv().Functions = {
    autoShake = function(gui)
        if gui:FindFirstChild("shakeui") and gui.shakeui.Enabled then
            gui.shakeui.safezone.button.Size = UDim2.new(1001, 0, 1001, 0)
            VirtualUser:Button1Down(Vector2.new(1, 1))
            task.wait(0.1)
            VirtualUser:Button1Up(Vector2.new(1, 1))
        end
    end,
    
    autoCast = function(mode, character, hrp)
        if mode == "Legit" then
            if character and hrp then
                local rod = character:FindFirstChild("Rod")
                if rod then
                    VirtualUser:Button1Down(Vector2.new(1, 1))
                    task.wait(0.1)
                    VirtualUser:Button1Up(Vector2.new(1, 1))
                end
            end
        elseif mode == "Blatant" then
            if character and hrp then
                local rod = character:FindFirstChild("Rod")
                if rod then
                    VirtualUser:Button1Down(Vector2.new(1, 1))
                    VirtualUser:Button1Up(Vector2.new(1, 1))
                end
            end
        end
    end,
    
    autoReel = function(gui, mode)
        if gui:FindFirstChild("ReelMeterUI") and gui.ReelMeterUI.Enabled then
            if mode == "Legit" then
                local bar = gui.ReelMeterUI:FindFirstChild("Bar")
                if bar then
                    local arrow = bar:FindFirstChild("Arrow")
                    local safe = bar:FindFirstChild("Safe")
                    if arrow and safe then
                        local arrowPos = arrow.Position.X.Scale
                        local safeStart = safe.Position.X.Scale
                        local safeEnd = safeStart + safe.Size.X.Scale
                        
                        if arrowPos >= safeStart and arrowPos <= safeEnd then
                            VirtualUser:Button1Down(Vector2.new(1, 1))
                            task.wait(0.1)
                            VirtualUser:Button1Up(Vector2.new(1, 1))
                        end
                    end
                end
            elseif mode == "Blatant" then
                VirtualUser:Button1Down(Vector2.new(1, 1))
                VirtualUser:Button1Up(Vector2.new(1, 1))
            end
        end
    end
}

return true
