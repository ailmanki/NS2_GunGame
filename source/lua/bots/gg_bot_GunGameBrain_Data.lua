--[[
 	GunGame NS2 Mod
	ZycaR (c) 2016
]]

Script.Load("lua/bots/BotDebug.lua")
Script.Load("lua/bots/CommonActions.lua")
Script.Load("lua/bots/BrainSenses.lua")
Script.Load("lua/bots/BotAim.lua")

local gMarineAimJitterAmount = 0.8


local function CreateExploreActionEx( weightIfTargetAcquired, moveToFunction )

    return function(bot, brain)

        local name = "explore"
        local player = bot:GetPlayer()
        local origin = player:GetOrigin()

        local findNew = true
        if brain.exploreTargetId ~= nil then
            local target = Shared.GetEntity(brain.exploreTargetId)
            if target ~= nil then
                local dist = target:GetOrigin():GetDistance(origin)
                if dist > 5.0 then
                    findNew = false
                end
            end
        end
        if findNew and brain.exploreSpawnLocation ~= nil then
            local target = Server.spawnLocationsList[brain.exploreSpawnLocation]
            if target ~= nil then
                local dist = target:GetOrigin():GetDistance(origin)
                if dist > 12.0 then 
                    findNew = false
                end
            end
        end

        if findNew then

            local memories = GetTeamMemories( player:GetTeamNumber() )
            local exploreMems = FilterTable( memories,
                function(mem) return mem.entId ~= brain.exploreTargetId end )

            -- pick one randomly
            if #exploreMems > 0 then
                local targetMem = exploreMems[ math.random(#exploreMems) ]
                brain.exploreTargetId = targetMem.entId
                --Shared.Message("explore target .. " .. tostring(brain.exploreTargetId))
            else
                local spawns = table.count(Server.spawnLocationsList)
                brain.exploreSpawnLocation = Server.spawnLocationsRandomizer:random(1, spawns)
                --Shared.Message("explore spawn .. " .. tostring(brain.exploreSpawnLocation) .. "/" .. tostring(spawns))
            end
        end

        local weight = 0.0
        if brain.exploreTargetId ~= nil or
           brain.exploreSpawnLocation ~= nil then
            weight = weightIfTargetAcquired
        end

        return { name = name, weight = weight,
            perform = function(move)
                local target = brain.exploreTargetId ~= nil and 
                    Shared.GetEntity( brain.exploreTargetId )or
                    Server.spawnLocationsList[brain.exploreSpawnLocation]

                if target then
                    moveToFunction( origin, target:GetOrigin(), bot, brain, move )
                end
            end }
    end
end


-----------------------------------------
--  Phase gates
------------------------------------------
local function FindNearestPhaseGate(fromPos, favoredGateId)

    local gates = GetEntitiesForTeam( "PhaseGate", kMarineTeamType )

    return GetMinTableEntry( gates,
            function(gate)

                assert( gate ~= nil )

                if gate:GetIsBuilt() and gate:GetIsPowered() then

                    local dist = fromPos:GetDistance(gate:GetOrigin())
                    if gate:GetId() == favoredGateId then
                        return dist * 0.9
                    else
                        return dist
                    end

                else
                    return nil
                end

            end)

end

------------------------------------------
--  Returns the distance, maybe using phase gates.
------------------------------------------
local function GetPhaseDistanceForMarine( marinePos, to, lastNearestGateId )

    local p0Dist, p0 = FindNearestPhaseGate(marinePos, lastNearestGateId)
    local p1Dist, p1 = FindNearestPhaseGate(to, nil)
    local euclidDist = marinePos:GetDistance(to)

    -- Favor the euclid dist just a bit..to prevent thrashing
    if p0Dist ~= nil and p1Dist ~= nil and (p0Dist + p1Dist) < euclidDist*0.9 then
        return (p0Dist + p1Dist), p0
    else
        return euclidDist, nil
    end

end


------------------------------------------
--  Handles things like using phase gates
------------------------------------------
local function PerformMove( marinePos, targetPos, bot, brain, move )

    local dist, gate = GetPhaseDistanceForMarine( marinePos, targetPos, brain.lastGateId )

    if gate ~= nil then

        local gatePos = gate:GetOrigin()
        bot:GetMotion():SetDesiredMoveTarget( gatePos )
        bot:GetMotion():SetDesiredViewTarget( nil )
        brain.lastGateId = gate:GetId()

    else

        bot:GetMotion():SetDesiredMoveTarget( targetPos )
        bot:GetMotion():SetDesiredViewTarget( nil )
        brain.lastGateId = nil

    end
end

------------------------------------------
--
------------------------------------------
local function GetCanAttack(marine)
    local weapon = marine:GetActiveWeapon()
    if weapon ~= nil then
        if weapon:isa("ClipWeapon") then
            return weapon:GetAmmo() > 0
        else
            return true
        end
    else
        return false
    end
end

local function PerformAttackEntity( eyePos, target, lastSeenPos, bot, brain, move )
    assert(target ~= nil )

    if not target.GetIsSighted then
        Print("attack target has no GetIsSighted: %s", target:GetClassName() )
        return
    end

    local sighted = target:GetIsSighted()
    local aimPos = sighted and GetBestAimPoint( target ) or lastSeenPos
    local dist = GetDistanceToTouch( eyePos, target )
    local doFire = false

    -- Avoid doing expensive vis check if we are too far
     local hasClearShot = dist < 20.0 and GetBotCanSeeTarget( bot:GetPlayer(), target )

    if not hasClearShot then
        -- just keep moving along the path to find it
        PerformMove( eyePos, aimPos, bot, brain, move )
        doFire = false
    else
        local weapon = bot:GetPlayer():GetActiveWeapon()
        local hasAxe = weapon ~= nil and weapon.GetMapName and weapon:GetMapName() == Axe.kMapName
        
        if dist > 40.0 then
            -- close in on it first without firing
            bot:GetMotion():SetDesiredMoveTarget( aimPos )
            doFire = false
        elseif dist > ConditionalValue(hasAxe, 1.0, 12.0) then
            -- move towards it while firing
            bot:GetMotion():SetDesiredMoveTarget( aimPos )
            doFire = true
        elseif dist < ConditionalValue(hasAxe, 0.1, 3.0) then   -- close enough for axe?
            -- too close - back away while firing
            bot:GetMotion():SetDesiredMoveTarget( nil )
            bot:GetMotion():SetDesiredMoveDirection( -( aimPos-eyePos ) )
            doFire = true
        else
            -- good distance
            -- TODO strafe with some regularity
            
            if not bot.lastStrafe or ( bot.lastStrafe - Shared.GetTime() ) < 0.0 then
                bot.lastStrafe = Shared.GetTime() + 1.0
                --Shared.Message("Strafe change")

                local botToTarget = GetNormalizedVectorXZ( (aimPos - eyePos) )
                local sideVector = botToTarget:CrossProduct(Vector(0, 1, 0))
                if math.random() < 0.5 then
                    bot.strafeOffset = botToTarget + sideVector
                else
                    bot.strafeOffset = botToTarget - sideVector
                end
            end

            if hasAxe then
                bot.strafeOffset = nil 
            end

            bot:GetMotion():SetDesiredMoveTarget( nil )
            bot:GetMotion():SetDesiredMoveDirection( bot.strafeOffset )

            doFire = true
        end
        
        doFire = doFire and bot.aim:UpdateAim(target, aimPos)

    end
    if doFire then
        local player = bot:GetPlayer()
        local weapon = player.GetActiveWeaponMapName and player:GetActiveWeaponMapName()
        if weapon ~= Pistol.kMapName then
            
            local mask = ConditionalValue(player:isa("Exo"), Move.SecondaryAttack, Move.PrimaryAttack)
            move.commands = AddMoveCommand( move.commands, mask )

        elseif not bot.lastAttack or (Shared.GetTime() - bot.lastAttack) > 0.12 then
            bot.lastAttack = Shared.GetTime()
            if HasMoveCommand( move.commands, Move.PrimaryAttack ) then 
                move.commands = RemoveMoveCommand( move.commands, Move.PrimaryAttack )
            else
                move.commands = AddMoveCommand( move.commands, Move.PrimaryAttack )
            end
        end
    else
        bot:GetMotion():SetDesiredViewTarget( nil )
    end
    
    -- Draw a red line to show what we are trying to attack
    if gBotDebug:Get("debugall") or brain.debug then

        if doFire then
            DebugLine( eyePos, aimPos, 0.0,   1,0,0,1, true)
        else
            DebugLine( eyePos, aimPos, 0.0,   1,0.5,0,1, true)
        end

    end

end

------------------------------------------
--
------------------------------------------
local function PerformAttack( eyePos, mem, bot, brain, move )
    assert( mem )
    local target = Shared.GetEntity(mem.entId)
    if target ~= nil then
        PerformAttackEntity( eyePos, target, mem.lastSeenPos, bot, brain, move )
    else
        assert(false)
    end
    brain.teamBrain:AssignBotToMemory(bot, mem)
end

kGunGameBrainActions =
{
    function(bot, brain)

        local name = "medpack"
        local marine = bot:GetPlayer()
        local sdb = brain:GetSenses()

        local weight = 0.0
        local health = sdb:Get("healthFraction")

        local pos = marine:GetOrigin()
        local meds = GetEntitiesWithinRangeAreVisible( "MedPack", pos, 10, true )
        local bestDist, bestMed = GetNearestFiltered( pos, meds )

        if bestMed ~= nil then
            weight = EvalLPF( bestDist, {
                    {0.0, EvalLPF(health, {
                        {0.0, 20.0},
                        {0.8, 1.0},
                        {1.0, 0.0}
                        })},
                    {5.0, EvalLPF(health, {
                        {0.0, 20.0},
                        {0.5, 1.0},
                        {1.0, 0.0}
                        })},
                    {10.0, EvalLPF(health, {
                        {0.0, 20.0},
                        {0.1, 1.0},
                        {1.0, 0.0}
                        })}
                    })
        end

        return { name = name, weight = weight,
                perform = function(move)
                    PerformMove( pos, bestMed:GetOrigin(), bot, brain, move )
                end }
    end,

    function(bot, brain)

        local name = "ammopack"
        local weight = 0.0
        local sdb = brain:GetSenses()
        local marine = bot:GetPlayer()
        local pos = marine:GetOrigin()

        local weapon = marine:GetActiveWeapon()
        local bestPack
        local bestDist

        if weapon ~= nil and weapon:isa("ClipWeapon") then

            local ammo = sdb:Get("ammoFraction")
            local packs = GetEntitiesWithinRangeAreVisible( "AmmoPack", pos, 10, true )

            local function IsPackForWeapon(pack)

                if pack:isa("WeaponAmmoPack") then
                    local weaponClass = pack:GetWeaponClassName()
                    return weapon:GetClassName() == weaponClass
                else
                    return true
                end

            end

            bestDist, bestPack = GetNearestFiltered( pos, packs, IsPackForWeapon )

            if bestPack ~= nil then
                weight = EvalLPF( bestDist, {
                        {0.0, EvalLPF(ammo, {
                            {0.0, 20.0},
                            {0.8, 1.0},
                            {1.0, 0.0}
                            })},
                        {5.0, EvalLPF(ammo, {
                            {0.0, 20.0},
                            {0.5, 1.0},
                            {1.0, 0.0}
                            })},
                        {10.0, EvalLPF(ammo, {
                            {0.0, 20.0},
                            {0.1, 1.0},
                            {1.0, 0.0}
                            })}
                        })
            end
        end

        return { name = name, weight = weight,
                perform = function(move)
                    PerformMove( pos, bestPack:GetOrigin(), bot, brain, move )
                end }
    end,

    function(bot, brain)

        local name = "reload"

        local marine = bot:GetPlayer()
        local weapon = marine:GetActiveWeapon()
        local s = brain:GetSenses()
        local weight = 0.0

        if weapon ~= nil and weapon:isa("ClipWeapon") and s:Get("ammoFraction") > 0.0 then

            local threat = s:Get("biggestThreat")

            if threat ~= nil and threat.distance < 10 and s:Get("clipFraction") > 0.0 then
                -- threat really close, and we have some ammo, shoot it!
                weight = 0.0
            else
                weight = EvalLPF( s:Get("clipFraction"), {
                        { 0.0 , 15 } , 
                        { 0.1 , 0 }  , 
                        { 1.0 , 0 }
                        })
            end
        end

        return { name = name, weight = weight,
            perform = function(move)
                move.commands = AddMoveCommand(move.commands, Move.Reload)
            end }
    end,

    function(bot, brain)

        local name = "attack"

        local marine = bot:GetPlayer()
        local sdb = brain:GetSenses()
        local threat = sdb:Get("biggestThreat")
        local weight = 0.0

        if threat ~= nil and sdb:Get("weaponReady") then

            weight = EvalLPF( threat.distance, {
                        { 0.0, EvalLPF( threat.urgency, {
                            {0, 0},
                            {10, 25}
                            })},
                        { 10.0, EvalLPF( threat.urgency, {
                            {0, 0},
                            {10, 5} })},
                        -- Never let it drop too low - ie. keep it always above explore
                        { 100.0, 0.1 } })
        end


        return { name = name, weight = weight,
            perform = function(move)
                PerformAttack( marine:GetEyePos(), threat.memory, bot, brain, move )
            end }
    end,


    ------------------------------------------
    --
    ------------------------------------------
    CreateExploreActionEx( 0.05, function( pos, targetPos, bot, brain, move )
            if gBotDebug:Get("debugall") or brain.debug then
                DebugLine(bot:GetPlayer():GetEyePos(), targetPos+Vector(0,1,0), 0.0,     0,0,1,1, true)
            end
            PerformMove(pos, targetPos, bot, brain, move)
            end ),

    ------------------------------------------
    --
    ------------------------------------------
    function(bot, brain)
        return { name = "debug idle", weight = 0.01,
                perform = function(move)
                    -- Do a jump..for fun
                    move.commands = AddMoveCommand(move.commands, Move.Jump)
                    bot:GetMotion():SetDesiredViewTarget(nil)
                    bot:GetMotion():SetDesiredMoveTarget(nil)
                end }
    end

}

------------------------------------------
--  More urgent == should really attack it ASAP
------------------------------------------
local function GetAttackUrgency(bot, mem)

    -- attack alive targets
    local target = Shared.GetEntity(mem.entId)
    if not HasMixin(target, "Live") or not target:GetIsAlive() then
        return nil
    end

    -- attack enemy targets
    local player = bot:GetPlayer()
    local targetTeam = HasMixin(target, "Team") and target:GetTeamNumber()
    if targetTeam ~= GetEnemyTeamNumber( player:GetTeamNumber() ) then
        return nil
    end

    -- Closer --> more urgent
    local dist = player:GetOrigin():GetDistance( mem.lastSeenPos )
    local closeBonus = ConditionalValue(dist < 15, ( 10 / math.max(0.01, dist) ), 0)

    local numOthers = ConditionalValue(dist < 15, 0,
        bot.brain.teamBrain:GetNumAssignedTo( mem,
            function(otherId) return ( otherId ~= player:GetId() ) end
        )
    )

    local urgencies =
    {
        [kMinimapBlipType.Marine] = numOthers >= 1 and 0.1 or 1.0,
        [kMinimapBlipType.JetpackMarine] = numOthers >= 2 and 0.1 or 2.0,
        [kMinimapBlipType.Exo] = numOthers >= 3  and 0.1 or 3.0,
    }

    return urgencies[mem.btype] and ( urgencies[mem.btype] + closeBonus ) or nil

end

function CreateGunGameBrainSenses()
    local s = BrainSenses()
    s:Initialize()

    s:Add("clipFraction", function(db)
            local marine = db.bot:GetPlayer()
            local weapon = marine:GetActiveWeapon()
            if weapon ~= nil then
                if weapon:isa("ClipWeapon") then
                    return weapon:GetClip() / weapon:GetClipSize()
                else
                    return 1.0
                end
            else
                return 0.0
            end
            end)

    s:Add("ammoFraction", function(db)
            local marine = db.bot:GetPlayer()
            local weapon = marine:GetActiveWeapon()
            if weapon ~= nil then
                if weapon:isa("ClipWeapon") then
                    return weapon:GetAmmo() / weapon:GetMaxAmmo()
                else
                    return 1.0
                end
            else
                return 0.0
            end
            end)

    s:Add("weaponReady", function(db)
            return db:Get("ammoFraction") > 0 or 
                   db.bot:GetPlayer():isa("Exo")
            end)

    s:Add("healthFraction", function(db)
            local player = db.bot:GetPlayer()
            return ConditionalValue( not player:isa("Exo"), player:GetHealthFraction(), 1.0 )
            end)

    s:Add("biggestThreat", function(db)
            local marine = db.bot:GetPlayer()
            local memories = GetTeamMemories( marine:GetTeamNumber() )
            local maxUrgency, maxMem = GetMaxTableEntry( memories,
                function( mem )
                    return GetAttackUrgency( db.bot, mem )
                end)
            if maxMem ~= nil then
                local dist = marine:GetEyePos():GetDistance(maxMem.lastSeenPos)
                return {urgency = maxUrgency, memory = maxMem, distance = dist}
            else
                return nil
            end
            end)

    return s

end
