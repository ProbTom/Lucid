local VirtualUser = game:GetService("VirtualUser")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

getgenv().Functions = {
    autoShake = function(gui)
        if gui:FindFirstChild("shakeui") and gui.shakeui.Enabled then
            -- Fix for the safezone button
            local safezone = gui.shakeui:FindFirstChild("safezone")
            if safezone then
                safezone.Size = UDim2.new(1001, 0, 1001, 0)
                VirtualUser:Button1Down(Vector2.new(1, 1))
                task.wait(0.1)
                VirtualUser:Button1Up(Vector2.new(1, 1))
            end
        end
    end,
    
    autoCast = function(mode, character, hrp)
        if mode == "Legit" then
            -- Legit casting logic
        elseif mode == "Blatant" then
            -- Blatant casting logic
        end
    end,
    
    autoReel = function(gui, mode)
        if gui:FindFirstChild("ReelMeterUI") and gui.ReelMeterUI.Enabled then
            if mode == "Legit" then
                -- Legit reeling logic
            elseif mode == "Blatant" then
                -- Blatant reeling logic
            end
        end
    end
}

return true
