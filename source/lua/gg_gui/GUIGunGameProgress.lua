--
--	GunGame NS2 Mod
--	ZycaR (c) 2016
--


Script.Load("lua/Globals.lua")
Script.Load("lua/GUIAnimatedScript.lua")

class 'GUIGunGameProgress' (GUIAnimatedScript)

kInactiveAlpha = 0.25
kActiveAlpha = 0.75
kGameNotStartedColor = Color(1.0, 0.0, 0.0, 0.5)

function GUIGunGameProgress:Initialize(client)
    GUIAnimatedScript.Initialize(self)
    
    self.lastGunGameLevel = nil
    self.levelProgress = {}
    
    self.lastGunGameExp = nil
    self.expProgress = {}
    
    self.lastGameStarted = false

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
        local ingame = player:GetGameStarted()
        return player.GunGameLevel, player.GunGameExp, ingame
    else
        return 1, 0, false
    end
end

local function CreateProgressIcon(index, scale)
    local w, h = kInventoryIconTextureWidth, kInventoryIconTextureHeight
    
    local icon = GUIManager:CreateGraphicItem()
    icon:SetLayer(kGUILayerPlayerHUD)
    icon:SetTexture(kInventoryIconsTexture)
    icon:SetInheritsParentAlpha(false)
    icon:SetIsVisible(true)
    
    -- choose icon by index
    local offset = index * kInventoryIconTextureHeight
    icon:SetTexturePixelCoordinates(0, offset - h, w, offset)

    icon:SetSize(Vector(GUIScale(w * scale), GUIScale(h * scale), 0))
    icon:SetColor(Color(1, 1, 1, kInactiveAlpha))
    
    return icon
end

function GUIGunGameProgress:Update(deltaTime)

    local lvl, exp, ingame = GetGunGameData()
    
    if (lvl and lvl ~= self.lastGunGameLevel) or
       (self.lastGameStarted ~= ingame)
    then
        self:SetLvlProgress(lvl, ingame)
        
        local reward = GunGameRewards[self.lastGunGameLevel]
        if reward ~= nil and reward.NextLvl ~= table.count(self.expProgress) then
            self:DestroyExpProgress()
            self:CreateExpProgress(reward.NextLvl)
        end

    end    
    
    if (exp ~= nil and exp ~= self.lastGunGameExp) or
       (self.lastGameStarted ~= ingame)
    then
        self:SetExpProgress(exp, ingame)
    end
    
    self.lastGameStarted = ingame
end

function GUIGunGameProgress:SetExpProgress(exp, ingame)

    self.lastGunGameExp = exp
    for index, icon in ipairs(self.expProgress) do
        local opacity = ConditionalValue(exp >= index, kActiveAlpha, kInactiveAlpha)
        -- different colors of skulls to indicate that game is running or not
        local color = ConditionalValue(ingame, Color(1, 1, 1, opacity), kGameNotStartedColor)
        icon:SetColor(color)
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
        -- skull image (index == 1)
        local icon = CreateProgressIcon(1, 0.75)
        icon:SetAnchor(GUIItem.Right, GUIItem.Bottom)
        icon:SetPosition(Vector(-GUIScale(offsetX + kSpacing * index), -GUIScale(offsetY), 0))
        table.insert(self.expProgress, icon)
    end

end

function GUIGunGameProgress:SetLvlProgress(lvl, ingame)

    self.lastGunGameLevel = lvl
    
    local color
    for index, icon in ipairs(self.levelProgress) do

        local color = Color(1, 1, 1, kInactiveAlpha)
        if lvl == index then
            color = Color(1.0, 0.651, 0.255, kActiveAlpha)
        elseif lvl > index then
            color = Color(1, 1, 1, kActiveAlpha)
        end
        
        -- different (red) color to indicate that game is not running
        if not ingame and lvl ~= index then
            color = kGameNotStartedColor
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

    local kSpacing = 64
    local offsetX = 32 * maxCount + w * 0.5
    local offsetY = 48 + h * 0.5

    for index = 1, maxCount do

        -- GunGame data for specified level
        local reward = GunGameRewards[index]
        
        local icon = CreateProgressIcon(reward.Weapon, 0.5)
        icon:SetAnchor(GUIItem.Middle, GUIItem.Bottom)

        local stacking = offsetY
        local playerType
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