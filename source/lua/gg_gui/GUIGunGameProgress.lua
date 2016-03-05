//
//	GunGame NS2 Mod
//	ZycaR (c) 2016
//


Script.Load("lua/Globals.lua")
Script.Load("lua/GUIAnimatedScript.lua")

class 'GUIGunGameProgress' (GUIAnimatedScript)

kInactiveAlpha = 0.25
kActiveAlpha = 0.75

function GUIGunGameProgress:Initialize(client)
    GUIAnimatedScript.Initialize(self)
    
    self.lastGunGameLevel = nil
    self.levelProgress = {}
    
    self.lastGunGameExp = nil
    self.expProgress = {}

    self:CreateLvlProgress(kMaxGunGameLevel)
    self:CreateExpProgress(1)
    return self
end

function GUIGunGameProgress:Uninitialize()
    GUIAnimatedScript.Uninitialize(self)
    
    self:DestroyLvlProgress()
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

local function CreateProgressIcon(index, scale)
    local w, h = kInventoryIconTextureWidth, kInventoryIconTextureHeight
    
    local icon = GUIManager:CreateGraphicItem()
    icon:SetLayer(kGUILayerPlayerHUD)
    icon:SetTexture(kInventoryIconsTexture)
    icon:SetInheritsParentAlpha(false)
    icon:SetIsVisible(true)
    
    // choose icon by index
    local offset = index * kInventoryIconTextureHeight
    icon:SetTexturePixelCoordinates(0, offset - h, w, offset)

    icon:SetSize(Vector(GUIScale(w * scale), GUIScale(h * scale), 0))
    icon:SetColor(Color(1, 1, 1, kInactiveAlpha))
    
    return icon
end

function GUIGunGameProgress:Update(deltaTime)

    local lvl, exp = GetGunGameData()
    
    if lvl and lvl ~= self.lastGunGameLevel then
        self:SetLvlProgress(lvl)
        
        local reward = GunGameRewards[self.lastGunGameLevel]
        if reward ~= nil and reward.NextLvl ~= table.count(self.expProgress) then
            self:DestroyExpProgress()
            self:CreateExpProgress(reward.NextLvl)
        end
        
        Print("@@@ GunGameLevel=[ "..lvl.." / "..kMaxGunGameLevel.."]")
    end    
    
    if exp ~= nil and exp ~= self.lastGunGameExp then

        self:SetExpProgress(exp)
    end
end

function GUIGunGameProgress:SetExpProgress(exp)

    self.lastGunGameExp = exp
    for index, icon in ipairs(self.expProgress) do
        local opacity = ConditionalValue(exp >= index, kActiveAlpha, kInactiveAlpha)
        icon:SetColor(Color(1, 1, 1, opacity))
    end

end

function GUIGunGameProgress:DestroyExpProgress()

    for i, icon in ipairs(self.expProgress) do
        if icon then GUI.DestroyItem(icon) end
    end
    self.expProgress = {}
    
end

function GUIGunGameProgress:CreateExpProgress(maxCount)

    local kSpacing = 256 / maxCount
    local offsetX = 32 + kInventoryIconTextureWidth * 0.75
    local offsetY = 48 + kInventoryIconTextureHeight * 0.5
 
    for index = maxCount - 1, 0 , -1 do
        // skull image (index == 1)
        local icon = CreateProgressIcon(1, 0.75)
        icon:SetAnchor(GUIItem.Right, GUIItem.Bottom)
        icon:SetPosition(Vector(-GUIScale(offsetX + kSpacing * index), -GUIScale(offsetY), 0))
        table.insert(self.expProgress, icon)
    end

end

function GUIGunGameProgress:SetLvlProgress(lvl)

    self.lastGunGameLevel = lvl
    
    local color
    for index, icon in ipairs(self.levelProgress) do

        local color = Color(1, 1, 1, kInactiveAlpha)
        if lvl == index then
            color = Color(1.0, 0.651, 0.255, kActiveAlpha)
        elseif lvl > index then
            color = Color(1, 1, 1, kActiveAlpha)
        end

        if icon.weapon ~= nil then icon.weapon:SetColor(color) end
        if icon.type ~= nil then icon.type:SetColor(color) end

    end
    
end

function GUIGunGameProgress:DestroyLvlProgress()

    for i, icon in ipairs(self.levelProgress) do
        if icon.weapon then GUI.DestroyItem(icon.weapon) end
        if icon.type ~= nil then GUI.DestroyItem(icon.type) end
    end
    self.levelProgress = {}

end

function GUIGunGameProgress:CreateLvlProgress(maxCount)

    local w, h = kInventoryIconTextureWidth, kInventoryIconTextureHeight

    local kSpacing = 640 / maxCount
    local offsetX = 320 + w * 0.5
    local offsetY = 48 + h * 0.5

    for index = 1, maxCount do

        // GunGame data for specified level
        local reward = GunGameRewards[index]
        
        local icon = CreateProgressIcon(reward.Weapon, 0.5)
        icon:SetAnchor(GUIItem.Middle, GUIItem.Bottom)

        local stacking = offsetY
        local playerType = nil
        if reward.Type ~= nil then
            stacking = 48 + h * 0.65
            playerType = CreateProgressIcon(reward.Type, 0.5)
            playerType:SetAnchor(GUIItem.Left, GUIItem.Bottom)
            icon:AddChild(playerType)
        end
        
        icon:SetPosition(Vector(-GUIScale(offsetX - kSpacing * index), -GUIScale(stacking), 0))
        self.levelProgress[index] = { weapon = icon, type = playerType }
    end
end