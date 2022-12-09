-------------------------------------------------------------------------------
--	File     : /maps/scca_coop_r06.remastered/SCCA_Coop_R06_script.lua
-- 	Author(s): Jessica St. Croix
--
-- 	Summary  : Main mission flow script for SCCA_Coop_R06
--
-- 	Copyright © 2006 Gas Powered Games, Inc.  All rights reserved.
-------------------------------------------------------------------------------
local Objectives = import('/lua/ScenarioFramework.lua').Objectives
local OpStrings = import('/maps/scca_coop_r06.remastered/SCCA_Coop_R06_strings.lua')
local ScenarioFramework = import('/lua/scenarioframework.lua')
local ScenarioPlatoonAI = import('/lua/scenarioplatoonai.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local Weather = import('/lua/weather.lua')
local M1AeonAI = import('/maps/scca_coop_r06.remastered/SCCA_Coop_R06_M1AeonAI.lua')
local M3AeonAI = import('/maps/scca_coop_r06.remastered/SCCA_Coop_R06_M3AeonAI.lua')
local M2UEFAI = import('/maps/scca_coop_r06.remastered/SCCA_Coop_R06_M2UEFAI.lua')
local M3UEFAI = import('/maps/scca_coop_r06.remastered/SCCA_Coop_R06_M3UEFAI.lua')
local M1CybranAI = import('/maps/scca_coop_r06.remastered/SCCA_Coop_R06_M1CybranAI.lua')
local CustomFunctions = import('/maps/scca_coop_r06.remastered/SCCA_Coop_R06_CustomFunctions.lua')

local Buff = import('/lua/sim/Buff.lua')

---------
-- Globals
---------
ScenarioInfo.Player1 = 1
ScenarioInfo.Aeon = 2
ScenarioInfo.UEF = 3
ScenarioInfo.BlackSun = 4
ScenarioInfo.Cybran = 5
ScenarioInfo.Player2 = 6
ScenarioInfo.Player3 = 7
ScenarioInfo.Player4 = 8

local Player1 = ScenarioInfo.Player1
local Aeon = ScenarioInfo.Aeon
local UEF = ScenarioInfo.UEF
local BlackSun = ScenarioInfo.BlackSun
local Cybran = ScenarioInfo.Cybran
local Player2 = ScenarioInfo.Player2
local Player3 = ScenarioInfo.Player3
local Player4 = ScenarioInfo.Player4

local Difficulty = ScenarioInfo.Options.Difficulty

local LeaderFaction
local LocalFaction

--Variables for the buffing functions
local AIs = {ScenarioInfo.Aeon, ScenarioInfo.UEF, ScenarioInfo.BlackSun, ScenarioInfo.Cybran}
local BuffCategories = {
	BuildPower = categories.FACTORY  + categories.ENGINEER,
	Economy = categories.ECONOMIC,
}

local aikoTaunt = 1
local arnoldTaunt = 9
local blakeTaunt = 17

--------------------------
-- Objective Reminder Times
--------------------------
local ObjectiveReminderTime = 300
local SubsequentTime = 300

--------------
-- Debug Only!
--------------
local DEBUG = false
local SkipIntro = false

------------------------
-- AI buffing functions
------------------------
---ACUs and sACUs belong to both ECONOMIC and ENGINEER categories.

--Buffs AI factory structures, and engineer units
function BuffAIBuildPower()
	--Build Rate multiplier values, depending on the Difficulty
	local Rate = {1.0, 1.5, 2.0}
	--Buff definitions
	buffDef = Buffs['CheatBuildRate']
	buffAffects = buffDef.Affects
	buffAffects.BuildRate.Mult = Rate[Difficulty]

	while true do
		for i, j in AIs do
			if table.getn(AIs) > 0 then
				local buildpower = ArmyBrains[j]:GetListOfUnits(BuffCategories.BuildPower, false)
				--Check if there is anything to buff
				if table.getn(buildpower) > 0 then
					for k, v in buildpower do
						--Apply buff to the entity if it hasn't been buffed yet
						if not v.BuildBuffed then
							Buff.ApplyBuff( v, 'CheatBuildRate' )
							--New Entity flag which is true if the entity has already been buffed
							v.BuildBuffed = true
						end
					end
				end
			end
		end
		--Do this again after 60 seconds
		WaitSeconds(60)
	end
end

--Buffs resource producing structures, (and ACU variants.)
function BuffAIEconomy()
	--Resource production multipliers, depending on the Difficulty
	local Rate = {2.0, 4.0, 8.0}
	--Buff definitions
	buffDef = Buffs['CheatIncome']
	buffAffects = buffDef.Affects
	buffAffects.EnergyProduction.Mult = Rate[Difficulty]
	buffAffects.MassProduction.Mult = Rate[Difficulty]
	
	while true do
		for i, j in AIs do
			if table.getn(AIs) > 0 then
				local economy = ArmyBrains[j]:GetListOfUnits(BuffCategories.Economy, false)
				--Check if there is anything to buff
				if table.getn(economy) > 0 then
					for k, v in economy do
						--Apply buff to the entity if it hasn't been buffed yet
						if not v.EcoBuffed then
							Buff.ApplyBuff( v, 'CheatIncome' )
							--New Entity flag which is true if the entity has already been buffed
							v.EcoBuffed = true
						end
					end
				end
			end
		end
		--Do this again after 60 seconds
		WaitSeconds(60)
	end
end

----------
-- Startup
----------
function OnPopulate(scenario)
    ScenarioUtils.InitializeScenarioArmies()
    LeaderFaction, LocalFaction = ScenarioFramework.GetLeaderAndLocalFactions()
	Weather.CreateWeather()
	
	if DEBUG then
		ForkThread(SpawnDebugPlayer)
	else
		ForkThread(SpawnPlayer)
	end
	--UEF and Aeon are initialized
    SpawnUEF()
    SpawnAeon()
end

--Dummy AI base is spawned in instead of the player base.
function SpawnDebugPlayer()
	--Dummy AI base
	DebugStartingBase = ScenarioUtils.CreateArmyGroup('Cybran', 'Allied_Debug_Base_D' .. Difficulty)
	
	--Cybran dummy AI
	M1CybranAI.M1CybranDebugBaseAI()
	
    -- Jericho
	ScenarioInfo.Jericho = ScenarioFramework.SpawnCommander('Player1', 'Jericho', false, LOC('{i sCDR_Jericho}'), false, JerichoKilled,
        {'ResourceAllocation', 'NaniteMissileSystem', 'Switchback'})
    ScenarioFramework.CreateUnitGivenTrigger(JerichoGiven, ScenarioInfo.Jericho)
	
	ForkThread(CustomFunctions.EnableStealthOnAir)
end

--Used for normal gameplay
function SpawnPlayer()
	--Player base
	ScenarioUtils.CreateArmyGroup('Player1', 'Base_D' .. Difficulty)
	
    -- Jericho
	ScenarioInfo.Jericho = ScenarioFramework.SpawnCommander('Player1', 'Jericho', false, LOC('{i sCDR_Jericho}'), false, JerichoKilled,
        {'ResourceAllocation', 'NaniteMissileSystem', 'Switchback'})
    ScenarioFramework.CreateUnitGivenTrigger(JerichoGiven, ScenarioInfo.Jericho)
	
	local sonar = ScenarioUtils.CreateArmyUnit('Player1', 'MobileSonar')
    ScenarioFramework.GroupPatrolChain({sonar}, 'Player_Subs_Patrol_Chain')

	-- Player Engineers
	local engineers = ScenarioUtils.CreateArmyGroup('Player1', 'Engineers')
	ScenarioFramework.GroupPatrolChain(engineers, 'Player_Jericho_Patrol_Chain')
		
    -- Player Mobile Defense
	local subs = ScenarioUtils.CreateArmyGroupAsPlatoon('Player1', 'Subs', 'AttackFormation')
	ScenarioFramework.PlatoonPatrolChain(subs, 'Player_Subs_Patrol_Chain')

	local landPatrol1 = ScenarioUtils.CreateArmyGroupAsPlatoon('Player1', 'LandPatrol1', 'AttackFormation')
	ScenarioFramework.PlatoonPatrolChain(landPatrol1, 'Player_Land_Patrol_Chain')

	local landPatrol2 = ScenarioUtils.CreateArmyGroupAsPlatoon('Player1', 'LandPatrol2', 'AttackFormation')
	ScenarioFramework.PlatoonPatrolChain(landPatrol2, 'Player_Land_Patrol_Chain')
	
	local airPatrol = ScenarioUtils.CreateArmyGroupAsPlatoon('Player1', 'AirPatrol', 'ChevronFormation')
	ScenarioFramework.PlatoonPatrolChain(airPatrol, 'Player_Base_Patrol_Chain')
end

function SpawnUEF()
    -- Control Center
    ScenarioInfo.ControlCenter = ScenarioUtils.CreateArmyUnit('BlackSun', 'ControlCenter')
    ScenarioInfo.ControlCenter:SetReclaimable(false)
    ScenarioInfo.ControlCenter:SetCapturable(false)
    ScenarioFramework.PauseUnitDeath(ScenarioInfo.ControlCenter)
    ScenarioFramework.CreateUnitDeathTrigger(ControlCenterDestroyed, ScenarioInfo.ControlCenter)
	
	--Control Center Base
	M2UEFAI.UEFControlCenterAI()
	
    -- UEF Main Base
	M3UEFAI.UEFMainBaseAI()
	M3UEFAI.UEFMainNavalBaseAI()
	
	--UEF Commander
	ScenarioInfo.Aiko = ScenarioFramework.SpawnCommander('UEF', 'Aiko', false, LOC('{i CDR_Aiko}'), false, AikoDestroyed,
        {'DamageStabilization', 'HeavyAntiMatterCannon', 'Shield'})
	ScenarioInfo.Aiko:SetAutoOvercharge(true)
	
	-- Black Sun
    ScenarioInfo.BlackSunWeapon = ScenarioUtils.CreateArmyUnit('BlackSun', 'BlackSun')
    ScenarioInfo.BlackSunWeapon:SetCanTakeDamage(false)
    ScenarioInfo.BlackSunWeapon:SetCanBeKilled(false)
    ScenarioInfo.BlackSunWeapon:SetReclaimable(false)
	
	-- Black Sun support structures
    local support = ScenarioUtils.CreateArmyGroup('BlackSun', 'Black_Sun_Support')
    for k, v in support do
        v:SetReclaimable(false)
        v:SetCapturable(false)
        v:SetUnSelectable(true)
        v:SetDoNotTarget(true)
        v:SetCanTakeDamage(false)
        v:SetCanBeKilled(false)
    end
end

function SpawnAeon()
    -- Aeon Main Base
	M1AeonAI.AeonMainBaseAI()
	
	--Aeon Commander
	ScenarioInfo.Arnold = ScenarioFramework.SpawnCommander('Aeon', 'Arnold', false, LOC('{i CDR_Arnold}'), false, ArnoldDestroyed,
        {'Shield', 'ShieldHeavy', 'HeatSink', 'CrysalisBeam'})
	ScenarioInfo.Arnold:SetAutoOvercharge(true)
	
	--Single Galactic Colossus
    ScenarioInfo.Colossus = ScenarioUtils.CreateArmyUnit('Aeon', 'M2_GC_1')
	ScenarioFramework.GroupPatrolChain({ScenarioInfo.Colossus}, 'AeonBase_Chain')
	ScenarioFramework.CreateUnitDeathTrigger(M1AeonAI.AeonMainColossusDefense, ScenarioInfo.Colossus)
	
    -- Aeon Czar units
    ScenarioInfo.CzarBombers = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'CzarBombers_D' .. Difficulty, 'NoFormation')
    for _, v in ScenarioInfo.CzarBombers:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('Aeon_Chain')))
    end
	
	--Initial Aeon air patrols
	local AirPlatoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'AeonMain_Air_Patrol_D' .. Difficulty, 'NoFormation')
	for _, v in AirPlatoon:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('Aeon_Chain')))
    end
	
	--Initial Aeon naval patrols
	local NavalPlatoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'AeonMain_Naval_Patrol_D' .. Difficulty, 'NoFormation')
	for _, v in NavalPlatoon:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('AeonNaval_Chain')))
    end
end

function OnStart(self)
	--Army colors
	-- Army colors
    ScenarioFramework.SetCybranColor(Player1)
	ScenarioFramework.SetCybranNeutralColor(Cybran)
    ScenarioFramework.SetAeonColor(Aeon)
    ScenarioFramework.SetUEFColor(UEF)
    ScenarioFramework.SetUEFAllyColor(BlackSun)
    local colors = {
        ['Player2'] = {183, 101, 24}, 
        ['Player3'] = {255, 135, 62}, 
        ['Player4'] = {255, 191, 128}
    }
    local tblArmy = ListArmies()
    for army, color in colors do
        if tblArmy[ScenarioInfo[army]] then
            ScenarioFramework.SetArmyColor(ScenarioInfo[army], unpack(color))
        end
    end
	-- Adjust buildable categories for Players
    ScenarioFramework.AddRestrictionForAllHumans(
        -- All non vanilla units
        categories.PRODUCTFA + -- All FA Units
        categories.drlk001 +   -- Cybran T3 Mobile AA
        categories.dra0202 +   -- Corsairs
        categories.drl0204 +   -- Hoplites
        categories.delk002 +   -- UEF T3 Mobile AA
        categories.del0204 +   -- Mongoose
        categories.dea0202 +   -- Janus
        categories.dalk003 +   -- Aeon M3 Mobile AA
        categories.dal0310 +   -- T3 Absolver
        categories.daa0206 +   -- Mercy

        -- Actual mission restrictions
        categories.urb2305 +   -- Cybran Strategic Missile Launcher
        categories.urb4302 +   -- Cybran Strategic Missile Defense
        categories.urs0304 +   -- Cybran Strategic Missile Submarine
		categories.urb2302 +   -- Cybran Long Range Heavy Artillery
        categories.urb0304 +   -- Cybran Quantum Gate
        categories.url0301 +   -- Cybran Sub Commander
        categories.url0402 +   -- Spider Bot

        categories.ueb2305 +   -- UEF Strategic Missile Launcher
        categories.ueb4302 +   -- UEF Strategic Missile Defense
        categories.ues0304 +   -- UEF Strategic Missile Submarine
        categories.ueb0304 +   -- UEF Quantum Gate
        categories.uel0301 +   -- UEF Sub Commander
        categories.uel0401 +   -- Fatboy

        categories.uab2305 +   -- Aeon Strategic Missile Launcher
        categories.uab4302 +   -- Aeon Strategic Missile Defense
        categories.uas0304 +   -- Aeon Strategic Missile Submarine
        categories.uab0304 +   -- Aeon Quantum Gate
        categories.ual0301 +   -- Aeon Sub Commander
        categories.ual0401     -- GC
    )
	
	-- UEF T1 + T2 Engineers + Expansion Packs units
	ScenarioFramework.AddRestriction(UEF, categories.uel0105 + categories.uel0208 + categories.PRODUCTFA + categories.PRODUCTDL)
	-- Aeon T1 + T2 Engineers + Expansion Packs units
	ScenarioFramework.AddRestriction(Aeon, categories.ual0105 + categories.ual0208 + categories.PRODUCTFA + categories.PRODUCTDL)
	
    ScenarioFramework.SetPlayableArea('M1Area', false)

    ScenarioFramework.SetSharedUnitCap(480)
    SetArmyUnitCap(Aeon, 2000)
    SetArmyUnitCap(UEF, 2000)
	
	if not SkipIntro then
        ScenarioFramework.SetPlayableArea('M1Area', false)

        ScenarioFramework.StartOperationJessZoom('CDRZoom', IntroMission1)
    else
        IntroMission1()
    end
end

function JerichoKilled()
    ScenarioFramework.Dialogue(OpStrings.C06_M01_080)
    ScenarioFramework.CDRDeathNISCamera( ScenarioInfo.Jericho, 7 )
end

function JerichoGiven(oldJericho, newJericho)
    ScenarioInfo.Jericho = newJericho
    ScenarioFramework.CreateUnitGivenTrigger(JerichoGiven, ScenarioInfo.Jericho)
end

-----------
-- Mission 1
-----------
function IntroMission1()
    ScenarioInfo.MissionNumber = 1
	
	--Player starting factories
    local landFactories = ScenarioFramework.GetListOfHumanUnits(categories.urb0301, false)
    local airFactories = ScenarioFramework.GetListOfHumanUnits(categories.urb0302, false)
    local seaFactories = ScenarioFramework.GetListOfHumanUnits(categories.urb0303, false)
	IssueClearFactoryCommands(landFactories)
    IssueClearFactoryCommands(airFactories)
    IssueClearFactoryCommands(seaFactories)
    IssueFactoryRallyPoint(landFactories, ScenarioUtils.MarkerToPosition('LandFactoryRally'))
    IssueFactoryRallyPoint(airFactories, ScenarioUtils.MarkerToPosition('AirFactoryRally'))
    IssueFactoryRallyPoint(seaFactories, ScenarioUtils.MarkerToPosition('SeaFactoryRally'))

	--Spawn in player ACUs
    ForkThread(function()
        local tblArmy = ListArmies()
        local i = 1
        while tblArmy[ScenarioInfo['Player' .. i]] do
            ScenarioInfo['Player' .. i .. 'CDR'] = ScenarioFramework.SpawnCommander('Player' .. i, 'Player' .. i .. 'CDR', 'Warp', true, true, PlayerKilled)
            WaitSeconds(2)
            i = i + 1
        end
    end)

    -- Jericho strut
    IssueMove({ScenarioInfo.Jericho}, ScenarioUtils.MarkerToPosition('JerichoDestination'))
	ScenarioFramework.GroupPatrolChain({ScenarioInfo.Jericho}, 'Player_Jericho_Patrol_Chain')
	
    -- After 2 minutes: Jericho VO trigger
    ScenarioFramework.CreateTimerTrigger(M1JerichoVO, 120)

    -- Cybran in Aeon LOS VO trigger
    ScenarioFramework.CreateArmyIntelTrigger(CybranSpotted, ArmyBrains[Aeon], 'LOSNow', false, true, categories.ALLUNITS, true, ArmyBrains[Player1])
	
	ScenarioFramework.Dialogue(OpStrings.C06_M01_010, StartMission1)
end

function StartMission1()
	ScenarioFramework.CreateTimerTrigger(Taunt, Random(300, 450))
	BuildCZAR()

	--------------------------------
    -- Primary Objective - Kill Czar
    --------------------------------
    ScenarioInfo.M1P1 = Objectives.Basic(
        'primary',                          -- type
        'incomplete',                       -- complete
        OpStrings.OpC06_M1P1_Title,         -- title
        OpStrings.OpC06_M1P1_Desc,          -- description
        Objectives.GetActionIcon('kill'),   -- action
        {                                   -- target
            -- Category = categories.uaa0310,
        }
    )
end

function M1JerichoVO()
    if(not ScenarioInfo.Jericho:IsDead()) then
        ScenarioFramework.Dialogue(OpStrings.C06_M01_020)
    else
        ScenarioFramework.Dialogue(OpStrings.C06_M01_022)
    end
end

function CybranSpotted()
    ScenarioFramework.Dialogue(OpStrings.C06_M01_030)
end

-- CZAR, AI builds it, it gets loaded with units and attacks the Control Center
function BuildCZAR()
    ScenarioInfo.CzarEngineer = ScenarioUtils.CreateArmyUnit('Aeon', 'CzarEngineer')

    -- Trigger to kill the Tempest if the engineer dies
    ScenarioFramework.CreateUnitDestroyedTrigger(CzarEngineerDefeated, ScenarioInfo.CzarEngineer)

    local platoon = ArmyBrains[Aeon]:MakePlatoon('', '')
    platoon.PlatoonData = {
        NamedUnitBuild = {'Czar'},
        NamedUnitBuildReportCallback = CzarBuildProgressUpdate,
        NamedUnitFinishedCallback = CzarFullyBuilt,
    }

    ArmyBrains[Aeon]:AssignUnitsToPlatoon(platoon, {ScenarioInfo.CzarEngineer}, 'Support', 'None')

    platoon:ForkAIThread(ScenarioPlatoonAI.StartBaseEngineerThread)
end

local LastUpdate = 0
function CzarBuildProgressUpdate(unit, eng)
    if unit.Dead then
        return
    end

    if not unit.UnitPassedToScript then
        unit.UnitPassedToScript = true
        ScenarioInfo.M1P1:AddUnitTarget(unit)
        ScenarioFramework.CreateUnitDeathTrigger(CzarDefeated, unit)
    end

    local fractionComplete = unit:GetFractionComplete()
    if math.floor(fractionComplete * 100) > math.floor(LastUpdate * 100) then
        LastUpdate = fractionComplete
        CZARBuildPercentUpdate(math.floor(LastUpdate * 100))
    end
end

function CZARBuildPercentUpdate(percent)
    if percent == 25 and not ScenarioInfo.CZAR25Dialogue then
        ScenarioInfo.CZAR25Dialogue = true
        ScenarioFramework.Dialogue(OpStrings.C06_M01_070)
    elseif percent == 50 and not ScenarioInfo.CZAR50Dialogue then
        ScenarioInfo.CZAR50Dialogue = true
        ScenarioFramework.Dialogue(OpStrings.C06_M01_076)
    elseif percent == 75 and not ScenarioInfo.CZARDialogue then
        ScenarioInfo.CZARDialogue = true
        ScenarioFramework.Dialogue(OpStrings.C06_M01_075)
    end
end

function CzarFullyBuilt()
	ScenarioInfo.CzarFullyBuilt = true
	ForkThread(CzarAI)
	--Expand playable area
    ScenarioFramework.SetPlayableArea('M2Area')
	
	--Control Center base will build additional defenses
	if (not ScenarioInfo.ControlCenterExpansionAuthorized) then
		M2UEFAI.M2UEFControlCenterExpansion()
	end

    ScenarioFramework.CreateAreaTrigger(CzarOverLand, 'CzarOverLand', categories.uaa0310, true, false, ArmyBrains[Aeon])
end

function CzarAI()
	ScenarioInfo.Czar = ArmyBrains[Aeon]:GetListOfUnits(categories.uaa0310, false)
	--Check if the Czar actually exists, because this is called even if the Czar is prematurely killed, and throws an error otherwise
	if ScenarioInfo.Czar[1] and not ScenarioInfo.Czar[1].Dead then
		--Load squadron into the Czar
		if ArmyBrains[Aeon]:PlatoonExists(ScenarioInfo.CzarBombers) then
			if table.getn(ScenarioInfo.CzarBombers:GetPlatoonUnits()) > 0 then
				ScenarioInfo.CzarBombers:Stop()
				local units = {}
				for _, unit in ScenarioInfo.CzarBombers:GetPlatoonUnits() do
					if not unit.Dead and not unit:IsUnitState('Attached') then
						table.insert(units, unit)
					end
				end
				IssueTransportLoad(units, ScenarioInfo.Czar[1])
			end
		end

	--Attack the Control Center
    IssueAttack(ScenarioInfo.Czar, ScenarioInfo.ControlCenter)
	--VO to warn of its take-off.
    ScenarioFramework.Dialogue(OpStrings.C06_M01_050)
	--Release squadron on taking damage
    ScenarioFramework.CreateUnitDamagedTrigger(ReleaseBombers, ScenarioInfo.Czar[1])
	end
end

function CzarEngineerDefeated()
    if not ScenarioInfo.CzarFullyBuilt and ScenarioInfo.CzarEngineer.UnitBeingBuilt then
        ScenarioInfo.CzarEngineer.UnitBeingBuilt:Kill()
    end
end

function CzarOverLand()
    if(ScenarioInfo.M1P1.Active) then
        ScenarioFramework.Dialogue(OpStrings.C06_M01_060)
    end
    ForkThread(ReleaseBombers)
end

function ReleaseBombers()
	if ScenarioInfo.BombersReleased then
        return
    end
	ScenarioInfo.BombersReleased = true
	
    IssueClearCommands(ScenarioInfo.Czar)
    IssueTransportUnload(ScenarioInfo.Czar, ScenarioInfo.Czar[1]:GetPosition())
	for _, unit in ScenarioInfo.CzarBombers:GetPlatoonUnits() do
		while not unit.Dead and unit:IsUnitState('Attached') do
			WaitSeconds(0.5)
		end
	end
	if ScenarioInfo.Czar[1] and not ScenarioInfo.Czar[1].Dead then
		IssueAttack(ScenarioInfo.Czar, ScenarioInfo.ControlCenter)
	end
    if(ScenarioInfo.CzarBombers and table.getn(ScenarioInfo.CzarBombers:GetPlatoonUnits()) > 0) then
        ScenarioInfo.CzarBombers:Stop()
        ScenarioInfo.CzarBombers:AggressiveMoveToLocation(ScenarioInfo.ControlCenter:GetPosition())
    end
end

function CzarDefeated()
    ScenarioInfo.M1P1:ManualResult(true)

    -- Make Control Center invulnerable
    ScenarioInfo.ControlCenter:SetCanTakeDamage(false)
    ScenarioInfo.ControlCenter:SetCanBeKilled(false)
    ScenarioInfo.ControlCenter:SetDoNotTarget(true)
	
	-- Rebuild the CZAR to attack players' base
    M1AeonAI.AeonMainCzarBuilder()

    if ScenarioInfo.Czar then
        -- Show the Czar dying, if the Czar was completely built when the player killed it
        local camInfo = {
            blendTime = 1.0,
            holdTime = 8,
            orientationOffset = { math.pi, 0.8, 0 },
            positionOffset = { 0, 0, 0 },
            zoomVal = 150,
        }
        ScenarioFramework.OperationNISCamera( ScenarioInfo.Czar[1], camInfo )
    end

    if(not ScenarioInfo.Arnold:IsDead()) then
        ScenarioFramework.Dialogue(OpStrings.C06_M01_100)
        ScenarioFramework.Dialogue(OpStrings.C06_M01_110, IntroMission2)
    else
        ScenarioFramework.Dialogue(OpStrings.C06_M01_100, IntroMission2)
    end
end

-----------
-- Mission 2
-----------
function IntroMission2()
    ScenarioInfo.MissionNumber = 2

    ScenarioFramework.SetSharedUnitCap(780)
	
	--If the Czar was taken out before completion, the Control Center will get its expanded defenses added here
	if(not ScenarioInfo.ControlCenterExpansionAuthorized) then
		M2UEFAI.M2UEFControlCenterExpansion()
	end
	
	--AI buffs from part 2
	ForkThread(BuffAIBuildPower)
	ForkThread(BuffAIEconomy)
	
	-----------------------
	-- M2 UEF AI functions
	-----------------------
	M2UEFAI.UEFDefensiveLineBaseAI()
	M2UEFAI.M2DefensiveLineExpansion()
	M3UEFAI.M3UEFMainExpansion()
	ForkThread(M2MobileFactoriesThread)
	
	local platoon = nil

    -- UEF Land Attack
    for i = 1, 3 do
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M2LandPatrol_D1_' .. i, 'AttackFormation')
        ScenarioFramework.PlatoonPatrolChain(platoon, 'M2LandAttack_Chain' .. i)
    end
    if(Difficulty >= 2) then
        for i = 1, 2 do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M2LandPatrol_D2_' .. i, 'AttackFormation')
            ScenarioFramework.PlatoonPatrolChain(platoon, 'M2LandAttack_Chain' .. i)
        end
    end
    if(Difficulty == 3) then
        for i = 1, 3 do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M2LandPatrol_D3_' .. i, 'AttackFormation')
           ScenarioFramework.PlatoonPatrolChain(platoon, 'M2LandAttack_Chain' .. i)
        end
    end

    -- UEF Air Attack
		for i = 1, 2 do
			platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M2AirPatrol_D1_' .. i, 'NoFormation')
			for _, unit in platoon:GetPlatoonUnits() do
				ScenarioFramework.GroupPatrolRoute({unit}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('ControlCenterAir_Chain')))
			end
		end
		if(Difficulty >= 2) then
			platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M2AirPatrol_D2_1', 'NoFormation')
			for _, unit in platoon:GetPlatoonUnits() do
				ScenarioFramework.GroupPatrolRoute({unit}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('ControlCenterAir_Chain')))
			end
		end
		if(Difficulty >= 3) then
			for i = 1, 2 do
				platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M2AirPatrol_D3_' .. i, 'NoFormation')
				for _, unit in platoon:GetPlatoonUnits() do
					ScenarioFramework.GroupPatrolRoute({unit}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('ControlCenterAir_Chain')))
				end
			end
		end

    -- Colossus Attack
    if(ScenarioInfo.Colossus and not ScenarioInfo.Colossus:IsDead()) then
        IssueClearCommands({ScenarioInfo.Colossus})
		ScenarioFramework.GroupPatrolChain({ScenarioInfo.Colossus}, 'Aeon_AttackChain')
    end

	ScenarioFramework.RemoveRestrictionForAllHumans(
        categories.urb4302 +   -- Cybran Strategic Missile Defense
        categories.urb0304 +   -- Cybran Quantum Gate
        categories.url0301 +   -- Cybran Sub Commander
        categories.url0402 +   -- Spider Bot

        categories.ueb4302 +   -- UEF Strategic Missile Defense
        categories.ueb0304 +   -- UEF Quantum Gate
        categories.uel0301 +   -- UEF Sub Commander
        categories.uel0401 +   -- Fatboy

        categories.uab4302 +   -- Aeon Strategic Missile Defense
        categories.uab0304 +   -- Aeon Quantum Gate
        categories.ual0301 +   -- Aeon Sub Commander
        categories.ual0401,    -- GC
        true
    )
	
    ScenarioFramework.Dialogue(OpStrings.C06_M02_010, StartMission2)
end

function StartMission2()
    ScenarioFramework.SetPlayableArea('M2Area')
	
    -- After 3 minutes: Jericho VO trigger
    ScenarioFramework.CreateTimerTrigger(M2JerichoVO, 180)

    -- After 4 minutes: Ops VO trigger
    ScenarioFramework.CreateTimerTrigger(M2OpsVO, 240)

    ---------------------------------
    -- Primary Objective - Build Gate
    ---------------------------------
    ScenarioInfo.M2P1 = Objectives.ArmyStatCompare(
        'primary',                      -- type
        'incomplete',                   -- complete
        OpStrings.OpC06_M2P1_Title,     -- title
        OpStrings.OpC06_M2P1_Desc,      -- description
        'build',                        -- action
        {                               -- target
            Armies = {'HumanPlayers'},
            StatName = 'Units_Active',
            CompareOp = '>=',
            Value = 1,
            Category = categories.urb0304,
        }
    )
    ScenarioInfo.M2P1:AddResultCallback(
        function(result)
			if result then
				ScenarioFramework.Dialogue(OpStrings.C06_M02_050, GateBuilt)
			end
		end
    )

    -- M2P1 Objective Reminder
    ScenarioFramework.CreateTimerTrigger(M2P1Reminder1, ObjectiveReminderTime)
	---------------------------------------------------
	-- Secondary Objective 2 - Build SMDs
	-- Reward for completion: Cybran T3 Heavy Artillery
	---------------------------------------------------
    ScenarioInfo.M2S1 = Objectives.ArmyStatCompare(
        'secondary',                    -- type
        'incomplete',                   -- complete
        OpStrings.OpC06_M2S1_Title,     -- title
        OpStrings.OpC06_M2S1_Desc,      -- description
        'build',                        -- action
        {                               -- target
            Armies = {'HumanPlayers'},
            StatName = 'Units_Active',
            CompareOp = '>=',
            Value = 5,
            Category = (categories.urb4302),
			ShowProgress = true,
        }
    )
    ScenarioInfo.M2S1:AddResultCallback(
        function(result)
			if result then
				ScenarioFramework.RemoveRestrictionForAllHumans(categories.urb2302, true) --Cybran Long Range Heavy Artillery
			end
        end
    )
end

function GateBuilt()
    -------------------------------------
    -- Primary Objective 2 - Download QAI
    -------------------------------------
    local gates = ScenarioFramework.GetListOfHumanUnits(categories.urb0304, false)
    ScenarioInfo.M2P2 = Objectives.Basic(
        'primary',                          -- type
        'incomplete',                       -- complete
        OpStrings.OpC06_M2P2_Title,         -- title
        OpStrings.OpC06_M2P2_Desc,          -- description
        Objectives.GetActionIcon('timer'),  -- action
        {                                   -- target
            Units = gates,
        }
    )

    -- Trigger will fire if all of the players gates are destroyed
    ScenarioFramework.CreateArmyStatTrigger(GateDestroyed, ArmyBrains[Player1], 'GateDestroyed',
        {{StatType = 'Units_Active', CompareType = 'LessThan', Value = 1, Category = categories.urb0304}})

    -- Trigger will fire when CDR is near the gate
    ScenarioInfo.CDRNearGate = ScenarioFramework.CreateUnitNearTypeTrigger(CDRNearGate, ScenarioInfo.Player1CDR, ArmyBrains[Player1],
        categories.urb0304, 10)

    -- M2P2 Objective Reminder
    ScenarioFramework.CreateTimerTrigger(M2P2Reminder1, ObjectiveReminderTime)
end

function GateDestroyed()
    if ScenarioInfo.M2P2.Active then
        ScenarioFramework.Dialogue(OpStrings.C06_M02_040)
        if(ScenarioInfo.CDRNearGate) then
            ScenarioInfo.CDRNearGate:Destroy()
        end
        ScenarioInfo.CDRNearGate = ScenarioFramework.CreateUnitNearTypeTrigger(CDRNearGate, ScenarioInfo.Player1CDR, ArmyBrains[Player1], categories.urb0304, 10)
        if(ScenarioInfo.DownloadTimer) then
            ScenarioFramework.ResetUITimer()
            ScenarioInfo.DownloadTimer:Destroy()
        end
    end
end

function CDRNearGate()
    local position = ScenarioInfo.Player1CDR:GetPosition()
    local rect = Rect(position[1] - 10, position[3] - 10, position[1] + 10, position[3] + 10)
    ScenarioFramework.CreateAreaTrigger(LeftGate, rect, categories.COMMAND * categories.CYBRAN, true, true, ArmyBrains[Player1])
    ScenarioInfo.DownloadTimer = ScenarioFramework.CreateTimerTrigger(DownloadFinished, 120, true)
    ScenarioFramework.Dialogue(OpStrings.C06_M02_060)
end

function LeftGate()
    if(ScenarioInfo.M2P2.Active and not ScenarioInfo.Player1CDR:IsDead()) then
        ScenarioFramework.Dialogue(OpStrings.C06_M02_070)
        ScenarioFramework.ResetUITimer()
        ScenarioInfo.DownloadTimer:Destroy()

        -- Trigger will fire when CDR is near the gate
        ScenarioFramework.CreateUnitNearTypeTrigger(CDRNearGate, ScenarioInfo.Player1CDR, ArmyBrains[Player1], categories.urb0304, 10)
    end
end

function DownloadFinished()
    ScenarioFramework.Dialogue(OpStrings.C06_M02_090)
	ScenarioFramework.Dialogue(OpStrings.C06_M02_080) --Aiko calls for reinforcements
    ScenarioInfo.M2P2:ManualResult(true)

    ScenarioInfo.ControlCenter:SetCapturable(true)

    -----------------------------------------------
    -- Primary Objective 3 - Capture Control Center
    -----------------------------------------------
    ScenarioInfo.M2P3 = Objectives.Capture(
        'primary',                      -- type
        'incomplete',                   -- complete
        OpStrings.OpC06_M2P3_Title,     -- title
        OpStrings.OpC06_M2P3_Desc,      -- description
        {                               -- target
            Units = {ScenarioInfo.ControlCenter},
        }
    )
    ScenarioInfo.M2P3:AddResultCallback(
        function(result)
            if result then
				--Control Center made invulnerable, increased AI activity makes it harder to hold it, let alone keeping it alive from splash damage.
                local unit = ScenarioFramework.GetListOfHumanUnits(categories.uec1902, false)
                ScenarioInfo.ControlCenter = unit[1]
                ScenarioInfo.ControlCenter:SetDoNotTarget(true)
				        ScenarioInfo.ControlCenter:SetCanTakeDamage(false)
						ScenarioInfo.ControlCenter:SetReclaimable(false)
						ScenarioInfo.ControlCenter:SetCanBeKilled(false)
						ScenarioInfo.ControlCenter:SetCapturable(false)
                ScenarioFramework.PauseUnitDeath(ScenarioInfo.ControlCenter)
                ScenarioFramework.CreateUnitDestroyedTrigger(PlayerLose, ScenarioInfo.ControlCenter)

                -- control center captured cam
                local camInfo = {
                    blendTime = 1.0,
                    holdTime = 4,
                    orientationOffset = { -2.6, 0.3, 0 },
                    positionOffset = { 0, 0.5, 0 },
                    zoomVal = 30,
                }
                ScenarioFramework.OperationNISCamera( ScenarioInfo.ControlCenter, camInfo )

                ScenarioFramework.Dialogue(OpStrings.C06_M02_130, IntroMission3, true)
            end
        end
    )

    -- M2P3 Objective Reminder
    ScenarioFramework.CreateTimerTrigger(M2P3Reminder1, ObjectiveReminderTime)
end

--The 2 fatboys are sent near the Control Center, and act as factories
function M2MobileFactoriesThread()
	local fatboys = {}
    -- Mobile Factories
    for i = 1, 2 do
		fatboys[i] = ScenarioUtils.CreateArmyUnit('UEF', 'MobileFactory' .. i)
        IssueMove({fatboys[i]}, ScenarioUtils.MarkerToPosition('MobileFactoryMove' .. i))

        M2UEFAI.MobileFactoryAI(fatboys[i], i)
    end
	--Triggers to begin rebuilding factories if they die
	ScenarioFramework.CreateUnitDeathTrigger(M3UEFAI.UEFMainFatboyFactory1, fatboys[1])
	ScenarioFramework.CreateUnitDeathTrigger(M3UEFAI.UEFMainFatboyFactory2, fatboys[2])
end

function M2JerichoVO()
    if(not ScenarioInfo.Jericho:IsDead()) then
        ScenarioFramework.Dialogue(OpStrings.C06_M02_020)
    else
        ScenarioFramework.Dialogue(OpStrings.C06_M02_025)
    end
end

function M2OpsVO()
    ScenarioFramework.Dialogue(OpStrings.C06_M02_030)
end

function M2P1Reminder1()
    if(ScenarioInfo.M2P1.Active) then
        ScenarioFramework.Dialogue(OpStrings.C06_M02_150)
        ScenarioFramework.CreateTimerTrigger(M2P1Reminder2, SubsequentTime)
    end
end

function M2P1Reminder2()
    if(ScenarioInfo.M2P1.Active) then
        ScenarioFramework.Dialogue(OpStrings.C06_M02_155)
        ScenarioFramework.CreateTimerTrigger(M2P1Reminder3, SubsequentTime)
    end
end

function M2P1Reminder3()
    if(ScenarioInfo.M2P1.Active) then
        ScenarioFramework.Dialogue(OpStrings.C06_M01_076)
        ScenarioFramework.CreateTimerTrigger(M2P1Reminder1, SubsequentTime)
    end
end

function M2P2Reminder1()
    if(ScenarioInfo.M2P2.Active) then
        ScenarioFramework.Dialogue(OpStrings.C06_M02_160)
        ScenarioFramework.CreateTimerTrigger(M2P2Reminder2, SubsequentTime)
    end
end

function M2P2Reminder2()
    if(ScenarioInfo.M2P2.Active) then
        ScenarioFramework.Dialogue(OpStrings.C06_M02_165)
        ScenarioFramework.CreateTimerTrigger(M2P2Reminder3, SubsequentTime)
    end
end

function M2P2Reminder3()
    if(ScenarioInfo.M2P2.Active) then
        ScenarioFramework.Dialogue(OpStrings.C06_M01_076)
        ScenarioFramework.CreateTimerTrigger(M2P2Reminder1, SubsequentTime)
    end
end

function M2P3Reminder1()
    if(ScenarioInfo.M2P3.Active) then
        ScenarioFramework.Dialogue(OpStrings.C06_M02_170)
        ScenarioFramework.CreateTimerTrigger(M2P3Reminder2, SubsequentTime)
    end
end

function M2P3Reminder2()
    if(ScenarioInfo.M2P3.Active) then
        ScenarioFramework.Dialogue(OpStrings.C06_M01_076)
        ScenarioFramework.CreateTimerTrigger(M2P3Reminder1, SubsequentTime)
    end
end

-----------
-- Mission 3
-----------
function IntroMission3()
    ScenarioInfo.MissionNumber = 3
	----------------------
	-- M3 UEF AI functions
	----------------------
	M3UEFAI.M3UEFBuildStrategicMissileLaunchers()
	M3UEFAI.M3UEFMainBuildHeavyArtillery()
	EnableUEFNukeAI()
	M3UEFAI.M3UEFSouthWesternBaseAI()
	--M3 UEF sACU for the South Western island.
	ScenarioInfo.SouthernUEF_sACU = ScenarioFramework.SpawnCommander('UEF', 'Michael_sACU', false, 'sCDR Michael', false, false,
        {'Shield', 'AdvancedCoolingUpgrade', 'ResourceAllocation'})
	--M3 UEF Commander for the South Western island
	ScenarioInfo.Blake = ScenarioFramework.SpawnCommander('UEF', 'Blake_ACU', false, 'CDR Blake', false, BlakeDestroyed,
        {'Shield', 'HeavyAntiMatterCannon', 'T3Engineering'})
	ScenarioInfo.Blake:SetAutoOvercharge(true)
	
	--M3 UEF Southern air patrols
	local M3UEFSouthAirPatrol = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M3_UEF_Southern_Air_Patrol_D' .. Difficulty, 'NoFormation')
	for _, v in M3UEFSouthAirPatrol:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M3_UEF_SouthWestern_Base_Patrol_Chain')))
    end
	
	--------------------------
	-- M3Aeon Southern Base AI
	--------------------------
	M3AeonAI.M3AeonSouthEasternBaseAI()
	ScenarioInfo.SouthernAeon_sACU = ScenarioFramework.SpawnCommander('Aeon', 'Matilda_sACU', false, 'sCDR Matilda', false, false,
        {'ShieldHeavy', 'EngineeringFocusingModule', 'ResourceAllocation'})
	
	--M3 Aeon Southern air patrols
	local M3AeonSouthAirPatrol = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M3_Aeon_Southern_Air_Patrol_D' .. Difficulty, 'NoFormation')
	for _, v in M3AeonSouthAirPatrol:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M3_Aeon_SouthEastern_Base_Patrol_Chain')))
    end
	
	--------------------
    -- UEF Naval Fleets
	--------------------
	local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M3_UEF_Main_Naval_Fleet_D' .. Difficulty, 'GrowthFormation')
	ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_UEF_Main_Naval_Attack_Chain')
	
	platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M3_UEF_Southern_Naval_Fleet_D' .. Difficulty, 'AttackFormation')
	ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_UEF_Southern_Naval_Attack_Chain')
	
	-------------------
    -- Atlantis Assault
	-------------------
    ScenarioInfo.AtlantisPlanes = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M3AtlantisPlanes_D' .. Difficulty, 'StaggeredChevronFormation')
    ScenarioInfo.Atlantis = ScenarioUtils.CreateArmyUnit('UEF', 'Atlantis')
	
    IssueTransportLoad(ScenarioInfo.AtlantisPlanes:GetPlatoonUnits(), ScenarioInfo.Atlantis)
    IssueDive({ScenarioInfo.Atlantis})
	
	ScenarioFramework.GroupPatrolChain({ScenarioInfo.Atlantis}, 'M3_UEF_Main_Naval_Attack_Chain')

	
    ScenarioFramework.CreateUnitNearTypeTrigger(AtlantisAI, ScenarioInfo.Atlantis, ArmyBrains[Player1], categories.ALLUNITS, 90)

    ScenarioFramework.SetSharedUnitCap(1200)

    -- Adjust buildable categories 

    ScenarioFramework.RemoveRestrictionForAllHumans(
        categories.urb2305 +    -- Cybran Strategic Missile Launcher
        categories.urs0304 +    -- Cybran Strategic Missile Submarine

        categories.ueb2305 +    -- UEF Strategic Missile Launcher
        categories.ues0304 +    -- UEF Strategic Missile Submarine

        categories.uab2305 +    -- Aeon Strategic Missile Launcher
		categories.uas0304,     -- Aeon Strategic Missile Submarine
        true
    )

    ScenarioFramework.Dialogue(OpStrings.C06_M03_010, StartMission3)
end

function StartMission3()
	ScenarioFramework.SetPlayableArea('M3NewArea') -- "M3Area" doesn't include the 2 Southern Islands, "M3NewArea" includes the entire map
	
    -- Primary Objective 1
    ScenarioInfo.M3P1 = Objectives.Capture(
        'primary',                      -- type
        'incomplete',                   -- complete
        OpStrings.OpC06_M3P1_Title,     -- title
        OpStrings.OpC06_M3P1_Desc,      -- description
        {                               -- target
            Units = {ScenarioInfo.BlackSunWeapon},
            NumRequired = 1,
        }
    )
    ScenarioInfo.M3P1:AddResultCallback(
        function(result)
            if(result) then
                local unit = ScenarioFramework.GetListOfHumanUnits(categories.uec1901, false)

                -- Primary Objective 2
                ScenarioInfo.M3P2 = Objectives.Basic(
                    'primary',                          -- type
                    'incomplete',                       -- complete
                    OpStrings.OpC06_M3P2_Title,         -- title
                    OpStrings.OpC06_M3P2_Desc,          -- description
                    Objectives.GetActionIcon('kill'),   -- action
                    {                                   -- target
                        Units = unit,
                    }
                )
                unit[1]:AddSpecialToggleEnable(BlackSunFired)
                unit[1]:SetCanTakeDamage(false)
                unit[1]:SetCanBeKilled(false)
                unit[1]:SetReclaimable(false)
                unit[1]:SetCapturable(false)
                unit[1]:SetDoNotTarget(true)

                ScenarioFramework.Dialogue(OpStrings.C06_M03_060)

                -- Show the captured Black Sun
                local camInfo = {
                    blendTime = 1.0,
                    holdTime = 4,
                    orientationOffset = { 1.8, 0.7, 0 },
                    positionOffset = { 0, 1, 0 },
                    zoomVal = 75,
                }
                ScenarioFramework.OperationNISCamera( unit[1], camInfo )

                -- M3P2 Objective Reminder
                ScenarioFramework.CreateTimerTrigger(M3P2Reminder1, ObjectiveReminderTime)
            end
        end
    )

    -- M3P1 Objective Reminder
    ScenarioFramework.CreateTimerTrigger(M3P1Reminder1, ObjectiveReminderTime)
end

function AtlantisAI()
	--Release aircraft
    IssueClearCommands({ScenarioInfo.Atlantis})
    IssueTransportUnload({ScenarioInfo.Atlantis}, ScenarioInfo.Atlantis:GetPosition())
	
	for _, unit in ScenarioInfo.AtlantisPlanes:GetPlatoonUnits() do
        while not unit.Dead and unit:IsUnitState('Attached') do
            WaitSeconds(.5)
        end
    end
	
	--Dive, and patrol player base area
	if not ScenarioInfo.Atlantis.Dead then
		IssueDive({ScenarioInfo.Atlantis})
		IssuePatrol({ScenarioInfo.Atlantis}, ScenarioUtils.MarkerToPosition('PlayerAir_Patrol3'))
		IssuePatrol({ScenarioInfo.Atlantis}, ScenarioUtils.MarkerToPosition('PlayerAir_Patrol2'))
	end
	--Aircraft patrols the player base area
	if ArmyBrains[UEF]:PlatoonExists(ScenarioInfo.AtlantisPlanes) then
		IssueClearCommands(ScenarioInfo.AtlantisPlanes:GetPlatoonUnits())
		ScenarioInfo.AtlantisPlanes:Stop()
		ScenarioInfo.AtlantisPlanes:Patrol(ScenarioUtils.MarkerToPosition('PlayerBase'))
		ScenarioInfo.AtlantisPlanes:Patrol(ScenarioUtils.MarkerToPosition('PlayerAir_Patrol2'))
		ScenarioInfo.AtlantisPlanes:Patrol(ScenarioUtils.MarkerToPosition('PlayerAir_Patrol3'))
	end

	--Play warning VO
	if not ScenarioInfo.Atlantis.Dead then
		M3AikoVO()
	end
end

--UEF Nuke AI during Phase 3, platoon.lua is used in this case
function EnableUEFNukeAI()
	--Get a table of all UEF SMLs
	local UEFSilos = ArmyBrains[UEF]:GetListOfUnits(categories.ueb2305, false)
		
		--Only do something if there is at least 1 SML in the table
		if table.getn(UEFSilos) > 0 then
			for k, v in UEFSilos do
				--Loop through each SML, and only enable the NukeAI for an instance if it hasn't been enabled yet
				if not v.SiloAIEnabled and not v:IsDead() then
					--Make a single unit platoon for each SML
					local SiloPlatoon = ArmyBrains[UEF]:MakePlatoon('','')
					ArmyBrains[UEF]:AssignUnitsToPlatoon(SiloPlatoon, {v}, 'Attack', 'None')
					--Platoon gets the AI function called
					SiloPlatoon:ForkAIThread(SiloPlatoon.NukeAI)
					--Flag to check if the NukeAI has already been called for the SML instance
					v.SiloAIEnabled = true
				end
			end
		end
	--Check for SMLs every 60 seconds
	ScenarioFramework.CreateTimerTrigger(EnableUEFNukeAI, 60)
end

function BlackSunFired()
    if(not ScenarioInfo.OpEnded) then
        ScenarioFramework.FlushDialogueQueue()
        ScenarioFramework.EndOperationSafety()
        ScenarioInfo.OpComplete = true
        if ScenarioInfo.M3P2 then
            ScenarioInfo.M3P2:ManualResult(true)
        end
        ScenarioFramework.EndOperation(ScenarioInfo.OpComplete, ScenarioInfo.OpComplete, true)
    end
end

function M3AikoVO()
    if(ScenarioInfo.Aiko and not ScenarioInfo.Aiko:IsDead()) then
		ScenarioFramework.Dialogue(OpStrings.C06_M03_030)
    end
end

function AikoDestroyed()
    ScenarioFramework.Dialogue(OpStrings.C06_M03_050)
    ScenarioFramework.CDRDeathNISCamera(ScenarioInfo.Aiko, 7)
end

function ArnoldDestroyed()
    ScenarioFramework.Dialogue(OpStrings.C06_M03_055)
    ScenarioFramework.CDRDeathNISCamera(ScenarioInfo.Arnold, 7)
end

function BlakeDestroyed()
    ScenarioFramework.Dialogue(OpStrings.C06_M03_100)
    ScenarioFramework.CDRDeathNISCamera(ScenarioInfo.Blake, 7)
end

function M3P1Reminder1()
    if(ScenarioInfo.M3P1.Active) then
        ScenarioFramework.Dialogue(OpStrings.C06_M03_070)
        ScenarioFramework.CreateTimerTrigger(M3P1Reminder2, SubsequentTime)
    end
end

function M3P1Reminder2()
    if(ScenarioInfo.M3P1.Active) then
        ScenarioFramework.Dialogue(OpStrings.C06_M03_075)
        ScenarioFramework.CreateTimerTrigger(M3P1Reminder3, SubsequentTime)
    end
end

function M3P1Reminder3()
    if(ScenarioInfo.M3P1.Active) then
        ScenarioFramework.Dialogue(OpStrings.C06_M01_076)
        ScenarioFramework.CreateTimerTrigger(M3P1Reminder1, SubsequentTime)
    end
end

function M3P2Reminder1()
    if(ScenarioInfo.M3P2.Active) then
        ScenarioFramework.Dialogue(OpStrings.C06_M03_080)
        ScenarioFramework.CreateTimerTrigger(M3P2Reminder2, SubsequentTime)
    end
end

function M3P2Reminder2()
    if(ScenarioInfo.M3P2.Active) then
        ScenarioFramework.Dialogue(OpStrings.C06_M03_085)
        ScenarioFramework.CreateTimerTrigger(M3P2Reminder3, SubsequentTime)
    end
end

function M3P2Reminder3()
    if(ScenarioInfo.M3P2.Active) then
        ScenarioFramework.Dialogue(OpStrings.C06_M01_076)
        ScenarioFramework.CreateTimerTrigger(M3P2Reminder1, SubsequentTime)
    end
end

function Taunt()
    -- Terminate if all 3 enemy ACUs are destroyed
	if ScenarioInfo.Aiko.Dead and ScenarioInfo.Arnold.Dead and ScenarioInfo.Blake.Dead then
		return
	end
    local choice = Random(0, 2)
    if(choice == 0) then
        PlayAikoTaunt()
    elseif(choice == 1) then
        PlayArnoldTaunt()
	else
        PlayBlakeTaunt()
    end
end

function PlayAikoTaunt()
	if ScenarioInfo.Aiko and not ScenarioInfo.Aiko.Dead then
		ScenarioFramework.Dialogue(OpStrings['TAUNT' .. aikoTaunt])
		--Start over with the taunts if needed
		if aikoTaunt >= 8 then
			aikoTaunt = 1
		else
			aikoTaunt = aikoTaunt + 1
		end
		ScenarioFramework.CreateTimerTrigger(Taunt, Random(100, 200))
	else
		Taunt()
	end
end

function PlayArnoldTaunt()
	if ScenarioInfo.Arnold and not ScenarioInfo.Arnold.Dead then
		ScenarioFramework.Dialogue(OpStrings['TAUNT' .. arnoldTaunt])
		--Start over with the taunts if needed
		if arnoldTaunt >= 16 then
			arnoldTaunt = 9
		else
			arnoldTaunt = arnoldTaunt + 1
		end
		ScenarioFramework.CreateTimerTrigger(Taunt, Random(100, 200))
	else
		Taunt()
	end
end

function PlayBlakeTaunt()
	if ScenarioInfo.MissionNumber == 3 and ScenarioInfo.Blake and not ScenarioInfo.Blake.Dead then
		ScenarioFramework.Dialogue(OpStrings['TAUNT' .. blakeTaunt])
		--Start over with the taunts if needed
		if blakeTaunt >= 22 then
			blakeTaunt = 17
		else
			blakeTaunt = blakeTaunt + 1
		end
		ScenarioFramework.CreateTimerTrigger(Taunt, Random(100, 200))
	else
		Taunt()
	end
end

----------
-- End Game
----------
function ControlCenterDestroyed()
    if(not ScenarioInfo.OpEnded) then
        ScenarioFramework.EndOperationSafety()
        ScenarioInfo.OpComplete = false
        ScenarioFramework.CreateVisibleAreaLocation(100, ScenarioUtils.MarkerToPosition('ControlCenter'), 0, ArmyBrains[Player1])

        -- Control center destroyed cam
--    ScenarioFramework.EndOperationCamera(ScenarioInfo.ControlCenter)
        local camInfo = {
            blendTime = 2.5,
            holdTime = nil,
            orientationOffset = { 0, 0.3, 0 },
            positionOffset = { 0, 0.5, 0 },
            zoomVal = 30,
            spinSpeed = 0.03,
            overrideCam = true,
        }
        ScenarioFramework.OperationNISCamera( ScenarioInfo.ControlCenter, camInfo )

        ScenarioInfo.M1P1:ManualResult(false)
        ScenarioFramework.Dialogue(OpStrings.C06_M01_090, StartKillGame, true)
    end
end

function PlayerLose()
    if(not ScenarioInfo.OpEnded) then
        ScenarioFramework.EndOperationSafety()
        ScenarioInfo.OpComplete = false

        -- Control Center destroyed cam
--    ScenarioFramework.EndOperationCamera(ScenarioInfo.ControlCenter)
        local camInfo = {
            blendTime = 2.5,
            holdTime = nil,
            orientationOffset = { 0, 0.3, 0 },
            positionOffset = { 0, 0.5, 0 },
            zoomVal = 30,
            spinSpeed = 0.03,
            overrideCam = true,
        }
        ScenarioFramework.OperationNISCamera( ScenarioInfo.ControlCenter, camInfo )

        ScenarioFramework.Dialogue(OpStrings.C06_M03_090, StartKillGame, true)
    end
end

function PlayerKilled(deadCommander)
	if DEBUG then
		return
	end
    ScenarioFramework.PlayerDeath(deadCommander, OpStrings.C06_D01_010)
end

function StartKillGame()
    ForkThread(KillGame)
end

function KillGame()
    if(not ScenarioInfo.OpComplete) then
        WaitSeconds(15)
    end
    ScenarioFramework.EndOperation(ScenarioInfo.OpComplete, ScenarioInfo.OpComplete, true)
end

------------------
-- Debug Functions
------------------

function OnCtrlF3()
    if ScenarioInfo.MissionNumber == 1 then
        IntroMission2()
    elseif ScenarioInfo.MissionNumber == 2 then
        IntroMission3()
    end
end

--Debug function to remove reclaimables, it does 1500 damage to all reclaimables, including most props, on the whole map.
function OnCtrlF4()
	CustomFunctions.AreaReclaimCleanUp()
end
