local VirtualUser = game:GetService("VirtualUser")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

getgenv().Functions = {
    autoShake = function(gui)
        if not gui or not gui:FindFirstChild("shakeui") or not gui.shakeui.Enabled then
            return
        end

        -- Safely find the button by recursively searching through the shakeui
        local function findButton(parent)
            for _, child in ipairs(parent:GetChildren()) do
                if child:IsA("TextButton") or child:IsA("ImageButton") then
                    return child
                end
                local found = findButton(child)
                if found then
                    return found
                end
            end
            return nil
        end
        
        local button = findButton(gui.shakeui)
        if button then
            button.Size = UDim2.new(1001, 0, 1001, 0)
            pcall(function()
                VirtualUser:Button1Down(Vector2.new(1, 1))
                task.wait(0.1)
                VirtualUser:Button1Up(Vector2.new(1, 1))
            end)
        end
    end,
    
    autoCast = function(mode, character, hrp)
        if not character or not hrp then return end
        
        local function performCast()
            pcall(function()
                VirtualUser:Button1Down(Vector2.new(1, 1))
                if mode == "Legit" then
                    task.wait(0.1)
                end
                VirtualUser:Button1Up(Vector2.new(1, 1))
            end)
        end

        local rod = character:FindFirstChild("Rod")
        if rod then
            performCast()
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
                pcall(function()
                    VirtualUser:Button1Down(Vector2.new(1, 1))
                    task.wait(0.1)
                    VirtualUser:Button1Up(Vector2.new(1, 1))
                end)
            end
        elseif mode == "Blatant" then
            pcall(function()
                VirtualUser:Button1Down(Vector2.new(1, 1))
                VirtualUser:Button1Up(Vector2.new(1, 1))
            end)
        end
    end
}

return true
