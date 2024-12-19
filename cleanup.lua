-- cleanup.lua
local Cleanup = {
    Handlers = {}
}

function Cleanup:AddHandler(name, handler)
    self.Handlers[name] = handler
end

function Cleanup:Initialize()
    getgenv().cleanup = function()
        for _, handler in pairs(self.Handlers) do
            pcall(handler)
        end
    end
end

-- Add default cleanup handlers
Cleanup:AddHandler("UnbindRenderSteps", function()
    local RunService = game:GetService("RunService")
    RunService:UnbindFromRenderStep("AutoCollectChests")
    RunService:UnbindFromRenderStep("AutoSellFish")
    RunService:UnbindFromRenderStep("AutoEquipBestRod")
    RunService:UnbindFromRenderStep("AutoCast")
    RunService:UnbindFromRenderStep("AutoShake")
    RunService:UnbindFromRenderStep("AutoReel")
end)

Cleanup:AddHandler("ResetToggles", function()
    for _, tab in pairs(getgenv().Tabs) do
        for _, element in pairs(tab:GetChildren()) do
            if element.ClassName == "Toggle" then
                element:SetValue(false)
            end
        end
    end
end)

Cleanup:Initialize()
return Cleanup
