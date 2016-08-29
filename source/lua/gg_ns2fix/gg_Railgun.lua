--[[
 	GunGame NS2 Mod
	ZycaR (c) 2016
]]

-- fix for "SetBypassRagdoll" players without Ragdoll mixin
if Server then
    function Railgun:OnDamageDone(doer, target)
        if doer == self and 
           target:isa("Player") and
           HasMixin(target, "Ragdoll") and
           not target:GetIsAlive()
        then
            target:SetBypassRagdoll(true)
        end
    end
end
