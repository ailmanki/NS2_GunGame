--
--	GunGame NS2 Mod
--	ZycaR (c) 2016
--
-- override for original lua\GUIPlayerResource.lua

Script.Load("lua/gg_gui/GUIGunGameProgress.lua")

class 'GUIPlayerResource'

GUIPlayerResource.kTresTextFontName = Fonts.kAgencyFB_Small

GUIPlayerResource.kTeam1TextPos = Vector(20, 360, 0)
GUIPlayerResource.kTeam2TextPos = Vector(20, 540, 0)

function CreatePlayerResourceDisplay(scriptHandle, hudLayer, frame, style)
    local result = GUIPlayerResource()
	
    result.GunGameProgress = GUIGunGameProgress()
    result.GunGameProgress:Initialize()

	-- for NS2+ (and other mods) to supply expected child elements
	result.script = scriptHandle
    result.hudLayer = hudLayer
    result.frame = frame
	result:Initialize(style)

    return result
end

-- for NS2+ (and other mods) to supply expected child elements
function GUIPlayerResource:Initialize(style, teamNumber)
    self.style = style
    self.teamNumber = teamNumber
    self.scale = 1
    self.lastPersonalResources = 0
	
    self.background = self.script:CreateAnimatedGraphicItem()
    self.rtCount = GetGUIManager():CreateGraphicItem()
    self.personalIcon = self.script:CreateAnimatedGraphicItem()
    self.personalText = self.script:CreateAnimatedTextItem()
    self.pResDescription = self.script:CreateAnimatedTextItem()
    self.ResGainedText = self.script:CreateAnimatedTextItem()
    self.teamText = self.script:CreateAnimatedTextItem()
end

function GUIPlayerResource:Reset(scale)
    --self.GunGameProgress:Reset(scale)
end

function GUIPlayerResource:Update(deltaTime, parameters)
    self.GunGameProgress:Update(deltaTime)
end

function GUIPlayerResource:OnAnimationCompleted(animatedItem, animationName, itemHandle)
    --self.GunGameProgress:OnAnimationCompleted(animatedItem, animationName, itemHandle)
end

function GUIPlayerResource:Destroy()
    if self.GunGameProgress then
        self.GunGameProgress:Uninitialize()
        self.GunGameProgress = nil
    end
end


