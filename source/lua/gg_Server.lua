--[[
 	GunGame NS2 Mod
  	ZycaR (c) 2016
]]

decoda_name = "Server"

-- choose spawn locations
Server.spawnLocationsList = table.array(32)
Server.spawnLocationsRandomizer = Randomizer()
Server.spawnLocationsRandomizer:randomseed(Shared.GetSystemTime())
Server.spawnLocationsQueues = { 
    [kMarineTeamType] = {},
    [kAlienTeamType] = {}
}

local function InsertSpawnLocationsForTeam(spawns, teamNumber)
    table.clear(spawns)

    for key, spawn in ipairs(Server.spawnLocationsList) do
        if (spawn:GetTeamNumber() == 0 or spawn:GetTeamNumber() == teamNumber) then 
            table.insert(spawns, spawn)
        end
    end
end

-- pseudorandom selection: get location exactly once, but in random order
function Server:ChooseSpawnLocation(teamNumber)
    assert(type(teamNumber) == "number")
    assert(table.maxn(Server.spawnLocationsList) > 0, "Can't find Spawn Locations on the map.")

    local queue = Server.spawnLocationsQueues[teamNumber]

    -- re-fill proper queue whether it's empty
    if  table.count(queue) < 1 then
        InsertSpawnLocationsForTeam(queue, teamNumber)
        --Print("Refill Spawn Queue Team:"..teamNumber.." Count:"..table.count(queue))
    end
   
    local index = Server.spawnLocationsRandomizer:random(1, table.count(queue))
    --Print("Choose Spawn Location #" .. index)
    
    local spawnLocation = queue[index]
    table.remove(queue, index)
    return spawnLocation
end

-- load spawn location
function GetLoadSpecial(mapName, groupName, values)
    local success = false
    
    if mapName == ReadyRoomSpawn.kMapName then
        local entity = ReadyRoomSpawn()
        entity:OnCreate()
        LoadEntityFromValues(entity, values)
        table.insert(Server.readyRoomSpawnList, entity)
        success = true
    elseif mapName == SpawnLocation.kMapName then
        local entity = SpawnLocation()
        entity:OnCreate()
        LoadEntityFromValues(entity, values)
        table.insert(Server.spawnLocationsList, entity)
        --Print("Load Spawn Location .. #" .. #Server.spawnLocationsList)
        success = true
    elseif mapName == "pathing_settings" then
        ParsePathingSettings(values)
        success = true
    elseif mapName == "cinematic" then
        success = values.startsOnMessage ~= nil and values.startsOnMessage ~= ""
        if success then
            PrecacheAsset(values.cinematicName)
            local entity = Server.CreateEntity(ServerParticleEmitter.kMapName, values)
            if entity then
                entity:SetMapEntity()
            end
        end
    end
    return success
end
