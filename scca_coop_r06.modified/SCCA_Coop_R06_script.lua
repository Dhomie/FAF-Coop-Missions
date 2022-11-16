-- ****************************************************************************
-- **
-- **  File     : /maps/scca_coop_r06.modified/SCCA_Coop_R06_script.lua
-- **  Author(s): Jessica St. Croix
-- **
-- **  Summary  :
-- **
-- **  Copyright © 2006 Gas Powered Games, Inc.  All rights reserved.
-- ****************************************************************************
local Objectives = import('/lua/ScenarioFramework.lua').Objectives
local OpStrings = import('/maps/scca_coop_r06.modified/SCCA_Coop_R06_strings.lua')
local ScenarioFramework = import('/lua/scenarioframework.lua')
local ScenarioPlatoonAI = import('/lua/scenarioplatoonai.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local Weather = import('/lua/weather.lua')
local M1AeonAI = import('/maps/scca_coop_r06.modified/SCCA_Coop_R06_M1AeonAI.lua')
local M3AeonAI = import('/maps/scca_coop_r06.modified/SCCA_Coop_R06_M3AeonAI.lua')
local M2UEFAI = import('/maps/scca_coop_r06.modified/SCCA_Coop_R06_M2UEFAI.lua')
local M3UEFAI = import('/maps/scca_coop_r06.modified/SCCA_Coop_R06_M3UEFAI.lua')
local M1CybranAI = import('/maps/scca_coop_r06.modified/SCCA_Coop_R06_M1CybranAI.lua')
local CustomFunctions = import('/maps/scca_coop_r06.modified/SCCA_Coop_R06_CustomFunctions.lua')

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

ScenarioInfo.VarTable = {}

local Player1 = ScenarioInfo.Player1
local aeon = ScenarioInfo.Aeon
local uef = ScenarioInfo.UEF
local blackSun = ScenarioInfo.BlackSun
local cybran = ScenarioInfo.Cybran
local Player2 = ScenarioInfo.Player2
local Player3 = ScenarioInfo.Player3
local Player4 = ScenarioInfo.Player4

local Players = {ScenarioInfo.Player1, ScenarioInfo.Player2, ScenarioInfo.Player3, ScenarioInfo.Player4}
local Difficulty = ScenarioInfo.Options.Difficulty

--Variables for the buffing functions
local AIs = {ScenarioInfo.Aeon, ScenarioInfo.UEF, ScenarioInfo.BlackSun, ScenarioInfo.Cybran}
local BuffCategories = {
	BuildPower = (categories.FACTORY * categories.STRUCTURE) + categories.ENGINEER,
	Economy = categories.ECONOMIC,
}

local aikoTaunt = 1
local arnoldTaunt = 9
local blakeTaunt = 17

--------------------------
-- Objective Reminder Times
--------------------------
local M1P1Time = 600
local M2P1Time = 300
local M2P2Time = 300
local M2P3Time = 300
local M3P1Time = 300
local M3P2Time = 300
local SubsequentTime = 300

------------------------
-- AI buffing functions
------------------------
---Comments:
---ACUs and sACUs belong to both ECONOMIC and ENGINEER categories.

--Buffs AI factory structures, and engineer units
function BuffAIBuildPower()
	--Build Rate multiplier values, depending on the Difficulty
	local Rate = {1.0, 2.0, 3.0}
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

---------
-- Startup
---------
function OnPopulate(scenario)
    ScenarioUtils.InitializeScenarioArmies()
    ScenarioFramework.GetLeaderAndLocalFactions()
	
	--Added in-game option to enable a debug/testing mode
	if ScenarioInfo.Options.opt_Coop_Debug_Mode == 2 then
		ForkThread(SpawnDebugPlayer)
	elseif ScenarioInfo.Options.opt_Coop_Debug_Mode == 1 then
		ForkThread(SpawnPlayer)
	end
	--UEF and Aeon are initialized the same way for both debug and normal modes
    SpawnUEF()
    SpawnAeon()
end

--Dummy AI takes the players' initial base, used for debug/testing purposes
function SpawnDebugPlayer()
	 -- Player Base
	local DebugStartingBase
	
	--Debug base is first spawned for the player, size chosen during map selection
	if ScenarioInfo.Options.opt_Coop_Initial_Base == 4  then
		DebugStartingBase = ScenarioUtils.CreateArmyGroup('Player1', 'Base_D' .. Difficulty)
	else
		DebugStartingBase = ScenarioUtils.CreateArmyGroup('Player1', 'Base_D' .. ScenarioInfo.Options.opt_Coop_Initial_Base)
	end
	
	--If the base exists, it gets transferred to the AI
	if DebugStartingBase then
		for k, v in DebugStartingBase do
            ScenarioFramework.GiveUnitToArmy(v, cybran)
        end
	else
		error('*MAIN SCRIPT/OPTIONS ERROR: DebugStartingBase is invalid/doesn\'t exist.', 2)
	end
	
	--Build rate buff
	ForkThread(BuffAIBuildPower)
	--Eco buff
	ForkThread(BuffAIEconomy)
	--Cybran dummy AI
	M1CybranAI.M1CybranDebugBaseAI()
	
    -- Jericho
    ScenarioInfo.Jericho = ScenarioUtils.CreateArmyUnit('Player1', 'Jericho')
    ScenarioInfo.Jericho:SetCustomName(LOC '{i sCDR_Jericho}')
    ScenarioInfo.Jericho:CreateEnhancement('ResourceAllocation')
    ScenarioInfo.Jericho:CreateEnhancement('NaniteMissileSystem')
    ScenarioInfo.Jericho:CreateEnhancement('Switchback')
    ScenarioFramework.CreateUnitDeathTrigger(JerichoKilled, ScenarioInfo.Jericho)
    ScenarioFramework.CreateUnitGivenTrigger(JerichoGiven, ScenarioInfo.Jericho)
	
	ForkThread(CustomFunctions.EnableStealthOnAir)
end

--Used for normal gameplay
function SpawnPlayer()

	--Player base size, depending on host's choice during map selection
	if ScenarioInfo.Options.opt_Coop_Initial_Base == 4  then
		ScenarioUtils.CreateArmyGroup('Player1', 'Base_D' .. Difficulty)
	else
		ScenarioUtils.CreateArmyGroup('Player1', 'Base_D' .. ScenarioInfo.Options.opt_Coop_Initial_Base)
	end
	
    -- Jericho
    ScenarioInfo.Jericho = ScenarioUtils.CreateArmyUnit('Player1', 'Jericho')
    ScenarioInfo.Jericho:SetCustomName(LOC '{i sCDR_Jericho}')
    ScenarioInfo.Jericho:CreateEnhancement('ResourceAllocation')
    ScenarioInfo.Jericho:CreateEnhancement('NaniteMissileSystem')
    ScenarioInfo.Jericho:CreateEnhancement('Switchback')
    ScenarioFramework.CreateUnitDeathTrigger(JerichoKilled, ScenarioInfo.Jericho)
    ScenarioFramework.CreateUnitGivenTrigger(JerichoGiven, ScenarioInfo.Jericho)
	
	local sonar = ScenarioUtils.CreateArmyUnit('Player1', 'MobileSonar')
    IssuePatrol({sonar}, ScenarioUtils.MarkerToPosition('PlayerSub_Patrol1'))
    IssuePatrol({sonar}, ScenarioUtils.MarkerToPosition('PlayerSub_Patrol2'))

    -- Only for Easy Difficulty
	if Difficulty == 1 then
	 -- Player Engineers
		local engineers = ScenarioUtils.CreateArmyGroup('Player1', 'Engineers')
		for k, v in engineers do
			for i = 1, 3 do
				IssuePatrol({v}, ScenarioUtils.MarkerToPosition('Jericho_Patrol' .. i))
			end
		end
    -- Player Mobile Defense
		local subs = ScenarioUtils.CreateArmyGroupAsPlatoon('Player1', 'Subs', 'AttackFormation')
		subs:Patrol(ScenarioUtils.MarkerToPosition('PlayerSub_Patrol1'))
		subs:Patrol(ScenarioUtils.MarkerToPosition('PlayerSub_Patrol2'))

		local landPatrol1 = ScenarioUtils.CreateArmyGroupAsPlatoon('Player1', 'LandPatrol1', 'AttackFormation')
		for i = 1, 4 do
			landPatrol1:Patrol(ScenarioUtils.MarkerToPosition('PlayerLand_Patrol' .. i))
		end

		local landPatrol2 = ScenarioUtils.CreateArmyGroupAsPlatoon('Player1', 'LandPatrol2', 'AttackFormation')
		for i = 1, 4 do
			landPatrol2:Patrol(ScenarioUtils.MarkerToPosition('PlayerLand_Patrol' .. i))
		end
	
		local airPatrol = ScenarioUtils.CreateArmyGroupAsPlatoon('Player1', 'AirPatrol', 'ChevronFormation')
		for k = 1, 4 do
			airPatrol:Patrol(ScenarioUtils.MarkerToPosition('PlayerAir_Patrol' .. k))
		end
	end
	
	--AIs will get buffed eco from the start, but not build power.
	ForkThread(BuffAIEconomy)
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
    ScenarioInfo.Aiko = ScenarioUtils.CreateArmyUnit('UEF', 'Aiko')
    ScenarioInfo.Aiko:SetCustomName(LOC '{i CDR_Aiko}')
	ScenarioInfo.Aiko:CreateEnhancement('Shield')
	ScenarioInfo.Aiko:CreateEnhancement('HeavyAntiMatterCannon')
	ScenarioInfo.Aiko:CreateEnhancement('T3Engineering')
	ScenarioInfo.Aiko:SetAutoOvercharge(true)
    ScenarioFramework.CreateUnitDeathTrigger(AikoDestroyed, ScenarioInfo.Aiko)
	
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
    ScenarioInfo.Arnold = ScenarioUtils.CreateArmyUnit('Aeon', 'Arnold')
    ScenarioInfo.Arnold:SetCustomName(LOC '{i CDR_Arnold}')
	ScenarioInfo.Arnold:CreateEnhancement('ShieldHeavy')
	ScenarioInfo.Arnold:CreateEnhancement('CrysalisBeam')
	ScenarioInfo.Arnold:CreateEnhancement('HeatSink')
	ScenarioInfo.Arnold:SetAutoOvercharge(true)
    ScenarioFramework.CreateUnitDeathTrigger(ArnoldDestroyed, ScenarioInfo.Arnold)
	
	--Single Galactic Colossus
    ScenarioInfo.Colossus = ScenarioUtils.CreateArmyUnit('Aeon', 'M2_GC_1')
    for i = 1, 4 do
        IssuePatrol({ScenarioInfo.Colossus}, ScenarioUtils.MarkerToPosition('AeonBase_Patrol' .. i))
    end
	
	--Engineer spawned in to make the scripted triggers work, but the BaseManager actually assigns this one to start building it.
    ScenarioInfo.CzarEngineer = ScenarioUtils.CreateArmyUnit('Aeon', 'CzarEngineer')

    -- Aeon Czar units
    ScenarioInfo.CzarBombers = ScenarioUtils.CreateArmyGroup('Aeon', 'CzarBombers_D' .. Difficulty)
    for k, v in ScenarioInfo.CzarBombers do
        local chain = ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('Aeon_Chain'))
        for i = 1, table.getn(chain) do
            IssuePatrol({v}, chain[i])
        end
    end
end

function OnStart(self)
    -- Adjust buildable categories for Player
    local tblArmy = ListArmies()
    for _, player in Players do
        for iArmy, strArmy in pairs(tblArmy) do
            if iArmy == player then
                ScenarioFramework.AddRestriction(player,
                    categories.PRODUCTFA + -- All FA Units
					categories.GATE + 		-- All Quantum Gates (RAS sACU spam is not really intended)
					categories.urb2302 +	-- Long Range Heavy Artillery
                    categories.urb2305 +	-- Strategic Missile Launcher
                    categories.urb4302 +	-- Strategic Missile Defense
                    categories.url0402 +	-- Spider Bot
                    categories.urs0304 +	-- Strategic Missile Submarine
                    categories.drlk001 +	-- Cybran T3 Mobile AA
                    --categories.dra0202 +	-- Corsairs
                    --categories.drl0204 +	-- Hoplites

                    categories.ueb2302 +  -- Long Range Heavy Artillery
                    categories.ueb4301 +  -- T3 Heavy Shield Generator
                    categories.uel0401 +  -- Experimental Mobile Factory
                    categories.delk002 +  -- UEF T3 Mobile AA
                    categories.ues0304 +  -- Strategic Missile Submarine
                    categories.del0204 +  -- Mongoose
                    categories.dea0202 +  -- Janus

                    categories.uab0304 + -- Quantum Gate
                    categories.ual0301 + -- Sub Commander
                    categories.dalk003 + -- Aeon M3 Mobile AA
                    categories.dal0310 + -- T3 Absolver
                    categories.daa0206 + -- Mercy
                    categories.uas0304)  -- Strategic Missile Submarine
            end
        end
    end
	
	-- UEF T1 + T2 Engineers + FA units + Cybran, UEF, Aeon T3 Mobile AA
	ScenarioFramework.AddRestriction(uef, categories.uel0105 + categories.uel0208 + categories.PRODUCTFA + categories.drlk001 + categories.delk002 + categories.dalk003)
	-- Aeon T1 + T2 Engineers + FA units + Cybran, UEF, Aeon T3 Mobile AA
	ScenarioFramework.AddRestriction(aeon, categories.ual0105 + categories.ual0208 + categories.PRODUCTFA + categories.drlk001 + categories.delk002 + categories.dalk003)
	
	--Remove Forged Alliance unit restrictions if the host chose to do so.
	if ScenarioInfo.Options.opt_Coop_Expansion_Pack_Units and ScenarioInfo.Options.opt_Coop_Expansion_Pack_Units == 2 then
		for iArmy, strArmy in pairs(tblArmy) do
			ScenarioFramework.RemoveRestriction(strArmy,
				categories.PRODUCTFA + 	--All Forged Alliance units
				categories.drlk001 +	--Cybran T3 Mobile AA
				categories.delk002 +	--UEF T3 Mobile AA
				categories.dalk003)		--Aeon T3 Mobile AA
		end
	end
	
    ScenarioFramework.SetPlayableArea('M1Area', false)

    ScenarioFramework.SetSharedUnitCap(480)
    SetArmyUnitCap(aeon, 2000)
    SetArmyUnitCap(uef, 2000)

    -- Army colors
    ScenarioFramework.SetCybranColor(Player1)
	ScenarioFramework.SetCybranNeutralColor(cybran)
    ScenarioFramework.SetAeonColor(aeon)
    ScenarioFramework.SetUEFColor(uef)
    ScenarioFramework.SetUEFAllyColor(blackSun)
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

    ScenarioFramework.StartOperationJessZoom('CDRZoom', IntroMission1)
end

function JerichoKilled()
    ScenarioFramework.Dialogue(OpStrings.C06_M01_080)
    ScenarioFramework.CDRDeathNISCamera( ScenarioInfo.Jericho, 7 )
end

function JerichoGiven(oldJericho, newJericho)
    ScenarioInfo.Jericho = newJericho
    ScenarioFramework.CreateUnitGivenTrigger(JerichoGiven, ScenarioInfo.Jericho)
end

----------
-- End Game
----------
-- rolled into BlackSunFired()
-- function PlayerWin()
-- end

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

    -- Player Commander
    ScenarioInfo.PlayerCDR = ScenarioUtils.CreateArmyUnit('Player1', 'Player')
    ScenarioInfo.PlayerCDR:PlayCommanderWarpInEffect()
    ScenarioInfo.PlayerCDR:SetCustomName(ArmyBrains[Player1].Nickname)

    ScenarioInfo.CoopCDR = {}
    local tblArmy = ListArmies()
    coop = 1
	-- Spawn in the rest of the co-op players
    for iArmy, strArmy in pairs(tblArmy) do
        if iArmy >= ScenarioInfo.Player2 then
            ScenarioInfo.CoopCDR[coop] = ScenarioUtils.CreateArmyUnit(strArmy, 'Player' .. coop)
            ScenarioInfo.CoopCDR[coop]:PlayCommanderWarpInEffect()
            ScenarioInfo.CoopCDR[coop]:SetCustomName(ArmyBrains[iArmy].Nickname)
            coop = coop + 1
            WaitSeconds(0.5)
        end
    end
	
    ScenarioFramework.PauseUnitDeath(ScenarioInfo.PlayerCDR)
    for index, coopACU in ScenarioInfo.CoopCDR do
        ScenarioFramework.PauseUnitDeath(coopACU)
        ScenarioFramework.CreateUnitDeathTrigger(PlayerKilled, coopACU)
    end
    ScenarioFramework.CreateUnitDeathTrigger(PlayerKilled, ScenarioInfo.PlayerCDR)

    -- Jericho strut
    local cmd = IssueMove({ScenarioInfo.Jericho}, ScenarioUtils.MarkerToPosition('JerichoDestination'))
    while(not IsCommandDone(cmd)) do
        WaitSeconds(.5)
    end
    ScenarioFramework.Dialogue(OpStrings.C06_M01_010, StartMission1)
    WaitSeconds(5)
    if(ScenarioInfo.Jericho:IsIdleState()) then
        for i = 1, 3 do
            IssuePatrol({ScenarioInfo.Jericho}, ScenarioUtils.MarkerToPosition('Jericho_Patrol' .. i))
        end
    end

    -- After 2 minutes: Jericho VO trigger
    ScenarioFramework.CreateTimerTrigger(M1JerichoVO, 120)

    -- Cybran in Aeon LOS VO trigger
    ScenarioFramework.CreateArmyIntelTrigger(CybranSpotted, ArmyBrains[aeon], 'LOSNow',
        false, true, categories.ALLUNITS, true, ArmyBrains[Player1])
end

function StartMission1()
    ScenarioFramework.CreateTimerTrigger(Taunt, Random(200, 300))

    -- Primary Objective 1
	--Trigger if the Czar is killed during construction
    ScenarioFramework.CreateArmyStatTrigger(CzarDefeated, ArmyBrains[aeon], 'CzarDefeated1',
        {{StatType = 'Units_Killed', CompareType = 'GreaterThanOrEqual', Value = 1, Category = categories.uaa0310}})
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

    -- M1P1 Objective Reminder
    ScenarioFramework.CreateTimerTrigger(M1P1Reminder1, M1P1Time)
	
	--Secondary Objective 1
	--Reward for completion: The Aeon Base will shut down completely.
	--Disabled, BaseManager keeps building Experimentals for some reason even after the base was disabled
	--[[ScenarioInfo.M1S1 = Objectives.KillOrCapture(
        'secondary',                      -- type
        'incomplete',                   -- complete
        OpStrings.OpC06_M1S1_Title,  -- title
        OpStrings.OpC06_M1S1_Desc,  -- description
        {
			MarkUnits = true,
            FlashVisible = true,
            Units = {ScenarioInfo.Arnold},
        }
    )
    ScenarioInfo.M1S1:AddResultCallback(
        function(result)
            if(result) then
                M1AeonAI.DisableAeonMainBase()
            end
        end
    )]] 
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
    ScenarioInfo.VarTable['CybranSpotted'] = true
end

function CzarFullyBuilt()
    ScenarioInfo.CzarFullyBuilt = true

    ScenarioFramework.SetPlayableArea('M2Area')
    ScenarioInfo.M2Area = true
	
	--Control Center base will build additional defenses
	if (not ScenarioInfo.ControlCenterExpansionAuthorized) then
		M2UEFAI.M2UEFControlCenterExpansion()
	end

    ScenarioFramework.CreateAreaTrigger(CzarOverLand, ScenarioUtils.AreaToRect('CzarOverLand'),
        categories.uaa0310, true, false, ArmyBrains[aeon])
end

function CzarAI(platoon)
	--Update mission state first
	ScenarioInfo.Czar = platoon:GetPlatoonUnits()
	if(table.getn(ScenarioInfo.Czar) > 0) then
        ScenarioInfo.M1P1:AddUnitTarget(ScenarioInfo.Czar[1])
		CzarFullyBuilt()
	end
	--Pause its death
    ScenarioFramework.PauseUnitDeath( ScenarioInfo.Czar[1] )
	
	--Assign squadron to a platoon, and load them inside the Czar
    if(ScenarioInfo.CzarBombers) then
        ScenarioInfo.CzarBomberPlatoon = ArmyBrains[aeon]:MakePlatoon('','')
        for k, v in ScenarioInfo.CzarBombers do
            if(not v:IsDead() and not v:IsUnitState('Attached')) then
                ArmyBrains[aeon]:AssignUnitsToPlatoon(ScenarioInfo.CzarBomberPlatoon, {v}, 'attack', 'NoFormation')
                IssueClearCommands({v})
            end
        end
		--Check if the squadron still exists
        if(table.getn(ScenarioInfo.CzarBomberPlatoon:GetPlatoonUnits()) > 0) then
            ScenarioInfo.CzarBomberPlatoon:Stop()
            IssueTransportLoad(ScenarioInfo.CzarBomberPlatoon:GetPlatoonUnits(), ScenarioInfo.Czar[1])
            WaitSeconds(5)
        end
    end
	--Attack the Control Center
    IssueAttack(ScenarioInfo.Czar, ScenarioInfo.ControlCenter)
	--VO to warn of its take-off.
    ScenarioFramework.Dialogue(OpStrings.C06_M01_050)
	--Release squadron on taking damage
    ScenarioFramework.CreateUnitDamagedTrigger(CzarDamaged, ScenarioInfo.Czar[1])
end

function CzarDamaged()
    ForkThread(ReleaseBombers)
end

function ReleaseBombers()
    if(not ScenarioInfo.BombersReleased) then
        ScenarioInfo.BombersReleased = true
        IssueClearCommands(ScenarioInfo.Czar)
        IssueTransportUnload(ScenarioInfo.Czar, ScenarioInfo.Czar[1]:GetPosition())
        WaitSeconds(5)
        IssueAttack(ScenarioInfo.Czar, ScenarioInfo.ControlCenter)
        if(ScenarioInfo.CzarBomberPlatoon and table.getn(ScenarioInfo.CzarBomberPlatoon:GetPlatoonUnits()) > 0) then
            ScenarioInfo.CzarBomberPlatoon:Stop()
            ScenarioInfo.CzarBomberPlatoon:AggressiveMoveToLocation(ScenarioInfo.ControlCenter:GetPosition())
        end
    end
end

function CzarDefeated()
    if(ScenarioInfo.M1P1.Active) then
        ScenarioInfo.M1P1:ManualResult(true)

        -- Make Control Center invulnerable
        ScenarioInfo.ControlCenter:SetCanTakeDamage(false)
        ScenarioInfo.ControlCenter:SetCanBeKilled(false)
        ScenarioInfo.ControlCenter:SetDoNotTarget(true)

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
end

--No longer used, but I'm keeping it, I might find a use for it for a different mission.
function CzarEngineerDefeated()
    if(not ScenarioInfo.CzarFullyBuilt) then
        if(ScenarioInfo.CzarEngineer.UnitBeingBuilt) then
            ScenarioInfo.CzarEngineer.UnitBeingBuilt:Kill()
        end
    end
end

--Called if the Czar is near the Control Center
function CzarOverLand()
    if(ScenarioInfo.M1P1.Active) then
        ScenarioFramework.Dialogue(OpStrings.C06_M01_060)
    end
    ForkThread(ReleaseBombers)
end

function M1P1Reminder1()
    if(ScenarioInfo.M1P1.Active) then
        ScenarioFramework.Dialogue(OpStrings.C06_M01_070)
        ScenarioFramework.CreateTimerTrigger(M1P1Reminder2, SubsequentTime)
    end
end

function M1P1Reminder2()
    if(ScenarioInfo.M1P1.Active) then
        ScenarioFramework.Dialogue(OpStrings.C06_M01_075)
        ScenarioFramework.CreateTimerTrigger(M1P1Reminder3, SubsequentTime)
    end
end

function M1P1Reminder3()
    if(ScenarioInfo.M1P1.Active) then
        ScenarioFramework.Dialogue(OpStrings.C06_M01_076)
        ScenarioFramework.CreateTimerTrigger(M1P1Reminder1, SubsequentTime)
    end
end

-----------
-- Mission 2
-----------
function IntroMission2()
    ScenarioInfo.MissionNumber = 2

    ScenarioFramework.SetSharedUnitCap(780)
	
	ForkThread(M2StationaryFatboysThread)
	
	--If the Czar was taken out before completion, the Control Center will get its expanded defenses added here
	if(not ScenarioInfo.ControlCenterExpansionAuthorized) then
		M2UEFAI.M2UEFControlCenterExpansion()
	end
	
	--Build Power buff is first called once Phase 2 starts in normal mode
	if ScenarioInfo.Options.opt_Coop_Debug_Mode ==  1 then
		ForkThread(BuffAIBuildPower)
	end
	
	--Expand the UEF base during Phase 2
	M3UEFAI.M3UEFMainExpansion()

    -- UEF Land Attack
    for i = 1, 3 do
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M2LandPatrol_D1_' .. i, 'AttackFormation')
        platoon.PlatoonData = {}
        platoon.PlatoonData.PatrolChain = 'M2LandAttack_Chain' .. i
        platoon:ForkAIThread(ScenarioPlatoonAI.PatrolThread)
    end
    if(Difficulty >= 2) then
        for i = 1, 2 do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M2LandPatrol_D2_' .. i, 'AttackFormation')
            platoon.PlatoonData = {}
            platoon.PlatoonData.PatrolChain = 'M2LandAttack_Chain' .. i
            platoon:ForkAIThread(ScenarioPlatoonAI.PatrolThread)
        end
    end
    if(Difficulty == 3) then
        for i = 1, 3 do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M2LandPatrol_D3_' .. i, 'AttackFormation')
            platoon.PlatoonData = {}
            platoon.PlatoonData.PatrolChain = 'M2LandAttack_Chain' .. i
            platoon:ForkAIThread(ScenarioPlatoonAI.PatrolThread)
        end
    end

    -- UEF Air Attack
	-- Spawned 2x, 3x times for Normal, Hard
	for k = 1, Difficulty do
		for i = 1, 2 do
			local group = ScenarioUtils.CreateArmyGroup('UEF', 'M2AirPatrol_D1_' .. i)
			for k, v in group do
				platoon = ArmyBrains[uef]:MakePlatoon('','')
				ArmyBrains[uef]:AssignUnitsToPlatoon(platoon, {v}, 'attack', 'NoFormation')
				platoon.PlatoonData = {}
				platoon.PlatoonData.PatrolChain = 'ControlCenterAir_Chain'
				platoon:ForkAIThread(ScenarioPlatoonAI.RandomPatrolThread)
			end
		end
		if(Difficulty >= 2) then
			local group = ScenarioUtils.CreateArmyGroup('UEF', 'M2AirPatrol_D2_1')
			for k, v in group do
				platoon = ArmyBrains[uef]:MakePlatoon('','')
				ArmyBrains[uef]:AssignUnitsToPlatoon(platoon, {v}, 'attack', 'NoFormation')
				platoon.PlatoonData = {}
				platoon.PlatoonData.PatrolChain = 'ControlCenterAir_Chain'
				platoon:ForkAIThread(ScenarioPlatoonAI.RandomPatrolThread)
			end
		end
		if(Difficulty >= 3) then
			for i = 1, 2 do
				local group = ScenarioUtils.CreateArmyGroup('UEF', 'M2AirPatrol_D3_' .. i)
				for k, v in group do
					platoon = ArmyBrains[uef]:MakePlatoon('','')
					ArmyBrains[uef]:AssignUnitsToPlatoon(platoon, {v}, 'attack', 'NoFormation')
					platoon.PlatoonData = {}
					platoon.PlatoonData.PatrolChain = 'ControlCenterAir_Chain'
					platoon:ForkAIThread(ScenarioPlatoonAI.RandomPatrolThread)
				end
			end
		end
	end

	
    -- Colossus Attack
	-- Only send it if Arnold is still alive
    if(ScenarioInfo.Colossus and not ScenarioInfo.Colossus:IsDead()) then
        IssueClearCommands({ScenarioInfo.Colossus})
        IssuePatrol({ScenarioInfo.Colossus}, ScenarioUtils.MarkerToPosition('M2LandAttack_Patrol2'))
        IssuePatrol({ScenarioInfo.Colossus}, ScenarioUtils.MarkerToPosition('M2LandAttack_Patrol3'))
        IssuePatrol({ScenarioInfo.Colossus}, ScenarioUtils.MarkerToPosition('M2LandAttack_Patrol1'))
    end

    ScenarioFramework.RemoveRestrictionForAllHumans(
        categories.urb4302 +    -- T3 Strategic Missile Defense
        categories.url0402 +     -- Spider Bot
        categories.ueb2302 +      -- Long Range Heavy Artillery
        categories.ueb4301 +      -- T3 Heavy Shield Generator
        categories.uel0401 +     -- Experimental Mobile Factory
        categories.ues0304 +       -- Strategic Missile Submarine
        categories.uab0304 +     -- Quantum Gate
        categories.ual0301 +     -- Sub Commander
        categories.uas0304		-- Strategic Missile Submarine
    )

    ScenarioFramework.RemoveRestriction(uef, categories.ueb2302 +  -- Long Range Heavy Artillery
                                categories.ueb4301 +  -- T3 Heavy Shield Generator
                                categories.uel0401 +  -- Experimental Mobile Factory
                                categories.ues0304)   -- Strategic Missile Submarine

    ScenarioFramework.RemoveRestriction(aeon, categories.uab0304 + -- Quantum Gate
                                 categories.ual0301 + -- Sub Commander
                                 categories.uas0304)  -- Strategic Missile Submarine
	--Allow Gates to be built
	ScenarioFramework.RemoveRestrictionForAllHumans(categories.GATE, true)
    ScenarioFramework.Dialogue(OpStrings.C06_M02_010, StartMission2)
end

function StartMission2()
    ScenarioFramework.SetPlayableArea('M2Area')
	
    -- After 3 minutes: Jericho VO trigger
    ScenarioFramework.CreateTimerTrigger(M2JerichoVO, 180)

    -- After 4 minutes: Ops VO trigger
    ScenarioFramework.CreateTimerTrigger(M2OpsVO, 240)

    -- Primary Objective 1
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
        function()
			ScenarioFramework.Dialogue(OpStrings.C06_M02_050, GateBuilt)
		end
    )

    -- M2P1 Objective Reminder
    ScenarioFramework.CreateTimerTrigger(M2P1Reminder1, M2P1Time)
	
	-- Secondary Objective 2
	-- Reward for completion: Cybran T3 Heavy Artillery
    ScenarioInfo.M2S1 = Objectives.ArmyStatCompare(
        'secondary',                      -- type
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
        function()
				ScenarioFramework.RemoveRestrictionForAllHumans(categories.urb2302, true) -- Long Range Heavy Artillery
        end
    )
end


--The 2 fatboys are sent near the Control Center, and no longer act as factories
function M2StationaryFatboysThread()
    -- Mobile Factories
    local StationaryFatboy1 = ScenarioUtils.CreateArmyUnit('UEF', 'MobileFactory1')
    local StationaryFatboy2 = ScenarioUtils.CreateArmyUnit('UEF', 'MobileFactory2')
    local cm1 = IssueMove({StationaryFatboy1}, ScenarioUtils.MarkerToPosition('MobileFactory1'))
    local cm2 = IssueMove({StationaryFatboy2}, ScenarioUtils.MarkerToPosition('MobileFactory2'))

    repeat
        WaitSeconds(5)
    until IsCommandDone(cm1) and IsCommandDone(cm2)
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
	M2UEFAI.UEFDefensiveLineBaseAI()
	M2UEFAI.M2DefensiveLineExpansion()
end

function Taunt()
    -- Choose Aiko or Arnold
    local choice = Random(0, 2)
    if(choice == 0) then
        -- Play Aiko taunt, if Aiko is dead, play Arnold taunt, if Arnold is also dead, play Blake taunt if he's still alive.
        if(ScenarioInfo.Aiko and not ScenarioInfo.Aiko:IsDead() and aikoTaunt <= 8) then
            PlayAikoTaunt()
        elseif(ScenarioInfo.Arnold and not ScenarioInfo.Arnold:IsDead() and arnoldTaunt <= 16) then
            PlayArnoldTaunt()
		elseif(ScenarioInfo.Blake and not ScenarioInfo.Blake:IsDead() and blakeTaunt <= 22) then
			PlayBlakeTaunt()
        end
    elseif(choice == 1) then
        -- Play Arnold taunt, if Arnold is dead play Aiko taunt, if Aiko is also dead, play Blake taunt if he's still alive.
        if(not ScenarioInfo.Arnold:IsDead() and arnoldTaunt <= 16) then
            PlayArnoldTaunt()
        elseif(not ScenarioInfo.Aiko:IsDead() and aikoTaunt <= 8) then
            PlayAikoTaunt()
		elseif(ScenarioInfo.Blake and not ScenarioInfo.Blake:IsDead() and blakeTaunt <= 22) then
			PlayBlakeTaunt()
        end
	else
		 -- Play Blake taunt, if Blake is dead play Aiko taunt, if Aiko is also dead, play Arnold taunt if he's still alive.
        if(ScenarioInfo.Blake and not ScenarioInfo.Blake:IsDead() and blakeTaunt <= 22) then
            PlayBlakeTaunt()
        elseif(ScenarioInfo.Aiko and not ScenarioInfo.Aiko:IsDead() and aikoTaunt <= 8) then
            PlayAikoTaunt()
		elseif(ScenarioInfo.Arnold and not ScenarioInfo.Arnold:IsDead() and arnoldTaunt <= 16) then
			PlayArnoldTaunt()
        end
    end
end

function PlayAikoTaunt()
    ScenarioFramework.Dialogue(OpStrings['TAUNT' .. aikoTaunt])
	--Start over with the taunts if needed
	if aikoTaunt > 8 then
		aikoTaunt = 1
	else
		aikoTaunt = aikoTaunt + 1
	end
    ScenarioFramework.CreateTimerTrigger(Taunt, Random(100, 200))
end

function PlayArnoldTaunt()
    ScenarioFramework.Dialogue(OpStrings['TAUNT' .. arnoldTaunt])
	--Start over with the taunts if needed
	if arnoldTaunt > 16 then
		arnoldTaunt = 9
	else
		arnoldTaunt = arnoldTaunt + 1
	end
    ScenarioFramework.CreateTimerTrigger(Taunt, Random(100, 200))
end

function PlayBlakeTaunt()
	--Only play Blake taunt if we're at Phase 3, otherwise, call the Taunt() function again after a small delay
	if ScenarioInfo.MissionNumber == 3 then
		ScenarioFramework.Dialogue(OpStrings['TAUNT' .. blakeTaunt])
		--Start over with the taunts if needed
		if blakeTaunt > 22 then
			blakeTaunt = 17
		else
			blakeTaunt = blakeTaunt + 1
		end
		ScenarioFramework.CreateTimerTrigger(Taunt, Random(100, 200))
	else
		ScenarioFramework.CreateTimerTrigger(Taunt, 5)
	end
end

function GateBuilt()
    -- Primary Objective 2
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
    ScenarioInfo.CDRNearGate = ScenarioFramework.CreateUnitNearTypeTrigger(CDRNearGate, ScenarioInfo.PlayerCDR, ArmyBrains[Player1],
        categories.urb0304, 10)

    -- M2P2 Objective Reminder
    ScenarioFramework.CreateTimerTrigger(M2P2Reminder1, M2P2Time)
end

function GateDestroyed()
    if(ScenarioInfo.M2P2.Active) then
        ScenarioFramework.Dialogue(OpStrings.C06_M02_040)
        if(ScenarioInfo.CDRNearGate) then
            ScenarioInfo.CDRNearGate:Destroy()
        end
        ScenarioInfo.CDRNearGate = ScenarioFramework.CreateUnitNearTypeTrigger(CDRNearGate, ScenarioInfo.PlayerCDR, ArmyBrains[Player1],
            categories.urb0304, 10)
        if(ScenarioInfo.DownloadTimer) then
            ScenarioFramework.ResetUITimer()
            ScenarioInfo.DownloadTimer:Destroy()
        end
    end
end

function CDRNearGate()
    local position = ScenarioInfo.PlayerCDR:GetPosition()
    local rect = Rect(position[1] - 10, position[3] - 10, position[1] + 10, position[3] + 10)
	--categories.url0001 (Cybran ACU) is going to mess with mods replacing unit IDs. Using categories.COMMAND * categories.CYBRAN instead
    ScenarioFramework.CreateAreaTrigger(LeftGate, rect, categories.COMMAND * categories.CYBRAN, true, true, ArmyBrains[Player1])
    ScenarioInfo.DownloadTimer = ScenarioFramework.CreateTimerTrigger(DownloadFinished, 120, true)
    ScenarioFramework.Dialogue(OpStrings.C06_M02_060)

	-- Dhomie42: Below part is left here in case something needs to be recycled.
    -- Send in UEF attack on CDR
    --[[if(not ScenarioInfo.CDRGateAttack) then
        ScenarioInfo.CDRGateAttack = true
        local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M2CDRAttack_D' .. Difficulty, 'StaggeredChevronFormation')
        platoon:AttackTarget(ScenarioInfo.PlayerCDR)
    end]]
end

function LeftGate()
    if(ScenarioInfo.M2P2.Active and not ScenarioInfo.PlayerCDR:IsDead()) then
        ScenarioFramework.Dialogue(OpStrings.C06_M02_070)
        ScenarioFramework.ResetUITimer()
        ScenarioInfo.DownloadTimer:Destroy()

        -- Trigger will fire when CDR is near the gate
        ScenarioFramework.CreateUnitNearTypeTrigger(CDRNearGate, ScenarioInfo.PlayerCDR, ArmyBrains[Player1],
            categories.urb0304, 10)
    end
end

function DownloadFinished()
    ScenarioFramework.Dialogue(OpStrings.C06_M02_090)
	--Aiko calls for reinforcements
	ScenarioFramework.Dialogue(OpStrings.C06_M02_080)
    ScenarioInfo.M2P2:ManualResult(true)

    ScenarioInfo.ControlCenter:SetCapturable(true)

    -- Primary Objective 3
    ScenarioInfo.M2P3 = Objectives.Capture(
        'primary',                      -- type
        'incomplete',                   -- complete
        OpStrings.OpC06_M2P3_Title,     -- title
        OpStrings.OpC06_M2P3_Desc,      -- description
        {                               -- target
            Units = {ScenarioInfo.ControlCenter},
            NumRequired = 1,
        }
    )
    ScenarioInfo.M2P3:AddResultCallback(
        function(result)
            if(result) then
                ScenarioFramework.Dialogue(OpStrings.C06_M02_130)

				--Control Center made invulnerable, increased AI activity makes it harder to hold it, let alone keeping it alive from splash damage.
                local unit = ScenarioFramework.GetListOfHumanUnits(categories.uec1902, false)
                ScenarioInfo.ControlCenter = unit[1]
                ScenarioInfo.ControlCenter:SetDoNotTarget(true)
				        ScenarioInfo.ControlCenter:SetCanTakeDamage(false)
						ScenarioInfo.ControlCenter:SetReclaimable(false)
						ScenarioInfo.ControlCenter:SetCanBeKilled(false)
						ScenarioInfo.ControlCenter:SetCapturable(false)
                ScenarioFramework.PauseUnitDeath(ScenarioInfo.ControlCenter)
                ScenarioFramework.CreateUnitDestroyedTrigger(ControlCenterLost, ScenarioInfo.ControlCenter)

                -- control center captured cam
                local camInfo = {
                    blendTime = 1.0,
                    holdTime = 4,
                    orientationOffset = { -2.6, 0.3, 0 },
                    positionOffset = { 0, 0.5, 0 },
                    zoomVal = 30,
                }
                ScenarioFramework.OperationNISCamera( ScenarioInfo.ControlCenter, camInfo )

                IntroMission3()
            end
        end
    )

    -- M2P3 Objective Reminder
    ScenarioFramework.CreateTimerTrigger(M2P3Reminder1, M2P3Time)
end

function ControlCenterLost()
    PlayerLose()
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

    ScenarioFramework.SetSharedUnitCap(1020)

    -- Adjust buildable categories
    ScenarioFramework.PlayUnlockDialogue()
    ScenarioFramework.RemoveRestriction(Player1, categories.urb2305 +    -- Strategic Missile Launcher
                                   categories.urs0304)     -- Strategic Missile Submarine

    local tblArmy = ListArmies()
    for iArmy, strArmy in pairs(tblArmy) do
        if iArmy >= ScenarioInfo.Player2 then
            ScenarioFramework.RemoveRestriction(iArmy,
                categories.urb2305 +    -- Strategic Missile Launcher
                categories.urs0304)     -- Strategic Missile Submarine
        end
    end

    ScenarioFramework.Dialogue(OpStrings.C06_M03_010, StartMission3)
end

function StartMission3()
	ScenarioFramework.SetPlayableArea('M3NewArea') -- "M3Area" doesn't include the 2 Southern Islands, "M3NewArea" includes the entire map
	
	M3UEFAI.M3UEFBuildStrategicMissileLaunchers()
	--UEF T3 Heavy Artillery for Phase 3
	M3UEFAI.M3UEFMainBuildHeavyArtillery()
	--UEF SML AI thread
	EnableUEFNukeAI()
	
	--Southern Islands Bases
	M3AeonAI.M3AeonSouthEasternBaseAI()
	M3UEFAI.M3UEFSouthWesternBaseAI()
	
	--M3 UEF sACU for the South Western island.
	ScenarioInfo.MichaelsCDR = ScenarioUtils.CreateArmyUnit('UEF', 'Michael_sACU')
	ScenarioInfo.MichaelsCDR:SetCustomName('sCDR Michael')
	
	--M3 UEF Commander for the South Western island
	ScenarioInfo.Blake = ScenarioUtils.CreateArmyUnit('UEF', 'Blake_ACU')
	ScenarioInfo.Blake:SetCustomName('CDR Blake')
	ScenarioInfo.Blake:CreateEnhancement('Shield')
	ScenarioInfo.Blake:CreateEnhancement('HeavyAntiMatterCannon')
	ScenarioInfo.Blake:CreateEnhancement('T3Engineering')
	ScenarioInfo.Blake:SetAutoOvercharge(true)
	ScenarioFramework.CreateUnitDeathTrigger(BlakeDestroyed, ScenarioInfo.Blake)
	
	--M3 Aeon sACU for the South Eastern island, work in progress.
	ScenarioInfo.MatildasCDR = ScenarioUtils.CreateArmyUnit('Aeon', 'Matilda_sACU')
	ScenarioInfo.MatildasCDR:SetCustomName('sCDR Matilda')
	--BaseManager's ACU/sACU upgrading isn't working with enhancements that have previous enhancement requirements (Shield --> ShieldHeavy)
	--Instead they are added on spawning.
	ScenarioInfo.MatildasCDR:CreateEnhancement('ShieldHeavy')
	ScenarioInfo.MatildasCDR:CreateEnhancement('EngineeringFocusingModule')
	ScenarioInfo.MatildasCDR:CreateEnhancement('ResourceAllocation')
	
    -- Atlantis Assault
    ScenarioInfo.AtlantisPlanes = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M3AtlantisPlanes_D' .. Difficulty, 'StaggeredChevronFormation')
    ScenarioInfo.Atlantis = ScenarioUtils.CreateArmyUnit('UEF', 'Atlantis')
    IssueTransportLoad(ScenarioInfo.AtlantisPlanes:GetPlatoonUnits(), ScenarioInfo.Atlantis)
    IssueDive({ScenarioInfo.Atlantis})
    for i = 1, 9 do
        IssuePatrol({ScenarioInfo.Atlantis}, ScenarioUtils.MarkerToPosition('AtlantisAttack' .. i)) 
    end
	
	--Dhomie42: AtlantisBoats will guard the Atlantis instead.
	--local AtlantisGuards = ScenarioUtils.CreateArmyGroup('UEF', 'M3NavyFleet_D' .. Difficulty)
    --IssueGuard(AtlantisGuards, ScenarioInfo.Atlantis)
	
    ScenarioFramework.CreateUnitNearTypeTrigger(StartAtlantisAI, ScenarioInfo.Atlantis, ArmyBrains[Player1], categories.ALLUNITS, 90)
	
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
                ScenarioFramework.CreateTimerTrigger(M3P2Reminder1, M3P2Time)
            end
        end
    )

    -- M3P1 Objective Reminder
    ScenarioFramework.CreateTimerTrigger(M3P1Reminder1, M3P1Time)
end

function StartAtlantisAI()
    ForkThread(AtlantisAI)
end

function AtlantisAI()
	--Release aircraft
    IssueClearCommands({ScenarioInfo.Atlantis})
    IssueTransportUnload({ScenarioInfo.Atlantis}, ScenarioInfo.Atlantis:GetPosition())
	WaitSeconds(5)
	--Dive, and patrol player base area
	if (ScenarioInfo.Atlantis and not ScenarioInfo.Atlantis:IsDead()) then
		IssueDive({ScenarioInfo.Atlantis})
		IssuePatrol({ScenarioInfo.Atlantis}, ScenarioUtils.MarkerToPosition('PlayerAir_Patrol3'))
		IssuePatrol({ScenarioInfo.Atlantis}, ScenarioUtils.MarkerToPosition('PlayerAir_Patrol2'))
	end
	--Aircraft patrols the player base area
	IssueClearCommands(ScenarioInfo.AtlantisPlanes:GetPlatoonUnits())
    ScenarioInfo.AtlantisPlanes:Stop()
	ScenarioInfo.AtlantisPlanes:Patrol(ScenarioUtils.MarkerToPosition('PlayerBase'))
	ScenarioInfo.AtlantisPlanes:Patrol(ScenarioUtils.MarkerToPosition('PlayerAir_Patrol2'))
	ScenarioInfo.AtlantisPlanes:Patrol(ScenarioUtils.MarkerToPosition('PlayerAir_Patrol3'))

	--Play warning VO
	if(ScenarioInfo.Atlantis and not ScenarioInfo.Atlantis:IsDead()) then
		M3AikoVO()
	end
	
end

--UEF Nuke AI during Phase 3
--platoon.lua is used in this case
function EnableUEFNukeAI()
	--Get a table of all UEF SMLs
	local UEFSilos = ArmyBrains[uef]:GetListOfUnits(categories.ueb2305, false)
		
		--Only do something if there is at least 1 SML in the table
		if table.getn(UEFSilos) > 0 then
			for k, v in UEFSilos do
				--Loop through each SML, and only enable the NukeAI for an instance if it hasn't been enabled yet
				if not v.SiloAIEnabled and not v:IsDead() then
					--Make a single unit platoon for each SML
					local SiloPlatoon = ArmyBrains[uef]:MakePlatoon('','')
					ArmyBrains[uef]:AssignUnitsToPlatoon(SiloPlatoon, {v}, 'Attack', 'None')
					--Platoon gets the AI function called
					--*PlatoonName*.NukeAI is called, because the 'Platoon' class is actually defined in platoon.lua
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
    ScenarioFramework.CDRDeathNISCamera( ScenarioInfo.Aiko, 7 )
end

function ArnoldDestroyed()
    ScenarioFramework.Dialogue(OpStrings.C06_M03_055)
    ScenarioFramework.CDRDeathNISCamera( ScenarioInfo.Arnold, 7 )
end

function BlakeDestroyed()
    ScenarioFramework.Dialogue(OpStrings.C06_M03_100)
    ScenarioFramework.CDRDeathNISCamera( ScenarioInfo.Blake, 7 )
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

------------------
-- Debug Functions
------------------

--Date for reference: 2022.11.01
	--BaseManager method of creating Transport platoons isn't working.
	--This was used to check if maybe something was wrong with the build condition, but it's something else.
		--Issue fixed by making a unique platoon template for the transports.
function OnCtrlF3()
    local AeonTransports = ArmyBrains[aeon]:GetCurrentUnits(categories.uaa0104)
	
	if AeonTransports > 0 then
		LOG('*DEBUG: Aeon Transport count:' .. AeonTransports)
	else
		LOG('*DEBUG: No Aeon Transports found')
	end
end

--Debug function to remove reclaimables, it does 1500 damage to all reclaimables, including most props, on the whole map.
--Don't use this for normal gameplay
function OnCtrlF4()
	LOG('*DEBUG: Starting')
	CustomFunctions.AreaReclaimCleanUp()
end
