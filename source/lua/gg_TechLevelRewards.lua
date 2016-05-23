//
//	GunGame NS2 Mod
//	ZycaR (c) 2016
//

// ---------------------------------------------
// --- Rewards for GunGame tech level system ---
// ---------------------------------------------

if(not HotReload) then
	GunGameRewards = {}
end

local function InitWeaponsWithAxe(player)
    if player:GetIsAlive() and
       player:GetMapName() ~= Exo.kMapName
    then
        player:DestroyWeapons()
        player:GiveItem(Axe.kMapName)
        player:SetQuickSwitchTarget(Axe.kMapName)
        return true
    end
    return false
end

//
// Level: 1  - Pistol
//
local function GivePistol(player)
    if InitWeaponsWithAxe(player) then
        local kWeaponMap = Pistol.kMapName
        player:GiveItem(kWeaponMap)
        player:SetActiveWeapon(kWeaponMap)
    end
    return Marine.kMapName
end

//
// Level: 2  - Rifle
//
local function GiveRifle(player)
    if InitWeaponsWithAxe(player) then
        local kWeaponMap = Rifle.kMapName
        player:GiveItem(kWeaponMap)
        player:SetActiveWeapon(kWeaponMap)
    end
    return Marine.kMapName
end

//
// Level: 3  - Shotgun
//
local function GiveShotgun(player)
    if InitWeaponsWithAxe(player) then
        local kWeaponMap = Shotgun.kMapName
        player:GiveItem(kWeaponMap)
        player:SetActiveWeapon(kWeaponMap)
    end    
    return Marine.kMapName
end

//
// Level: 4  - GrenadeLauncher
//
local function GiveGrenadeLauncher(player)
    if InitWeaponsWithAxe(player) then
        local kWeaponMap = GrenadeLauncher.kMapName
        player:GiveItem(kWeaponMap)
        player:SetActiveWeapon(kWeaponMap)
    end
    return Marine.kMapName
end

//
// Level: 5  - Rifle & Jetpack
//
local function GiveRifleJetpack(player)
    if InitWeaponsWithAxe(player) then
        local kWeaponMap = Rifle.kMapName
        player:GiveItem(kWeaponMap)
        player:SetActiveWeapon(kWeaponMap)
    end
    return JetpackMarine.kMapName
end

//
// Level: 6  - Shotgun & Jetpack
//
local function GiveShotgunJetpack(player)
    if InitWeaponsWithAxe(player) then
        local kWeaponMap = Shotgun.kMapName
        player:GiveItem(kWeaponMap)
        player:SetActiveWeapon(kWeaponMap)
    end
    return JetpackMarine.kMapName
end

//
// Level: 7  - Railgun Exosuit
//
local function GiveRailgunExo(player)
    player:ExoLayout("ClawRailgun")
    return Exo.kMapName
end

//
// Level: 8  - Minigun Exosuit
//
local function GiveMinigunExo(player)
    player:ExoLayout("ClawMinigun")
    return Exo.kMapName
end

//
// Level: 9  - Grenade & Jetpack
//
local function GiveGrenadeJetpack(player)
    if InitWeaponsWithAxe(player) then
        local kWeaponMap = PulseGrenadeThrower.kMapName
        player:GiveItem(kWeaponMap)
        player:SetActiveWeapon(kWeaponMap)
    end
    return JetpackMarine.kMapName
end

//
// Level: 10  - Axe & Jetpack
//
local function GiveAxeJetpack(player)
    if InitWeaponsWithAxe(player) then
        // no weapon just axe and jetpack
    end
    return JetpackMarine.kMapName    
end


// reset rewards if any, and repopulate for each level
// NextLvl   (integer)  .. How much exp is needed to level-up
// GiveGunFn (function) .. Callback to give guns and set class to player
for k,v in pairs(GunGameRewards) do GunGameRewards[k]=nil end

local icons = kDeathMessageIcon

GunGameRewards[1]  = { NextLvl = 3, GiveGunFn = GivePistol           , Weapon = icons.Pistol       , Type = nil           }
GunGameRewards[2]  = { NextLvl = 3, GiveGunFn = GiveRifle            , Weapon = icons.Rifle        , Type = nil           }
GunGameRewards[3]  = { NextLvl = 3, GiveGunFn = GiveShotgun          , Weapon = icons.Shotgun      , Type = nil           }
GunGameRewards[4]  = { NextLvl = 3, GiveGunFn = GiveGrenadeLauncher  , Weapon = icons.GL           , Type = nil           }
GunGameRewards[5]  = { NextLvl = 3, GiveGunFn = GiveRifleJetpack     , Weapon = icons.Rifle        , Type = icons.Jetpack }
GunGameRewards[6]  = { NextLvl = 3, GiveGunFn = GiveShotgunJetpack   , Weapon = icons.Shotgun      , Type = icons.Jetpack }
GunGameRewards[7]  = { NextLvl = 3, GiveGunFn = GiveRailgunExo       , Weapon = icons.Railgun      , Type = nil           }
GunGameRewards[8]  = { NextLvl = 3, GiveGunFn = GiveMinigunExo       , Weapon = icons.Minigun      , Type = nil           }
GunGameRewards[9]  = { NextLvl = 1, GiveGunFn = GiveGrenadeJetpack   , Weapon = icons.PulseGrenade , Type = icons.Jetpack }
GunGameRewards[10] = { NextLvl = 1, GiveGunFn = GiveAxeJetpack       , Weapon = icons.Axe          , Type = icons.Jetpack }

kMaxGunGameLevel = table.count(GunGameRewards)