//
//	GunGame NS2 Mod
//	ZycaR (c) 2016
//

if Server then

    class 'GunGameTeam' (PlayingTeam)

    // GunGame version of giving exosuit, that exosuit can be given over exosuit
    local function GiveExosuit(player, teamNumber, origin, exoLayout)
        player:DestroyWeapons()
        
        // handle extra values: set exo layout
        local extraValues = { layout = exoLayout }
        local exo = player:Replace(Exo.kMapName, teamNumber, false, origin, extraValues)
        
        // effect of spawn exosuit
        exo:TriggerEffects("spawn_exo")
        return exo
    end

    // GunGame version of removing exosuit from player, there is eject in original ns2.
    local function ReplaceExosuitToMarine(player, teamNumber, origin)
        // explosion effect .. nice effect and exo garbage around (like egg hatching)
        player:TriggerEffects("death", { classname = player:GetClassName(), effecthostcoords = Coords.GetTranslation(player:GetOrigin()) })

        // inform guns that its end of exo (stop effects)
        local activeWeapon = player:GetActiveWeapon()
        if activeWeapon and activeWeapon.OnParentKilled then
            activeWeapon:OnParentKilled()
        end
        
        return player:Replace(Marine.kMapName, teamNumber, false, origin)
    end

    function GunGameTeam:PutPlayerInClassChangeQueue(player)
        if player:GetMapName() ~= player:ClassAfterRespawn() or
           (player.layout ~= nil and player.layout ~= player:ExoLayout())
        then
            table.insertunique(self.changeClassQueue, player:GetId())
        end
    end

    local function OnPlayerChangeClass(self, player)
        local mapName, exoLayout = player:ClassAfterRespawn(), player:ExoLayout()
        
        // validate whether the variables are still valid since player is in class change queue
        if player:GetMapName() == mapName and (player.layout == nil or player.layout == exoLayout) then
            Print("GunGame: '"..self:GetName().."' class change failed ("..mapName.." class)")
            return
        end
        
        local teamNumber = self:GetTeamNumber()
        local origin = Vector(player:GetOrigin())
        
        if mapName == JetpackMarine.kMapName and player.GiveJetpack then
            Print("+++ GunGame: '"..player:GetName().."' class change -> jetpack")
            player:GiveJetpack()
        elseif mapName == Exo.kMapName then
            Print("+++ GunGame: '"..player:GetName().."' class change -> exo")
            GiveExosuit(player, teamNumber, origin, exoLayout)
        else 
            Print("+++ GunGame: '"..player:GetName().."'class change -> marine")

            local marine
            if player:GetMapName() == Exo.kMapName then
                marine = ReplaceExosuitToMarine(player, teamNumber, origin)
            else
                local health = player:GetHealth()
                local weapon = player.GetActiveWeaponMapName and player:GetActiveWeaponMapName()
                marine = player:Replace(Marine.kMapName, teamNumber, true, origin)
                marine:SetActiveWeapon(weapon)
                marine:SetHealth(health)
            end
        end
    end

    local function ProcessClassChangePlayers(self)

        for i, playerId in ipairs(self.changeClassQueue) do
            local player = Shared.GetEntity(playerId)
            if player and player:isa("Player") and player.ClassAfterRespawn then
                OnPlayerChangeClass(self, player)
            end
        end

        table.clear(self.changeClassQueue)
    end

    function GunGameTeam:AddPlayer(player)
        local added = Team.AddPlayer(self, player)
        player:SetTeamNumber(self:GetTeamNumber())  // fix for team number.
        player.teamResources = self.teamResources
        return added
    end

    function GunGameTeam:RespawnPlayer(player, origin, angles)

        local success = false
        local spawn = Server.ChooseSpawnLocation(self, self:GetTeamNumber())

        if origin ~= nil and angles ~= nil then
            success = Team.RespawnPlayer(self, player, origin, angles)
        elseif spawn ~= nil then
        
            // Compute random spawn location
            local capsuleHeight, capsuleRadius = player:GetTraceCapsule()
            local spawnOrigin = GetRandomSpawnForCapsule(capsuleHeight, capsuleRadius, spawn:GetOrigin(), 0, 5, EntityFilterAll())
            
            if not spawnOrigin then
                spawnOrigin = spawn:GetOrigin() + Vector(2, 0.2, 2)
            end
            
            // Orient player towards tech point
            local lookAtPoint = spawn:GetOrigin() + Vector(0, 5, 0)
            local toSpawnPoint = GetNormalizedVector(lookAtPoint - spawnOrigin)
            success = Team.RespawnPlayer(self, player, spawnOrigin, Angles(GetPitchFromVector(toSpawnPoint), GetYawFromVector(toSpawnPoint), 0))
        else
            Print("GunGameTeam:RespawnPlayer(): No initial spawn location.")
        end
        return success
    end

    function GunGameTeam:ResetTeam()

        local players = GetEntitiesForTeam("Player", self:GetTeamNumber())
        for p = 1, #players do
       
            local player = players[p]
            local spawn = self:GetInitialTechPoint()
            player:OnInitialSpawn(spawn:GetOrigin())
        end

        if self.brain ~= nil then
            self.brain:Reset()
        end
        
        return nil
    end

    function GunGameTeam:Initialize(teamName, teamNumber)
        PlayingTeam.Initialize(self, teamName, teamNumber)
        self.teamType = teamNumber
        self.respawnEntity = Marine.kMapName

        // This is a special queue to place players in if the player change level
        self.changeClassQueue = table.array(16)
    end

    local function RespawnDeadMeat(self, deadmeat)
        local success, player = self:ReplaceRespawnPlayer(deadmeat, nil, nil)
        if success then
            player:SetCameraDistance(0)
            //self:TriggerEffects("player_spawned")
            return true
        end
        Print("Warning: RespawnDeadMeat() failed to spawn the player")
        return false
    end

    local function RespawnQueuedDeadMeats(self)

        if self.timeLastRespawnPlayers == nil then
            self.timeLastRespawnPlayers = Shared.GetTime() - 1
        end

        // not so often (only once a tick) for better performance
        if self.timeLastRespawnPlayers + 1 <= Shared.GetTime() then

            local deadmeats = self:GetSortedRespawnQueue()

            for i = 1, #deadmeats do
                local deadmeat = deadmeats[i]
                
                // skip auto team balance queue
                if not deadmeat:GetIsWaitingForTeamBalance() then
                    // start respawning
                    deadmeat:SetIsRespawning(true)
                    self:RemovePlayerFromRespawnQueue(deadmeat)
                    if not RespawnDeadMeat(self, deadmeat) then 
                        // put back to queue if respawning failed
                        self:PutPlayerInRespawnQueue(deadmeat)
                        deadmeat:SetIsRespawning(false)
                    end
                end
            end

            self.timeLastRespawnPlayers = Shared.GetTime()
        end
    end

    function GunGameTeam:Update(timePassed)
        PROFILE("GunGameTeam:Update")
        PlayingTeam.Update(self, timePassed)
        RespawnQueuedDeadMeats(self)
        ProcessClassChangePlayers(self)
    end

    function GunGameTeam:InitTechTree()
       PlayingTeam.InitTechTree(self)
    end
    function GunGameTeam:UpdateTechTree()
    end
    function GunGameTeam:UpdateMinResTick()
    end
    function GunGameTeam:UpdateVotes()
    end
    function GunGameTeam:GetSpectatorMapName()
        return MarineSpectator.kMapName
    end

    function GunGameTeam:GetWinner()
        local winner = nil

        if GetGamerules():GetGameStarted() and not Shared.GetCheatsEnabled() then
            local function FilterWinner( player )
                if player:IsWinner() then winner = player end
            end
            self:ForEachPlayer( FilterWinner )
        end
        
        return winner
    end

end