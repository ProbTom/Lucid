-- main.lua
-- Version: 1.0.1
-- Author: ProbTom
-- Created: 2024-12-20 19:34:00 UTC

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Constants
local VERSION = "1.0.1"
local BASE_URL = "https://raw.githubusercontent.com/ProbTom/Lucid/main/"

-- Create modules folder
local modulesFolder = Instance.new("Folder")
modulesFolder.Name = "LucidModules"
modulesFolder.Parent = ReplicatedStorage

-- Load module from
