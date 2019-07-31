--[[
 	GunGame NS2 Mod
	ZycaR (c) 2016
]]

if Client then
    -- create gui scripts for client only
    Script.Load("lua/gg_gui/GUIGunGameEnd.lua")
end

-- Custome message when game ends
local kGunGameEnd =
{
    team = "integer (0 to 2)",
    winrar = "string (32)"
}
Shared.RegisterNetworkMessage("GunGameEnd", kGunGameEnd)

if Server then
    
    -- Broadcast custom network message to GUI that game ends
    function SendGunGameEndNetworkMessage(winrar)
        local teamNumber = winrar.GetTeamNumber and winrar:GetTeamNumber()
        local winrarName = winrar.GetName and winrar:GetName()
        local ggMessage = {
            team = ConditionalValue(teamNumber == kTeam1Index or teamNumber == kTeam2Index, teamNumber, kNeutralTeamType),
            winrar = ConditionalValue(winrarName ~= nil, winrarName, "- ??? -")
        }
        Server.SendNetworkMessage( "GunGameEnd", ggMessage, true)    
    end

elseif Client then

    function OnGunGameEnd(msg)
        if Client.GetLocalPlayer() then
            local guiGunGameEnd = GetGUIManager():CreateGUIScript("gg_gui/GUIGunGameEnd")
            if guiGunGameEnd and guiGunGameEnd.ShowGunGameEnd then
                guiGunGameEnd:ShowGunGameEnd(msg.team, msg.winrar)
            end
            Client.PlayMusic("sound/NS2.fev/victory")
        end

        -- Automatically end any performance logging when the round is done.
        Shared.ConsoleCommand("p_endlog")
    end

    Client.HookNetworkMessage("GunGameEnd", OnGunGameEnd)
end
