//
//	GunGame NS2 Mod
//	ZycaR (c) 2016
//

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

    local ns2_EndGame = NS2Gamerules.EndGame
    function NS2Gamerules:EndGame(player)
        if GetGamerules():GetGameStarted() then
            
            Shared.Message("Player " .. player:GetName() .. " win GunGame round")
            PostGameViz("GunGame Ends Winner:" .. player:GetName())

            // call it draw (internally)
            self:SetGameState(kGameState.Draw)
            // bloadcast custom network message that game ends
            SendGunGameEndNetworkMessage(player)
            
            self.team1:SetFrozenState(true)
            self.team2:SetFrozenState(true)

            self.team1:ClearRespawnQueue()
            self.team2:ClearRespawnQueue()

            -- Clear out Draw Game window handling
            self.team1Lost = nil
            self.team2Lost = nil
            self.timeDrawWindowEnds = nil
            
            -- Automatically end any performance logging when the round has ended.
            Shared.ConsoleCommand("p_endlog")
        end
    end
    
    local ns2_CheckGameStart = NS2Gamerules.CheckGameStart
    function NS2Gamerules:CheckGameStart()
   
        if self:GetGameState() == kGameState.NotStarted or self:GetGameState() == kGameState.PreGame then
            -- Start pre-game when both teams have players or when once side does if cheats are enabled
            local team1Players = self.team1:GetNumPlayers()
            local team2Players = self.team2:GetNumPlayers()
            
            if (team1Players > 0 and team2Players > 0) or (Shared.GetCheatsEnabled() and (team1Players > 0 or team2Players > 0)) then
                if self:GetGameState() == kGameState.NotStarted then
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
    
    // no tech points to be updated
    local ns2_UpdateTechPoints = NS2Gamerules.UpdateTechPoints
    function NS2Gamerules:UpdateTechPoints()
    end

    // customized constants (varions tweaks)
    local ns2_GetPregameLength = NS2Gamerules.GetPregameLength
    function NS2Gamerules:GetPregameLength()
        return ConditionalValue(Shared.GetCheatsEnabled(), 0, kGunGamePregameLength)
    end

    // do not check for commanders    
    local function ggCheckForNoCommander(self, onTeam, commanderType)
    end
    ReplaceLocals(NS2Gamerules.OnUpdate, { CheckForNoCommander = ggCheckForNoCommander })
end
----------------    
-- End Server --
----------------