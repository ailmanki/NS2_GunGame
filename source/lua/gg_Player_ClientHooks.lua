//
//	GunGame NS2 Mod
//	ZycaR (c) 2016
//

// Hide commander name. "No Commander" message in GunGame by setting transparent color
// Workaround to have always commander is to replace real commander name with "GunGame" text.
function PlayerUI_GetCommanderName()
    return "GunGame"
end