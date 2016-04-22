//
//	GunGame NS2 Mod
//	ZycaR (c) 2016
//

do
    // Server & Client tweaks
    ModLoader.SetupFileHook( "lua/Player.lua", "lua/gg_PlayerNetVars.lua" , "post" )
    ModLoader.SetupFileHook( "lua/NanoShieldMixin.lua", "lua/gg_NanoShieldMixin.lua" , "post" )

    // GUI & HUD tweaks
    
    // Outline for power-ups
    ModLoader.SetupFileHook( "lua/GUIPickups.lua", "lua/gg_gui/GUIPickupsHooks.lua" , "post" )
    
    // Hide "NO COMMANDER" text
    ModLoader.SetupFileHook( "lua/Hud/Marine/GUIMarineHUD.lua", "lua/gg_gui/GUIMarineHUDHooks.lua" , "post" )
    ModLoader.SetupFileHook( "lua/Player_Client.lua", "lua/gg_Player_ClientHooks.lua" , "post" )
end