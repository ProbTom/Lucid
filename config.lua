-- config.lua
-- Version: 2024.12.20
-- Author: ProbTom
-- Purpose: Central configuration for Lucid Hub

local Config = {
    Version = "1.0.1",
    LastUpdated = "2024-12-20",
    Author = "ProbTom",
    Debug = true,
    
    URLs = {
        FluentUI = "https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua",
        Repository = "https://raw.githubusercontent.com/ProbTom/Lucid/main/",
        Updates = "https://raw.githubusercontent.com/ProbTom/Lucid/main/version.json"
    },
    
    UI = {
        Window = {
            Title = "Lucid Hub",
            SubTitle = "by ProbTom",
            TabWidth = 160,
            Size = UDim2.fromOffset(580, 460),
            Theme = "Dark",
            MinimizeKeybind = Enum.KeyCode.RightControl
        },
        
        Tabs = {
            Home = {
                Name = "Home",
                Icon = "home",
                Sections = {
                    Welcome = {
                        Title = "Welcome",
                        Content = "Welcome to Lucid Hub!"
                    },
                    Status = {
                        Title = "Status",
                        Content = "Connected and Ready"
                    }
                }
            },
            Main = {
                Name = "Main",
                Icon = "list",
                Sections = {
                    Fishing = {
                        Title = "Fishing Controls",
                        Features = {
                            AutoCast = true,
                            AutoReel = true,
                            AutoShake = true
                        }
                    }
                }
            },
            Items = {
                Name = "Items",
                Icon = "package",
                Sections = {
                    Inventory = {
                        Title = "Inventory",
                        Features = {
                            AutoCollect = true,
                            AutoSell = true
                        }
                    }
                }
            },
            Teleports = {
                Name = "Teleports",
                Icon = "map-pin",
                Sections = {
                    Locations = {
                        Title = "Locations",
                        Features = {
                            SavePosition = true,
                            LoadPosition = true
                        }
                    }
                }
            },
            Misc = {
                Name = "Misc",
                Icon = "file-text",
                Sections = {
                    Settings = {
                        Title = "Settings",
                        Features = {
                            AutoSave = true,
                            Performance = true
                        }
                    }
                }
            },
            Settings = {
                Name = "Settings",
                Icon = "settings",
                Sections = {
                    Configuration = {
                        Title = "Configuration",
                        Features = {
                            Theme = true,
                            Performance = true
                        }
                    }
                }
            },
            Credits = {
                Name = "Credits",
                Icon = "heart",
                Sections = {
                    Info = {
                        Title = "Credits",
                        Content = {
                            Developer = "ProbTom",
                            UILibrary = "Fluent UI Library by dawid-scripts",
                            Version = "1.0.1"
                        }
                    }
                }
            }
        }
    },
    
    Features = {
        AutoCast = {
            Enabled = false,
            Delay = 1,
            MaxAttempts = 3,
            RetryDelay = 0.5
        },
        AutoReel = {
            Enabled = false,
            Delay = 0.1,
            Sensitivity = 0.8,
            MaxDistance = 100
        },
        AutoShake = {
            Enabled = false,
            Delay = 0.1,
            Intensity = 1,
            Duration = 0.5
        }
    },
    
    Performance = {
        UpdateRate = 0.1,
        MaxThreads = 10,
        CacheTime = 30,
        AutoCleanup = true,
        MemoryThreshold = 1000
    },
    
    Security = {
        AntiCheatEnabled = true,
        MaxRetries = 3,
        Cooldown = 5,
        AllowedMethods = {
            "AutoCast",
            "AutoReel",
            "AutoShake"
        }
    },
    
    Events = {
        Required = {
            "castrod",
            "character",
            "fishing"
        },
        Optional = {
            "trade",
            "inventory",
            "shop"
        }
    }
}

-- Initialize Config
function Config.Initialize()
    if getgenv().LucidState then
        getgenv().LucidState.Config = Config
    end
    
    if getgenv().LucidDebug then
        getgenv().LucidDebug.Log("Config initialized")
    end
    
    return true
end

return Config
