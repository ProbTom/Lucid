-- debug.lua
local Debug = {}

-- Enable or disable debugging
Debug.Enabled = true

-- Log a message if debugging is enabled
function Debug.Log(message)
    if Debug.Enabled then
        print("[DEBUG] " .. message)
    end
end

-- Log an error message if debugging is enabled
function Debug.Error(message)
    if Debug.Enabled then
        warn("[ERROR] " .. message)
    end
end

return Debug