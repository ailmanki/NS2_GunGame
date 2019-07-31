--
--	GunGame NS2 Mod
--	ZycaR (c) 2016
--

Script.Load("lua/Class.lua")

-- Hide commander name. "No Commander" message in GunGame
GUIMarineHUD.kActiveCommanderColor = Color(0, 0, 0, 0)

local ns2_GUIMarineHUD_Update, gg_GUIMarineHUD_Update
gg_GUIMarineHUD_Update = function(self, deltaTime)
    ns2_GUIMarineHUD_Update(self, deltaTime)

	self.commanderName:SetIsVisible(false)
end
ns2_GUIMarineHUD_Update = Class_ReplaceMethod("GUIMarineHUD", "Update", gg_GUIMarineHUD_Update)


