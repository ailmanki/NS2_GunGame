--
--	GunGame NS2 Mod
--	ZycaR (c) 2016
--

-- Hide commander name. "No Commander" message in GunGame by setting transparent color
-- Workaround to have always commander is to replace real commander name with "GunGame" text.
function PlayerUI_GetCommanderName()
    return "GunGame"
end

-- fix a bug with top bar
function Player:UpdateDamageIndicators()
    
    local indicesToRemove = {}
    
    if self.damageIndicators then
        -- Expire old damage indicators
        for index, indicatorTriple in ipairs(self.damageIndicators) do
            
            if Shared.GetTime() > (indicatorTriple[3] + Player.kDamageIndicatorDrawTime) then
                
                table.insert(indicesToRemove, index)
            
            end
        
        end
    end
    for i, index in ipairs(indicesToRemove) do
        table.remove(self.damageIndicators, index)
    end
    
    -- update damage given
    if self.giveDamageTimeClientCheck ~= self.giveDamageTime then
        
        self.giveDamageTimeClientCheck = self.giveDamageTime
        self.giveDamageTimeClient = Shared.GetTime()
        
        self.showDamage = self:GetShowDamageIndicator()
        if self.showDamage then
            self:OnGiveDamage()
        end
    
    end

end


function PlayerUI_GetDamageIndicators()
    
    local drawIndicators = {}
    
    local player = Client.GetLocalPlayer()
    if player and player.damageIndicators then
        
        for index, indicatorTriple in ipairs(player.damageIndicators) do
            
            local alpha = Clamp(1 - ((Shared.GetTime() - indicatorTriple[3])/Player.kDamageIndicatorDrawTime), 0, 1)
            table.insert(drawIndicators, alpha)
            
            local worldX = indicatorTriple[1]
            local worldZ = indicatorTriple[2]
            
            local normDirToDamage = GetNormalizedVector(Vector(player:GetOrigin().x, 0, player:GetOrigin().z) - Vector(worldX, 0, worldZ))
            local worldToView = player:GetViewAngles():GetCoords():GetInverse()
            
            local damageDirInView = worldToView:TransformVector(normDirToDamage)
            
            local directionRadians = math.atan2(damageDirInView.x, damageDirInView.z)
            if directionRadians < 0 then
                directionRadians = directionRadians + 2 * math.pi
            end
            
            table.insert(drawIndicators, directionRadians)
        
        end
    
    end
    
    return drawIndicators

end