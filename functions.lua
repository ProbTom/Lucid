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
        if not character or not hrp then return end
        
        local rod = character:FindFirstChild("Rod")
        if rod then
            if mode == "Legit" then
                VirtualUser:Button1Down(Vector2.new(1, 1))
                task.wait(0.1)
                VirtualUser:Button1Up(Vector2.new(1, 1))
            elseif mode == "Blatant" then
                VirtualUser:Button1Down(Vector2.new(1, 1))
                VirtualUser:Button1Up(Vector2.new(1, 1))
            end
        end
    end,
    
    autoReel = function(gui, mode)
        if not gui or not gui:FindFirstChild("ReelMeterUI") or not gui.ReelMeterUI.Enabled then
            return
        end

        if mode == "Legit" then
            local bar = gui.ReelMeterUI:FindFirstChild("Bar")
            if not bar then return end

            local arrow = bar:FindFirstChild("Arrow")
            local safe = bar:FindFirstChild("Safe")
            if not arrow or not safe then return end

            local arrowPos = arrow.Position.X.Scale
            local safeStart = safe.Position.X.Scale
            local safeEnd = safeStart + safe.Size.X.Scale
            
            if arrowPos >= safeStart and arrowPos <= safeEnd then
                VirtualUser:Button1Down(Vector2.new(1, 1))
                task.wait(0.1)
                VirtualUser:Button1Up(Vector2.new(1, 1))
            end
        elseif mode == "Blatant" then
            VirtualUser:Button1Down(Vector2.new(1, 1))
            VirtualUser:Button1Up(Vector2.new(1, 1))
        end
    end
}

return true
