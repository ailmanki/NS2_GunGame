--
--	GunGame NS2 Mod
--	ZycaR (c) 2016
--

Script.Load("lua/BaseSpawn.lua")

class 'SpawnLocation' (BaseSpawn)

SpawnLocation.kMapName = "spawn_location"

function SpawnLocation:GetTeamNumber()
    return self.teamNumber
end