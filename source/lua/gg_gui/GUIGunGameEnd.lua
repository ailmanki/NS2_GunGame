--
--	GunGame NS2 Mod
--	ZycaR (c) 2016
--

Script.Load("lua/GUIAnimatedScript.lua")

class 'GUIGunGameEnd' (GUIAnimatedScript)

PrecacheAsset('ui/alien_buyslot.dds')

local kTexture = { dds = "ui/GUIGunGameEnd.dds", width = 1024, height = 256 }
local kPosition = Vector(-kTexture.width / 2, -kTexture.height / 2, 0)

local kMessageFont = Fonts.kAgencyFB_Large
local kMessageColor = Color(1, 0.625, 0, 1)
local kMessageOffset = Vector(0, -69, 0)

function GUIGunGameEnd:Initialize()
    GUIAnimatedScript.Initialize(self)
    
    self.gunGameEndSprite = self:CreateAnimatedGraphicItem()
    self.gunGameEndSprite:SetColor(Color(1, 1, 1, 0))
    self.gunGameEndSprite:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.gunGameEndSprite:SetLayer(kGUILayerPlayerHUD)
    self.gunGameEndSprite:SetInheritsParentAlpha(true)
    self.gunGameEndSprite:SetIsScaling(false)
    self.gunGameEndSprite:SetIsVisible(false)

    self.winnerMessageText = self:CreateAnimatedTextItem()
    self.winnerMessageText:SetColor(kMessageColor)
    self.winnerMessageText:SetAnchor(GUIItem.Middle, GUIItem.Bottom)
    self.winnerMessageText:SetLayer(kGUILayerPlayerHUD)
    self.winnerMessageText:SetInheritsParentAlpha(true)
    self.winnerMessageText:SetIsScaling(false)
    self.winnerMessageText:SetTextAlignmentX(GUIItem.Align_Center)
    self.winnerMessageText:SetTextAlignmentY(GUIItem.Align_Center)
    self.winnerMessageText:SetFontName(kMessageFont)
    
    self.gunGameEndSprite:AddChild(self.winnerMessageText)
end

function GUIGunGameEnd:ShowGunGameEnd(team, winrar)

    self.gunGameEndSprite:DestroyAnimations()
    self.gunGameEndSprite:SetIsVisible(true)

    local invisibleFunc = function() self.gunGameEndSprite:SetIsVisible(false) end
    local fadeOutFunc = function() self.gunGameEndSprite:FadeOut(0.2, nil, AnimateLinear, invisibleFunc) end
    local pauseFunc = function() self.gunGameEndSprite:Pause(6, nil, nil, fadeOutFunc) end
    self.gunGameEndSprite:FadeIn(1.0, nil, AnimateLinear, pauseFunc)
    
    self.gunGameEndSprite:SetTexture(kTexture.dds)
    self.gunGameEndSprite:SetPosition(kPosition * GUIScale(1))
    self.gunGameEndSprite:SetSize(Vector(GUIScale(kTexture.width), GUIScale(kTexture.height), 0))
    
    self.winnerMessageText:SetScale(GetScaledVector())
    GUIMakeFontScale(self.winnerMessageText)
    self.winnerMessageText:SetPosition(kMessageOffset * GUIScale(1))
    self.winnerMessageText:SetText(winrar)
end

function GUIGunGameEnd:Uninitialize()
    if self.winnerMessageText then
        GUI.DestroyItem(self.winnerMessageText)
    end
    self.winnerMessageText = nil

    if self.gunGameEndSprite then
        GUI.DestroyItem(self.gunGameEndSprite)
    end
    self.gunGameEndSprite = nil

    GUIAnimatedScript.Uninitialize(self)
end