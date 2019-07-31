--[[
 	GunGame NS2 Mod
	ZycaR (c) 2016
]]

-- ----------------------------------------------
-- --- Overrides related to tech level system ---
-- ----------------------------------------------
Script.Load("lua/gg_TechLevelRewards.lua")

-- ----------------------------------------------
-- --- Overrides related to tech level system ---
-- ----------------------------------------------

if Server then

    local function CanResupplyGrenade(player)
        return player:GetIsAlive() and 
               player:GetIsOnPlayingTeam() and
               player:GetGameStarted() and
               not player.preventWeapons and               
               GetCanGiveGrenade(player)
    end

    local function ResupplyGrenade(self, timePassed)
        if CanResupplyGrenade(self) then
            self:GiveItem(PulseGrenadeThrower.kMapName)
        end
        self.pendingGrenade = false
        return false
    end

    local ns2_Player_OnUpdatePlayer, gg_Player_OnUpdatePlayer
    gg_Player_OnUpdatePlayer = function(self, deltaTime)
        ns2_Player_OnUpdatePlayer(self, deltaTime)
        
        if not self.pendingGrenade and CanResupplyGrenade(self) then
            self.pendingGrenade = true
            self:AddTimedCallback(ResupplyGrenade, 3)
        end
    end
    ns2_Player_OnUpdatePlayer = Class_ReplaceMethod("Player", "OnUpdatePlayer", gg_Player_OnUpdatePlayer)

    local ns2_Player_Reset, gg_Player_Reset
    gg_Player_Reset = function(self)
        ScriptActor.Reset(self)
        
	    self:ResetGunGameData()
        self:SetCameraDistance(0)
    end
    ns2_Player_Reset = Class_ReplaceMethod("Player", "Reset", gg_Player_Reset)


    local ns2_Player_Replace, gg_Player_Replace
    gg_Player_Replace = function(self, mapName, newTeamNumber, preserveWeapons, atOrigin, extraValues)

        -- handle class after respawn
        local spawnMapName = self:ClassAfterRespawn()
        if mapName == nil then mapName = spawnMapName end
        
        return ns2_Player_Replace(self, mapName, newTeamNumber, preserveWeapons, atOrigin, extraValues)
    end
    ns2_Player_Replace = Class_ReplaceMethod("Player", "Replace", gg_Player_Replace)


    local ns2_Marine_OnKill, gg_Marine_OnKill
    gg_Marine_OnKill = function(self, attacker, doer, point, direction)
        local isHumiliation = doer and ( doer:isa("Axe") or doer:isa("Claw") )
        local isSuicide = not doer and not attacker
        local isKilledByEnemy = attacker and GetAreEnemies(self, attacker) and attacker:isa("Player")

        -- destroy the weapons so they don't drop
        self.lastWeaponList = { }
        self:DestroyWeapons()
        
        Player.OnKill(self, attacker, doer, point, direction)
        
        -- Note: Flashlight is powered by Marine's beating heart. Eco friendly.
        self:SetFlashlightOn(false)
        self.originOnDeath = self:GetOrigin()
        
        if isKilledByEnemy then
            attacker:AdjustExp(ConditionalValue(isHumiliation and not attacker:LastHumiliationTime(), 3, 1))
            attacker:AdjustGunGameData()

            -- set last humiliation time after adjusting game data (or it will removed it in case of level change)
            if isHumiliation then
                attacker:LastHumiliationTime(Shared.GetTime())
            end
        end
        
        if isSuicide or isHumiliation then
            self:AdjustExp(ConditionalValue(isHumiliation, -3, -1))
        end
    end
    ns2_Marine_OnKill = Class_ReplaceMethod("Marine", "OnKill", gg_Marine_OnKill)


    local ns2_Exo_OnKill, gg_Exo_OnKill
    gg_Exo_OnKill = function(self, attacker, doer, point, direction)
        local isHumiliation = doer and ( doer:isa("Axe") or doer:isa("Claw") )
        local isSuicide = not doer and not attacker
        local isKilledByEnemy = attacker and GetAreEnemies(self, attacker) and attacker:isa("Player")

        ns2_Exo_OnKill(self, attacker, doer, point, direction)
        
        -- override last exosuit layout with gun game data
        self.lastExoLayout = { self:ExoLayout() }
        
        if isKilledByEnemy then
            attacker:AdjustExp(ConditionalValue(isHumiliation and not attacker:LastHumiliationTime(), 3, 1))
            attacker:AdjustGunGameData()

            if isHumiliation then
                attacker:LastHumiliationTime(Shared.GetTime())
            end
        end
        
        if isSuicide or isHumiliation then
            self:AdjustExp(ConditionalValue(isHumiliation, -3, -1))
        end
    end
    ns2_Exo_OnKill = Class_ReplaceMethod("Exo", "OnKill", gg_Exo_OnKill)


    -- This will copy GunGame data from player to spectator and back for respawn purpose
    local ns2_Player_CopyPlayerDataFrom, gg_Player_CopyPlayerDataFrom
    gg_Player_CopyPlayerDataFrom = function(self, player)
        ns2_Player_CopyPlayerDataFrom(self, player)
        
        self.GunGameLevel = player.GunGameLevel
        self.GunGameExp = player.GunGameExp
        self.GunGameSpawnProtection = player.GunGameSpawnProtection

        self:ClassAfterRespawn(player:ClassAfterRespawn())
        self:ExoLayout(player:ExoLayout())
        self:LastTeamNumber(player:LastTeamNumber())
        self:LastHumiliationTime(player:LastHumiliationTime())

        self:AdjustGunGameData(true)
	end
    ns2_Player_CopyPlayerDataFrom = Class_ReplaceMethod("Player", "CopyPlayerDataFrom", gg_Player_CopyPlayerDataFrom)
	
	
    local ns2_Marine_CopyPlayerDataFrom, gg_Marine_CopyPlayerDataFrom
    gg_Marine_CopyPlayerDataFrom = function(self, player)
        self.preventWeapons = false   -- enable give weapon
        Player.CopyPlayerDataFrom(self, player)
    end	
    ns2_Marine_CopyPlayerDataFrom = Class_ReplaceMethod("Marine", "CopyPlayerDataFrom", gg_Marine_CopyPlayerDataFrom)


    local ns2_MarineSpectator_CopyPlayerDataFrom, gg_MarineSpectator_CopyPlayerDataFrom
    gg_MarineSpectator_CopyPlayerDataFrom = function(self, player)
        self.preventWeapons = true    -- disable give weapon
        Player.CopyPlayerDataFrom(self, player)
    end	
    ns2_MarineSpectator_CopyPlayerDataFrom = Class_ReplaceMethod("MarineSpectator", "CopyPlayerDataFrom", gg_MarineSpectator_CopyPlayerDataFrom)
    
    
    -- initial marine weapon should do nothing as we adds weapons by CopyPlayerDataFrom
    local ns2_Marine_InitWeapons, gg_Marine_InitWeapons
    gg_Marine_InitWeapons = function(self)    
    end
    ns2_Marine_InitWeapons = Class_ReplaceMethod("Marine", "InitWeapons", gg_Marine_InitWeapons)

end
