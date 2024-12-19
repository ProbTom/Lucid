-- compatibility.lua
local HttpService = game:GetService("HttpService")

local function createCompatibilityWrapper()
    local config = {
        settings = {},
        windowState = {
            theme = "Dark",
            transparency = 0,
            acrylic = true
        }
    }

    -- Create persistent storage
    local function saveSettings()
        local success, err = pcall(function()
            local data = HttpService:JSONEncode(config)
            writefile("LucidHub_settings.json", data)
        end)
        return success
    end

    local function loadSettings()
        local success, data = pcall(function()
            if isfile("LucidHub_settings.json") then
                return HttpService:JSONDecode(readfile("LucidHub_settings.json"))
            end
        end)
        if success and data then
            config = data
        end
    end

    -- Load settings on init
    loadSettings()

    return {
        wrapFluentUI = function(fluentLib)
            local wrapped = {}
            
            -- Preserve original methods
            for k, v in pairs(fluentLib) do
                wrapped[k] = v
            end

            -- Add missing methods
            wrapped.SaveConfig = wrapped.SaveConfig or function(self, value)
                config.settings.saveWindow = value
                return saveSettings()
            end

            wrapped.SetBackgroundTransparency = wrapped.SetBackgroundTransparency or function(self, value)
                config.windowState.transparency = value
                if self.Frame then
                    pcall(function()
                        self.Frame.BackgroundTransparency = value
                    end)
                end
                saveSettings()
            end

            wrapped.ToggleAcrylic = wrapped.ToggleAcrylic or function(self, value)
                config.windowState.acrylic = value
                if self.Frame then
                    pcall(function()
                        self.Frame.Acrylic = value
                    end)
                end
                saveSettings()
            end

            wrapped.SetTheme = wrapped.SetTheme or function(self, theme)
                config.windowState.theme = theme
                if self.Frame then
                    pcall(function()
                        self.Frame.Theme = theme
                    end)
                end
                saveSettings()
            end

            return wrapped
        end,
        
        getConfig = function()
            return config
        end
    }
end

getgenv().CompatibilityLayer = createCompatibilityWrapper()
return true