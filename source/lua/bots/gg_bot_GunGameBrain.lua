--[[
 	GunGame NS2 Mod
	ZycaR (c) 2016
]]

Script.Load("lua/bots/PlayerBrain.lua")
Script.Load("lua/bots/gg_bot_GunGameBrain_Data.lua")

gGunGameBrains = {}

class 'GunGameBrain' (PlayerBrain)

function GunGameBrain:Initialize()
    PlayerBrain.Initialize(self)
    self.senses = CreateGunGameBrainSenses()
    table.insert(gGunGameBrains, self)

    self.expectedPlayerClass = nil
    self.expectedTeamNumber = nil

end

function GunGameBrain:Update( bot, move )

    if gBotDebug:Get("spam") then
        Print("GunGameBrain:Update")
    end

    if PlayerBrain.Update( self, bot, move ) == false then
        return false
    end

    local player = bot:GetPlayer()
    self.expectedPlayerClass = player:GetClassName()
    self.expectedTeamNumber = player:GetTeamNumber()

    PlayerBrain.Update( self, bot, move )
end

function GunGameBrain:GetExpectedPlayerClass()
    return self.expectedPlayerClass or "Marine"
end

function GunGameBrain:GetExpectedTeamNumber()
    return self.expectedTeamNumber or kMarineTeamType
end

function GunGameBrain:GetActions()
    return kGunGameBrainActions
end

function GunGameBrain:GetSenses()
    return self.senses
end