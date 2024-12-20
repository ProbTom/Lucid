-- state.lua
local State = {
    _initialized = false,
    _data = {
        AutoCasting = false,
        AutoReeling = false,
        AutoShaking = false,
        Events = {
            Available = {}
        }
    }
}

function State.Initialize()
    if not getgenv then return false end
    if not getgenv().LucidState then
        getgenv().LucidState = State._data
    end
    State._initialized = true
    return true
end

function State.Get(key)
    if not State._initialized then return nil end
    return getgenv().LucidState[key]
end

function State.Set(key, value)
    if not State._initialized then return false end
    getgenv().LucidState[key] = value
    return true
end

return State