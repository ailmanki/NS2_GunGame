--[[
 	GunGame NS2 Mod
	ZycaR (c) 2016
]]

Script.Load("lua/bots/gg_bot_GunGameBrain.lua")

function PlayerBot:_LazilyInitBrain()

    if self.brain == nil then
        local player = self:GetPlayer()

        if player:isa("Marine") or player:isa("JetpackMarine") or player:isa("Exo") then
            self.brain = GunGameBrain()
        elseif player:isa("Skulk") then
            self.brain = SkulkBrain()
        elseif player:isa("Gorge") then
            self.brain = GorgeBrain()
        elseif player:isa("Lerk") then
            self.brain = LerkBrain()
        elseif player:isa("Fade") then
            self.brain = FadeBrain()
        elseif player:isa("Onos") then
            self.brain = OnosBrain()
        end

        if self.brain ~= nil then
            self.brain:Initialize()
            self:GetPlayer().botBrain = self.brain
            self.aim = BotAim()
            self.aim:Initialize(self)
        end

    else

        -- destroy brain if we are ready room
        if self:GetPlayer():isa("ReadyRoomPlayer") then
            self.brain = nil
            self:GetPlayer().botBrain = nil
        end

    end

end