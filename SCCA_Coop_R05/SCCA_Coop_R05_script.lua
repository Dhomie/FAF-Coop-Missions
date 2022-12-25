-- ****************************************************************************
-- **
-- **  File     :  /maps/scca_coop_r05.v0020/SCCA_Coop_R05_script.lua
-- **  Author(s):  Greg
-- **
-- **  Summary  :
-- **
-- **  Copyright © 2006 Gas Powered Games, Inc.  All rights reserved.
-- ****************************************************************************

local ScenarioFramework = import('/lua/scenarioframework.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local Objectives = import('/lua/ScenarioFramework.lua').Objectives
local SimCamera = import('/lua/SimCamera.lua').SimCamera
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local Cinematics = import('/lua/cinematics.lua')
local OpStrings   = import('/maps/SCCA_Coop_R05/SCCA_Coop_R05_Strings.lua')
local ScenarioStrings = import('/lua/ScenarioStrings.lua')
local VizMarker = import('/lua/sim/VizMarker.lua').VizMarker
local Utilities = import('/lua/utilities.lua')
local M1UEFAI = import ('/maps/SCCA_Coop_R05/SCCA_Coop_R05_m1uefai.lua')
local M2UEFAI = import ('/maps/SCCA_Coop_R05/SCCA_Coop_R05_m2uefai.lua')
local M3UEFAI = import ('/maps/SCCA_Coop_R05/SCCA_Coop_R05_m3uefai.lua')

local Buff = import('/lua/sim/Buff.lua')

----------
-- Globals
----------

ScenarioInfo.Player1 = 1
ScenarioInfo.UEF = 2
ScenarioInfo.Hex5 = 3
ScenarioInfo.FauxUEF = 4
ScenarioInfo.Player2 = 5
ScenarioInfo.Player3 = 6
ScenarioInfo.Player4 = 7

local Player1 = ScenarioInfo.Player1
local UEF = ScenarioInfo.UEF
local Hex5 = ScenarioInfo.Hex5
local FauxUEF = ScenarioInfo.FauxUEF
local Player2 = ScenarioInfo.Player2
local Player3 = ScenarioInfo.Player3
local Player4 = ScenarioInfo.Player4
local Players = {ScenarioInfo.Player1, ScenarioInfo.Player2, ScenarioInfo.Player3, ScenarioInfo.Player4}
local AIs = {ScenarioInfo.UEF}
-- Table of unit categories for the buffing functions
local BuffCategories = {
	BuildPower = (categories.FACTORY * categories.STRUCTURE) + categories.ENGINEER,
	Economy = categories.ECONOMIC,
}

local Difficulty = ScenarioInfo.Options.Difficulty

local LeaderFaction
local LocalFaction

ScenarioInfo.M3P1Complete               = false

ScenarioInfo.M2_OmniObjCompleted        = false
ScenarioInfo.M3_VirusUploaded           = false
ScenarioInfo.M3_AirPlatformsDestroyed   = false
ScenarioInfo.UEFCommanderDestroyed      = false
ScenarioInfo.M2_FinalGunshipGroupsDefeated  = 0
ScenarioInfo.GunshipScenarioStarted         = false
ScenarioInfo.M2_OffmapPlatoonsDead          = 0
ScenarioInfo.M2_Hard_OffmapAttackCount      = 0
ScenarioInfo.UEFOmniDestroyedCounter        = 0

local M3_InitGunshipPlatsKilled         = 0
local M2_DelaySecondNavalAttack         = 290   -- Delay after start of M2 that we begin launcher the occasional secondary naval attacks
local M2_GunshipAttackDelay             = 10    -- Delay between warning dialogue and launch of attack. Currently, we want delay + travel time to be about 2 minutes

function AdjustDifficulty (table)
    return table[Difficulty]
end

 --- hard diff stuff
local M2_OffmapAttack_Land_Inital                   =   300
local M2_OffmapAttack_Land_Delay                    =   500
local M2_OffmapAttack_Air_Inital                    =   160
local M2_OffmapAttack_Air_Delay                     =   290
local M2_OffmapAttack_Air_Delay2                    =   400
ScenarioInfo.M2_OffmapAirDead                       =   0
ScenarioInfo.M2_Hard_OffmapAir_Count                =   0

ScenarioInfo.VarTable['M1_UEFAttackBegin'] = false				--Part 1, first stage of attacks, no off-map units
ScenarioInfo.VarTable['M1_UEFAttackBeginIncrease'] = false		--Part 1, first stage escalates, no off-map units
ScenarioInfo.VarTable['M1_UEFAttackBegin2'] = false				--Part 1, second stage of attacks, off-map air attacks begin.
ScenarioInfo.VarTable['M1_UEFAttackBegin3']  = false			--Part 1, third, and final stage of attacks, off-map naval, and transport attacks begin.
ScenarioInfo.VarTable['M2_DelayedNaval'] = false				--Part 2, Used for scripted spawns
ScenarioInfo.VarTable['M2_UEF_NavalBase_Operational'] = true   	--Part 2, used by the UEF AI to check if it should build patrols for the naval base
ScenarioInfo.VarTable['M3_VirusUpload'] = false					--Part 3, secondary objective flag if completed

ScenarioInfo.OperationEnding        = false						--Flag used to ensure only 1 method of completing the operation is being focused on.
																--The 2 methods are either killing Hex5's prison building near Godwyn's main base, or killing Godwyn himself.

------------------------
-- AI buffing functions
------------------------
-- Comments:
-- ACUs and sACUs belong to both ECONOMIC and ENGINEER categories.

-- Buffs AI factory structures, and engineer units
function BuffAIBuildPower()
	-- Build Rate multiplier values, depending on the Difficulty
	local Rate = {1.0, 1.5, 2.0}
	-- Buff definitions
	buffDef = Buffs['CheatBuildRate']
	buffAffects = buffDef.Affects
	buffAffects.BuildRate.Mult = Rate[Difficulty]

	while true do
		for i, j in AIs do
			if table.getn(AIs) > 0 then
				local buildpower = ArmyBrains[j]:GetListOfUnits(BuffCategories.BuildPower, false)
				-- Check if there is anything to buff
				if table.getn(buildpower) > 0 then
					for k, v in buildpower do
						-- Apply buff to the entity if it hasn't been buffed yet
						if not v.BuildBuffed then
							Buff.ApplyBuff(v, 'CheatBuildRate')
							-- New Entity flag which is true if the entity has already been buffed
							v.BuildBuffed = true
						end
					end
				end
			end
		end
		-- Do this again after 60 seconds
		WaitSeconds(60)
	end
end

-- Buffs resource producing structures, (and ACU variants.)
function BuffAIEconomy()
	-- Resource production multipliers, depending on the Difficulty
	local Rate = {2.0, 4.0, 6.0}
	-- Buff definitions
	buffDef = Buffs['CheatIncome']
	buffAffects = buffDef.Affects
	buffAffects.EnergyProduction.Mult = Rate[Difficulty]
	buffAffects.MassProduction.Mult = Rate[Difficulty]
	
	while true do
		for i, j in AIs do
			if table.getn(AIs) > 0 then
				local economy = ArmyBrains[j]:GetListOfUnits(BuffCategories.Economy, false)
				-- Check if there is anything to buff
				if table.getn(economy) > 0 then
					for k, v in economy do
				-- Apply buff to the entity if it hasn't been buffed yet
						if not v.EcoBuffed then
					Buff.ApplyBuff(v, 'CheatIncome')
					-- New Entity flag which is true if the entity has already been buffed
					v.EcoBuffed = true
						end
					end
				end
			end
		end
		-- Do this again after 60 seconds
		WaitSeconds(60)
	end
end
-----------
-- Startup
-----------
function OnPopulate(scenario)
	-- Initial units
    ScenarioUtils.InitializeScenarioArmies()
    LeaderFaction, LocalFaction = ScenarioFramework.GetLeaderAndLocalFactions()

    -- Set difficulty concantenation string
    if ScenarioInfo.Options.Difficulty == 1 then DifficultyConc = 'Light' end
    if ScenarioInfo.Options.Difficulty == 2 then DifficultyConc = 'Medium' end
    if ScenarioInfo.Options.Difficulty == 3 then DifficultyConc = 'Strong' end
	
	--------------
    -- M1 UEF Base
	--------------
	-- This is needed to make advanced platoon threads work
	ArmyBrains[UEF]:ForkThread(ArmyBrains[UEF].PickEnemy)
	M1UEFAI.UEFM1BaseAI()
    ScenarioInfo.UEFGenerators = ScenarioUtils.CreateArmyGroup ('UEF', 'M1_UEFGenerators')
	ScenarioUtils.CreateArmyGroup('UEF', 'M1_UEFBase_Naval_Defense_D' .. Difficulty)

    -- UEF Naval Units
    -- Create patrol 1 through 4, and send them on their same-numbered patrol chain 1 through 4
    for i = 1,4 do
        local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon ('UEF', 'M1_UEFNavalPatrol'..i..'_'..DifficultyConc, 'AttackFormation')
        ScenarioFramework.PlatoonPatrolChain(platoon, 'M1_UEF_NavalPatrol_Chain')
    end
    ScenarioInfo.M1_UEFNavalPatrol5 = ScenarioUtils.CreateArmyGroupAsPlatoon ('UEF', 'M1_UEFNavalPatrol5_'..DifficultyConc, 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.M1_UEFNavalPatrol5, 'M1_UEFNaval_Mid_PatrolChain_1')

    -- UEF Gunship Patrols
	for i = 1, 5 do
		local GunshipPlatoon = ScenarioUtils.CreateArmyGroupAsPlatoon ('UEF', 'M1_UEFGunshipsPatrol'..i..'_'..DifficultyConc, 'NoFormation')
			for k, v in GunshipPlatoon:GetPlatoonUnits() do
			if(v and not v:IsDead()) then
				ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M1_UEF_AirPatrol_Chain')))
			end
		end
	end
	
    -- UEF Base area ground patrols
    -- 3 patrol groups, each given a similarly numbered patrol
    for i = 1,3 do
        local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon ('UEF', 'M1_UEFBase_DefensePatrol_'..i.. '_'..DifficultyConc, 'AttackFormation')
        ScenarioFramework.PlatoonPatrolChain(platoon, 'M1_UEFLandPatrolChain_'..i)
    end

    -- M2 Area Eastern Omni Base: factories and infrastructure, as we will use this base to make offmap gunships in M1.
	M2UEFAI.UEFM2OmniBaseEastAI()
	-- M2 Area Naval Base: factories and walls, it will build naval attacks from the start.
	M2UEFAI.UEFM2NavalBaseAI()
	-- M2 Area Northen Omni Base: factories and walls, it will build transport attacks from the start.
	M2UEFAI.UEFM2OmniBaseNorthAI()
	-- M2 Area South Western Omni Base: factories and walls, it will build transport attacks from the start.
	M2UEFAI.UEFM2OmniBaseSouthWestAI()
	
	--AI buffing functions, forkthreaded, they act as coroutines, we want to check for units to buff every 60 seconds.
	ForkThread(BuffAIBuildPower)
	ForkThread(BuffAIEconomy)
end

function OnStart(self)
    ScenarioFramework.SetCybranColor(Player1)
    ScenarioFramework.SetUEFColor(UEF)
    ScenarioFramework.SetCybranAllyColor(Hex5)
    ScenarioFramework.SetUEFAllyColor(FauxUEF)
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

    ForkThread(IntroMission1)
end

function IntroMission1()
	ScenarioInfo.MissionNumber = 1
	
	-- Unit caps
	SetArmyUnitCap(UEF, 1500)
    ScenarioFramework.SetSharedUnitCap(540)
	
    Cinematics.EnterNISMode()
    ScenarioFramework.CreateTimerTrigger(SpawnCommanders, 1.25)
    Cinematics.CameraMoveToRectangle(ScenarioUtils.AreaToRect('Intro_Camera_1'), .75)
    Cinematics.CameraMoveToRectangle(ScenarioUtils.AreaToRect('Intro_Camera_2'), 3.5)
    WaitSeconds(1.5)
    Cinematics.CameraMoveToRectangle(ScenarioUtils.AreaToRect('Intro_Camera_3'), .75)
    WaitSeconds(1.25)
    Cinematics.ExitNISMode()
    StartMission1()
end

function SpawnCommanders()
	-- Use only for debug purposes:
	-- ScenarioUtils.CreateArmyGroup('Player1', 'PlayerStartingBase')
	
	-- Spawn in the players
	local tblArmy = ListArmies()
	local i = 1
	while tblArmy[ScenarioInfo['Player' .. i]] do
        ScenarioInfo['Player' .. i .. 'CDR'] = ScenarioFramework.SpawnCommander('Player' .. i, 'Player_' .. i, 'Warp', true, true, PlayerCDRKilled)
        WaitSeconds(1)
        i = i + 1
    end
end

--------------
-- Mission 1
--------------
function StartMission1()
    ScenarioInfo.MissionNumber = 1
	ScenarioFramework.SetPlayableArea('M1_PlayableArea', false)
	
	-- Unit, enhancement restrictions
	ScenarioFramework.AddRestrictionForAllHumans(
        categories.PRODUCTFA + -- All FA Units
		categories.PRODUCTDL + -- All SC1 bonus units(Hoplite, Corsair, etc.), and T3 Mobile AA
		(categories.NAVAL * categories.TECH3) +	-- All T3 naval units, including factories
		categories.EXPERIMENTAL +	-- All experimentals
        categories.urb2302 + -- Long Range Heavy Artillery
        categories.url0301 + -- Sub Commander
        categories.urb3104 + -- Omni Sensor Suite
        categories.urb4302 + -- T3 Strategic Missile Defense
        categories.urb2305 + -- Strategic Missile Launcher
        categories.urs0304 + -- Strategic Missile Submarine
        categories.urb4207 + -- Final T2 Shield upgrade

        categories.ueb2302 + -- Long Range Heavy Artillery
        categories.uel0301 + -- Sub Commander
        categories.ueb3104 + -- Omni Sensor Suite
        categories.ueb4302 + -- T3 Strategic Missile Defense
        categories.ueb2305 + -- Strategic Missile Launcher
        categories.ues0304 + -- Strategic Missile Submarine

        categories.urb2108 + -- Tactical Missile Launcher
        categories.urb2304 + -- T3 SAM Launcher
        categories.ura0304 + -- Strategic Bomber
        categories.ura0303 + -- Air Superiority Fighter
        categories.urb0304 + -- Quantum Gate
        categories.url0303 + -- Siege Assault Bot

        categories.ueb2108 + -- Tactical Missile Launcher
        categories.ueb2304 + -- T3 SAM Launcher
        categories.uea0304 + -- Strategic Bomber
        categories.uea0303 + -- Air Superiority Fighter
        categories.ueb0304 + -- Quantum Gate
        categories.uel0303	 -- Siege Assault Bot
	)
	
    ScenarioFramework.RestrictEnhancements({'StealthGenerator', 'Teleporter'})

	-- Mission start dialogue
	ScenarioFramework.Dialogue(OpStrings.C05_M01_010)
	-----------------------------------------------
	-- Primary Objective - Destroy Power Generators
	-----------------------------------------------
	ScenarioInfo.M1P1 = Objectives.CategoriesInArea(
        'primary',                    	-- type
        'incomplete',                   -- status
        OpStrings.M1P1Text,  			-- title
        OpStrings.M1P1Detail,  			-- description
        'kill',							-- goal
        {
            MarkUnits = true,
            Requirements = {
                {Area = 'M1_UEFBase_Area', Category = categories.ENERGYPRODUCTION, CompareOp = '<=', Value = 0, ArmyIndex = UEF},
            },
        }
   )
	
	ScenarioInfo.M1P1:AddResultCallback(
        function(result)
			if result then
				local camInfo = {
					blendTime = 1,
					holdTime = 4,
					orientationOffset = { -0.72, 0.35, 0 },
					positionOffset = { 0, 1.5, 0 },
					zoomVal = 55,
					markerCam = true,
				}
				ScenarioFramework.OperationNISCamera(ScenarioUtils.MarkerToPosition('NIS_M1_PowerGens'), camInfo)
				ScenarioFramework.Dialogue(OpStrings.C05_M01_050, StartMission2)
			end
        end
   )
    ScenarioFramework.Dialogue(ScenarioStrings.NewPObj)

	-- Naval patrol intel triggers for VO
    ScenarioFramework.CreateArmyIntelTrigger(M1_PromptNavalDialogue, ArmyBrains[Player1], 'Radar', false, true, categories.NAVAL, true, ArmyBrains[UEF])
    ScenarioFramework.CreateArmyIntelTrigger(M1_PromptNavalDialogue, ArmyBrains[Player1], 'Sonar', false, true, categories.NAVAL, true, ArmyBrains[UEF])
    ScenarioFramework.CreateArmyIntelTrigger(M1_PromptNavalDialogue, ArmyBrains[Player1], 'LOSNow', false, true, categories.NAVAL, true, ArmyBrains[UEF])
    ScenarioFramework.CreateArmyIntelTrigger(M1_PromptNavalDialogue, ArmyBrains[Player1], 'Omni', false, true, categories.NAVAL, true, ArmyBrains[UEF])

    -- Intel trigger for LOS on player
    ScenarioFramework.CreateArmyIntelTrigger(M1_UEFSpotsPlayer, ArmyBrains[UEF], 'LOSNow', false, true, categories.ALLUNITS, true, ArmyBrains[Player1])

	-- Timer for 1st wave of attacks
	local delay = {750, 600, 450}
    ScenarioFramework.CreateTimerTrigger (M1ScoutThread, delay[Difficulty])

    -- Taunt when 5th naval unit killed
    ScenarioFramework.CreateArmyStatTrigger(M1_NavalProgressTaunt, ArmyBrains[Player1], 'TauntTrigger',
        {{ StatType = 'Enemies_Killed', CompareType = 'GreaterThan', Value = 4, Category = categories.NAVAL * categories.UEF, },}) -- 5 uef naval
		
	-- If the players don't complete the objective soon, remind them that it's important
    ScenarioFramework.CreateTimerTrigger(M1P1Reminder, 900)
end

function M1_PromptNavalDialogue()
    if not ScenarioInfo.M1_NavalPromptPlayed then
        ScenarioInfo.M1_NavalPromptPlayed = true
        ScenarioFramework.Dialogue(OpStrings.C05_M01_030)
    end
end

function M1_NavalProgressTaunt()
    ScenarioFramework.Dialogue(OpStrings.TAUNT8)
end

function M1_UEFSpotsPlayer()
    ScenarioFramework.Dialogue(OpStrings.C05_M01_040)
end

function M1ScoutThread()
    if ScenarioInfo.MissionNumber ==1 then
		-- Scouts for land area
        local ScoutGroupOne = ScenarioUtils.CreateArmyGroupAsPlatoon ('UEF', 'M1_UEFScouts', 'ChevronFormation')
        ScenarioFramework.PlatoonPatrolChain(ScoutGroupOne, 'M1_UEFScout_Land_Chain')
		-- Scouts for water area
        local ScoutGroupTwo = ScenarioUtils.CreateArmyGroupAsPlatoon ('UEF', 'M1_UEFScouts', 'ChevronFormation')
        ScenarioFramework.PlatoonPatrolChain(ScoutGroupTwo, 'M1_UEFScout_Water_Chain')
		
		-- Delay first wave by 1 minute after being spotted.
        ScenarioFramework.CreateTimerTrigger(M1FirstAttackWave, 60)
    end
end

-- First attack wave, only triggered by timers, we don't want players to be rushed in the first few minutes just because they might have been spotted too early.
function M1FirstAttackWave()
    -- Tell PBM to begin building the 1st wave
    ScenarioInfo.VarTable['M1_UEFAttackBegin'] = true
	
	-- Timer for next phase
	local delay = {450, 400, 300}
    ScenarioFramework.CreateTimerTrigger (M1ReinforceFirstAttackWave, delay[Difficulty])
end

--Escalates the 1st wave
function M1ReinforceFirstAttackWave()
    -- Tell PBM to begin reinforcing the 1st wave
    ScenarioInfo.VarTable['M1_UEFAttackBeginIncrease'] = true
	
	-- Timer for next phase
	local delay = {450, 400, 300}
    ScenarioFramework.CreateTimerTrigger (M1SecondAttackWave, delay[Difficulty])
end

 -- Second attack wave, Resource base builds more units, Eastern Omni base sends light 'offmap' air attacks
function M1SecondAttackWave()
    -- Tell PBM to begin building the 2nd wave
    ScenarioInfo.VarTable['M1_UEFAttackBegin2'] = true
	
	-- Timer for next phase
	local delay = {450, 400, 300}
    ScenarioFramework.CreateTimerTrigger (M1ThirdAttackWave, delay[Difficulty])
end

-- Third Stage of attacks, SW and Northen Omni bases begin landing land units, offmap naval base begins naval attacks
-- Some of these received additional build conditions, this only tells the PBM that one of those build conditions is now met
function M1ThirdAttackWave()
	-- Tell PBM to begin building the 2nd wave
    ScenarioInfo.VarTable['M1_UEFAttackBegin3'] = true
	
	-- Taunt 4 moved here, to tell the players to get ready.
	-- 'Godwyn: There is more here than meets the eye.'
	ScenarioFramework.Dialogue(OpStrings.TAUNT4)
	
	-- Send the naval patrol to player area if it still exists
    if ArmyBrains[UEF]:PlatoonExists(ScenarioInfo.M1_UEFNavalPatrol5) == true then
        ScenarioInfo.M1_UEFNavalPatrol5:Stop()
        ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.M1_UEFNavalPatrol5, 'M1_UEFNaval_Mid_PatrolChain_2')
    end
end

--------------
-- Mission 2
--------------

function StartMission2()
	-- Update mission number, and playable area
	ScenarioInfo.MissionNumber = 2
    ScenarioFramework.SetPlayableArea('M2_PlayableArea')
	
	-- Update player unit cap
    ScenarioFramework.SetSharedUnitCap(720)
	
	-- Update unit restrictions
    ScenarioFramework.RemoveRestrictionForAllHumans(
        categories.urb2108 + -- T2 TML
        categories.urb2304 + -- T3 SAM Launcher
		categories.urb3104 + -- T3 Omni Sensor
		categories.url0303 + -- Siege Assault Bot
        categories.ura0304 + -- Strategic Bomber
		
		categories.ueb2108 + -- Tactical Missile Launcher
        categories.ueb2304 + -- T3 SAM Launcher
		categories.ueb3104 + -- T3 Omni Sensor
		categories.uel0303 + -- Siege Assault Bot
        categories.uea0304	 --Strategic Bomber
	)
	
	-- No cinematics for this part, we're using a different function to spawn in the units
    M2_CreateUnitsForMission()
	
	--------------------------------------------
    --Primary Objective 1 - Destroy Omni Sensors
	--------------------------------------------
    ScenarioInfo.M2P1 = Objectives.KillOrCapture(
        'primary',                      -- type
        'incomplete',                   -- complete
        OpStrings.M2P1Text,             -- title
        OpStrings.M2P1Detail,           -- description
        {                               -- target
            Units = ScenarioInfo.M2_ObjectiveOmniTable,
            FlashVisible = true,
            ShowProgress = true,
        }
   )
	
	------------------------------------------------
    --Secondary Objective 1 - Destroy UEF Naval Base
	------------------------------------------------
	ScenarioInfo.M2S1 = Objectives.CategoriesInArea(
        'secondary',                    	-- type
        'incomplete',               	-- status
        OpStrings.M2S1Text,  			-- title
        OpStrings.M2S1Detail,  			-- description
        'kill',							-- goal
        {
            MarkUnits = true,
            Requirements = {
                {Area = 'M2_NavalBase_Area', Category = categories.FACTORY + categories.ENGINEER, CompareOp = '<=', Value = 0, ArmyIndex = UEF},
            },
        }
   )
	ScenarioInfo.M2S1:AddResultCallback(
        function()
			ScenarioInfo.VarTable['M2_UEF_NavalBase_Operational'] = false
			ScenarioFramework.Dialogue(OpStrings.C05_M02_050)
			
			-- Navalbase destroyed cam
			local camInfo = {
				blendTime = 1,
				holdTime = 4,
				orientationOffset = { 0.72, 0.35, 0 },
				positionOffset = { 0, 0.75, 0 },
				zoomVal = 65,
				markerCam = true,
			}
			ScenarioFramework.OperationNISCamera(ScenarioUtils.MarkerToPosition('NIS_M2_Navalbase'), camInfo)
        end
   )

    --ScenarioFramework.Dialogue(ScenarioStrings.NewPObj)
    ScenarioFramework.Dialogue(OpStrings.C05_M02_010)
    --ScenarioFramework.Dialogue(ScenarioStrings.NewSObj)
	--Objective reminder
    ScenarioFramework.CreateTimerTrigger(M2P1Reminder, 600)

    -- Timer for some banter from enemy CDR, and tech tree unlock
    ScenarioFramework.CreateTimerTrigger (M2_EnemyBanterFourMins, 240)
    ScenarioFramework.CreateTimerTrigger (M2_UnlockAirSup, 300)
    ScenarioFramework.CreateTimerTrigger (M2_EnemyTaunt, 600)

    -- Special hard-difficulty offmap attacks.
    if Difficulty == 3 then
        ScenarioFramework.CreateTimerTrigger(M2_Hard_OffmapTransAttack, M2_OffmapAttack_Land_Inital)
        ScenarioFramework.CreateTimerTrigger(M2_Hard_OffmapAirAttack, M2_OffmapAttack_Air_Inital)
    end
end

function M2_CreateUnitsForMission()
    -- Create UEF Omni towers, their death triggers, and add them to a table for the objective system
    ScenarioInfo.M2_UEFOmniEast =  ScenarioUtils.CreateArmyUnit ('UEF', 'M2_UEFOmniEast')
    ScenarioInfo.M2_UEFOmniNorth = ScenarioUtils.CreateArmyUnit ('UEF', 'M2_UEFOmniNorth')
    ScenarioInfo.M2_UEFOmniSouthWest =  ScenarioUtils.CreateArmyUnit ('UEF', 'M2_UEFOmniSouthWest')

    ScenarioFramework.CreateUnitDestroyedTrigger(M2_OmniDestroyed, ScenarioInfo.M2_UEFOmniEast)
    ScenarioFramework.CreateUnitDestroyedTrigger(M2_OmniDestroyed, ScenarioInfo.M2_UEFOmniNorth)
    ScenarioFramework.CreateUnitDestroyedTrigger(M2_OmniDestroyed, ScenarioInfo.M2_UEFOmniSouthWest)

    ScenarioInfo.M2_ObjectiveOmniTable = {}
    table.insert(ScenarioInfo.M2_ObjectiveOmniTable, ScenarioInfo.M2_UEFOmniEast)
    table.insert(ScenarioInfo.M2_ObjectiveOmniTable, ScenarioInfo.M2_UEFOmniNorth)
    table.insert(ScenarioInfo.M2_ObjectiveOmniTable, ScenarioInfo.M2_UEFOmniSouthWest)

    -- UEF Omni base patrols
	-- Eastern patrols
    local eastOmniDef1 = ScenarioUtils.CreateArmyGroupAsPlatoon ('UEF', 'M2_UEFOmniBaseEast_AirPatrol1_'..DifficultyConc, 'NoFormation')
    local eastOmniDef2 = ScenarioUtils.CreateArmyGroupAsPlatoon ('UEF', 'M2_UEFOmniBaseEast_AirPatrol2_'..DifficultyConc, 'NoFormation')
    ScenarioFramework.PlatoonPatrolChain(eastOmniDef1, 'M2_UEFOmniEast_AirPatrolChain')
    ScenarioFramework.PlatoonPatrolChain(eastOmniDef2, 'M2_NavalEasternCombo_PatrolChain1')

     -- Southwestern patrols
    local swOmniDef1 = ScenarioUtils.CreateArmyGroupAsPlatoon ('UEF', 'M2_UEFOmniBaseSouthWest_AirPatrol1_'..DifficultyConc, 'NoFormation')
    local swOmniDef2 = ScenarioUtils.CreateArmyGroupAsPlatoon ('UEF', 'M2_UEFOmniBaseSouthWest_LandPatrol1_'..DifficultyConc, 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(swOmniDef1, 'M2_UEFOmniSW_LandPatrolChain_1')
    ScenarioFramework.PlatoonPatrolChain(swOmniDef2, 'M2_UEFOmniSW_AirPatrolChain')

    -- Northen patrols
    local northAirDef1 = ScenarioUtils.CreateArmyGroupAsPlatoon ('UEF', 'M2_UEFOmniBaseNorth_AirPatrol1_'..DifficultyConc, 'NoFormation')
    local northLandDef1 = ScenarioUtils.CreateArmyGroupAsPlatoon ('UEF', 'M2_UEFOmniBaseNorth_LandPatrol1_'..DifficultyConc, 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(northAirDef1, 'M2_UEFOmniNorth_AirPatrolChain')
    ScenarioFramework.PlatoonPatrolChain(northLandDef1, 'M2_UEFOmniNorth_LandPatrolChain_1')

    -- T2 Artillery for Normal, and Hard, won't be rebuilt by Engineers
    if Difficulty > 1 then
        ScenarioUtils.CreateArmyGroup ('UEF', 'M2_OmniBaseNorth_NoMaintain')
    end
	
	-- Naval base patrols
    local navalSeaDef1 = ScenarioUtils.CreateArmyGroupAsPlatoon ('UEF', 'M2_UEFNavalBase_NavalPatrol1_'..DifficultyConc, 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(navalSeaDef1, 'M2_UEFNaval_SeaPatrolChain')

    local navalAirDef1 = ScenarioUtils.CreateArmyGroupAsPlatoon ('UEF', 'M2_UEFNavalBase_AirPatrol1_'..DifficultyConc, 'NoFormation')
    local navalAirDef2 = ScenarioUtils.CreateArmyGroupAsPlatoon ('UEF', 'M2_UEFNavalBase_AirPatrol2_'..DifficultyConc, 'NoFormation')
    ScenarioFramework.PlatoonPatrolChain(navalAirDef1, 'M2_UEFNaval_AirPatrolChain')
    ScenarioFramework.PlatoonPatrolChain(navalAirDef2, 'M2_UEFNaval_AirPatrolChain')

    -- 4 general, not-base-specific patrols of gunships
    for i = 1,4 do
        local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon ('UEF', 'M2_UEFGunshipsPatrol'..i.. '_'..DifficultyConc, 'NoFormation')
        ScenarioFramework.PlatoonPatrolChain(platoon, 'M2_UEFGunshipPatrolGeneral_Chain_'..i)
    end

    -- Create an offmap generator for Hex5, so when he comes onto the map, he has the power to run his Stealth.
    ScenarioInfo.Hex5_Offmap_Generator = ScenarioUtils.CreateArmyUnit ('Hex5', 'M2_Hex_Temporary_Generator')
	
	-- Part 3 UEF bases are spawned at part 2, we want them to build off-map units, and also finish their patrol platoons by the time the map expands.
	-- UEF Main Base
	M3UEFAI.UEFM3MainBaseAI()
	
	-- UEF Air Base
	M3UEFAI.UEFM3AirBaseAI()
	
	-- Godwyn with some enhancements
	ScenarioInfo.M3_UEFMainBase_Commander = ScenarioFramework.SpawnCommander('UEF', 'M3_UEFMainBase_Commander', false, (LOC '{i R05_UEFCommander}'), true, false,
	{'ShieldGeneratorField', 'ResourceAllocation', 'DamageStabilization'})
	ScenarioInfo.M3_UEFMainBase_Commander:SetAutoOvercharge(true)
end

function M2_EnemyBanterFourMins()
    -- Enemy CDR banter, at four minutes
    ScenarioFramework.Dialogue(OpStrings.C05_M02_020)
end

function M2_UnlockAirSup()
    -- Unlock Air Superiority Fighters, associated dialogue
    ScenarioFramework.Dialogue(OpStrings.C05_M02_040)
    ScenarioFramework.RemoveRestrictionForAllHumans(categories.ura0303 + categories.uea0303)
end

function M2_EnemyTaunt()
    if ScenarioInfo.MissionNumber == 2 then
        ScenarioFramework.Dialogue(OpStrings.TAUNT1)
    end
end

function M2_OmniDestroyed(unit)
    ScenarioInfo.UEFOmniDestroyedCounter = ScenarioInfo.UEFOmniDestroyedCounter + 1
    if ScenarioInfo.UEFOmniDestroyedCounter == 1 then
        -- Taunt/banter from enemy CDR
        ScenarioFramework.Dialogue(OpStrings.C05_M02_030)
        ScenarioFramework.Dialogue(OpStrings.C05_M02_060)
        ScenarioFramework.CreateTimerTrigger(M2_OmniTriggeredTaunt1, 75) -- taunt
    end
    if ScenarioInfo.UEFOmniDestroyedCounter == 2 then
        ScenarioFramework.Dialogue(OpStrings.C05_M02_070)
        ScenarioFramework.CreateTimerTrigger(M2_OmniTriggeredTaunt2, 75) -- taunt
    end
    if ScenarioInfo.UEFOmniDestroyedCounter == 3 then
        -- Flag as done, so we don't try to do anything with the research facility.
        ScenarioInfo.M2_OmniObjCompleted = true
        ScenarioFramework.Dialogue(OpStrings.C05_M02_080)
        ScenarioFramework.Dialogue(ScenarioStrings.PObjComp)
        ScenarioInfo.M2P1Complete = true
        M2_Hex5Appears()
    end

	-- Omni Destroyed Camera
    local camInfo = {
        blendTime = 1.0,
        holdTime = 4,
        orientationOffset = { 0, 0.1, 0 },
        positionOffset = { 0, 1, 0 },
        zoomVal = 25,
    }
    if unit == ScenarioInfo.M2_UEFOmniEast then
        camInfo.orientationOffset[1] = 1.3
        camInfo.zoomVal = 45
    elseif unit == ScenarioInfo.M2_UEFOmniNorth then
        camInfo.orientationOffset[1] = 0.9269
    elseif unit == ScenarioInfo.M2_UEFOmniSouthWest then
        camInfo.orientationOffset[1] = 2.55
    end
    ScenarioFramework.OperationNISCamera(unit, camInfo)
end

function M2_OmniTriggeredTaunt1()
    if ScenarioInfo.MissionNumber == 2 then
        ScenarioFramework.Dialogue(OpStrings.TAUNT3)
    end
end

function M2_OmniTriggeredTaunt2()
    if ScenarioInfo.MissionNumber == 2 then
        ScenarioFramework.Dialogue(OpStrings.TAUNT6)
    end
end
----------------------------
-- Hex5 functions for part 2
----------------------------
function M2_Hex5Appears()
    --[[ScenarioInfo.M2P2 = Objectives.Basic(
        'primary',
        'incomplete',
        OpStrings.M2P2Text,
        OpStrings.M2P2Detail,
        Objectives.GetActionIcon('move'),
        {
            Area = 'M2_Hex5ObjectiveMarker',
            MarkArea = true,
        }
   )]]
   
	---------------------------------
    --Primary Objective 2 - Meet Hex5
	---------------------------------
	ScenarioInfo.M2P2 = Objectives.CategoriesInArea(
        'primary',                    	-- type
        'incomplete',               	-- status
        OpStrings.M2P2Text,  			-- title
        OpStrings.M2P2Detail,  			-- description
        'move',							-- goal
        {
            MarkArea = true,
            Requirements = {
                {Area = 'M2_Hex5Area', Category = categories.COMMAND * categories.CYBRAN, CompareOp = '>=', Value = 1, ArmyIndex = Player1},
				{Area = 'M2_Hex5Area', Category = categories.SUBCOMMANDER * categories.CYBRAN, CompareOp = '>=', Value = 1, ArmyIndex = Hex5},
            },
        }
   )

	--Genericly spawn the transport and Hex5, then assign them to a platoon.
	ScenarioInfo.M2_Hex5_Commander = ScenarioUtils.CreateArmyUnit ('Hex5', 'M2_Hex5_Commander')
	ScenarioInfo.M2_Hex5_Transport = ScenarioUtils.CreateArmyUnit ('Hex5', 'M2_Hex5_Transport')
	
	ScenarioInfo.M2_Hex5Platoon = ArmyBrains[Hex5]:MakePlatoon('', '')
    ScenarioInfo.M2_Hex5Platoon:UniquelyNamePlatoon('M2_Hex5Platoon')
	ArmyBrains[Hex5]:AssignUnitsToPlatoon(ScenarioInfo.M2_Hex5Platoon, {ScenarioInfo.M2_Hex5_Commander, ScenarioInfo.M2_Hex5_Transport}, 'Attack', 'None')
	
    ScenarioInfo.M2_Hex5_Commander:SetCanBeKilled(false)
    ScenarioInfo.M2_Hex5_Commander:SetCanTakeDamage(false)

    ScenarioInfo.M2_Hex5_Transport:SetReclaimable(false)
    ScenarioInfo.M2_Hex5_Transport:SetCapturable(false)
    ScenarioInfo.M2_Hex5_Transport:SetCanBeKilled(false)
    ScenarioInfo.M2_Hex5_Transport:SetCanTakeDamage(false)

    ScenarioInfo.M2_Hex5_Commander:SetCustomName(LOC '{i R05_Hex5Name}')

    -- Give him cloaking, and turn it on
    ScenarioInfo.M2_Hex5_Commander:InitIntel(3,'CloakField', 8)
    ScenarioInfo.M2_Hex5_Commander:EnableIntel('CloakField')

    -- Send him to the location, create a trigger that detects when he gets near the location so we can uncloak him,
    -- and fork a thread to check when he is unloaded
    ScenarioFramework.AttachUnitsToTransports({ScenarioInfo.M2_Hex5_Commander}, {ScenarioInfo.M2_Hex5_Transport})
    ScenarioInfo.M2_CommandHex5Unload = ScenarioInfo.M2_Hex5Platoon:UnloadAllAtLocation(ScenarioUtils.MarkerToPosition('M2_Hex5TransportPoint'))
    ScenarioFramework.CreateAreaTrigger(M2_UncloakHex5, ScenarioUtils.AreaToRect('M2_Hex5Area'), categories.ura0104, true, false, ArmyBrains[Hex5], 1, false)
    ForkThread(M2_Hex5UnloadCheckThread)
	
	--Objective reminder
	ScenarioFramework.CreateTimerTrigger(M2P2Reminder, 300)
end

function M2_UncloakHex5()
    ScenarioInfo.M2_Hex5_Commander:DisableIntel('CloakField')
    SetAlliance(Player1, Hex5, 'Ally')
    SetAlliance(Hex5, Player1, 'Ally')

	-- Now that Hex5 has been uncloaked enroute to his landing area, kick off the NIS
    WaitSeconds(2)
    local camInfo = {
        blendTime = 1.0,
        holdTime = 4,
        orientationOffset = {-2.2, 0.1, 0},
        positionOffset = {0, 0.5, 0},
        zoomVal = 55,
        markerCam = true,
    }
    ScenarioFramework.OperationNISCamera(ScenarioUtils.MarkerToPosition('NIS_M2_Hex5Intro'), camInfo)
end

function M2_Hex5UnloadCheckThread()
    while ScenarioInfo.M2_Hex5Platoon:IsCommandsActive(ScenarioInfo.M2_CommandHex5Unload) == true do
        WaitSeconds(1)
    end

    -- Move Hex5 away from his transport a bit, and give him a brief time in which to do so
    IssueMove({ScenarioInfo.M2_Hex5_Commander}, ScenarioUtils.MarkerToPosition('M2_Hex5WalkPoint'))
    WaitSeconds(3)

    -- Once Hex5 is in the area and uncloaked etc, create a trigger to see if the player CDR is present.
    ScenarioFramework.CreateAreaTrigger(M2_DownloadToCommander, ScenarioUtils.AreaToRect('M2_Hex5Area'), categories.COMMAND, true, false, ArmyBrains[Player1], 1, false)
end

function M2_DownloadToCommander()
    -- Fork thread, so we can have a slight pause before we do the download stuff
    ForkThread(M2_DownloadToCommanderThread)
end

function M2_DownloadToCommanderThread()
    -- Pause so the dialogue/download doesnt happen *immediately* after hitting the area
    WaitSeconds(3)
    ScenarioFramework.Dialogue(OpStrings.C05_M02_090)

-- Hex5 Download Cam
    local camInfo = {
        blendTime = 1.0,
        holdTime = 4,
        orientationOffset = { -2.2, 0.4, 0 },
        positionOffset = { 0, 0.5, 0 },
        zoomVal = 35,
        markerCam = true,
    }
    ScenarioFramework.OperationNISCamera(ScenarioUtils.MarkerToPosition('NIS_M2_Hex5Intro'), camInfo)

    -- Pause a bit to keep hex5 moving taking place after his bit of dialogue plays (instead of at the start of it)
    WaitSeconds(5)

    -- Complete the Hex5 Obj, and assign the Gunship Attack objective
    ScenarioInfo.M2P2:ManualResult(true) -- "Reach Hex5 with Your Commander"
    ScenarioFramework.Dialogue(ScenarioStrings.PObjComp)
	
	------------------------------------------------------------
	-- Primary Objective 3 - Eliminate UEF Aerial Counter-attack
	------------------------------------------------------------
    ScenarioInfo.M2P3 = Objectives.Basic(
        'primary',
        'incomplete',
        OpStrings.M2P3Text,
        OpStrings.M2P3Detail,
        Objectives.GetActionIcon('protect'),
        {
        }
	)
    ScenarioInfo.M2P2Complete = true

    -- Hex5 moves out, heads offmap. Fork thread to check for when his load command is complete, so we can then recloak him.
    ScenarioInfo.M2_Hex5LoadToLeaveCommand = ScenarioInfo.M2_Hex5Platoon:LoadUnits(categories.ALLUNITS)
    ScenarioInfo.M2_Hex5Platoon:MoveToLocation(ScenarioUtils.MarkerToPosition('M2_Hex5_ReturnPoint'), false)
    ScenarioInfo.M2_Hex5Platoon:Destroy()
    ForkThread(M2_Hex5ReloadAndLeaveCheckThread)

    -- Spawn in Gunship Attack, as thread so we can add delays as needed
    ForkThread(M2_UEFGunshipAttackThread)
end

function M2_Hex5ReloadAndLeaveCheckThread()
--    while ScenarioInfo.M2_Hex5Platoon:IsCommandsActive(ScenarioInfo.M2_Hex5LoadToLeaveCommand) == true do
    WaitSeconds(4)
--    end
    -- Do Stuff
    ForkThread(M2_ActivateHex5CloakThread)
end

function M2_ActivateHex5CloakThread()
    -- Pause before we reenable the cloak, so we see the transport begin moving first (purely for effect)
    WaitSeconds(3)
    -- Set Hex5 back to neutral, so we lose line-of-site
    SetAlliance(Player1, Hex5, 'Neutral')
    SetAlliance(Hex5, Player1, 'Neutral')
    ScenarioInfo.M2_Hex5_Commander:EnableIntel('CloakField')
end

function M2_UEFGunshipAttackThread()
    -- Pause a bit, so that this delay + travel time = about two minutes
    WaitSeconds(10)
    ScenarioInfo.M2_GunshipAttackPlatoon1 = ScenarioUtils.CreateArmyGroupAsPlatoon ('UEF', 'M2_UEFGunshipAttack1_'..DifficultyConc, 'NoFormation')
    ScenarioInfo.M2_GunshipAttackPlatoon2 = ScenarioUtils.CreateArmyGroupAsPlatoon ('UEF', 'M2_UEFGunshipAttack2_'..DifficultyConc, 'NoFormation')

    ScenarioFramework.CreatePlatoonDeathTrigger (M2_GunshipAttackDefeated, ScenarioInfo.M2_GunshipAttackPlatoon1)
    ScenarioFramework.CreatePlatoonDeathTrigger (M2_GunshipAttackDefeated, ScenarioInfo.M2_GunshipAttackPlatoon2)
    ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.M2_GunshipAttackPlatoon1, 'M2_UEFGunshipAttack_Chain2')
    ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.M2_GunshipAttackPlatoon2, 'M2_UEFGunshipAttack_Chain1')

    -- Med/Hard, add in some guarding air units
    if Difficulty > 1 then
        local guards = ScenarioUtils.CreateArmyGroupAsPlatoon ('UEF', 'M2_UEFGunshipAttackEscort_'..DifficultyConc, 'AttackFormation')
        local target = ScenarioInfo.UnitNames[UEF]['M2_MedGunship_Point']
        guards:GuardTarget(target)
        ScenarioFramework.PlatoonPatrolChain(guards, 'M2_UEFGunshipAttack_Chain1')
    end
end

function M2_GunshipAttackDefeated()
    ScenarioInfo.M2_FinalGunshipGroupsDefeated = ScenarioInfo.M2_FinalGunshipGroupsDefeated + 1
    if ScenarioInfo.M2_FinalGunshipGroupsDefeated == 2 then
        -- Complete mission/objective, start M3 with a pause
        ScenarioInfo.M2P3:ManualResult(true) -- "Defends against incoming gunship attack"
        ScenarioFramework.Dialogue(OpStrings.C05_M02_120, BeginMission3)
    end
end

-- Hard difficulty M2 offmap attacks
-- Land (west)
function M2_Hard_OffmapAttack_Counter()
    ScenarioInfo.M2_OffmapPlatoonsDead = ScenarioInfo.M2_OffmapPlatoonsDead + 1
    if ScenarioInfo.M2_OffmapPlatoonsDead == 4 then
        ScenarioInfo.M2_OffmapPlatoonsDead = 0
        ScenarioFramework.CreateTimerTrigger(M2_Hard_OffmapTransAttack, M2_OffmapAttack_Land_Delay)
    end
end

function M2_Hard_OffmapTransAttack()
    ForkThread(M2_Hard_OffmapTransAttack_Thread)
end

function M2_Hard_OffmapTransAttack_Thread()
    if ScenarioInfo.MissionNumber == 2 and Difficulty == 3 then
        -- Track number of attacks we've sent
        ScenarioInfo.M2_Hard_OffmapAttackCount = ScenarioInfo.M2_Hard_OffmapAttackCount + 1

        -- 1 - 4, to choose which spot we'll land at
        local rnd = Random(1,4)

        -- Do some normal sized attacks for a while, and eventually kick it up a notch by adding a tougher transport in.
        if ScenarioInfo.M2_Hard_OffmapAttackCount < 3  then
            for i = 1,4 do
                local transport =  ScenarioUtils.CreateArmyGroupAsPlatoon ('UEF', 'M2_UEF_Offscreen_Land_Transport', 'ChevronFormation')
                local units = ScenarioUtils.CreateArmyGroupAsPlatoon ('UEF', 'M2_UEF_Offscreen_LandUnits1', 'AttackFormation')
                local escort =  ScenarioUtils.CreateArmyGroupAsPlatoon ('UEF', 'M2_UEF_Offscreen_Land_AirEscort', 'ChevronFormation')
                M2_Hard_Offmap_AddEscort(escort,transport)
                ForkThread(TransportAttack, transport, units, 2,  'PlayerBase_Attack_'..rnd, 'Player_Base_LandAttackChain')
                ScenarioFramework.CreatePlatoonDeathTrigger(M2_Hard_OffmapAttack_Counter, units)
                WaitSeconds(0.3)
            end
        else
            for i = 1,4 do
                local transport =  ScenarioUtils.CreateArmyGroupAsPlatoon ('UEF', 'M2_UEF_Offscreen_Land_Transport', 'ChevronFormation')
                local units = ScenarioUtils.CreateArmyGroupAsPlatoon ('UEF', 'M2_UEF_Offscreen_LandUnits1', 'AttackFormation')
                local escort =  ScenarioUtils.CreateArmyGroupAsPlatoon ('UEF', 'M2_UEF_Offscreen_Land_AirEscort', 'ChevronFormation')
                M2_Hard_Offmap_AddEscort(escort,transport)
                ForkThread(TransportAttack, transport, units, 2,  'PlayerBase_Attack_'..rnd, 'Player_Base_LandAttackChain')
                ScenarioFramework.CreatePlatoonDeathTrigger(M2_Hard_OffmapAttack_Counter, units)
                WaitSeconds(0.3)
            end
            local transport =  ScenarioUtils.CreateArmyGroupAsPlatoon ('UEF', 'M2_UEF_Offscreen_Land_Transport', 'ChevronFormation')
            local units = ScenarioUtils.CreateArmyGroupAsPlatoon ('UEF', 'M2_UEF_Offscreen_LandUnits2', 'AttackFormation')
            local escort =  ScenarioUtils.CreateArmyGroupAsPlatoon ('UEF', 'M2_UEF_Offscreen_Land_AirEscort', 'ChevronFormation')
            M2_Hard_Offmap_AddEscort(escort,transport)
            ForkThread(TransportAttack, transport, units, 2,  'PlayerBase_Attack_'..rnd, 'Player_Base_LandAttackChain')
        end
    end
end

function M2_Hard_Offmap_AddEscort(escort, transport)
    transUnit = transport:GetPlatoonUnits()
    escort:GuardTarget (transUnit[1], 'Attack')
    ScenarioFramework.PlatoonPatrolChain(escort, 'M2_UEFGunshipAttack_Chain2')
end

-- Air (South)
function M2_Hard_OffmapAirAttack_Counter()
    -- increment counter for each platoon death
    ScenarioInfo.M2_OffmapAirDead = ScenarioInfo.M2_OffmapAirDead + 1

    -- if the number of platoons killed matches the number created,
    if ScenarioInfo.M2_OffmapAirDead == ScenarioInfo.M2_Hard_OffMapAirDeath then

        -- reset, and begin a timer for an attack again
        ScenarioInfo.M2_OffmapAirDead = 0
        if ScenarioInfo.M2_Hard_OffmapAir_Count <= 5 then
            ScenarioFramework.CreateTimerTrigger(M2_Hard_OffmapAirAttack, M2_OffmapAttack_Air_Delay)
        else
            ScenarioFramework.CreateTimerTrigger(M2_Hard_OffmapAirAttack, M2_OffmapAttack_Air_Delay2)
        end
    end
end

function M2_Hard_OffmapAirAttack()
    ForkThread(M2_Hard_OffmapAirAttack_Thread)
end

function M2_Hard_OffmapAirAttack_Thread()
    if ScenarioInfo.MissionNumber == 2 and Difficulty == 3 then
        ScenarioInfo.M2_Hard_OffmapAir_Count = ScenarioInfo.M2_Hard_OffmapAir_Count + 1

        -- 3 types of attacks, each using a different number of instances of the base platoon, and a death trigger for each to track.
        -- Set the count-to to that number of platoons. Final attack uses a "tougher" group as well.
        if ScenarioInfo.M2_Hard_OffmapAir_Count <= 1 then
            for i = 1,1 do
                local air =  ScenarioUtils.CreateArmyGroupAsPlatoon ('UEF', 'M2_UEF_Offscreen_AirUnits_1', 'ChevronFormation')
                ScenarioFramework.PlatoonPatrolChain(air, 'M1_UEFAirAttack2_Chain')
                ScenarioFramework.CreatePlatoonDeathTrigger(M2_Hard_OffmapAirAttack_Counter, air)
                WaitSeconds(1.5)
            end
            ScenarioInfo.M2_Hard_OffMapAirDeath = 1
        elseif ScenarioInfo.M2_Hard_OffmapAir_Count > 1 and ScenarioInfo.M2_Hard_OffmapAir_Count <= 5 then
            for i = 1,2 do
                local air =  ScenarioUtils.CreateArmyGroupAsPlatoon ('UEF', 'M2_UEF_Offscreen_AirUnits_1', 'ChevronFormation')
                ScenarioFramework.PlatoonPatrolChain(air, 'M1_UEFAirAttack2_Chain')
                ScenarioFramework.CreatePlatoonDeathTrigger(M2_Hard_OffmapAirAttack_Counter, air)
                WaitSeconds(1.5)
            end
            ScenarioInfo.M2_Hard_OffMapAirDeath = 2
        elseif ScenarioInfo.M2_Hard_OffmapAir_Count > 5 then
            for i = 1,2 do
                local air = ScenarioUtils.CreateArmyGroupAsPlatoon ('UEF', 'M2_UEF_Offscreen_AirUnits_1', 'ChevronFormation')
                ScenarioFramework.PlatoonPatrolChain(air, 'M1_UEFAirAttack2_Chain')
                ScenarioFramework.CreatePlatoonDeathTrigger(M2_Hard_OffmapAirAttack_Counter, air)
                WaitSeconds(1.5)
            end
            local air =  ScenarioUtils.CreateArmyGroupAsPlatoon ('UEF', 'M2_UEF_Offscreen_AirUnits_2', 'ChevronFormation')
            ScenarioFramework.PlatoonPatrolChain(air, 'M1_UEFAirAttack2_Chain')
            ScenarioFramework.CreatePlatoonDeathTrigger(M2_Hard_OffmapAirAttack_Counter, air)
            ScenarioInfo.M2_Hard_OffMapAirDeath = 3
        end
    end
end

--------------
-- Mission 3
--------------

function BeginMission3()
    ScenarioFramework.SetSharedUnitCap(960)
	ScenarioInfo.MissionNumber = 3
    ScenarioFramework.SetPlayableArea(ScenarioUtils.AreaToRect('M3_PlayableArea'))
	M3_CreateUnitsForMission()

    ScenarioFramework.Dialogue(OpStrings.C05_M03_010)
    ScenarioFramework.Dialogue(OpStrings.C05_M03_030)
	----------------------------------------------
	--Primary Objective 1 - Kill Commander Godywin
	----------------------------------------------
    ScenarioInfo.M3P1 = Objectives.KillOrCapture(  -- Kill enemy Commander
        'primary',                      -- type
        'incomplete',                   -- complete
        OpStrings.M3P1Text,             -- title
        OpStrings.M3P1Detail,           -- description
        {                               -- target
            Units = {ScenarioInfo.M3_UEFMainBase_Commander},
        }
	)
    ScenarioInfo.M3P1:AddResultCallback(
        function()
            M3_UEFCommanderDestroyed()
        end
	)
	--TODO: Rewrite this from Objectives.Basic to Objectives.Capture
    ScenarioInfo.M3S1 = Objectives.Basic(   -- Gunship Virus, secondary
        'secondary',
        'incomplete',
        OpStrings.M3S1Text,
        OpStrings.M3S1Detail,
        Objectives.GetActionIcon('move'),
        {
            Units = ScenarioInfo.M3_UEFAirBase_ASPlatforms,
            MarkUnits = true,
            FlashVisible = true,
        }
	)

    ScenarioFramework.Dialogue(ScenarioStrings.NewSObj)
    ScenarioFramework.Dialogue(ScenarioStrings.NewPObj)
    ScenarioFramework.CreateTimerTrigger(M3P1Reminder, 600)

    -- Destroy Hex5's offmap generator from M2
    if not ScenarioInfo.Hex5_Offmap_Generator:IsDead() then
        ScenarioInfo.Hex5_Offmap_Generator:Destroy()
    end

    -- Timed dialogue
    ScenarioFramework.CreateTimerTrigger (M3_GodwynThreat1, 60)

    -- If player gets near the souther prison colony, explain what it is
    ScenarioFramework.CreateAreaTrigger(M2_ColonyDialogue, ScenarioUtils.AreaToRect('M3_PrisonColonyArea'), categories.ALLUNITS, true, false, ArmyBrains[Player1], 1, false)
end

function M3_CreateUnitsForMission()	
    -- Spawn 3 smallish groups of gunships, so we definitely see gunships early
    for i=1,3 do
        local gunshipPlatoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF' ,'M3_UEF_GunshipAttack_'..i..'_'..DifficultyConc ,'NoFormation')
        gunshipPlatoon:ForkAIThread (ScenarioPlatoonAI.PlatoonAttackHighestThreat)
        ScenarioFramework.CreatePlatoonDeathTrigger(M3_InitialGunshipTaunt, gunshipPlatoon)
    end

    local airDef1 = ScenarioUtils.CreateArmyGroupAsPlatoon ('UEF', 'M3_UEFAirBase_AirPatrol1_'..DifficultyConc, 'NoFormation')
    local airDef2 = ScenarioUtils.CreateArmyGroupAsPlatoon ('UEF', 'M3_UEFAirBase_AirPatrol2_'..DifficultyConc, 'NoFormation')
    local landDef2 = ScenarioUtils.CreateArmyGroupAsPlatoon ('UEF', 'M3_UEFAirBase_LandPatrol1_'..DifficultyConc, 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(airDef1, 'M3_UEFAir_AirPatrolChain')
    ScenarioFramework.PlatoonPatrolChain(airDef2, 'M3_UEFAir_AirPatrolChain')
    ScenarioFramework.PlatoonPatrolChain(landDef2, 'M3_UEFAir_LandPatrolChain_1')

      --- fail the gunship virus obj if all the platforms get destroyed
    ScenarioInfo.M3_UEFAirBase_ASPlatforms = ScenarioUtils.CreateArmyGroup ('UEF', 'M3_UEFAirBase_Platforms')
    ScenarioFramework.CreateGroupDeathTrigger(M3_PlatformsDestroyedObjFail, ScenarioInfo.M3_UEFAirBase_ASPlatforms)

      --- capture triggers for each plat, to start the gunship destruction
    for k,unit in ScenarioInfo.M3_UEFAirBase_ASPlatforms do
        ScenarioFramework.CreateUnitCapturedTrigger(M3_StartGunshipDestroy, nil, unit)
        unit:SetDoNotTarget(true)
    end

    -- Create the Hex5 Prison building (at main base), and the southern Penal Colony
    ScenarioUtils.CreateArmyGroup ('FauxUEF', 'M3_FauxUEF_Base_Prison')
    ScenarioInfo.M2_FauxUEF_PrisonBuilding = ScenarioUtils.CreateArmyUnit ('FauxUEF', 'M3_FauxUEF_PrisonBuilding')
    ScenarioFramework.CreateUnitDeathTrigger(M3_Hex5Destroyed, ScenarioInfo.M2_FauxUEF_PrisonBuilding)
    ScenarioFramework.CreateUnitReclaimedTrigger(M3_Hex5Destroyed, ScenarioInfo.M2_FauxUEF_PrisonBuilding)
    ScenarioFramework.CreateUnitCapturedTrigger(nil, M3_PrisonCaptured, ScenarioInfo.M2_FauxUEF_PrisonBuilding)
    ScenarioInfo.M3_FauxUEF_PrisonShieldUnit = ScenarioUtils.CreateArmyUnit ('FauxUEF', 'M3_FauxUEF_PrisonShieldUnit')
    ScenarioInfo.M3_FauxUEF_PrisonShieldUnit:ToggleScriptBit('RULEUTC_ShieldToggle')
    ScenarioInfo.M2_FauxUEF_PrisonBuilding:SetCustomName(LOC '{i R05_Hex5Prison}')
    ScenarioFramework.PauseUnitDeath(ScenarioInfo.M2_FauxUEF_PrisonBuilding)

    ScenarioUtils.CreateArmyGroup ('FauxUEF', 'M3_FauxUEF_Colony_Structures')
    ScenarioInfo.M3_ColonyPrisonBuilding = ScenarioUtils.CreateArmyUnit ('FauxUEF', 'M3_FauxUEF_PrisonUnit')
    ScenarioInfo.M3_FauxUEF_ColonyShield = ScenarioUtils.CreateArmyUnit ('FauxUEF', 'M3_FauxUEF_ColonyShield')
    ScenarioInfo.M3_FauxUEF_ColonyShield:ToggleScriptBit('RULEUTC_ShieldToggle')
    ScenarioInfo.M3_ColonyPrisonBuilding:SetCustomName(LOC '{i R05_GeneralPrison}')

    -- Base patrols
    local mainAirDef1 = ScenarioUtils.CreateArmyGroupAsPlatoon ('UEF', 'M3_UEFMainBase_AirPatrol1_'..DifficultyConc, 'NoFormation')
    local mainAirDef2 = ScenarioUtils.CreateArmyGroupAsPlatoon ('UEF', 'M3_UEFMainBase_AirPatrol2_'..DifficultyConc, 'NoFormation')
    local mainLandDef1 = ScenarioUtils.CreateArmyGroupAsPlatoon ('UEF', 'M3_UEFMainBase_LandPatrol1_'..DifficultyConc, 'AttackFormation')
    local mainLandDef2 = ScenarioUtils.CreateArmyGroupAsPlatoon ('UEF', 'M3_UEFMainBase_LandPatrol2_'..DifficultyConc, 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(mainAirDef1, 'M3_UEFMainBase_AirPatrolChain')
    ScenarioFramework.PlatoonPatrolChain(mainAirDef2, 'M3_UEFMainBase_AirPatrolChain')
    ScenarioFramework.PlatoonPatrolChain(mainLandDef1, 'M3_UEFMainBase_LandPatrolChain_1')
    ScenarioFramework.PlatoonPatrolChain(mainLandDef2, 'M3_UEFMainBase_LandPatrolChain_2')
    
    -- Hard difficulty: ASF patrols, AA patrols
    if Difficulty == 3 then
        local mainExtraAir1 = ScenarioUtils.CreateArmyGroupAsPlatoon ('UEF', 'M3_UEFMainBase_AirPatrol3a', 'NoFormation')
        local mainExtraAir2 = ScenarioUtils.CreateArmyGroupAsPlatoon ('UEF', 'M3_UEFMainBase_AirPatrol3b', 'NoFormation')
        ScenarioFramework.PlatoonPatrolChain(mainExtraAir1, 'M3_UEFMainBase_AirPatrolChain')
        ScenarioFramework.PlatoonPatrolChain(mainExtraAir2, 'M3_UEFMainBase_AirPatrolChain')

        local mainExtraAA1 = ScenarioUtils.CreateArmyGroupAsPlatoon ('UEF', 'M3_UEFMainBase_LandPatrol3a', 'AttackFormation')
        local mainExtraAA2 = ScenarioUtils.CreateArmyGroupAsPlatoon ('UEF', 'M3_UEFMainBase_LandPatrol3b', 'AttackFormation')
        ScenarioFramework.PlatoonPatrolChain(mainExtraAA1, 'M3_UEFMainBase_LandPatrolChain_1')
        ScenarioFramework.PlatoonPatrolChain(mainExtraAA2, 'M3_UEFMainBase_LandPatrolChain_2')
    end

    -- Create 4 non-base-specific gunship patrols that wander around the map
    for i = 1,4 do
        local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon ('UEF', 'M3_UEFGunshipsPatrol'..i.. '_'..DifficultyConc, 'NoFormation')
        ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_UEFGunshipPatrolGeneral_Chain_'..i)
    end
end

function M3_PrisonCaptured(unit)
    ScenarioFramework.CreateUnitCapturedTrigger(nil, M3_PrisonCaptured, unit)
    ScenarioFramework.CreateUnitDeathTrigger(M3_Hex5Destroyed, unit)
    ScenarioFramework.CreateUnitReclaimedTrigger(M3_Hex5Destroyed, unit)
    ScenarioInfo.M2_FauxUEF_PrisonBuilding = unit
end

function M3_InitialGunshipTaunt()
    M3_InitGunshipPlatsKilled = M3_InitGunshipPlatsKilled + 1
    if M3_InitGunshipPlatsKilled == 3 then
        if (ScenarioInfo.M3_UEFMainBase_Commander and not ScenarioInfo.M3_UEFMainBase_Commander:IsDead()) then
            ScenarioFramework.Dialogue(OpStrings.TAUNT7)
        end
    end
end

function M3_GodwynThreat1()
    ScenarioFramework.Dialogue(OpStrings.C05_M03_020)
end

function M2_ColonyDialogue()
    ScenarioFramework.Dialogue(OpStrings.C05_M03_060)
end
----------------------------------------
-- UEF Gunship virus objective functions
----------------------------------------
function M3_PlatformsDestroyedObjFail()
    ScenarioInfo.M3_AirPlatformsDestroyed = true
    if ScenarioInfo.M3_VirusUploaded == false then
        ScenarioInfo.M3S1:ManualResult(false)
        ScenarioFramework.Dialogue(ScenarioStrings.SObjFail)
    end
end

function M3_StartGunshipDestroy()
    if ScenarioInfo.GunshipScenarioStarted == false then
        ScenarioInfo.GunshipScenarioStarted = true
        ForkThread(M3_UEFGunshipVirusThread)
    end
end

function M3_UEFGunshipVirusThread()
	-- Update UEF restrictions accordingly
    ScenarioFramework.AddRestriction(UEF, categories.uea0203 +  categories.uea0305)
    WaitTicks(1)
    -- Clear any Gunships that factories may be building
    local uefFactories = ArmyBrains[UEF]:GetListOfUnits(categories.FACTORY * categories.AIR, false)
    for k,v in uefFactories do
        if (not v:IsDead()) and v.UnitBeingBuilt and not v.UnitBeingBuilt:IsDead() and EntityCategoryContains(categories.uea0203 + categories.uea0305, v.UnitBeingBuilt) then
            IssueClearCommands({v})
        end
    end

    -- Play dialogue, complete the objective
    ScenarioInfo.M3S1:ManualResult(true)
    ScenarioFramework.Dialogue(OpStrings.C05_M03_050)

    ScenarioInfo.M3_VirusUploaded = true
	-- Get all UEF Gunships, and 'Ctrl+K' them, with a slight pause between each, for cinematics
    local UEFGunships = ArmyBrains[UEF]:GetListOfUnits(categories.uea0203 + categories.uea0305, false)
    for k, v in UEFGunships do
        if not v:IsDead() then -- check that the gunship hasnt already been killed in the meantime.
            local pos = v:GetPosition()
            local spec = {
                X = pos[1],
                Z = pos[2],
                Radius = 16,
                LifeTime = 6,
                Omni = false,
                Vision = true,
                Army = 1,
            }
            local vizmarker = VizMarker(spec)
            vizmarker:AttachBoneTo(-1,v,-1)

            v:Kill()
            WaitSeconds(0.5)
        end
    end

    -- Godwyn VO response after the final Gunship has been toasted, with a slight delay
    ScenarioFramework.CreateTimerTrigger(M3_GodwynGunshipResponseDialogue, 15)
end

function M3_GodwynGunshipResponseDialogue()
    -- Make sure we arent already in the process of ending the Op due to the enemy CDR being killed
    if ScenarioInfo.UEFCommanderDestroyed == false then
		-- Godwyn is pissed
        ScenarioFramework.Dialogue(OpStrings.C05_M03_070)
        ScenarioFramework.CreateTimerTrigger(M3_GodwynGunshipTaunt, 60)
    end
end

function M3_GodwynGunshipTaunt()
    if ScenarioInfo.UEFCommanderDestroyed == false then
        ScenarioFramework.Dialogue(OpStrings.TAUNT2)
    end
end

-----------------------------
-- Offmap transport functions
-----------------------------
function TransportAttack(transports, landPlat, brainNum, landingMarkerName, attackMarkerChain)
    ScenarioFramework.AttachUnitsToTransports(landPlat:GetPlatoonUnits(), transports:GetPlatoonUnits())
    local cmd = transports:UnloadAllAtLocation(ScenarioUtils.MarkerToPosition(landingMarkerName))
    while ArmyBrains[brainNum]:PlatoonExists(transports) and transports:IsCommandsActive(cmd) do
        WaitSeconds(1)
    end

    if ArmyBrains[brainNum]:PlatoonExists(landPlat) then
        for k,v in ScenarioUtils.ChainToPositions(attackMarkerChain) do
            landPlat:Patrol(v)
        end
    end

    if ArmyBrains[brainNum]:PlatoonExists(transports) then
        for k,v in ScenarioUtils.ChainToPositions(attackMarkerChain) do
            transports:Patrol(v)
        end
    end
end

function AddGroupToTable(unitTable, group)
    for k,unit in group do
        table.insert(unitTable, unit)
    end
end

function AddPlatoonToTable(unitTable, platoon)
    local group = platoon:GetPlatoonUnits()
    for k,unit in group do
        table.insert(unitTable, unit)
    end
end
-----------------------------
-- Objective reminder threads
-----------------------------
function M1P1Reminder()
	if ScenarioInfo.M1P1Objective.Active and not ScenarioInfo.OpEnded then
		if not ScenarioInfo.M1P1ReminderAlternate then
			ScenarioInfo.M1P1ReminderAlternate = 1
			ScenarioFramework.Dialogue(OpStrings.C05_M01_020)
		elseif ScenarioInfo.M1P1ReminderAlternate == 1 then
			ScenarioInfo.M1P1ReminderAlternate = 2
			ScenarioFramework.Dialogue(OpStrings.C05_M01_060)
		elseif ScenarioInfo.M1P1ReminderAlternate == 2 then
            ScenarioInfo.M1P1ReminderAlternate = 3
			ScenarioFramework.Dialogue(OpStrings.C05_M01_070)
		else
			ScenarioInfo.M1P1ReminderAlternate = false
			ScenarioFramework.Dialogue(ScenarioStrings.CybranGenericReminder)
		end
        ScenarioFramework.CreateTimerTrigger(M1P1Reminder, 600)
	end
end

function M2P1Reminder()
	if ScenarioInfo.M1P1Objective.Active and not ScenarioInfo.OpEnded then
		if not ScenarioInfo.M1P1ReminderAlternate then
			ScenarioInfo.M1P1ReminderAlternate = 1
			ScenarioFramework.Dialogue(OpStrings.C05_M02_100)
		elseif ScenarioInfo.M1P1ReminderAlternate == 1 then
			ScenarioInfo.M1P1ReminderAlternate = false
			ScenarioFramework.Dialogue(OpStrings.C05_M02_105)
		else
			ScenarioInfo.M1P1ReminderAlternate = false
			ScenarioFramework.Dialogue(ScenarioStrings.CybranGenericReminder)
		end
        ScenarioFramework.CreateTimerTrigger(M1P1Reminder, 600)
	end
end

function M2P2Reminder()
	if ScenarioInfo.M1P1Objective.Active and not ScenarioInfo.OpEnded then
		if not ScenarioInfo.M1P1ReminderAlternate then
			ScenarioInfo.M1P1ReminderAlternate = 1
			ScenarioFramework.Dialogue(OpStrings.C05_M02_110)
		elseif ScenarioInfo.M1P1ReminderAlternate == 1 then
			ScenarioInfo.M1P1ReminderAlternate = false
			ScenarioFramework.Dialogue(OpStrings.C05_M02_115)
		else
			ScenarioInfo.M1P1ReminderAlternate = false
			ScenarioFramework.Dialogue(ScenarioStrings.CybranGenericReminder)
		end
        ScenarioFramework.CreateTimerTrigger(M2P2Reminder, 300)
	end
end

function M3P1Reminder()
	if ScenarioInfo.M1P1Objective.Active and not ScenarioInfo.OpEnded then
		if not ScenarioInfo.M1P1ReminderAlternate then
			ScenarioInfo.M1P1ReminderAlternate = 1
			ScenarioFramework.Dialogue(OpStrings.C05_M03_100)
		elseif ScenarioInfo.M1P1ReminderAlternate == 1 then
			ScenarioInfo.M1P1ReminderAlternate = false
			ScenarioFramework.Dialogue(OpStrings.C05_M03_105)
		else
			ScenarioInfo.M1P1ReminderAlternate = false
			ScenarioFramework.Dialogue(ScenarioStrings.CybranGenericReminder)
		end
        ScenarioFramework.CreateTimerTrigger(M3P1Reminder, 600)
	end
end

---------------------
-- Win/Lose functions
---------------------
function M3_UEFCommanderDestroyed()
    -- Flag uef cdr as dead for other checks
    ScenarioInfo.UEFCommanderDestroyed = true
    ScenarioInfo.M3P1Complete = true

    -- check that we arent already completing the op
    if not ScenarioInfo.OperationEnding then
        ScenarioInfo.OperationEnding = true
        ScenarioFramework.EndOperationSafety({ ScenarioInfo.M2_FauxUEF_PrisonBuilding })
-- UEF CDR Killed
--    ScenarioFramework.EndOperationCamera(ScenarioInfo.M3_UEFMainBase_Commander, true)
        ScenarioFramework.CDRDeathNISCamera(ScenarioInfo.M3_UEFMainBase_Commander)
        ScenarioFramework.Dialogue(OpStrings.C05_M03_090, KillGame_Win, true)
    end
end

function M3_Hex5Destroyed()
    if not ScenarioInfo.M3P1Complete then
        ScenarioInfo.M3H1 = Objectives.Basic(   -- 'Hidden' obj, Hex5 killed
            'secondary',
            'incomplete',
            OpStrings.M3H1Text,
            OpStrings.M3H1Detail,
            Objectives.GetActionIcon('kill'),
            {
            }
		)

        -- Because this ends the Op, lets flag the M3 main obj as "done", for the purposes of checks, so we dont try to
        -- complete again if UEF cdr is subsequently killed. As well, flag the enemy cdr as dead, so taunts and other
        -- dialogue related to him dont play now (wouldnt be appropriate, as we are ending the op here)
        ScenarioInfo.M3P1Complete = true
        ScenarioInfo.M3H1:ManualResult(true)
        ScenarioInfo.UEFCommanderDestroyed = true

        -- If the op isnt already ending, then allow it to happen here
        if not ScenarioInfo.OperationEnding then
            ScenarioInfo.OperationEnding = true
            ScenarioFramework.EndOperationSafety({ScenarioInfo.M3_UEFMainBase_Commander})

            -- Hex5 "dying" in prison cam
--        ScenarioFramework.EndOperationCamera(ScenarioInfo.M2_FauxUEF_PrisonBuilding, true)
            local camInfo = {
                blendTime = 2.5,
                holdTime = nil,
                orientationOffset = { 0.7854, 0.8, 0 },
                positionOffset = { 0, 0.5, 0 },
                zoomVal = 45,
                spinSpeed = 0.03,
                overrideCam = true,
            }
            ScenarioFramework.OperationNISCamera(ScenarioInfo.M2_FauxUEF_PrisonBuilding, camInfo)

            ScenarioFramework.Dialogue(OpStrings.C05_M03_080, KillGame_Win, true)
        end
    end
end

function PlayerCDRKilled(deadCommander)
    ScenarioFramework.PlayerDeath(deadCommander, OpStrings.C05_D01_010)
end

function KillGame_Win()
    WaitSeconds(7.0)
    local secondaries = Objectives.IsComplete(ScenarioInfo.M1S1) and Objectives.IsComplete(ScenarioInfo.M2S1) and Objectives.IsComplete(ScenarioInfo.M3S1)
    ScenarioFramework.EndOperation(true, true, secondaries)
end
-----------------
-- Misc functions
-----------------
