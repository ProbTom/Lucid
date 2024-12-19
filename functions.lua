-- Update functions.lua - Add these new functions at the end before the return statement

-- Add these new functions to the Functions table
Functions.sellFish = function(rarity)
    pcall(function()
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        if backpack then
            for _, item in pairs(backpack:GetChildren()) do
                if item:FindFirstChild("values") and 
                   item.values:FindFirstChild("rarity") and 
                   item.values.rarity.Value == rarity then
                    game:GetService("ReplicatedStorage").events.character:FireServer("sell", item.Name)
                end
            end
        end
    end)
end

Functions.collectChest = function(chest, range)
    pcall(function()
        local character = LocalPlayer.Character
        if character and chest then
            local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
            local chestPart = chest:FindFirstChild("Hitbox") or chest:FindFirstChild("HumanoidRootPart")
            
            if humanoidRootPart and chestPart then
                local distance = (humanoidRootPart.Position - chestPart.Position).Magnitude
                if distance <= (range or 50) then
                    game:GetService("ReplicatedStorage").events.character:FireServer("collect", chest)
                end
            end
        end
    end)
end

Functions.equipBestRod = function()
    pcall(function()
        local rodRanking = {
            "Rod Of The Eternal King",
            "Rod Of The Depths",
            "Celestial Rod",
            "Phoenix Rod",
            "Astral Rod",
            "Magma Rod",
            "Frost Warden Rod",
            "North-Star Rod",
            "Aurora Rod",
            "Destiny Rod",
            "Mythical Rod",
            "Kings Rod",
            "Lucky Rod",
            "Fortune Rod"
        }
        
        local character = LocalPlayer.Character
        if character then
            for _, rodName in ipairs(rodRanking) do
                local rod = character:FindFirstChild(rodName)
                if rod then
                    game:GetService("ReplicatedStorage").events.character:FireServer("equip", rodName)
                    break
                end
            end
        end
    end)
end
