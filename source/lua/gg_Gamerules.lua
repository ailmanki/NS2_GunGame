//
//	GunGame NS2 Mod
//	ZycaR (c) 2016
//

------------
-- Server --
------------
if (Server) then

    local ns2_BuildTeam = NS2Gamerules.BuildTeam
    local ns2_EndGame = NS2Gamerules.EndGame
    local ns2_CheckGameStart = NS2Gamerules.CheckGameStart
    local ns2_CheckGameEnd = NS2Gamerules.CheckGameEnd
    local ns2_GetCanSpawnImmediately = NS2Gamerules.GetCanSpawnImmediately
    local ns2_UpdateTechPoints = NS2Gamerules.UpdateTechPoints
    
    function NS2Gamerules:BuildTeam(teamType)
        return GunGameTeam()
    end

    function NS2Gamerules:EndGame(player)
        if self:GetGameState() == kGameState.Started then
            
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

    function NS2Gamerules:CheckGameEnd()
        PROFILE("GunGameGamerules:CheckGameEnd")
        if self:GetGameStarted() and self.timeGameEnded == nil and not Shared.GetCheatsEnabled() then

            local winner1 = self.team1:GetWinner()
            local winner2 = self.team2:GetWinner()
            local winner = ConditionalValue((winner1 ~= nil), winner1, winner2 )
            
            if winner ~= nil then
                self:EndGame(winner)
            end
        end
    end
    
    function NS2Gamerules:GetCanSpawnImmediately()
        return true
    end
    
    // no tech points to be updated
    function NS2Gamerules:UpdateTechPoints()
    end

    // do not check for commanders    
    local function ggCheckForNoCommander(self, onTeam, commanderType)
    end
    ReplaceLocals(NS2Gamerules.OnUpdate, { CheckForNoCommander = ggCheckForNoCommander })

    // customized constants to speed up game start and end (varions tweaks)
    ReplaceLocals(NS2Gamerules.UpdatePregame, { preGameTime = kGunGamePregameLength })
    ReplaceLocals(NS2Gamerules.UpdateToReadyRoom, { kTimeToReadyRoom = kGunGameTimeToReadyRoom })

end
----------------    
-- End Server --
----------------

