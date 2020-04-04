--[[
 	GunGame NS2 Mod
	ZycaR (c) 2016
]]

------------
-- Server --
------------
if (Server) then

    local ns2_OnMapPostLoad = NS2Gamerules.OnMapPostLoad
    function NS2Gamerules:OnMapPostLoad()
        ns2_OnMapPostLoad(self)
        kNanoShieldDuration = ConditionalValue(self.SpawnProtectionTime ~= nil, 
            self.SpawnProtectionTime, kSpawnProtectionTime)
    end

    local ns2_BuildTeam = NS2Gamerules.BuildTeam
    function NS2Gamerules:BuildTeam(teamType)
        return GunGameTeam()
    end
    
    local function GetTeamSkills()
        local averagePlayerSkills = {
            [kMarineTeamType] = {},
            [kAlienTeamType] = {},
            [3] = {},
        }
        
        for _, player in ipairs(GetEntitiesWithMixin("Scoring")) do
            
            local skill = player:GetPlayerSkill() and math.max(player:GetPlayerSkill(), 0)
            -- DebugPrint("%s skill: %s", ToString(player:GetName()), ToString(skill))
            
            if skill then
                
                local teamType = HasMixin(player, "Team") and player:GetTeamType() or -1
                if teamType == kMarineTeamType or teamType == kAlienTeamType then
                    table.insert(averagePlayerSkills[teamType], skill)
                end
                
                table.insert(averagePlayerSkills[3], skill)
            
            end
        
        end
        
        averagePlayerSkills[kMarineTeamType].mean = table.mean(averagePlayerSkills[kMarineTeamType])
        averagePlayerSkills[kAlienTeamType].mean = table.mean(averagePlayerSkills[kAlienTeamType])
        averagePlayerSkills[3].mean = table.mean(averagePlayerSkills[3])
        
        averagePlayerSkills[kMarineTeamType].median = table.median(averagePlayerSkills[kMarineTeamType])
        averagePlayerSkills[kAlienTeamType].median = table.median(averagePlayerSkills[kAlienTeamType])
        averagePlayerSkills[3].median = table.median(averagePlayerSkills[3])
        
        averagePlayerSkills[kMarineTeamType].standardDeviation = table.standardDeviation(averagePlayerSkills[kMarineTeamType])
        averagePlayerSkills[kAlienTeamType].standardDeviation = table.standardDeviation(averagePlayerSkills[kAlienTeamType])
        averagePlayerSkills[3].standardDeviation = table.standardDeviation(averagePlayerSkills[3])
        
        return averagePlayerSkills
    end
    
    local ns2_EndGame = NS2Gamerules.EndGame
    function NS2Gamerules:EndGame(player)
        if GetGamerules():GetGameStarted() then
            
            -- call it draw (internally)
            self:SetGameState(kGameState.Draw)
    
            Shared.Message("Player " .. player:GetName() .. " wins GunGame round")
            PostGameViz("GunGame Winner:" .. player:GetName())
        
            -- bloadcast custom network message that game ends
            SendGunGameEndNetworkMessage(player)
            
            --self.team1:SetFrozenState(true)
            --self.team2:SetFrozenState(true)

            self.team1:ClearRespawnQueue()
            self.team2:ClearRespawnQueue()

            -- Clear out Draw Game window handling
            self.team1Lost = nil
            self.team2Lost = nil
            self.timeDrawWindowEnds = nil
    
            local entityList = Shared.GetEntitiesWithClassname("GameInfo")
            if entityList:GetSize() > 0 then
                local gameInfo = entityList:GetEntityAtIndex(0)
                local gameLength = math.max( 0, math.floor(Shared.GetTime()) - gameInfo:GetStartTime() )
        
                gameInfo.prevTimeLength = gameLength
                gameInfo.prevWinner = player:GetName()
                gameInfo.prevTeamsSkills = GetTeamSkills()
                --Client.showFeedback = true
           
            end
            
            -- Automatically end any performance logging when the round has ended.
            Shared.ConsoleCommand("p_endlog")
        end
    end
    
    local ns2_CheckGameStart = NS2Gamerules.CheckGameStart
    function NS2Gamerules:CheckGameStart()
   
        -- it's ordered int enum (less or equal than pregame means game not started yet)
        if self:GetGameState() <= kGameState.PreGame then
            -- Start pre-game when both teams have players or when once side does if cheats are enabled
            local team1Players = self.team1:GetNumPlayers()
            local team2Players = self.team2:GetNumPlayers()
            
            if (team1Players > 0 and team2Players > 0) or (Shared.GetCheatsEnabled() and (team1Players > 0 or team2Players > 0)) then
                if self:GetGameState() < kGameState.PreGame then
                    self:SetGameState(kGameState.PreGame)
                end
            elseif self:GetGameState() == kGameState.PreGame then
                self:SetGameState(kGameState.NotStarted)
            end
        end   
    end

    local ns2_CheckGameEnd = NS2Gamerules.CheckGameEnd
    function NS2Gamerules:CheckGameEnd()
        PROFILE("GunGameGamerules:CheckGameEnd")
        if self:GetGameStarted() and self.timeGameEnded == nil and not Shared.GetCheatsEnabled() then

            local winner1 = self.team1:GetWinner()
            local winner2 = self.team2:GetWinner()
            local winner = ConditionalValue(winner1 ~= nil, winner1, winner2 )
            
            if winner ~= nil then
                self:EndGame(winner)
            end
        end
    end
    
    local ns2_GetCanSpawnImmediately = NS2Gamerules.GetCanSpawnImmediately
    function NS2Gamerules:GetCanSpawnImmediately()
        return true
    end
    
    -- no tech points to be updated
    local ns2_UpdateTechPoints = NS2Gamerules.UpdateTechPoints
    function NS2Gamerules:UpdateTechPoints()
    end

    -- customized constants (varions tweaks)
    local ns2_GetPregameLength = NS2Gamerules.GetPregameLength
    function NS2Gamerules:GetPregameLength()
        return ConditionalValue(Shared.GetCheatsEnabled(), 0, kGunGamePregameLength)
    end

    -- do not check for commanders
    local function ggCheckForNoCommander(self, onTeam, commanderType)
    end
    ReplaceLocals(NS2Gamerules.OnUpdate, { CheckForNoCommander = ggCheckForNoCommander })
end
----------------    
-- End Server --
----------------