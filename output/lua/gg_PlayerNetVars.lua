--[[
 	GunGame NS2 Mod
	ZycaR (c) 2016
]]


-- don't delete old network vars, simply replace them if their type has changed or add them if new
local networkVarsExt = {
    GunGameLevel = "integer (0 to 99)",
    GunGameExp   = "integer (0 to 10)"
}

Shared.LinkClassToMap("Player", Player.kMapName, networkVarsExt)
