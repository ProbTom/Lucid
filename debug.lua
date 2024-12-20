-- debug.lua
local Debug = {
    _enabled = true
}

function Debug.Log(message)
    if Debug._enabled then
        print(string.format("[%s] %s", os.date("%H:%M:%S"), message))
    end
end

function Debug.Error(message)
    if Debug._enabled then
        warn(string.format("[%s] [ERROR] %s", os.date("%H:%M:%S"), message))
    end
end

function
