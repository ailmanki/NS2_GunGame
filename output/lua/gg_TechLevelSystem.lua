--
--	GunGame NS2 Mod
--	ZycaR (c) 2016
--

kLevelUpSoundName = PrecacheAsset("sound/NS2.fev/marine/structures/power_up")
kLevelDownSoundName = PrecacheAsset("sound/NS2.fev/marine/common/squad_spawn")

if Server then 

    function Player:ResetGunGameData()

        -- level = every 3 kills (except grenade)
        self.GunGameLevel = 1

        -- kill based (+1 .. kill, -3 .. death by axe or suicide, etc.)
        self.GunGameExp = 0

        -- nanoshield after respawn and every time exosuit is spawned
        self.GunGameSpawnProtection = false

        -- actual player class for respawn
        self.ggData = {}
        self.ggData.classAfterRespawn = nil
        self.ggData.exoLayout = nil
       
        -- save the last team
        self.ggData.lastTeamNumber = self:GetTeamNumber()

        -- time, when player kill by axe / claw
        self.ggData.lastHumiliationTime = nil
    end
    
    local function ChangeGunGameLevel(player, value)
        player.GunGameLevel = Clamp(player.GunGameLevel + value, 1, kMaxGunGameLevel + 1)

        -- Give weapons only when playing and according actual gun reward
        local reward = GunGameRewards[player.GunGameLevel]
        if reward ~= nil and 
           player:GetIsOnPlayingTeam() and
           not player.preventWeapons
        then
            player.ggData.classAfterRespawn = nil
            player.ggData.exoLayout = nil
            player:ResetHeathAndArmor()
            
            local mapName = reward.GiveGunFn(player)
            mapName = player:ClassAfterRespawn(mapName)
            
            player:GetTeam():PutPlayerInClassChangeQueue(player)
        end
    end
    
    local function GunGameLevelUp(player, value)
        local lastReward = GunGameRewards[player.GunGameLevel]

        -- this might (and should) change reward
        ChangeGunGameLevel(player, value)
        player.ggData.lastHumiliationTime = nil

        -- remove acquired exp based on last next level exp value
        player.GunGameExp = player.GunGameExp - lastReward.NextLvl
        
        if player.GunGameLevel <= kMaxGunGameLevel then
            StartSoundEffectForPlayer(kLevelUpSoundName, player)
        end
    end
    
    local function GunGameLevelDown(player, value)
        local lastLevel = player.GunGameLevel
        
        ChangeGunGameLevel(player, -value)
        player.ggData.lastHumiliationTime = nil
        
        -- re-calculate remaining exp when level down
        if player.GunGameLevel < lastLevel then
            local reward = GunGameRewards[player.GunGameLevel]
            player.GunGameExp = player.GunGameExp + reward.NextLvl
            
            StartSoundEffectForPlayer(kLevelDownSoundName, player)
        end
    end
    
    function Player:AdjustGunGameData(force)
        if not self.ggData then
            self:ResetGunGameData()
        end
        
        local lastReward = GunGameRewards[self.GunGameLevel]
        if lastReward ~= nil and self.GunGameExp >= lastReward.NextLvl
        then
            GunGameLevelUp(self, 1)
        elseif self.GunGameExp < 0 then
            GunGameLevelDown(self, 1)
        elseif force ~= nil then
            ChangeGunGameLevel(self, 0)
        end
        
        -- make sure, that do not overflow next level or less than zero
        local reward = GunGameRewards[self.GunGameLevel]
        if reward ~= nil and reward.NextLvl > 0 then
            self.GunGameExp = Clamp(self.GunGameExp, 0, reward.NextLvl - 1)
        else
            self.GunGameExp = 0
        end
    end
    
    function Player:AdjustExp(value)
        if GetGamerules():GetGameStarted() then
            self.GunGameExp = self.GunGameExp + value
        end
    end
    
    -- Winning condition is passing max available GunGame level (one level above axe)
    function Player:IsWinner()
        return (self.GunGameLevel > kMaxGunGameLevel)
    end

    function Player:ClassAfterRespawn(mapName)
        if mapName ~= nil then
            -- store given player class for respawn
            self.ggData.classAfterRespawn = mapName
        end
        return self.ggData.classAfterRespawn
    end
    
    function Player:ExoLayout(layout)
        if layout ~= nil then
            self.ggData.exoLayout = layout
        end
        return self.ggData.exoLayout
    end
    
    function Player:LastTeamNumber(teamNumber)
        if not self.ggData then return kNeutralTeamType end
        if teamNumber ~= nil then
            self.ggData.lastTeamNumber = teamNumber
        end    
        return self.ggData.lastTeamNumber
    end
    
    function Player:LastHumiliationTime(time)
        if not self.ggData then return nil end
        if time ~= nil then
            self.ggData.lastHumiliationTime = time
        end    
        return self.ggData.lastHumiliationTime
    end    
end