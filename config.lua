-- config.lua
-- Version: 1.0.1
-- Author: ProbTom
-- Created: 2024-12-20 14:41:31 UTC

local Config = {}

-- Default configuration
local defaultConfig = {
    -- Core Settings
    Version = "1.0.1",
    Debug = true,
    AutoUpdate = true,
    
    -- UI Settings
    UI = {
        Theme = "Dark",
        AccentColor = Color3.fromRGB(0, 120, 255),
        Font = "Gotham",
        Scale = 1.0,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Draggable = true
    },
    
    -- Performance Settings
    Performance = {
        MaxFPS = 60,
        LowLatencyMode = false,
        OptimizeMemory = true,
        CacheTimeout = 300
    },
    
    -- Security Settings
    Security = {
        AntiKick = true,
        AntiTeleport = true,
        AntiScreenshot = false,
        ObfuscateStrings = true,
        EncryptData = true
    },
    
    -- Feature Settings
    Features = {
        AutoRejoin = true,
        ServerHop = true,
        ChatLogger = false,
        ESPEnabled = false,
        AimbotEnabled = false
    },
    
    -- Network Settings
    Network = {
        Timeout = 10,
        RetryAttempts = 3,
        RetryDelay = 1,
        ProxyEnabled = false
    }
}

-- Current configuration
local currentConfig = table.clone(defaultConfig)

-- Load configuration from file
function Config.Load()
    local success, savedConfig = pcall(function()
        local data = readfile("lucid_config.json")
        return game:GetService("HttpService"):JSONDecode(data)
    end)
    
    if success and savedConfig then
        -- Merge saved config with defaults
        for key, value in pairs(savedConfig) do
            if defaultConfig[key] ~= nil then
                currentConfig[key] = value
            end
        end
        return true
    end
    
    return false
end

-- Save configuration to file
function Config.Save()
    local success, err = pcall(function()
        local data = game:GetService("HttpService"):JSONEncode(currentConfig)
        writefile("lucid_config.json", data)
    end)
    
    return success
end

-- Get configuration value
function Config.Get(key)
    local keys = string.split(key, ".")
    local value = currentConfig
    
    for _, k in ipairs(keys) do
        if type(value) ~= "table" then
            return nil
        end
        value = value[k]
    end
    
    return value
end

-- Set configuration value
function Config.Set(key, value)
    local keys = string.split(key, ".")
    local current = currentConfig
    
    -- Navigate to the correct table
    for i = 1, #keys - 1 do
        if type(current[keys[i]]) ~= "table" then
            current[keys[i]] = {}
        end
        current = current[keys[i]]
    end
    
    -- Set the value
    current[keys[#keys]] = value
    
    -- Auto-save configuration
    Config.Save()
    
    return true
end

-- Reset configuration to defaults
function Config.Reset()
    currentConfig = table.clone(defaultConfig)
    Config.Save()
    return true
end

-- Get all configuration
function Config.GetAll()
    return table.clone(currentConfig)
end

-- Validate configuration
function Config.Validate()
    local function validateTable(current, default)
        for key, value in pairs(default) do
            if current[key] == nil then
                current[key] = value
            elseif type(value) == "table" and type(current[key]) == "table" then
                validateTable(current[key], value)
            end
        end
    end
    
    validateTable(currentConfig, defaultConfig)
    return true
end

-- Initialize module
function Config.init()
    -- Load saved configuration
    if not Config.Load() then
        Config.Save() -- Save default configuration
    end
    
    -- Validate configuration
    Config.Validate()
    
    return true
end

return Config
