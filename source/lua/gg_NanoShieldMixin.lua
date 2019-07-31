--
--	GunGame NS2 Mod
--	ZycaR (c) 2016
--

kNanoShieldDelay = 0.1

-- modify nanoshield activation to force start after specific period of time
local ns2_ActivateNanoShield = NanoShieldMixin.ActivateNanoShield
function NanoShieldMixin:ActivateNanoShield()

    -- clear sound effect if activate twice
    -- NOTE: When player respawns and change class to exo it produces errors on server.
    if Server and self.shieldLoopSound then
        DestroyEntity(self.shieldLoopSound)
        self.shieldLoopSound = nil
    end

    ns2_ActivateNanoShield(self)
    self.nanoShielded = false
end

function NanoShieldMixin:GetIsNanoShielded()
    if Server and not self.nanoShielded and 
       self.timeNanoShieldInit ~= nil and 
       self.timeNanoShieldInit ~= 0 
    then
        self.nanoShielded = self.timeNanoShieldInit + kNanoShieldDelay < Shared.GetTime()
    end

    return self.nanoShielded 
end
