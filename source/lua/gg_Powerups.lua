//
//	GunGame NS2 Mod
//	ZycaR (c) 2016
//

class 'Powerups' (Entity)

Powerups.kMapName = "powerups"

local networkVars = {}
local kPowerupDrop = { ClassName = "CatPack", MapName = CatPack.kMapName, Sound = CatPack.kPickupSound }

local function TriggerPowerup(self, timePassed)

    local position = Vector(self:GetOrigin())
    if GetGamerules():GetGameStarted() and
       not self:GetHasDrop(position)
    then
        CreateEntity(self.drop.MapName, position)
        StartSoundEffectAtOrigin(self.drop.Sound, position)
    end
    
    return true
end

function Powerups:GetHasDrop(position)
    return #GetEntitiesWithinRange(self.drop.ClassName, position, self.dropRadius) > 0
end

function Powerups:OnCreate()
    Entity.OnCreate(self)
    self:SetPropagate(Entity.Propagate_Never)
end

function Powerups:OnInitialized()
    Entity.OnInitialized(self)
    
    self.drop = kPowerupDrop
    self.dropRadius = Clamp(self.dropRadius, 1.0, 100.0)
    self.dropRate = Clamp(self.dropRate, 12, 360)

    if Server then
        self:AddTimedCallback(TriggerPowerup, self.dropRate)
    end
end

if Server then 
    -- Override to allow pickup powerups for both teams
    local ns2_DropPack_OnUpdate, gg_DropPack_OnUpdate
    gg_DropPack_OnUpdate = function(self, deltaTime)
        ns2_DropPack_OnUpdate(self, deltaTime)

        local playersNearby = GetEntitiesWithinRange( "Player", self:GetOrigin(), self.pickupRange )
        Shared.SortEntitiesByDistance(self:GetOrigin(), playersNearby)

        for _, player in ipairs(playersNearby) do
            if player:GetIsOnPlayingTeam() and
               not player:isa("Commander") and  
               self:GetIsValidRecipient(player)
        then
                self:OnTouch(player)
                DestroyEntity(self)
                break
            end
        end        
    end
    ns2_DropPack_OnUpdate = Class_ReplaceMethod("DropPack", "OnUpdate", gg_DropPack_OnUpdate)
end

Shared.LinkClassToMap("Powerups", Powerups.kMapName, networkVars)