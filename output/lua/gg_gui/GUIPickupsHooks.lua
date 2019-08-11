--
--	GunGame NS2 Mod
--	ZycaR (c) 2016
--

-- show on closer range, that powerups are not so obvious
local kPickupsVisibleRange = 9

local function gg_GetNearbyPickups()
    local localPlayer = Client.GetLocalPlayer()
    if localPlayer and localPlayer:GetIsOnPlayingTeam() then
        local function PickupableFilterFunction(entity)
            return entity:GetIsValidRecipient(localPlayer)
        end
        return Shared.GetEntitiesWithTagInRange("Pickupable", localPlayer:GetOrigin(),
            kPickupsVisibleRange, PickupableFilterFunction)
    end
    return nil
end
ReplaceLocals(GUIPickups.Update, { GetNearbyPickups = gg_GetNearbyPickups })