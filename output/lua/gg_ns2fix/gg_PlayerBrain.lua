--[[
 	GunGame NS2 Mod
	ZycaR (c) 2016
]]

-- fix for "spectator" entities without selectable mixin
function PlayerBrain:GetShouldDebug(bot)
	local player = bot:GetPlayer()
    local isSelected = HasMixin(player, "Selectable") and ( player:GetIsSelected( kMarineTeamType ) or player:GetIsSelected( kAlienTeamType ) )

    if isSelected and gDebugSelectedBots then
        return true
    elseif self.targettedForDebug then
        return true
    else
        return false
    end
end
