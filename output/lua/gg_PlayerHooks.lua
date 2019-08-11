--
--	GunGame NS2 Mod
--	ZycaR (c) 2016
--

Script.Load("lua/Class.lua")
Script.Load("lua/Player.lua")

HeathAndArmorLUT = {
    [Marine.kMapName]         = { health = kMarineHealth,  armor = kMarineArmor  },
    [JetpackMarine.kMapName]  = { health = kJetpackHealth, armor = kJetpackArmor },
    [Exo.kMapName]            = { health = kExosuitHealth, armor = kExosuitArmor }
}

function Player:ResetHeathAndArmor()
    local mapName = self:GetMapName()
    local data = HeathAndArmorLUT[mapName]
    
    if data then
        self:SetHealth(data.health)
        self:SetMaxArmor(data.armor)
        self:SetArmor(data.armor)
    end
end

local ns2_Player_OnCreate, gg_Player_OnCreate
gg_Player_OnCreate = function(self)
    ns2_Player_OnCreate(self)
    
    if Server then
        self:ResetGunGameData()
    elseif Client then
		InitMixin( self, ColoredSkinsMixin )
	end
end
ns2_Player_OnCreate = Class_ReplaceMethod("Player", "OnCreate", gg_Player_OnCreate)

local ns2_Player_OnInitialized, gg_Player_OnInitialized
gg_Player_OnInitialized = function(self)
	ns2_Player_OnInitialized(self)
	
	if Client then
		self:InitializeSkin()
	end
end
ns2_Player_OnInitialized = Class_ReplaceMethod("Player", "OnInitialized", gg_Player_OnInitialized)

local ns2_Player_OnJoinTeam, gg_Player_OnJoinTeam
gg_Player_OnJoinTeam = function(self)

	ns2_Player_OnJoinTeam(self)
	
	local teamNumber = self:GetTeamNumber()
	local lastTeamNumber = self:LastTeamNumber()
	
	if self:GetIsOnPlayingTeam() and self:GetGameStarted() and
	   (lastTeamNumber == kTeam1Index or lastTeamNumber == kTeam2Index)
    then
	    self:LastTeamNumber(teamNumber)
	    self:AdjustExp(kRejoinGunGamePenalty)
        self.GunGameSpawnProtection = true
        self:AdjustGunGameData(true)

        local message = "You lost kill(s) for rejoining the game!"
        local chat = BuildChatMessage(true, "[GunGame]", -1, kTeamReadyRoom, kNeutralTeamType, message)
	    Server.SendNetworkMessage(self, "Chat", chat, true)
    end
    
end
ns2_Player_OnJoinTeam = Class_ReplaceMethod("Player", "OnJoinTeam", gg_Player_OnJoinTeam)

if Client then

	function Player:InitializeSkin()
		local teamNumber = self:GetTeamNumber()
		
		self.skinColoringEnabled = true
        self.skinAtlasIndex = ConditionalValue(teamNumber ~= kTeamReadyRoom, teamNumber - 1, 0)

		self.skinBaseColor = self:GetBaseSkinColor(teamNumber)
		self.skinAccentColor = self:GetAccentSkinColor(teamNumber)
		self.skinTrimColor = self:GetTrimSkinColor(teamNumber)

--[[
        local function DumpColor(color)
            return "(R:"..color.r..";G:"..color.g..";B:"..color.b..")"
        end
        Print("BaseSkinColor: " .. DumpColor(self.skinBaseColor) )
        Print("SkinAtlasIndex: " .. self.skinAtlasIndex )
        Print("SkinColoringEnabled: " .. ConditionalValue(self.skinColoringEnabled, "true", "false" ) )
--]]
	end
	
	function Player:GetBaseSkinColor(teamNumber)
		if teamNumber == kTeam1Index or teamNumber == kTeam2Index then
			return ConditionalValue( teamNumber == kTeam1Index, kTeam1_BaseColor, kTeam2_BaseColor )
		else
			return kNeutral_BaseColor
		end		
	end

	function Player:GetAccentSkinColor(teamNumber)
		if teamNumber == kTeam1Index or teamNumber == kTeam2Index then
			return ConditionalValue( teamNumber == kTeam1Index, kTeam1_AccentColor, kTeam2_AccentColor )
		else
			return kNeutral_AccentColor
		end
	end
	
	function Player:GetTrimSkinColor(teamNumber)
		if teamNumber == kTeam1Index or teamNumber == kTeam2Index then
			return ConditionalValue( teamNumber == kTeam1Index, kTeam1_TrimColor, kTeam2_TrimColor )
		else
			return kNeutral_TrimColor
		end
	end
end

function Marine:GetActiveWeaponMapName()
    local activeWeapon = self:GetActiveWeapon()
    return activeWeapon ~= nil and activeWeapon.GetMapName and activeWeapon:GetMapName() or nil
end

-- Don't drop weapons .. it's GunGame not charity.
-- It should destroy them, but for now just override Marine:Drop()
Class_ReplaceMethod("Marine", "Drop", 
    function(self, weapon, ignoreDropTimeLimit, ignoreReplacementWeapon)
	    return true -- do nothing
    end
)

-- Don't eject from exo .. same story as dropping weapons
Class_ReplaceMethod("Exo", "GetCanEject", 
    function(self)
        return false
    end
)

-- fix because it switch players to first team only
Class_ReplaceMethod("MarineSpectator", "OnCreate", 
    function(self)
        TeamSpectator.OnCreate(self)
        --self:SetTeamNumber(1)
        if Client then
            InitMixin(self, TeamMessageMixin, { kGUIScriptName = "GUIMarineTeamMessage" })
        end
    end
)

Class_ReplaceMethod("MarineSpectator", "OnInitialized", 
    function(self)
        TeamSpectator.OnInitialized(self)
        --self:SetTeamNumber(1)
    end
)