//
//	GunGame NS2 Mod
//	ZycaR (c) 2016
//

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

    self:SetHealth(data.health)
    self:SetMaxArmor(data.armor)
    self:SetArmor(data.armor)
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

if Client then

	function Player:InitializeSkin()
		local teamNum = self:GetTeamNumber()
		
		self.skinColoringEnabled = true
		self.skinBaseColor = self:GetBaseSkinColor(teamNum)
		self.skinAccentColor = self:GetAccentSkinColor(teamNum)
		self.skinTrimColor = self:GetTrimSkinColor(teamNum)
		
    	if teamNum ~= kTeamReadyRoom then
			self.skinAtlasIndex = teamNum - 1
		else
			self.skinAtlasIndex = 0 // Clamp( self.previousTeamNumber - 1, 0, kTeam2Index )
		end

--[[
        local function DumpColor(color)
            return "(R:"..color.r..";G:"..color.g..";B:"..color.b..")"
        end
        Print("BaseSkinColor: " .. DumpColor(self.skinBaseColor) )
        Print("SkinAtlasIndex: " .. self.skinAtlasIndex )
        Print("SkinColoringEnabled: " .. ConditionalValue(self.skinColoringEnabled, "true", "false" ) )
--]]
	end
	
	function Player:GetBaseSkinColor(teamNum)
		if self.previousTeamNumber == kTeam1Index or self.previousTeamNumber == kTeam2Index and teamNum == kTeamReadyRoom then
			return ConditionalValue( self.previousTeamNumber == kTeam1Index, kTeam1_BaseColor, kTeam2_BaseColor )
		elseif teamNum == kTeam1Index or teamNum == kTeam2Index then
			return ConditionalValue( teamNum == kTeam1Index, kTeam1_BaseColor, kTeam2_BaseColor )
		else
			return kNeutral_BaseColor
		end		
	end

	function Player:GetAccentSkinColor(teamNum)
		if self.previousTeamNumber == kTeam1Index or self.previousTeamNumber == kTeam2Index and teamNum == kTeamReadyRoom then
			return ConditionalValue( self.previousTeamNumber == kTeam1Index, kTeam1_AccentColor, kTeam2_AccentColor )
		elseif teamNum == kTeam1Index or teamNum == kTeam2Index then
			return ConditionalValue( teamNum == kTeam1Index, kTeam1_AccentColor, kTeam2_AccentColor )
		else
			return kNeutral_AccentColor
		end
	end
	
	function Player:GetTrimSkinColor(teamNum)
		if self.previousTeamNumber == kTeam1Index or self.previousTeamNumber == kTeam2Index and teamNum == kTeamReadyRoom then
			return ConditionalValue( self.previousTeamNumber == kTeam1Index, kTeam1_TrimColor, kTeam2_TrimColor )
		elseif teamNum == kTeam1Index or teamNum == kTeam2Index then
			return ConditionalValue( teamNum == kTeam1Index, kTeam1_TrimColor, kTeam2_TrimColor )
		else
			return kNeutral_TrimColor
		end
	end
end

function Marine:GetActiveWeaponMapName()
    local activeWeapon = self:GetActiveWeapon()
    return ConditionalValue(activeWeapon, activeWeapon:GetMapName(), nil)
end

// Don't drop weapons .. it's GunGame not charity.
// It should destroy them, but for now just override Marine:Drop()
Class_ReplaceMethod("Marine", "Drop", 
    function(self, weapon, ignoreDropTimeLimit, ignoreReplacementWeapon)
	    return true // do nothing
    end
)

// fix because it switch players to first team only
Class_ReplaceMethod("MarineSpectator", "OnCreate", 
    function(self)
        TeamSpectator.OnCreate(self)
        //self:SetTeamNumber(1)
        if Client then
            InitMixin(self, TeamMessageMixin, { kGUIScriptName = "GUIMarineTeamMessage" })
        end
    end
)

Class_ReplaceMethod("MarineSpectator", "OnInitialized", 
    function(self)
        TeamSpectator.OnInitialized(self)
        //self:SetTeamNumber(1)
    end
)