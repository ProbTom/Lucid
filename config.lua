-- config.lua
-- Version: 1.0.1
-- Author: ProbTom
-- Created: 2024-12-20 19:49:16 UTC

local Config = {
    _VERSION = "1.0.1",
    _initialized = false
}

-- Dependencies
local Debug
local Utils

-- Default configuration
local defaultConfig = {
    Version = "1.0.1",
    Debug = true,
    AutoUpdate = true,
    
    UI = {
        Theme = "Dark",
        Scale = 1.0,
        Position = UDim2.new(0.5, 0, 0.5, 0)
    },
    
    Performance = {
        MaxFPS = 60,
        LowLatencyMode = false
    },
    
    Features = {
        AutoFish = false,
        AutoCollect = false,
        AutoSell = false
    }
}

-- Current configuration
local currentConfig = Utils and Utils.DeepCopy(defaultConfig) or table.clone(defaultConfig)

-- Save configuration
function Config.Save()
    if not Debug then return false end
    
    local success, err = pcall(function()
        local data = game:GetService("HttpService"):JSONEncode(currentConfig)
        writefile("lucid_config.json", data)
    end)
    
    if success then
        Debug.Info("Configuration saved")
        return true
    else
        Debug.Error("Failed to save configuration: " .. tostring(err))
        return false
    end
end

-- Load configuration
function Config.Load()
    if not Debug then return false end
    
    local success, data = pcall(function()
        return readfile("lucid_config.json")
    end)
    
    if success then
        local decoded = game:GetService("HttpService"):JSONDecode(data)
        currentConfig = Utils.Merge(Utils.DeepCopy(defaultConfig), decoded)
        Debug.Info("Configuration loaded")
        return true
    else
        Debug.Warn("No saved configuration found, using defaults")
        return false
    end
end

-- Get configuration value
function Config.Get(key)
    if not key then return Utils.DeepCopy(currentConfig) end
    
    local value = currentConfig
    for k in key:gmatch("[^%.]+") do
        if type(value) ~= "table" then return nil end
        value = value[k]
    end
    
    return Utils.DeepCopy(value)
end

-- Set configuration value
function Config.Set(key, value)
    if not key then return false end
    
    local current = currentConfig
    local keys = {}
    for k in key:gmatch("[^%.]+") do
        table.insert(keys, k)
    end
    
    for i = 1, #keys - 1 do
        if type(current[keys[i]]) ~= "table" then
            current[keys[i]] = {}
        end
        current = current[keys[i]]
    end
    
    current[keys[#keys]] = value
    Config.Save()
    return true
end

-- Reset configuration
function Config.Reset()
    currentConfig = Utils.DeepCopy(defaultConfig)
    Config.Save()
    Debug.Info("Configuration reset to defaults")
    return true
end

-- Initialize module
function Config.init(modules)
    if Config._initialized then return true end
    
    Debug = modules.debug
    Utils = modules.utils
    
    if not Debug or not Utils then
        return false
    end
    
    -- Load saved config or create new one
    if not Config.Load() then
        Config.Save()
    end
    
    Config._initialized = true
    Debug.Info("Config module initialized")
    return true
end

return Config
