-- Safe check for playerstats
local playerStats = ReplicatedStorage and ReplicatedStorage:FindFirstChild("playerstats")
if not playerStats then
    warn("playerstats not found in ReplicatedStorage")
end
