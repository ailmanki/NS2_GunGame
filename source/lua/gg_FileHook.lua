//
//	GunGame NS2 Mod
//	ZycaR (c) 2016
//

do
    // for both server & Client
    ModLoader.SetupFileHook( "lua/Player.lua", "lua/gg_PlayerNetVars.lua" , "post" )
    ModLoader.SetupFileHook( "lua/NanoShieldMixin.lua", "lua/gg_NanoShieldMixin.lua" , "post" )    
    ModLoader.SetupFileHook( "lua/GUIPickups.lua", "lua/gg_gui/GUIPickupsHooks.lua" , "post" )    
end