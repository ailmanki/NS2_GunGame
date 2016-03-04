//
//	GunGame NS2 Mod
//	ZycaR (c) 2016
//


Script.Load("lua/Globals.lua")
Script.Load("lua/GUIAnimatedScript.lua")

class 'GUIGunGameProgress' (GUIAnimatedScript)

kExpIconSpacing = 0.75
kInactiveAlpha = 0.25
kActiveAlpha = 0.75

function GUIGunGameProgress:Initialize(client)
    GUIAnimatedScript.Initialize(self)
    
    self.lastGunGameLevel = nil
    self.levelProgress = {}
    
    self.lastGunGameExp = nil
    self.expProgress = {}

    return self
end

function GUIGunGameProgress:Uninitialize()
    GUIAnimatedScript.Uninitialize(self)
    
    //self:DestroyLevelProgress()
    self:DestroyExpProgress()
end

local function GetGunGameData()
    local player = Client.GetLocalPlayer()
    if player then
        return player.GunGameLevel, player.GunGameExp
    else
        return 1, 0
    end
end

function GUIGunGameProgress:Update(deltaTime)

    local lvl, exp = GetGunGameData()
    
    if lvl and lvl ~= self.lastGunGameLevel then
        self.lastGunGameLevel = lvl
        
        local reward = GunGameRewards[self.lastGunGameLevel]
        if reward ~= nil and reward.NextLvl ~= table.count(self.expProgress) then
            self:DestroyExpProgress()
            self:CreateExpProgress(reward.NextLvl)
        end
        
        Print("@@@ GunGameLevel=[ "..lvl.." / "..kMaxGunGameLevel.."]")
    end    
    
    if exp ~= nil and exp ~= self.lastGunGameExp then
        
        self.lastGunGameExp = exp

        for index, icon in ipairs(self.expProgress) do
            local opacity = ConditionalValue(self.lastGunGameExp >= index, kIActiveAlpha, kInactiveAlpha)
            icon:SetColor(Color(1, 1, 1, opacity))
        end
    end
end

function GUIGunGameProgress:DestroyExpProgress()

    for i, icon in ipairs(self.expProgress) do
        if icon then GUI.DestroyItem(icon) end
    end
    
    self.expProgress = {}
end

function GUIGunGameProgress:CreateExpProgress(maxCount)

    for index = maxCount - 1, 0 , -1 do
    
        local icon = GUIManager:CreateGraphicItem()
        
        // skull image
        icon:SetTexturePixelCoordinates(0, 0, kInventoryIconTextureWidth, kInventoryIconTextureHeight)

        icon:SetLayer(kGUILayerPlayerHUD)
        icon:SetSize(Vector(GUIScale(kInventoryIconTextureWidth), GUIScale(kInventoryIconTextureHeight), 0))
        icon:SetAnchor(GUIItem.Right, GUIItem.Bottom)
        icon:SetTexture(kInventoryIconsTexture)
        icon:SetInheritsParentAlpha(true)
        icon:SetIsVisible(true)
        icon:SetColor(Color(1, 1, 1, kInactiveAlpha))
        
        local offsetX = -GUIScale(kInventoryIconTextureWidth * kExpIconSpacing * index + kInventoryIconTextureWidth)
        local offsetY = -GUIScale(kInventoryIconTextureHeight * 2)
        icon:SetPosition(Vector(offsetX, offsetY, 0))
        
        table.insert(self.expProgress, icon)
    end

end