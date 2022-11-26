--****************************************************************************
--**
--**  File     : /maps/X1CA_001/X1CA_001_m3uefai.lua
--**  Author(s): Jessica St. Croix
--**
--**  Summary  : UEF army AI for Mission 3 - X1CA_001
--**
--**  Copyright © 2007 Gas Powered Games, Inc.  All rights reserved.
--****************************************************************************
local BaseManager = import('/maps/X1CA_001/X1CA_001_BaseManager.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')

local SPAIFileName = '/lua/scenarioplatoonai.lua'

-- ------
-- Locals
-- ------
local UEF = 4
local Difficulty = ScenarioInfo.Options.Difficulty

-- -------------
-- Base Managers
-- -------------
local UEFM2SouthernTown = BaseManager.CreateBaseManager()

function UEFM2SouthernTownAI()

    -- ----------------
    -- UEF Southern Town
    -- ----------------
    UEFM2SouthernTown:Initialize(ArmyBrains[UEF], 'M2_South_Town_Base', 'UEF_M2_South_Base_Marker', 90,
	{
	    M2_South_Town_Factories = 250,
		M2_South_Town_Economy = 200,
		M2_South_Town_Misc = 150,
		M2_South_Town_Walls = 100,
	}
    )
    UEFM2SouthernTown:StartNonZeroBase({7, 6, 5})
    UEFM2SouthernTown:SetMaximumConstructionEngineers(7)

	UEFM2SouthernTown:AddBuildGroupDifficulty('M2_South_Town_Defense', 225)

    UEFM2SouthernTownLandAttacks()
    UEFM2SouthernTownAirAttacks()
end

function UEFM2SouthernTownLandAttacks()
    local opai = nil

    -- ---------------------------------------
    -- UEF M3 Southern Town Op AI, Land Attacks
    -- ---------------------------------------

    -- sends [mobile missiles]
    opai = UEFM2SouthernTown:AddOpAI('BasicLandAttack', 'M2_South_Town_LandAttack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
			Priority = 90,
        }
    )
    opai:SetChildQuantity('MobileMissiles', 6)

    -- sends [heavy tanks]
    opai = UEFM2SouthernTown:AddOpAI('BasicLandAttack', 'M2_South_Town_LandAttack_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
			Priority = 90,
        }
    )
    opai:SetChildQuantity('HeavyTanks', 6)

    -- sends [light bots]
    opai = UEFM2SouthernTown:AddOpAI('BasicLandAttack', 'M2_South_Town_LandAttack_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
			Priority = 90,
        }
    )
    opai:SetChildQuantity('SiegeBots', 3)

    -- sends [light artillery]
    opai = UEFM2SouthernTown:AddOpAI('BasicLandAttack', 'M2_South_Town_LandAttack_4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
			Priority = 90,
        }
    )
    opai:SetChildQuantity('AmphibiousTanks', 6)

    -- sends [mobile shields]
    opai = UEFM2SouthernTown:AddOpAI('BasicLandAttack', 'M2_South_Town_LandAttack_5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
			Priority = 90,
        }
    )
    opai:SetChildQuantity('HeavyBots', 3)

    -- sends [range bots]
    opai = UEFM2SouthernTown:AddOpAI('BasicLandAttack', 'M2_South_Town_LandAttack_6',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
			Priority = 90,
        }
    )
    opai:SetChildQuantity('RangeBots', 6)
end

function UEFM2SouthernTownAirAttacks()
    local opai = nil

    -- ----------------------------------------
    --  UEF M3 South Town Op AI, Air Defenses
    -- ----------------------------------------

    -- Air defense
    --for i = 1, 3 do
        opai = UEFM2SouthernTown:AddOpAI('AirAttacks', 'M2_South_Town_AirDefense_Gunships',
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M3_South_Town_AirPatrol_Chain',
                },
            }
        )
        opai:SetChildQuantity('Gunships', 6)
		opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
		
		opai = UEFM2SouthernTown:AddOpAI('AirAttacks', 'M2_South_Town_AirDefense_ASF',
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M3_South_Town_AirPatrol_Chain',
                },
            }
        )
        opai:SetChildQuantity('AirSuperiority', 6)
		opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    --end
end
