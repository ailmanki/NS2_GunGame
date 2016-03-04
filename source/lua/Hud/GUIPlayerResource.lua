//
//	GunGame NS2 Mod
//	ZycaR (c) 2016
//
// override for original lua\GUIPlayerResource.lua

Script.Load("lua/gg_gui/GUIGunGameProgress.lua")

class 'GUIPlayerResource'

function CreatePlayerResourceDisplay(scriptHandle, hudLayer, frame, style)
    local result = GUIPlayerResource()

    result.GunGameProgress = GUIGunGameProgress()
    result.GunGameProgress:Initialize()

    return result
end

function GUIPlayerResource:Reset(scale)
    //self.GunGameProgress:Reset(scale)
end

function GUIPlayerResource:Update(deltaTime, parameters)
    self.GunGameProgress:Update(deltaTime)
end

function GUIPlayerResource:OnAnimationCompleted(animatedItem, animationName, itemHandle)
    //self.GunGameProgress:OnAnimationCompleted(animatedItem, animationName, itemHandle)
end

function GUIPlayerResource:Destroy()
    if self.GunGameProgress then
        self.GunGameProgress:Uninitialize()
        self.GunGameProgress = nil
    end
end


