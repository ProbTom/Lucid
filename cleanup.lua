-- cleanup.lua
local Cleanup = {
    Handlers = {}
}

-- Register cleanup handlers for each module
Cleanup.Handlers.ItemsTab = function()
    local RunService = game:GetService("RunService")
    
    -- Unbind all render steps
    RunService:UnbindFromRenderStep("AutoCollectChests")
    RunService:UnbindFromRenderStep("AutoSellFish")
    RunService:UnbindFromRenderStep("AutoEquipBestRod")
    
    -- Reset ItemsTab options
    if getgenv().Options then
        getgenv().Options.ChestRange = getgenv().Config.Items.ChestRange.Default
        getgenv().Options.SelectedRarities = {Common = true}
        getgenv().Options.AutoCollectEnabled = false
        getgenv().Options.AutoSellEnabled = false
        getgenv().Options.AutoEquipBestRod = false
    end
    
    -- Reset toggles if they exist
    if getgenv().Tabs and getgenv().Tabs.Items then
        for _, element in pairs(getgenv().Tabs.Items:GetChildren()) do
            if element.ClassName == "Toggle" then
                pcall(function()
                    element:SetValue(false)
                end)
            end
        end
    end
end

-- Initialize cleanup system
function Cleanup:Initialize()
    getgenv().cleanup = function()
        for _, handler in pairs(self.Handlers) do
            pcall(handler)
        end
    end
end

-- Add any existing cleanup handlers
if getgenv().cleanup then
    local oldCleanup = getgenv().cleanup
    Cleanup.Handlers.Original = oldCleanup
end

Cleanup:Initialize()
return Cleanup
