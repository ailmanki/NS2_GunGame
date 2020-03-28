--
--	GunGame NS2 Mod
--	ZycaR (c) 2016
--

-- ---------------------------------------------
-- --- Rewards for GunGame tech level system ---
-- ---------------------------------------------

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

--
-- Level: Pistol
--
local function GivePistol(player)
    if InitWeaponsWithAxe(player) then
        local kWeaponMap = Pistol.kMapName
        player:GiveItem(kWeaponMap)
        player:SetActiveWeapon(kWeaponMap)
    end
    return Marine.kMapName
end

--
-- Level: Rifle
--
local function GiveRifle(player)
    if InitWeaponsWithAxe(player) then
        local kWeaponMap = Rifle.kMapName
        player:GiveItem(kWeaponMap)
        player:SetActiveWeapon(kWeaponMap)
    end
    return Marine.kMapName
end

--
-- Level: Shotgun
--
local function GiveShotgun(player)
    if InitWeaponsWithAxe(player) then
        local kWeaponMap = Shotgun.kMapName
        player:GiveItem(kWeaponMap)
        player:SetActiveWeapon(kWeaponMap)
    end    
    return Marine.kMapName
end

--
-- Level: GrenadeLauncher
--
local function GiveGrenadeLauncher(player)
    if InitWeaponsWithAxe(player) then
        local kWeaponMap = GrenadeLauncher.kMapName
        player:GiveItem(kWeaponMap)
        player:SetActiveWeapon(kWeaponMap)
    end
    return Marine.kMapName
end

--
-- Level: Flamethrower
--
local function GiveFlamethrower(player)
    if InitWeaponsWithAxe(player) then
        local kWeaponMap = Flamethrower.kMapName
        player:GiveItem(kWeaponMap)
        player:SetActiveWeapon(kWeaponMap)
    end
    return Marine.kMapName
end

--
-- Level: HeavyMachineGun
--
local function GiveHeavyMachineGun(player)
    if InitWeaponsWithAxe(player) then
        local kWeaponMap = HeavyMachineGun.kMapName
        player:GiveItem(kWeaponMap)
        player:SetActiveWeapon(kWeaponMap)
    end
    return Marine.kMapName
end

--
-- Level: Rifle & Jetpack
--
local function GiveRifleJetpack(player)
    if InitWeaponsWithAxe(player) then
        local kWeaponMap = Rifle.kMapName
        player:GiveItem(kWeaponMap)
        player:SetActiveWeapon(kWeaponMap)
    end
    return JetpackMarine.kMapName
end

--
-- Level: Shotgun & Jetpack
--
local function GiveShotgunJetpack(player)
    if InitWeaponsWithAxe(player) then
        local kWeaponMap = Shotgun.kMapName
        player:GiveItem(kWeaponMap)
        player:SetActiveWeapon(kWeaponMap)
    end
    return JetpackMarine.kMapName
end

--
-- Level: Railgun Exosuit
--
local function GiveRailgunExo(player)
    player:ExoLayout("ClawRailgun")
    return Exo.kMapName
end

local function GiveDualRailgunExo(player)
    player:ExoLayout("RailgunRailgun")
    return Exo.kMapName
end
--
-- Level: Minigun Exosuit
--
local function GiveMinigunExo(player)
    player:ExoLayout("ClawMinigun")
    return Exo.kMapName
end

local function GiveDualMinigunExo(player)
    player:ExoLayout("MinigunMinigun")
    return Exo.kMapName
end
--
-- Level: Grenade & Jetpack
--
local function GiveGrenadeJetpack(player)
    if InitWeaponsWithAxe(player) then
        local kWeaponMap = PulseGrenadeThrower.kMapName
        player:GiveItem(kWeaponMap)
        player:SetActiveWeapon(kWeaponMap)
    end
    return JetpackMarine.kMapName
end

--
-- Level: Axe & Jetpack
--
local function GiveAxeJetpack(player)
    if InitWeaponsWithAxe(player) then
        -- no weapon just axe and jetpack
    end
    return JetpackMarine.kMapName    
end

-- reset rewards if any, and repopulate for each level
-- NextLvl   (integer)  .. How much exp is needed to level-up
-- GiveGunFn (function) .. Callback to give guns and set class to player
for k,v in pairs(GunGameRewards) do GunGameRewards[k]=nil end

local icons = kDeathMessageIcon
local kPulseGrenade = icons.PulseGrenade

GunGameRewards[#GunGameRewards + 1]  = { NextLvl = 3, GiveGunFn = GivePistol           , Weapon = icons.Pistol          , Type = nil           }
GunGameRewards[#GunGameRewards + 1]  = { NextLvl = 3, GiveGunFn = GiveRifle            , Weapon = icons.Rifle           , Type = nil           }
GunGameRewards[#GunGameRewards + 1]  = { NextLvl = 3, GiveGunFn = GiveShotgun          , Weapon = icons.Shotgun         , Type = nil           }
GunGameRewards[#GunGameRewards + 1]  = { NextLvl = 3, GiveGunFn = GiveFlamethrower     , Weapon = icons.Flamethrower    , Type = nil      }
GunGameRewards[#GunGameRewards + 1]  = { NextLvl = 3, GiveGunFn = GiveHeavyMachineGun  , Weapon = icons.HeavyMachineGun , Type = nil   }
GunGameRewards[#GunGameRewards + 1]  = { NextLvl = 3, GiveGunFn = GiveGrenadeLauncher  , Weapon = icons.GL              , Type = nil           }
GunGameRewards[#GunGameRewards + 1]  = { NextLvl = 3, GiveGunFn = GiveRifleJetpack     , Weapon = icons.Rifle           , Type = icons.Jetpack }
GunGameRewards[#GunGameRewards + 1]  = { NextLvl = 3, GiveGunFn = GiveShotgunJetpack   , Weapon = icons.Shotgun         , Type = icons.Jetpack }
GunGameRewards[#GunGameRewards + 1]  = { NextLvl = 3, GiveGunFn = GiveRailgunExo       , Weapon = icons.Claw            , Type = icons.Railgun    }
GunGameRewards[#GunGameRewards + 1]  = { NextLvl = 3, GiveGunFn = GiveDualRailgunExo   , Weapon = icons.Railgun         , Type =  icons.Railgun}
GunGameRewards[#GunGameRewards + 1]  = { NextLvl = 3, GiveGunFn = GiveMinigunExo       , Weapon = icons.Claw            , Type = icons.Minigun    }
GunGameRewards[#GunGameRewards + 1]  = { NextLvl = 3, GiveGunFn = GiveDualMinigunExo   , Weapon = icons.Minigun         , Type = icons.Minigun }
GunGameRewards[#GunGameRewards + 1] =  { NextLvl = 1, GiveGunFn = GiveGrenadeJetpack   , Weapon = kPulseGrenade         , Type = icons.Jetpack }
GunGameRewards[#GunGameRewards + 1] =  { NextLvl = 1, GiveGunFn = GiveAxeJetpack       , Weapon = icons.Axe             , Type = icons.Jetpack }

kMaxGunGameLevel = table.count(GunGameRewards)

function GetCanGiveGrenade(player)
    local reward = GunGameRewards[player.GunGameLevel]
    return reward ~= nil and reward.Weapon == kPulseGrenade and
           table.maxn(GetChildEntities(player, "PulseGrenadeThrower")) < 1
end